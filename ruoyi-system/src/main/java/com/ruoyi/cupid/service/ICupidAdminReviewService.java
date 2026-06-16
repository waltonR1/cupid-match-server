package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

/**
 * Cupid Match 后台审核服务
 */
public interface ICupidAdminReviewService
{
    List<Map<String, Object>> selectProfileList(Map<String, Object> params);

    Map<String, Object> selectProfileDetail(String profileId);

    void reviewProfile(String profileId, String status, String reason, String reviewerUserId);

    List<Map<String, Object>> selectPhotoList(Map<String, Object> params);

    Map<String, Object> selectPhotoDetail(String photoId);

    void reviewPhoto(String photoId, String status, String reason, String reviewerUserId);

    List<Map<String, Object>> selectVerificationList(Map<String, Object> params);

    Map<String, Object> selectVerificationDetail(String profileId);

    void reviewVerification(String profileId, String status, String reason, String reviewerUserId);
}
