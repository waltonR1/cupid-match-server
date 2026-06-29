package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

/** Cupid Match 通知发送数据层。 */
public interface CupidInboxNotificationMapper
{
    Map<String, Object> selectUser(@Param("userId") String userId);

    List<Map<String, Object>> searchUsers(@Param("keyword") String keyword);

    List<Map<String, Object>> searchSubjects(@Param("userId") String userId,
            @Param("subjectType") String subjectType, @Param("keyword") String keyword);

    List<Map<String, Object>> selectBroadcastUsers(@Param("scope") String scope,
            @Param("tier") String tier, @Param("userIds") List<String> userIds);

    int countSubjectAccess(@Param("userId") String userId, @Param("subjectType") String subjectType,
            @Param("subjectId") String subjectId);

    String selectOpenSystemThread(@Param("userId") String userId,
            @Param("subjectType") String subjectType, @Param("subjectId") String subjectId);

    int insertThread(@Param("id") String id, @Param("userId") String userId,
            @Param("subjectType") String subjectType, @Param("subjectId") String subjectId);

    int insertNotification(Map<String, Object> params);

    int touchThread(@Param("threadId") String threadId);
}
