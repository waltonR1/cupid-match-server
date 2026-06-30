package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

public interface ICupidAdminAuditService
{
    List<Map<String, Object>> selectAdminAuditLogs(Map<String, Object> params);

    Map<String, Object> selectAdminAuditLogById(String id);
}
