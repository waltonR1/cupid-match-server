package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

/** Cupid Match 后台通知发布服务。 */
public interface ICupidAdminInboxService
{
    List<Map<String, Object>> searchUsers(String keyword);

    List<Map<String, Object>> searchSubjects(String userId, String subjectType, String keyword);

    List<Map<String, Object>> enabledTemplates();

    Map<String, Object> preview(Map<String, Object> body);

    void send(Map<String, Object> body, String staffUserId);

    Map<String, Object> previewBroadcast(Map<String, Object> body);

    Map<String, Object> broadcast(Map<String, Object> body, String staffUserId);

    List<Map<String, Object>> selectBroadcastHistory(Map<String, Object> params);

    Map<String, Object> selectBroadcastDetail(String id);

    List<Map<String, Object>> selectSingleHistory(Map<String, Object> params);

    Map<String, Object> selectSingleDetail(String id);
}
