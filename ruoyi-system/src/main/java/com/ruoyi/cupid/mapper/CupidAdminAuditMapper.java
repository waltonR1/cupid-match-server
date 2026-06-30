package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface CupidAdminAuditMapper
{
    List<Map<String, Object>> selectAdminAuditLogs(Map<String, Object> params);

    Map<String, Object> selectAdminAuditLogById(@Param("id") String id);
}
