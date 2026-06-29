package com.ruoyi.cupid.service.impl;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.mapper.CupidCommonOptionMapper;
import com.ruoyi.cupid.mapper.CupidInboxNotificationMapper;
import com.ruoyi.cupid.mapper.CupidInboxTemplateMapper;
import com.ruoyi.cupid.service.ICupidInboxNotificationService;

/** Cupid Match 通知渲染、会话复用与消息写入。 */
@Service
public class CupidInboxNotificationService implements ICupidInboxNotificationService
{
    private static final Set<String> LOCALES = Set.of("zh", "fr", "en");
    private static final Set<String> SUBJECT_TYPES = Set.of("profile", "event", "private_introduction_request", "membership");
    private static final Pattern VARIABLE_PATTERN = Pattern.compile("\\{\\{([A-Za-z][A-Za-z0-9]*)}}");

    @Autowired
    private CupidInboxTemplateMapper templateMapper;

    @Autowired
    private CupidInboxNotificationMapper notificationMapper;

    @Autowired
    private CupidCommonOptionMapper commonOptionMapper;

    @Override
    public Map<String, Object> preview(Map<String, Object> request)
    {
        PreparedMessage prepared = prepare(request);
        Map<String, Object> result = new HashMap<>();
        result.put("body", prepared.body);
        result.put("locale", prepared.locale);
        result.put("messageType", prepared.messageType);
        result.put("subjectType", prepared.subjectType);
        result.put("actionType", prepared.actionType);
        return result;
    }

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public String sendStaffNotification(Map<String, Object> request, String staffUserId, String dedupeKey)
    {
        String userId = required(request, "userId");
        Map<String, Object> user = requireUser(userId);
        if (!booleanValue(user.get("staffContactEnabled")))
        {
            throw new ServiceException("该用户已关闭工作人员联系");
        }
        PreparedMessage prepared = prepare(request);
        String subjectId = text(request.get("subjectId"));
        validateSubject(userId, prepared.subjectType, subjectId);
        String messageId = write(userId, prepared, subjectId, "staff", staffUserId, dedupeKey);
        audit(messageId, "cupid.inbox.send", staffUserId,
                Map.of("userId", userId, "templateCode", nullToEmpty(prepared.templateCode)));
        return messageId;
    }

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public String sendStaffAnnouncement(Map<String, Object> request, String staffUserId, String dedupeKey)
    {
        String userId = required(request, "userId");
        requireUser(userId);
        PreparedMessage prepared = prepare(request);
        if (StringUtils.hasText(prepared.subjectType))
        {
            throw new ServiceException("群发只能使用无业务对象的通知模板");
        }
        String messageId = write(userId, prepared, null, "staff", staffUserId, dedupeKey);
        audit(messageId, "cupid.inbox.broadcast.send", staffUserId,
                Map.of("userId", userId, "templateCode", nullToEmpty(prepared.templateCode)));
        return messageId;
    }

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public String sendSystemNotification(String userId, String templateCode, String locale,
            Map<String, Object> variables, String subjectId, String dedupeKey)
    {
        Map<String, Object> user = requireUser(userId);
        Map<String, Object> request = new HashMap<>();
        request.put("mode", "template");
        request.put("templateCode", templateCode);
        request.put("locale", StringUtils.hasText(locale) ? locale : user.get("preferredLocale"));
        request.put("variables", variables == null ? Map.of() : variables);
        PreparedMessage prepared = prepare(request);
        validateSubject(userId, prepared.subjectType, subjectId);
        String messageId = write(userId, prepared, subjectId, "system", null, dedupeKey);
        if (messageId != null)
        {
            commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "system", null,
                    "inbox_message", messageId, "cupid.inbox.automatic.send", null,
                    JSON.toJSONString(Map.of("userId", userId, "templateCode", templateCode)), null);
        }
        return messageId;
    }

    private PreparedMessage prepare(Map<String, Object> request)
    {
        String mode = text(request.get("mode"));
        String locale = normalizeLocale(text(request.get("locale")));
        if ("custom".equals(mode))
        {
            @SuppressWarnings("unchecked")
            Map<String, Object> localizedBodies = request.get("localizedBodies") instanceof Map<?, ?>
                    ? (Map<String, Object>) request.get("localizedBodies") : Map.of();
            for (String requiredLocale : LOCALES)
            {
                String localizedBody = text(localizedBodies.get(requiredLocale));
                if (!StringUtils.hasText(localizedBody) || localizedBody.length() > 4000)
                {
                    throw new ServiceException("自定义通知必须填写中、法、英三语正文，且每份不超过 4000 字符");
                }
            }
            String body = text(localizedBodies.get(locale));
            if (body.length() > 4000)
            {
                throw new ServiceException("通知正文不能超过 4000 字符");
            }
            String subjectType = text(request.get("subjectType"));
            validateSubjectType(subjectType);
            return new PreparedMessage(body, locale, "text", subjectType, null, null);
        }

        String templateCode = required(request, "templateCode");
        Map<String, Object> template = templateMapper.selectTemplateByCode(templateCode);
        if (template == null || !"enabled".equals(text(template.get("status"))))
        {
            throw new ServiceException("通知模板不存在或已停用");
        }
        Map<String, Object> localized = templateMapper.selectLocalizedField(String.valueOf(template.get("id")), locale);
        if (localized == null)
        {
            throw new ServiceException("模板缺少当前语言内容");
        }
        @SuppressWarnings("unchecked")
        Map<String, Object> variables = request.get("variables") instanceof Map<?, ?>
                ? (Map<String, Object>) request.get("variables") : Map.of();
        String body = render(String.valueOf(localized.get("body")), variables);
        return new PreparedMessage(body, locale, text(template.get("messageType")),
                text(template.get("subjectType")), text(template.get("actionType")), templateCode);
    }

    private String write(String userId, PreparedMessage message, String subjectId,
            String senderType, String senderUserId, String dedupeKey)
    {
        String threadId = notificationMapper.selectOpenSystemThread(userId, message.subjectType, subjectId);
        if (!StringUtils.hasText(threadId))
        {
            threadId = IdUtils.fastUUID();
            try
            {
                notificationMapper.insertThread(threadId, userId, message.subjectType, subjectId);
            }
            catch (DuplicateKeyException ex)
            {
                threadId = notificationMapper.selectOpenSystemThread(userId, message.subjectType, subjectId);
                if (!StringUtils.hasText(threadId))
                {
                    throw ex;
                }
            }
        }
        String messageId = IdUtils.fastUUID();
        Map<String, Object> params = new HashMap<>();
        params.put("id", messageId);
        params.put("threadId", threadId);
        params.put("senderType", senderType);
        params.put("senderUserId", senderUserId);
        params.put("messageType", message.messageType);
        params.put("body", message.body);
        params.put("templateCode", message.templateCode);
        params.put("templateLocale", message.locale);
        params.put("actionType", message.actionType);
        params.put("dedupeKey", StringUtils.hasText(dedupeKey) ? dedupeKey : null);
        try
        {
            notificationMapper.insertNotification(params);
        }
        catch (DuplicateKeyException ex)
        {
            return null;
        }
        notificationMapper.touchThread(threadId);
        return messageId;
    }

    private void validateSubject(String userId, String subjectType, String subjectId)
    {
        if (!StringUtils.hasText(subjectType) && !StringUtils.hasText(subjectId))
        {
            return;
        }
        if (!StringUtils.hasText(subjectType) || !StringUtils.hasText(subjectId)
                || notificationMapper.countSubjectAccess(userId, subjectType, subjectId) == 0)
        {
            throw new ServiceException("业务对象与目标用户不匹配");
        }
    }

    private static String render(String template, Map<String, Object> variables)
    {
        Matcher matcher = VARIABLE_PATTERN.matcher(template);
        StringBuffer result = new StringBuffer();
        while (matcher.find())
        {
            Object value = variables.get(matcher.group(1));
            if (value == null || !StringUtils.hasText(String.valueOf(value)))
            {
                throw new ServiceException("缺少模板变量：" + matcher.group(1));
            }
            matcher.appendReplacement(result, Matcher.quoteReplacement(String.valueOf(value)));
        }
        matcher.appendTail(result);
        if (result.indexOf("{{") >= 0)
        {
            throw new ServiceException("模板存在未解析变量");
        }
        return result.toString();
    }

    private Map<String, Object> requireUser(String userId)
    {
        Map<String, Object> user = notificationMapper.selectUser(userId);
        if (user == null || !"active".equals(text(user.get("status"))))
        {
            throw new ServiceException("目标用户不存在或不可用");
        }
        return user;
    }

    private void audit(String subjectId, String action, String userId, Object after)
    {
        if (subjectId == null)
        {
            return;
        }
        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", userId,
                "inbox_message", subjectId, action, null, JSON.toJSONString(after), null);
    }

    private static String required(Map<String, Object> source, String key)
    {
        String value = text(source.get(key));
        if (!StringUtils.hasText(value))
        {
            throw new ServiceException(key + " 不能为空");
        }
        return value;
    }

    private static void validateSubjectType(String subjectType)
    {
        if (StringUtils.hasText(subjectType) && !SUBJECT_TYPES.contains(subjectType))
        {
            throw new ServiceException("业务对象类型无效");
        }
    }

    private static String normalizeLocale(String locale)
    {
        return LOCALES.contains(locale) ? locale : "zh";
    }

    private static String text(Object value)
    {
        return value == null ? null : String.valueOf(value).trim();
    }

    private static boolean booleanValue(Object value)
    {
        return Boolean.TRUE.equals(value) || "1".equals(String.valueOf(value)) || "true".equalsIgnoreCase(String.valueOf(value));
    }

    private static String nullToEmpty(String value)
    {
        return value == null ? "" : value;
    }

    private static final class PreparedMessage
    {
        private final String body;
        private final String locale;
        private final String messageType;
        private final String subjectType;
        private final String actionType;
        private final String templateCode;

        private PreparedMessage(String body, String locale, String messageType,
                String subjectType, String actionType, String templateCode)
        {
            this.body = body;
            this.locale = locale;
            this.messageType = messageType;
            this.subjectType = subjectType;
            this.actionType = actionType;
            this.templateCode = templateCode;
        }
    }
}
