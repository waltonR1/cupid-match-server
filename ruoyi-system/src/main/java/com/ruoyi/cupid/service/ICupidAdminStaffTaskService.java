package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

public interface ICupidAdminStaffTaskService
{
    List<Map<String, Object>> selectAdminStaffTasks(Map<String, Object> params);

    Map<String, Object> selectAdminStaffTaskById(String id);

    List<Map<String, Object>> selectAvailableAssignees();

    void createAdminStaffTask(Map<String, Object> body, String operatorUserId);

    void updateAdminStaffTask(String id, Map<String, Object> body, String operatorUserId);
}
