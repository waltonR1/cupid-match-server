package com.ruoyi.cupid.mapper;

import java.util.Date;
import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface CupidAdminStaffTaskMapper
{
    List<Map<String, Object>> selectAdminStaffTasks(Map<String, Object> params);

    Map<String, Object> selectAdminStaffTaskById(@Param("id") String id);

    List<Map<String, Object>> selectAvailableAssignees();

    int insertAdminStaffTask(@Param("id") String id,
            @Param("assigneeSysUserId") Long assigneeSysUserId,
            @Param("subjectType") String subjectType,
            @Param("subjectId") String subjectId,
            @Param("status") String status,
            @Param("priority") String priority,
            @Param("dueAt") Date dueAt,
            @Param("completedAt") Date completedAt);

    int updateAdminStaffTask(@Param("id") String id,
            @Param("assigneeSysUserId") Long assigneeSysUserId,
            @Param("status") String status,
            @Param("priority") String priority,
            @Param("dueAt") Date dueAt,
            @Param("completedAt") Date completedAt);

    int upsertTaskLocalizedField(@Param("id") String id,
            @Param("staffTaskId") String staffTaskId,
            @Param("locale") String locale,
            @Param("value") String value);
}
