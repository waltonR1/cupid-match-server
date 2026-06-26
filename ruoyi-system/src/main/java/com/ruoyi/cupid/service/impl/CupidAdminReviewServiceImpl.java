package com.ruoyi.cupid.service.impl;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.time.temporal.ChronoUnit;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.domain.CupidProfileVerification;
import com.ruoyi.cupid.domain.CupidProfileVerificationMaterial;
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

    private static final Set<String> MATERIAL_TYPES = Set.of("identity", "education", "income", "marital");

    private static final int INTRODUCTION_COOLDOWN_DAYS = 90;

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
            profile.put("verification", profileMapper.selectVerificationByProfileId(profileId));
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
    public Map<String, Object> selectVerificationDetail(String materialId)
    {
        return profileMapper.selectAdminVerificationDetail(materialId);
    }

    @Override
    @Transactional
    public void reviewVerification(String materialId, String status, String reason, String reviewerUserId)
    {
        assertReviewStatus(status);
        Map<String, Object> before = require(profileMapper.selectAdminVerificationDetail(materialId), "认证材料不存在");
        assertCurrentStatus(before, "status", "pending", "该认证材料已处理，不能重复审核");
        if ("approved".equals(status) && !"passed".equals(before.get("scanStatus")))
        {
            throw new ServiceException("认证材料未通过安全检查，不能审核通过");
        }
        String profileId = String.valueOf(before.get("profileId"));
        String materialType = String.valueOf(before.get("materialType"));
        String materialStatus = "approved".equals(status) ? "verified" : "rejected";
        profileMapper.updateAdminVerificationMaterialStatus(materialId, status, reviewerUserId, reason);
        profileMapper.updateVerificationStatusByMaterial(profileId, materialType, materialStatus, reviewerUserId);
        profileMapper.refreshVerificationReviewStatus(profileId);
        Map<String, Object> after = profileMapper.selectAdminVerificationDetail(materialId);
        insertAudit("profile_verification_material", materialId,
                "cupid.verification.review", reviewerUserId, before, after, reason);
    }

    @Override
    @Transactional
    public void createVerificationMaterial(Map<String, Object> payload, String materialUrl,
            String scanStatus, String scanMessage, String reviewerUserId)
    {
        String profileId = string(payload, "profileId");
        String materialType = string(payload, "materialType");
        String materialName = string(payload, "materialName");
        String reviewNote = string(payload, "reviewNote");
        String legalName = string(payload, "legalName");
        java.util.Date dateOfBirth = parseSqlDate(string(payload, "dateOfBirth"));
        if (!MATERIAL_TYPES.contains(materialType))
        {
            throw new ServiceException("认证材料类型不正确");
        }
        if (!hasText(profileId))
        {
            throw new ServiceException("资料ID不能为空");
        }
        if (!"passed".equals(scanStatus))
        {
            throw new ServiceException("认证材料未通过安全检查，不能保存");
        }
        if (!hasText(materialName))
        {
            throw new ServiceException("材料名称不能为空");
        }
        if (!hasText(reviewNote))
        {
            throw new ServiceException("补录说明不能为空");
        }
        if ("identity".equals(materialType) && (!hasText(legalName) || dateOfBirth == null))
        {
            throw new ServiceException("身份认证补录需要填写法定姓名和出生日期");
        }
        Map<String, Object> profile = require(profileMapper.selectAdminProfileDetail(profileId), "资料不存在");
        String submittedByUserId = String.valueOf(profile.get("ownerUserId"));
        if (!hasText(submittedByUserId) || "null".equals(submittedByUserId))
        {
            throw new ServiceException("资料未关联C端用户，不能补录认证材料");
        }
        CupidProfileVerificationMaterial material = new CupidProfileVerificationMaterial();
        material.setId(IdUtils.fastUUID());
        material.setProfileId(profileId);
        material.setMaterialType(materialType);
        material.setStatus("pending");
        material.setLegalName(legalName);
        material.setDateOfBirth(dateOfBirth);
        material.setMaterialName(materialName);
        material.setMaterialUrl(materialUrl);
        material.setScanStatus(scanStatus);
        material.setScanMessage(scanMessage);
        material.setReviewNote(reviewNote);
        material.setSubmittedByUserId(submittedByUserId);
        profileMapper.upsertVerification(buildInitialVerification(profileId));
        profileMapper.insertVerificationMaterial(material);
        profileMapper.markVerificationMaterialPending(profileId, materialType, legalName, dateOfBirth, submittedByUserId);
        Map<String, Object> after = profileMapper.selectAdminVerificationDetail(material.getId());
        insertAudit("profile_verification_material", material.getId(),
                "cupid.verification.material.create", reviewerUserId, profile, after, reviewNote);
    }

    @Override
    @Transactional
    public void resetVerification(String profileId, String materialType, String reason, String reviewerUserId)
    {
        if (!hasText(profileId))
        {
            throw new ServiceException("资料ID不能为空");
        }
        if (!MATERIAL_TYPES.contains(materialType))
        {
            throw new ServiceException("认证材料类型不正确");
        }
        if (!hasText(reason))
        {
            throw new ServiceException("重置原因不能为空");
        }
        Map<String, Object> profile = require(profileMapper.selectAdminProfileDetail(profileId), "资料不存在");
        CupidProfileVerification before = profileMapper.selectVerificationByProfileId(profileId);
        if (before == null)
        {
            throw new ServiceException("资料没有认证状态记录");
        }
        profileMapper.resetVerificationStatusByMaterial(profileId, materialType, reviewerUserId);
        profileMapper.refreshVerificationReviewStatus(profileId);
        CupidProfileVerification after = profileMapper.selectVerificationByProfileId(profileId);
        insertAudit("profile_verification", profileId,
                "cupid.verification.reset", reviewerUserId, Map.of("profile", profile, "verification", before),
                Map.of("profile", profile, "verification", after), reason);
    }

    @Override
    public List<Map<String, Object>> selectIntroductionList(Map<String, Object> params)
    {
        return profileMapper.selectAdminIntroductionList(params);
    }

    @Override
    public Map<String, Object> selectIntroductionDetail(String requestId)
    {
        Map<String, Object> detail =
                require(profileMapper.selectAdminIntroductionDetail(requestId), "私人介绍申请不存在");
        detail.put("auditLogs", profileMapper.selectAdminIntroductionAuditLogs(requestId));
        return detail;
    }

    @Override
    @Transactional
    public void acceptIntroduction(String requestId, String reason, String reviewerUserId)
    {
        Map<String, Object> before = requirePendingIntroduction(requestId);
        if (profileMapper.updateAdminIntroductionAccepted(requestId) != 1)
        {
            throw new ServiceException("该申请已处理，不能重复操作");
        }
        Map<String, Object> after = profileMapper.selectAdminIntroductionDetail(requestId);
        insertAudit("private_introduction_request", requestId,
                "cupid.introduction.accept", reviewerUserId, before, after, reason);
    }

    @Override
    @Transactional
    public void declineIntroduction(String requestId, String reason, String reviewerUserId)
    {
        if (!hasText(reason))
        {
            throw new ServiceException("暂不受理原因不能为空");
        }
        Map<String, Object> before = requirePendingIntroduction(requestId);
        java.util.Date cooldownUntil = java.util.Date.from(
                java.time.Instant.now().plus(INTRODUCTION_COOLDOWN_DAYS, ChronoUnit.DAYS));
        if (profileMapper.updateAdminIntroductionDeclined(requestId, cooldownUntil) != 1)
        {
            throw new ServiceException("该申请已处理，不能重复操作");
        }
        Object balanceId = before.get("entitlementBalanceId");
        if (balanceId != null && hasText(String.valueOf(balanceId)))
        {
            profileMapper.restoreIntroductionEntitlement(String.valueOf(balanceId));
        }
        Map<String, Object> after = profileMapper.selectAdminIntroductionDetail(requestId);
        insertAudit("private_introduction_request", requestId,
                "cupid.introduction.decline", reviewerUserId, before, after, reason);
    }

    @Override
    @Transactional
    public void noteIntroduction(String requestId, String note, String reviewerUserId)
    {
        if (!hasText(note))
        {
            throw new ServiceException("备注不能为空");
        }
        Map<String, Object> current =
                require(profileMapper.selectAdminIntroductionDetail(requestId), "私人介绍申请不存在");
        insertAudit("private_introduction_request", requestId,
                "cupid.introduction.note", reviewerUserId, current, current, note);
    }

    private void assertReviewStatus(String status)
    {
        if (!REVIEW_STATUSES.contains(status))
        {
            throw new ServiceException("审核状态不正确");
        }
    }

    private Map<String, Object> requirePendingIntroduction(String requestId)
    {
        Map<String, Object> row =
                require(profileMapper.selectAdminIntroductionForUpdate(requestId), "私人介绍申请不存在");
        assertCurrentStatus(row, "rawStatus", "requested", "该申请已处理，不能重复操作");
        Object expiresAt = row.get("expiresAt");
        if (expiresAt instanceof java.util.Date && !((java.util.Date) expiresAt).after(new java.util.Date()))
        {
            throw new ServiceException("该申请已过期，不能继续处理");
        }
        return row;
    }

    private CupidProfileVerification buildInitialVerification(String profileId)
    {
        CupidProfileVerification verification = new CupidProfileVerification();
        verification.setId(IdUtils.fastUUID());
        verification.setProfileId(profileId);
        verification.setIdentityStatus("unverified");
        verification.setEducationStatus("unverified");
        verification.setIncomeStatus("unverified");
        verification.setMaritalVerificationStatus("unverified");
        verification.setReviewStatus("unreviewed");
        return verification;
    }

    private String string(Map<String, Object> payload, String key)
    {
        Object value = payload == null ? null : payload.get(key);
        return value == null ? null : String.valueOf(value).trim();
    }

    private boolean hasText(String value)
    {
        return value != null && !value.trim().isEmpty();
    }

    private java.sql.Date parseSqlDate(String value)
    {
        if (!hasText(value))
        {
            return null;
        }
        try
        {
            return java.sql.Date.valueOf(value);
        }
        catch (IllegalArgumentException e)
        {
            throw new ServiceException("日期格式不正确");
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
