package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.mapper.CupidCommonOptionMapper;
import com.ruoyi.cupid.mapper.CupidInboxTemplateMapper;
import com.ruoyi.cupid.service.ICupidInboxTemplateService;

/** Cupid Match 通知模板服务实现。 */
@Service
public class CupidInboxTemplateServiceImpl implements ICupidInboxTemplateService
{
    private static final Set<String> LOCALES = Set.of("zh", "fr", "en");
    private static final Set<String> MESSAGE_TYPES = Set.of("text", "system_notice", "status_update", "action_prompt");
    private static final Set<String> SUBJECT_TYPES = Set.of("profile", "event", "private_introduction_request", "membership");
    private static final Set<String> STATUSES = Set.of("enabled", "disabled");
    private static final Set<String> ACTION_TYPES = Set.of("view_profile", "view_event", "view_introduction", "view_membership");
    private static final Set<String> VARIABLES = Set.of("profileName", "eventTitle", "status",
            "reason", "verificationType", "accountName", "code", "ttlMinutes", "purpose");
    private static final Pattern VARIABLE_PATTERN = Pattern.compile("\\{\\{([A-Za-z][A-Za-z0-9]*)}}"
    );

    @Autowired
    private CupidInboxTemplateMapper templateMapper;

    @Autowired
    private CupidCommonOptionMapper commonOptionMapper;

    @Override
    public List<Map<String, Object>> selectTemplates(Map<String, Object> params)
    {
        return templateMapper.selectTemplates(params);
    }

    @Override
    public Map<String, Object> selectTemplate(String id)
    {
        Map<String, Object> template = requireTemplate(id);
        template.put("localizedFields", templateMapper.selectLocalizedFields(id));
        template.put("allowedVariables", VARIABLES);
        return template;
    }

    @Override
    public List<Map<String, Object>> selectEnabledTemplates()
    {
        Map<String, Object> params = new HashMap<>();
        params.put("status", "enabled");
        List<Map<String, Object>> result = templateMapper.selectTemplates(params);
        result.forEach(item -> item.put("localizedFields",
                templateMapper.selectLocalizedFields(String.valueOf(item.get("id")))));
        return result;
    }

    @Override
    @Transactional
    public void createTemplate(Map<String, Object> body, String staffUserId)
    {
        String code = required(body, "templateCode");
        if (!code.matches("[a-z][a-z0-9_]{2,79}"))
        {
            throw new ServiceException("模板 Code 只能使用小写字母、数字和下划线");
        }
        if (templateMapper.selectTemplateByCode(code) != null)
        {
            throw new ServiceException("模板 Code 已存在");
        }
        String id = IdUtils.fastUUID();
        body.put("id", id);
        body.put("status", "enabled");
        validateTemplate(body);
        List<Map<String, Object>> localized = localizedFields(body);
        templateMapper.insertTemplate(body);
        saveLocalized(id, localized);
        audit(id, "cupid.inboxTemplate.create", staffUserId, null, body);
    }

    @Override
    @Transactional
    public void updateTemplate(String id, Map<String, Object> body, String staffUserId)
    {
        Map<String, Object> before = selectTemplate(id);
        body.put("id", id);
        body.put("templateCode", before.get("templateCode"));
        validateTemplate(body);
        List<Map<String, Object>> localized = localizedFields(body);
        templateMapper.updateTemplate(body);
        saveLocalized(id, localized);
        audit(id, "cupid.inboxTemplate.update", staffUserId, before, body);
    }

    @Override
    @Transactional
    public void updateStatus(String id, String status, String staffUserId)
    {
        Map<String, Object> before = requireTemplate(id);
        if (!STATUSES.contains(status))
        {
            throw new ServiceException("模板状态无效");
        }
        templateMapper.updateTemplateStatus(id, status);
        audit(id, "cupid.inboxTemplate.changeStatus", staffUserId, before, Map.of("status", status));
    }

    private void validateTemplate(Map<String, Object> body)
    {
        String messageType = required(body, "messageType");
        if (!MESSAGE_TYPES.contains(messageType))
        {
            throw new ServiceException("消息类型无效");
        }
        String subjectType = text(body.get("subjectType"));
        if (StringUtils.hasText(subjectType) && !SUBJECT_TYPES.contains(subjectType))
        {
            throw new ServiceException("业务对象类型无效");
        }
        String actionType = text(body.get("actionType"));
        if (StringUtils.hasText(actionType) && !ACTION_TYPES.contains(actionType))
        {
            throw new ServiceException("操作类型无效");
        }
        if (StringUtils.hasText(actionType) && !StringUtils.hasText(subjectType))
        {
            throw new ServiceException("配置操作类型时必须选择业务对象类型");
        }
        if (StringUtils.hasText(actionType) && !actionTypeMatchesSubject(actionType, subjectType))
        {
            throw new ServiceException("点击动作与关联业务类型不匹配");
        }
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> localizedFields(Map<String, Object> body)
    {
        Object value = body.get("localizedFields");
        if (!(value instanceof List<?>))
        {
            throw new ServiceException("请填写三语模板内容");
        }
        List<Map<String, Object>> fields = (List<Map<String, Object>>) value;
        Set<String> seen = new HashSet<>();
        Set<String> expectedVariables = null;
        for (Map<String, Object> field : fields)
        {
            String locale = required(field, "locale");
            String name = required(field, "name");
            String templateBody = required(field, "body");
            if (!LOCALES.contains(locale) || !seen.add(locale) || name.length() > 120 || templateBody.length() > 4000)
            {
                throw new ServiceException("模板三语内容无效");
            }
            Set<String> variables = validateVariables(templateBody);
            if (expectedVariables == null)
            {
                expectedVariables = variables;
            }
            else if (!expectedVariables.equals(variables))
            {
                throw new ServiceException("三语模板必须使用相同变量");
            }
        }
        if (!seen.equals(LOCALES))
        {
            throw new ServiceException("中文、法文和英文模板均为必填");
        }
        return new ArrayList<>(fields);
    }

    private Set<String> validateVariables(String body)
    {
        Matcher matcher = VARIABLE_PATTERN.matcher(body);
        Set<String> variables = new HashSet<>();
        StringBuffer stripped = new StringBuffer();
        while (matcher.find())
        {
            if (!VARIABLES.contains(matcher.group(1)))
            {
                throw new ServiceException("模板包含未知变量：" + matcher.group(1));
            }
            variables.add(matcher.group(1));
            matcher.appendReplacement(stripped, "");
        }
        matcher.appendTail(stripped);
        if (stripped.indexOf("{{") >= 0 || stripped.indexOf("}}") >= 0)
        {
            throw new ServiceException("模板变量格式无效");
        }
        return variables;
    }

    private void saveLocalized(String templateId, List<Map<String, Object>> fields)
    {
        for (Map<String, Object> field : fields)
        {
            field.put("id", IdUtils.fastUUID());
            field.put("templateId", templateId);
            templateMapper.upsertLocalizedField(field);
        }
    }

    private Map<String, Object> requireTemplate(String id)
    {
        Map<String, Object> template = templateMapper.selectTemplateById(id);
        if (template == null)
        {
            throw new ServiceException("通知模板不存在");
        }
        return new HashMap<>(template);
    }

    private void audit(String id, String action, String userId, Object before, Object after)
    {
        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", userId,
                "inbox_template", id, action,
                before == null ? null : JSON.toJSONString(before), JSON.toJSONString(after), null);
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

    private static String text(Object value)
    {
        return value == null ? null : String.valueOf(value).trim();
    }

    private static boolean actionTypeMatchesSubject(String actionType, String subjectType)
    {
        return ("view_profile".equals(actionType) && "profile".equals(subjectType))
                || ("view_event".equals(actionType) && "event".equals(subjectType))
                || ("view_introduction".equals(actionType) && "private_introduction_request".equals(subjectType))
                || ("view_membership".equals(actionType) && "membership".equals(subjectType));
    }
}
