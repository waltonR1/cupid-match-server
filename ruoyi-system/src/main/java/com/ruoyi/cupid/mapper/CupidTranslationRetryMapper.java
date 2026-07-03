package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface CupidTranslationRetryMapper
{
    int recordFailure(@Param("id") String id,
            @Param("entityType") String entityType,
            @Param("entityId") String entityId,
            @Param("fieldName") String fieldName,
            @Param("sourceLocale") String sourceLocale,
            @Param("targetLocale") String targetLocale,
            @Param("errorMessage") String errorMessage,
            @Param("maxAttempts") int maxAttempts,
            @Param("baseDelayMinutes") int baseDelayMinutes);

    List<Map<String, Object>> selectDueRetries(@Param("batchSize") int batchSize,
            @Param("maxAttempts") int maxAttempts);

    int deleteRetry(@Param("entityType") String entityType,
            @Param("entityId") String entityId,
            @Param("fieldName") String fieldName,
            @Param("targetLocale") String targetLocale);
}
