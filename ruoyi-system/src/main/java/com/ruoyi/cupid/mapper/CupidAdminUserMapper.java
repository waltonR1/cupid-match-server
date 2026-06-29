package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface CupidAdminUserMapper
{
    List<Map<String, Object>> selectAdminUsers(Map<String, Object> params);

    Map<String, Object> selectAdminUserDetail(@Param("id") String id);

    List<Map<String, Object>> selectUserProfiles(@Param("userId") String userId);

    List<Map<String, Object>> selectUserRecentEvents(@Param("userId") String userId);

    List<Map<String, Object>> selectUserIdentities(@Param("userId") String userId);

    List<Map<String, Object>> selectUserProfileContacts(@Param("userId") String userId);

    int updateUserStatus(@Param("id") String id, @Param("status") String status);
}
