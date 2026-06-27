package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

/**
 * Cupid Match 后台活动与报名服务。
 */
public interface ICupidAdminEventService
{
    List<Map<String, Object>> selectAdminEvents(Map<String, Object> params);

    Map<String, Object> selectAdminEventDetail(String id);

    void createEvent(Map<String, Object> data, String operatorUserId);

    void updateEvent(String id, Map<String, Object> data, String operatorUserId);

    void updateEventStatus(String id, String status, String reason, String reviewerUserId);

    List<Map<String, Object>> selectAdminRegistrations(Map<String, Object> params);

    Map<String, Object> selectAdminRegistrationDetail(String id);

    void reviewRegistration(String id, String targetStatus, String reason, String reviewerUserId);
}
