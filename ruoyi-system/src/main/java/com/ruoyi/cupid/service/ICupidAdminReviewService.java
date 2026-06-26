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

    Map<String, Object> selectVerificationDetail(String materialId);

    void reviewVerification(String materialId, String status, String reason, String reviewerUserId);

    void createVerificationMaterial(Map<String, Object> payload, String materialUrl,
            String scanStatus, String scanMessage, String reviewerUserId);

    void resetVerification(String profileId, String materialType, String reason, String reviewerUserId);

    List<Map<String, Object>> selectIntroductionList(Map<String, Object> params);

    Map<String, Object> selectIntroductionDetail(String requestId);

    void acceptIntroduction(String requestId, String reason, String reviewerUserId);

    void declineIntroduction(String requestId, String reason, String reviewerUserId);

    void noteIntroduction(String requestId, String note, String reviewerUserId);
}
