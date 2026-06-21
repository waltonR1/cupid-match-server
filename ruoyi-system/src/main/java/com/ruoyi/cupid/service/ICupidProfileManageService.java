package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

/**
 * Cupid Match 后台资料运营管理服务
 */
public interface ICupidProfileManageService
{
    List<Map<String, Object>> selectProfileList(Map<String, Object> params);

    Map<String, Object> selectProfileDetail(String profileId);

    List<Map<String, Object>> selectProfileNotes(String profileId);

    void updateInternalFields(String profileId, Map<String, Object> body, String staffUserId);

    void updateNotes(String profileId, Map<String, Object> body, String staffUserId);
}
