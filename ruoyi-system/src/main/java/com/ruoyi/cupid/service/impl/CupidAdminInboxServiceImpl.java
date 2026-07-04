package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.mapper.CupidCommonOptionMapper;
import com.ruoyi.cupid.mapper.CupidInboxDispatchMapper;
import com.ruoyi.cupid.mapper.CupidInboxNotificationMapper;
import com.ruoyi.cupid.service.ICupidAdminInboxService;
import com.ruoyi.cupid.service.ICupidInboxNotificationService;
import com.ruoyi.cupid.service.ICupidInboxTemplateService;

@Service
public class CupidAdminInboxServiceImpl implements ICupidAdminInboxService
{
    private static final Set<String> BROADCAST_SCOPES = Set.of("all_active", "membership_tier", "selected_users");

    @Autowired
    private CupidInboxNotificationMapper notificationMapper;

    @Autowired
    private ICupidInboxNotificationService notificationService;

    @Autowired
    private ICupidInboxTemplateService templateService;

    @Autowired
    private CupidCommonOptionMapper commonOptionMapper;

    @Autowired
    private CupidInboxDispatchMapper dispatchMapper;

    @Override
    public List<Map<String, Object>> searchUsers(String keyword)
    {
        return notificationMapper.searchUsers(keyword == null ? null : keyword.trim());
    }

    @Override
    public List<Map<String, Object>> searchSubjects(String userId, String subjectType, String keyword)
    {
        if (!StringUtils.hasText(userId) || !StringUtils.hasText(subjectType))
        {
            return List.of();
        }
        return notificationMapper.searchSubjects(userId, subjectType, keyword == null ? null : keyword.trim());
    }

    @Override
    public List<Map<String, Object>> enabledTemplates()
    {
        return templateService.selectEnabledTemplates();
    }

    @Override
    public Map<String, Object> preview(Map<String, Object> body)
    {
        return notificationService.preview(body);
    }

    @Override
    public void send(Map<String, Object> body, String staffUserId)
    {
        String dispatchId = IdUtils.fastUUID();
        Map<String, Object> record = new HashMap<>();
        record.put("id", dispatchId);
        record.put("staffUserId", staffUserId);
        record.put("userId", body.get("userId"));
        record.put("mode", body.get("mode"));
        record.put("templateCode", body.get("templateCode"));
        record.put("locale", body.get("locale"));
        record.put("subjectType", body.get("subjectType"));
        record.put("subjectId", body.get("subjectId"));
        record.put("payloadJson", JSON.toJSONString(body));
        dispatchMapper.insertSingleDispatch(record);
        try
        {
            String messageId = notificationService.sendStaffNotification(
                    body, staffUserId, "single-dispatch:" + dispatchId);
            dispatchMapper.updateSingleDispatchSuccess(dispatchId, messageId);
        }
        catch (RuntimeException ex)
        {
            dispatchMapper.updateSingleDispatchFailure(
                    dispatchId, safeMessage(ex), CupidMessageRetryPolicy.isRetryable(ex));
            throw ex;
        }
    }

    @Override
    public Map<String, Object> previewBroadcast(Map<String, Object> body)
    {
        List<Map<String, Object>> users = broadcastUsers(body);
        Map<String, Object> previewRequest = new HashMap<>(body);
        if (!users.isEmpty() && "template".equals(String.valueOf(body.get("mode"))))
        {
            previewRequest.put("locale", users.get(0).get("preferredLocale"));
        }
        Map<String, Object> result = new HashMap<>();
        result.put("targetCount", users.size());
        result.put("sampleUsers", users.subList(0, Math.min(10, users.size())));
        Map<String, Object> message = notificationService.preview(previewRequest);
        if (StringUtils.hasText(String.valueOf(message.getOrDefault("subjectType", ""))))
        {
            throw new ServiceException("群发只能使用无业务对象的通知模板");
        }
        result.put("message", message);
        return result;
    }

    @Override
    public Map<String, Object> broadcast(Map<String, Object> body, String staffUserId)
    {
        List<Map<String, Object>> users = broadcastUsers(body);
        String broadcastId = IdUtils.fastUUID();
        Map<String, Object> broadcastRecord = new HashMap<>();
        broadcastRecord.put("id", broadcastId);
        broadcastRecord.put("staffUserId", staffUserId);
        broadcastRecord.put("scope", body.get("scope"));
        broadcastRecord.put("tier", body.get("tier"));
        broadcastRecord.put("mode", body.get("mode"));
        broadcastRecord.put("templateCode", body.get("templateCode"));
        broadcastRecord.put("locale", body.get("locale"));
        broadcastRecord.put("subjectType", body.get("subjectType"));
        broadcastRecord.put("payloadJson", JSON.toJSONString(body));
        dispatchMapper.insertBroadcast(broadcastRecord);

        int succeeded = 0;
        List<Map<String, Object>> failures = new ArrayList<>();
        for (Map<String, Object> user : users)
        {
            String userId = String.valueOf(user.get("id"));
            Map<String, Object> request = new HashMap<>(body);
            request.put("userId", userId);
            request.put("locale", user.get("preferredLocale"));
            try
            {
                String messageId = notificationService.sendStaffAnnouncement(request, staffUserId,
                        "broadcast:" + broadcastId + ":" + userId);
                dispatchMapper.insertBroadcastTarget(buildBroadcastTargetRecord(broadcastId, userId, messageId,
                        "success", null));
                succeeded++;
            }
            catch (RuntimeException ex)
            {
                String errorMessage = safeMessage(ex);
                String status = CupidMessageRetryPolicy.isRetryable(ex) ? "retrying" : "failure";
                dispatchMapper.insertBroadcastTarget(buildBroadcastTargetRecord(broadcastId, userId, null,
                        status, errorMessage));
                if (failures.size() < 20)
                {
                    failures.add(Map.of("userId", userId, "message", errorMessage));
                }
            }
        }
        dispatchMapper.updateBroadcastCounts(broadcastId, users.size(), succeeded, users.size() - succeeded);

        Map<String, Object> result = new HashMap<>();
        result.put("broadcastId", broadcastId);
        result.put("targetCount", users.size());
        result.put("successCount", succeeded);
        result.put("failureCount", users.size() - succeeded);
        result.put("failures", failures);

        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", staffUserId, "inbox_broadcast",
                broadcastId, "cupid.inbox.broadcast", null,
                JSON.toJSONString(Map.of("scope", body.get("scope"), "targetCount", users.size(),
                        "successCount", succeeded, "failureCount", users.size() - succeeded)),
                null);
        return result;
    }

    @Override
    public List<Map<String, Object>> selectBroadcastHistory(Map<String, Object> params)
    {
        return dispatchMapper.selectBroadcastHistory(params);
    }

    @Override
    public Map<String, Object> selectBroadcastDetail(String id)
    {
        Map<String, Object> detail = dispatchMapper.selectBroadcastDetail(id);
        if (detail == null)
        {
            throw new ServiceException("群发记录不存在");
        }
        detail.put("targets", dispatchMapper.selectBroadcastTargets(id));
        return detail;
    }

    @Override
    public List<Map<String, Object>> selectSingleHistory(Map<String, Object> params)
    {
        return dispatchMapper.selectSingleHistory(params);
    }

    @Override
    public Map<String, Object> selectSingleDetail(String id)
    {
        Map<String, Object> detail = dispatchMapper.selectSingleDetail(id);
        if (detail == null)
        {
            throw new ServiceException("单发记录不存在");
        }
        return detail;
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> broadcastUsers(Map<String, Object> body)
    {
        String scope = String.valueOf(body.get("scope"));
        if (!BROADCAST_SCOPES.contains(scope))
        {
            throw new ServiceException("群发范围无效");
        }
        String tier = body.get("tier") == null ? null : String.valueOf(body.get("tier"));
        List<String> userIds = body.get("userIds") instanceof List<?> ? (List<String>) body.get("userIds") : List.of();
        if ("membership_tier".equals(scope) && !StringUtils.hasText(tier))
        {
            throw new ServiceException("请选择会员等级");
        }
        if ("selected_users".equals(scope) && userIds.isEmpty())
        {
            throw new ServiceException("请选择目标用户");
        }
        return notificationMapper.selectBroadcastUsers(scope, tier, userIds);
    }

    private Map<String, Object> buildBroadcastTargetRecord(String broadcastId, String userId, String messageId,
            String status, String errorMessage)
    {
        Map<String, Object> targetRecord = new HashMap<>();
        targetRecord.put("id", IdUtils.fastUUID());
        targetRecord.put("broadcastId", broadcastId);
        targetRecord.put("userId", userId);
        targetRecord.put("messageId", messageId);
        targetRecord.put("status", status);
        targetRecord.put("errorMessage", errorMessage);
        return targetRecord;
    }

    private static String safeMessage(RuntimeException ex)
    {
        String message = ex.getMessage();
        message = StringUtils.hasText(message) ? message : "发送失败";
        return message.substring(0, Math.min(message.length(), 500));
    }
}
