package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

public interface ICupidSecurityEventService
{
    void recordEvent(String userId, String identityId, String eventType, String eventResult,
            String riskLevel, String deviceId, Map<String, Object> detail);

    List<Map<String, Object>> selectAdminSecurityEvents(Map<String, Object> params);

    Map<String, Object> selectAdminSecurityEventById(String id);
}
