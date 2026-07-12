package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

/**
 * Cupid Match admin contact lead service.
 */
public interface ICupidAdminContactLeadService
{
    List<Map<String, Object>> selectAdminContactLeads(Map<String, Object> params);

    Map<String, Object> selectAdminContactLeadById(String id);

    void handleAdminContactLead(String id, Map<String, Object> body, String operatorUserId);
}
