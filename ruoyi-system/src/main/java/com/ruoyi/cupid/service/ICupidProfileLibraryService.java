package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

/**
 * Cupid Match 后台资料库只读服务
 */
public interface ICupidProfileLibraryService
{
    List<Map<String, Object>> selectProfileList(Map<String, Object> params);

    Map<String, Object> selectProfileDetail(String profileId);
}
