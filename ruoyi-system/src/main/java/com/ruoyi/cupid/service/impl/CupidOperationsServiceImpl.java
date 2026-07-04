package com.ruoyi.cupid.service.impl;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Date;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.mapper.CupidInboxDispatchMapper;
import com.ruoyi.cupid.service.ICupidInboxNotificationService;
import com.ruoyi.cupid.service.ICupidOperationsService;

@Service
public class CupidOperationsServiceImpl implements ICupidOperationsService
{
    @Autowired
    private CupidInboxDispatchMapper dispatchMapper;

    @Autowired
    private ICupidInboxNotificationService notificationService;

    @Value("${cupid.message-retry.max-attempts:5}")
    private int maxAttempts;

    @Value("${cupid.message-retry.batch-size:100}")
    private int batchSize;

    @Value("${cupid.message-retry.base-delay-minutes:5}")
    private int baseDelayMinutes;

    @Value("${cupid.retention.technical-log-days:180}")
    private int technicalLogDays;

    @Value("${cupid.retention.security-event-days:365}")
    private int securityEventDays;

    @Value("${cupid.retention.exhausted-retry-days:90}")
    private int exhaustedRetryDays;

    @Value("${cupid.retention.expired-challenge-days:30}")
    private int expiredChallengeDays;

    @PostConstruct
    public void normalizeConfiguration()
    {
        maxAttempts = bounded(maxAttempts, 1, 10, 5);
        batchSize = bounded(batchSize, 1, 1000, 100);
        baseDelayMinutes = bounded(baseDelayMinutes, 1, 1440, 5);
        technicalLogDays = bounded(technicalLogDays, 1, 3650, 180);
        securityEventDays = bounded(securityEventDays, 1, 3650, 365);
        exhaustedRetryDays = bounded(exhaustedRetryDays, 1, 3650, 90);
        expiredChallengeDays = bounded(expiredChallengeDays, 1, 3650, 30);
    }

    @Override
    public int retryFailedMessages()
    {
        int remaining = Math.max(1, batchSize);
        List<Map<String, Object>> singles =
                dispatchMapper.selectDueSingleRetries(maxAttempts, remaining);
        int completed = retrySingles(singles);
        remaining -= singles.size();

        List<Map<String, Object>> broadcasts = remaining > 0
                ? dispatchMapper.selectDueBroadcastRetries(maxAttempts, remaining) : List.of();
        completed += retryBroadcasts(broadcasts);
        remaining -= broadcasts.size();

        List<Map<String, Object>> systemMessages = remaining > 0
                ? dispatchMapper.selectDueSystemRetries(maxAttempts, remaining) : List.of();
        completed += retrySystemMessages(systemMessages);
        return completed;
    }

    @Override
    public int cleanupOperationalData()
    {
        int cleaned = 0;
        cleaned += dispatchMapper.cleanupMessageRetries(beforeDays(exhaustedRetryDays));
        cleaned += dispatchMapper.cleanupTranslationRetries(beforeDays(exhaustedRetryDays));
        cleaned += dispatchMapper.cleanupSecurityChallenges(beforeDays(expiredChallengeDays));
        cleaned += dispatchMapper.cleanupSecurityEvents(beforeDays(securityEventDays));
        cleaned += dispatchMapper.cleanupLoginLogs(beforeDays(technicalLogDays));
        cleaned += dispatchMapper.cleanupOperationLogs(beforeDays(technicalLogDays));
        cleaned += dispatchMapper.cleanupJobLogs(beforeDays(technicalLogDays));
        return cleaned;
    }

    @Override
    public Map<String, Object> getOperationalStatistics()
    {
        Map<String, Object> result = dispatchMapper.selectDeliveryStatistics();
        return result == null ? Map.of() : result;
    }

    @Override
    public void recordSystemMessageFailure(String userId, String templateCode,
            Map<String, Object> variables, String subjectId, String dedupeKey, RuntimeException error)
    {
        boolean retryable = CupidMessageRetryPolicy.isRetryable(error);
        Map<String, Object> failure = new HashMap<>();
        failure.put("id", IdUtils.fastUUID());
        failure.put("userId", userId);
        failure.put("templateCode", templateCode);
        failure.put("variablesJson", JSON.toJSONString(variables == null ? Map.of() : variables));
        failure.put("subjectId", subjectId);
        failure.put("dedupeKey", dedupeKey);
        failure.put("errorMessage", safeMessage(error));
        failure.put("status", retryable ? "pending" : "failure");
        failure.put("retryable", retryable);
        dispatchMapper.insertSystemFailure(failure);
    }

    private int retrySingles(List<Map<String, Object>> retries)
    {
        int completed = 0;
        for (Map<String, Object> row : retries)
        {
            String id = text(row.get("id"));
            try
            {
                Map<String, Object> request = parseMap(row.get("payloadJson"));
                String dedupeKey = "single-dispatch:" + id;
                String messageId = notificationService.sendStaffNotification(
                        request, text(row.get("staffUserId")), dedupeKey);
                if (messageId == null)
                {
                    messageId = dispatchMapper.selectMessageIdByDedupeKey(dedupeKey);
                }
                dispatchMapper.updateSingleDispatchSuccess(id, messageId);
                completed++;
            }
            catch (RuntimeException ex)
            {
                if (CupidMessageRetryPolicy.isRetryable(ex))
                {
                    dispatchMapper.markSingleRetryFailure(id, safeMessage(ex), maxAttempts, baseDelayMinutes);
                }
                else
                {
                    dispatchMapper.updateSingleDispatchFailure(id, safeMessage(ex), false);
                }
            }
        }
        return completed;
    }

    private int retryBroadcasts(List<Map<String, Object>> retries)
    {
        int completed = 0;
        for (Map<String, Object> row : retries)
        {
            String id = text(row.get("id"));
            try
            {
                Map<String, Object> request = parseMap(row.get("payloadJson"));
                request.put("userId", row.get("userId"));
                request.put("locale", row.get("preferredLocale"));
                String dedupeKey = "broadcast:" + row.get("broadcastId") + ":" + row.get("userId");
                String messageId = notificationService.sendStaffAnnouncement(
                        request, text(row.get("staffUserId")), dedupeKey);
                if (messageId == null)
                {
                    messageId = dispatchMapper.selectMessageIdByDedupeKey(dedupeKey);
                }
                dispatchMapper.markBroadcastRetrySuccess(id, messageId);
                dispatchMapper.refreshBroadcastCounts(text(row.get("broadcastId")));
                completed++;
            }
            catch (RuntimeException ex)
            {
                if (CupidMessageRetryPolicy.isRetryable(ex))
                {
                    dispatchMapper.markBroadcastRetryFailure(id, safeMessage(ex), maxAttempts, baseDelayMinutes);
                }
                else
                {
                    dispatchMapper.markBroadcastPermanentFailure(id, safeMessage(ex));
                }
                dispatchMapper.refreshBroadcastCounts(text(row.get("broadcastId")));
            }
        }
        return completed;
    }

    private int retrySystemMessages(List<Map<String, Object>> retries)
    {
        int completed = 0;
        for (Map<String, Object> row : retries)
        {
            String id = text(row.get("id"));
            try
            {
                notificationService.sendSystemNotification(text(row.get("userId")),
                        text(row.get("templateCode")), null, parseMap(row.get("variablesJson")),
                        text(row.get("subjectId")), text(row.get("dedupeKey")));
                dispatchMapper.deleteSystemFailure(id);
                completed++;
            }
            catch (RuntimeException ex)
            {
                if (CupidMessageRetryPolicy.isRetryable(ex))
                {
                    dispatchMapper.markSystemRetryFailure(id, safeMessage(ex), maxAttempts, baseDelayMinutes);
                }
                else
                {
                    dispatchMapper.markSystemPermanentFailure(id, safeMessage(ex));
                }
            }
        }
        return completed;
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> parseMap(Object value)
    {
        if (value == null)
        {
            return new HashMap<>();
        }
        return JSON.parseObject(String.valueOf(value), Map.class);
    }

    private static Date beforeDays(int days)
    {
        return Date.from(Instant.now().minus(days, ChronoUnit.DAYS));
    }

    private static String text(Object value)
    {
        return value == null ? null : String.valueOf(value);
    }

    private static String safeMessage(RuntimeException ex)
    {
        String message = ex.getMessage() == null ? "发送失败" : ex.getMessage();
        return message.substring(0, Math.min(message.length(), 500));
    }

    private static int bounded(int value, int min, int max, int fallback)
    {
        return value >= min && value <= max ? value : fallback;
    }
}
