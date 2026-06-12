package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

/**
 * Cupid Match 活动服务
 */
public interface ICupidEventService
{
    /**
     * 查询活动目录（含分页和筛选面）
     */
    Map<String, Object> getEvents(Map<String, String> params, String userId);

    /**
     * 查询活动详情（含当前用户报名状态）
     */
    Map<String, Object> getEventDetail(String eventId, String userId, String locale);

    /**
     * 报名活动
     */
    Map<String, Object> register(String userId, String eventId);

    /**
     * 取消报名
     */
    Map<String, Object> cancel(String userId, String eventId);

    /**
     * 查询当前用户的报名记录
     */
    List<Map<String, Object>> getMyEvents(String userId, String locale);
}
