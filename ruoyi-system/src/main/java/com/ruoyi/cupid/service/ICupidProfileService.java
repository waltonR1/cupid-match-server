package com.ruoyi.cupid.service;

import java.util.Map;

/**
 * Cupid Match 用户资料服务
 */
public interface ICupidProfileService
{
    /**
     * 查询自助征婚资料目录
     */
    Map<String, Object> getSelfProfileDirectory(Map<String, String> params, String userId);

    /**
     * 查询家庭征婚资料目录
     */
    Map<String, Object> getFamilyProfileDirectory(Map<String, String> params, String userId);

    /**
     * 查询首页精选资料
     */
    Map<String, Object> getFeaturedProfiles(Map<String, String> params);

    /**
     * 查询自助征婚资料详情
     */
    Map<String, Object> getSelfProfileDetail(String profileId, String userId, String locale);

    /**
     * 查询家庭征婚资料详情
     */
    Map<String, Object> getFamilyProfileDetail(String profileId, String userId, String locale);
}
