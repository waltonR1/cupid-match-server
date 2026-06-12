package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

/**
 * Cupid Match 收件箱数据层。
 */
public interface CupidInboxMapper
{
    List<Map<String, Object>> selectThreadsByUserId(@Param("userId") String userId);

    Map<String, Object> selectThreadByIdAndUserId(
            @Param("threadId") String threadId, @Param("userId") String userId);

    List<Map<String, Object>> selectMessages(
            @Param("threadId") String threadId,
            @Param("before") String before,
            @Param("limit") int limit);

    int upsertRead(@Param("id") String id,
            @Param("threadId") String threadId,
            @Param("userId") String userId);

    Map<String, Object> selectRead(
            @Param("threadId") String threadId, @Param("userId") String userId);

    int insertMessage(@Param("id") String id,
            @Param("threadId") String threadId,
            @Param("userId") String userId,
            @Param("body") String body);

    int touchThread(@Param("threadId") String threadId);
}
