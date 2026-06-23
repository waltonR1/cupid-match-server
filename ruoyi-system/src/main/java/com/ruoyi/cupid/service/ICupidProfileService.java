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

    /**
     * 查询当前用户管理的全部资料
     */
    Map<String, Object> getOwnerProfiles(String userId, String locale);

    /**
     * 查询当前用户管理的资料详情
     */
    Map<String, Object> getOwnerProfileDetail(String profileId, String userId, String locale);

    /**
     * 保存资料（新建或更新）
     */
    Map<String, Object> saveProfile(String userId, Map<String, Object> payload, String locale);

    /**
     * 归档资料
     */
    Map<String, Object> archiveProfile(String profileId, String userId);

    /**
     * 提交资料进入发布审核
     */
    Map<String, Object> submitProfileForReview(String profileId, String userId, String locale);

    /**
     * 更新资料隐私偏好
     */
    Map<String, Object> updatePrivacyPreferences(String profileId, String userId, Map<String, Object> prefs);

    /**
     * 查询资料认证材料状态
     */
    Map<String, Object> getVerificationMaterials(String profileId, String userId);

    /**
     * 提交资料认证材料
     */
    Map<String, Object> submitVerificationMaterial(String profileId, String userId, Map<String, Object> payload);
}
