package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

public interface ICupidAdminUserService
{
    List<Map<String, Object>> selectAdminUsers(Map<String, Object> params);

    Map<String, Object> selectAdminUserDetail(String id);

    List<Map<String, Object>> selectUserSessions(String userId);

    void updateUserStatus(String userId, String status, String reason, String operatorUserId);

    void deleteUserSession(String userId, String sessionId, String reason, String operatorUserId);

    void deleteAllUserSessions(String userId, String reason, String operatorUserId);

    Map<String, Object> viewSensitive(String userId, String reason, String operatorUserId);
}
