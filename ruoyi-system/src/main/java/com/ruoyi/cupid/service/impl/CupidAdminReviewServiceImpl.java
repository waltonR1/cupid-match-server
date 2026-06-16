package com.ruoyi.cupid.service.impl;

import java.util.List;
import java.util.Map;
import java.util.Set;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.mapper.CupidProfileMapper;
import com.ruoyi.cupid.service.ICupidAdminReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Cupid Match 后台审核服务实现
 */
@Service
public class CupidAdminReviewServiceImpl implements ICupidAdminReviewService
{
    private static final Set<String> REVIEW_STATUSES = Set.of("approved", "rejected");

    @Autowired
    private CupidProfileMapper profileMapper;

    @Override
    public List<Map<String, Object>> selectProfileList(Map<String, Object> params)
    {
        return profileMapper.selectAdminProfileList(params);
    }

    @Override
    public Map<String, Object> selectProfileDetail(String profileId)
    {
        Map<String, Object> profile = profileMapper.selectAdminProfileDetail(profileId);
        if (profile != null)
        {
            profile.put("photos", profileMapper.selectAdminPhotosByProfileId(profileId));
            profile.put("localizedFields", profileMapper.selectAdminLocalizedFieldsByProfileId(profileId));
            profile.put("localizedItems", profileMapper.selectAdminLocalizedItemsByProfileId(profileId));
            profile.put("verification", profileMapper.selectAdminVerificationDetail(profileId));
            profile.put("languages", profileMapper.selectLanguagesByProfileId(profileId));
            profile.put("relationshipValues", profileMapper.selectRelationshipValuesByProfileId(profileId));
            profile.put("privacyPreferences", profileMapper.selectPrivacyPreferenceByProfileId(profileId));
            profile.put("contact", profileMapper.selectContactByProfileId(profileId));
        }
        return profile;
    }

    @Override
    @Transactional
    public void reviewProfile(String profileId, String status, String reason, String reviewerUserId)
    {
        assertReviewStatus(status);
        Map<String, Object> before = require(profileMapper.selectAdminProfileDetail(profileId), "资料不存在");
        assertCurrentStatus(before, "profileStatus", "review", "该资料已处理，不能重复审核");
        String targetStatus = "approved".equals(status) ? "open" : "hidden";
        profileMapper.updateAdminProfileReviewStatus(profileId, targetStatus);
        Map<String, Object> after = profileMapper.selectAdminProfileDetail(profileId);
        insertAudit("profile", profileId, "cupid.profile.review", reviewerUserId, before, after, reason);
    }

    @Override
    public List<Map<String, Object>> selectPhotoList(Map<String, Object> params)
    {
        return profileMapper.selectAdminPhotoList(params);
    }

    @Override
    public Map<String, Object> selectPhotoDetail(String photoId)
    {
        return profileMapper.selectAdminPhotoDetail(photoId);
    }

    @Override
    @Transactional
    public void reviewPhoto(String photoId, String status, String reason, String reviewerUserId)
    {
        assertReviewStatus(status);
        Map<String, Object> before = require(profileMapper.selectAdminPhotoDetail(photoId), "照片不存在");
        assertCurrentStatus(before, "status", "review", "该照片已处理，不能重复审核");
        profileMapper.updateAdminPhotoReviewStatus(photoId, status);
        Map<String, Object> after = profileMapper.selectAdminPhotoDetail(photoId);
        insertAudit("profile_photo", photoId, "cupid.photo.review", reviewerUserId, before, after, reason);
    }

    @Override
    public List<Map<String, Object>> selectVerificationList(Map<String, Object> params)
    {
        return profileMapper.selectAdminVerificationList(params);
    }

    @Override
    public Map<String, Object> selectVerificationDetail(String profileId)
    {
        return profileMapper.selectAdminVerificationDetail(profileId);
    }

    @Override
    @Transactional
    public void reviewVerification(String profileId, String status, String reason, String reviewerUserId)
    {
        assertReviewStatus(status);
        Map<String, Object> before = require(profileMapper.selectAdminVerificationDetail(profileId), "认证资料不存在");
        assertCurrentStatus(before, "reviewStatus", "pending", "该认证已处理，不能重复审核");
        String materialStatus = "approved".equals(status) ? "verified" : "rejected";
        profileMapper.updateAdminVerificationReviewStatus(profileId, status, materialStatus, reviewerUserId);
        Map<String, Object> after = profileMapper.selectAdminVerificationDetail(profileId);
        insertAudit("profile_verification", profileId, "cupid.verification.review", reviewerUserId, before, after, reason);
    }

    private void assertReviewStatus(String status)
    {
        if (!REVIEW_STATUSES.contains(status))
        {
            throw new ServiceException("审核状态不正确");
        }
    }

    private Map<String, Object> require(Map<String, Object> row, String message)
    {
        if (row == null)
        {
            throw new ServiceException(message);
        }
        return row;
    }

    private void assertCurrentStatus(Map<String, Object> row, String field, String expected, String message)
    {
        Object status = row.get(field);
        if (!expected.equals(status))
        {
            throw new ServiceException(message);
        }
    }

    private void insertAudit(String subjectType, String subjectId, String action, String actorUserId,
            Map<String, Object> before, Map<String, Object> after, String reason)
    {
        profileMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", actorUserId, subjectType, subjectId,
                action, JSON.toJSONString(before), JSON.toJSONString(after), reason);
    }
}
