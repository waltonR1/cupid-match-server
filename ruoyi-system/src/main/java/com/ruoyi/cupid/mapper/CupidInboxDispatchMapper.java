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

    int updateSingleDispatchFailure(@Param("id") String id, @Param("errorMessage") String errorMessage);

    List<Map<String, Object>> selectSingleHistory(Map<String, Object> params);

    Map<String, Object> selectSingleDetail(@Param("id") String id);
}
