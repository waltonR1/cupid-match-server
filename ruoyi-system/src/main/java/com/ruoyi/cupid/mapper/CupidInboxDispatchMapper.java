package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

/**
 * Inbox 后台单发/群发记录数据层
 */
public interface CupidInboxDispatchMapper
{
    int insertBroadcast(Map<String, Object> params);

    int insertBroadcastTarget(Map<String, Object> params);

    int updateBroadcastCounts(@Param("id") String id, @Param("targetCount") int targetCount,
            @Param("successCount") int successCount, @Param("failureCount") int failureCount);

    List<Map<String, Object>> selectBroadcastHistory(Map<String, Object> params);

    Map<String, Object> selectBroadcastDetail(@Param("id") String id);

    List<Map<String, Object>> selectBroadcastTargets(@Param("broadcastId") String broadcastId);

    int insertSingleDispatch(Map<String, Object> params);

    int updateSingleDispatchSuccess(@Param("id") String id, @Param("messageId") String messageId);

    int updateSingleDispatchFailure(@Param("id") String id, @Param("errorMessage") String errorMessage,
            @Param("retryable") boolean retryable);

    List<Map<String, Object>> selectSingleHistory(Map<String, Object> params);

    Map<String, Object> selectSingleDetail(@Param("id") String id);

    List<Map<String, Object>> selectDueSingleRetries(@Param("maxAttempts") int maxAttempts,
            @Param("batchSize") int batchSize);

    List<Map<String, Object>> selectDueBroadcastRetries(@Param("maxAttempts") int maxAttempts,
            @Param("batchSize") int batchSize);

    int markSingleRetryFailure(@Param("id") String id, @Param("errorMessage") String errorMessage,
            @Param("maxAttempts") int maxAttempts, @Param("baseDelayMinutes") int baseDelayMinutes);

    int markBroadcastRetrySuccess(@Param("id") String id, @Param("messageId") String messageId);

    int markBroadcastRetryFailure(@Param("id") String id, @Param("errorMessage") String errorMessage,
            @Param("maxAttempts") int maxAttempts, @Param("baseDelayMinutes") int baseDelayMinutes);

    int markBroadcastPermanentFailure(@Param("id") String id, @Param("errorMessage") String errorMessage);

    int refreshBroadcastCounts(@Param("broadcastId") String broadcastId);

    String selectMessageIdByDedupeKey(@Param("dedupeKey") String dedupeKey);

    int insertSystemFailure(Map<String, Object> params);

    List<Map<String, Object>> selectDueSystemRetries(@Param("maxAttempts") int maxAttempts,
            @Param("batchSize") int batchSize);

    int deleteSystemFailure(@Param("id") String id);

    int markSystemRetryFailure(@Param("id") String id, @Param("errorMessage") String errorMessage,
            @Param("maxAttempts") int maxAttempts, @Param("baseDelayMinutes") int baseDelayMinutes);

    int markSystemPermanentFailure(@Param("id") String id, @Param("errorMessage") String errorMessage);

    Map<String, Object> selectDeliveryStatistics();

    int cleanupMessageRetries(@Param("before") java.util.Date before);
    int cleanupTranslationRetries(@Param("before") java.util.Date before);
    int cleanupSecurityChallenges(@Param("before") java.util.Date before);
    int cleanupSecurityEvents(@Param("before") java.util.Date before);
    int cleanupLoginLogs(@Param("before") java.util.Date before);
    int cleanupOperationLogs(@Param("before") java.util.Date before);
    int cleanupJobLogs(@Param("before") java.util.Date before);
}
