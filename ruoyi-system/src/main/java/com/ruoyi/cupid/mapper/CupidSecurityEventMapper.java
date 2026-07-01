package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.cupid.domain.CupidSecurityEvent;

public interface CupidSecurityEventMapper
{
    int insertSecurityEvent(CupidSecurityEvent event);

    List<Map<String, Object>> selectAdminSecurityEvents(Map<String, Object> params);

    Map<String, Object> selectAdminSecurityEventById(@Param("id") String id);
}
