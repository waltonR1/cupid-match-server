package com.ruoyi.cupid.service;

import java.util.Map;

/** Cupid Match 通知渲染与写入服务。 */
public interface ICupidInboxNotificationService
{
    Map<String, Object> preview(Map<String, Object> request);

    String sendStaffNotification(Map<String, Object> request, String staffUserId, String dedupeKey);

    String sendStaffAnnouncement(Map<String, Object> request, String staffUserId, String dedupeKey);

    String sendSystemNotification(String userId, String templateCode, String locale,
            Map<String, Object> variables, String subjectId, String dedupeKey);
}
