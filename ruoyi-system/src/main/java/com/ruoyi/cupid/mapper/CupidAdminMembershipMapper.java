package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface CupidAdminMembershipMapper
{
    List<Map<String, Object>> selectAdminMemberships(Map<String, Object> params);

    Map<String, Object> selectAdminMembershipDetail(@Param("id") String id);

    Map<String, Object> selectPlanByTier(@Param("tier") String tier);

    int updateMembershipStatus(@Param("id") String id, @Param("status") String status);

    int updateMembershipFields(@Param("id") String id,
            @Param("planId") String planId,
            @Param("tier") String tier,
            @Param("startedAt") java.util.Date startedAt,
            @Param("expiresAt") java.util.Date expiresAt);
}
