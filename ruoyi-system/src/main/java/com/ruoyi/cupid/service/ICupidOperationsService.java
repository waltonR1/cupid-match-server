package com.ruoyi.cupid.service;

import java.util.Map;

public interface ICupidOperationsService
{
    int retryFailedMessages();

    int cleanupOperationalData();

    Map<String, Object> getOperationalStatistics();

    void recordSystemMessageFailure(String userId, String templateCode,
            Map<String, Object> variables, String subjectId, String dedupeKey, RuntimeException error);
}
