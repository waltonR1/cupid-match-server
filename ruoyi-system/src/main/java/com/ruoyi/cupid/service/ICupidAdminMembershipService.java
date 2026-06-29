package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

public interface ICupidAdminMembershipService
{
    List<Map<String, Object>> selectAdminMemberships(Map<String, Object> params);

    Map<String, Object> selectAdminMembershipDetail(String id);

    void updateMembershipStatus(String id, String status, String reason, String operatorUserId);

    void updateMembershipFields(String id, String tier, String startedAt, String expiresAt,
            String reason, String operatorUserId);
}
