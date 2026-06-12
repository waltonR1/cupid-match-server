package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

/**
 * Cupid Match 收件箱服务。
 */
public interface ICupidInboxService
{
    List<Map<String, Object>> getThreads(String userId);

    Map<String, Object> getMessages(String userId, String threadId, String before, int limit);

    Map<String, Object> markRead(String userId, String threadId);

    Map<String, Object> sendMessage(String userId, String threadId, String body);
}
