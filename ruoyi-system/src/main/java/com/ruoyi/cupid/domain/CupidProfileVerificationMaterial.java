package com.ruoyi.cupid.domain;

import java.util.Date;

/**
 * Cupid Match 资料认证材料 cm_profile_verification_materials
 */
public class CupidProfileVerificationMaterial
{
    private String id;
    private String profileId;
    private String materialType;
    private String status;
    private String legalName;
    private Date dateOfBirth;
    private String materialName;
    private String materialUrl;
    private String reviewNote;
    private String submittedByUserId;
    private Date submittedAt;
    private String reviewedByUserId;
    private Date reviewedAt;
    private String rejectionReason;
    private Date createdAt;
    private Date updatedAt;

    public String getId() { return id; }

    public void setId(String id) { this.id = id; }

    public String getProfileId() { return profileId; }

    public void setProfileId(String profileId) { this.profileId = profileId; }

    public String getMaterialType() { return materialType; }

    public void setMaterialType(String materialType) { this.materialType = materialType; }

    public String getStatus() { return status; }

    public void setStatus(String status) { this.status = status; }

    public String getLegalName() { return legalName; }

    public void setLegalName(String legalName) { this.legalName = legalName; }

    public Date getDateOfBirth() { return dateOfBirth; }

    public void setDateOfBirth(Date dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getMaterialName() { return materialName; }

    public void setMaterialName(String materialName) { this.materialName = materialName; }

    public String getMaterialUrl() { return materialUrl; }

    public void setMaterialUrl(String materialUrl) { this.materialUrl = materialUrl; }

    public String getReviewNote() { return reviewNote; }

    public void setReviewNote(String reviewNote) { this.reviewNote = reviewNote; }

    public String getSubmittedByUserId() { return submittedByUserId; }

    public void setSubmittedByUserId(String submittedByUserId) { this.submittedByUserId = submittedByUserId; }

    public Date getSubmittedAt() { return submittedAt; }

    public void setSubmittedAt(Date submittedAt) { this.submittedAt = submittedAt; }

    public String getReviewedByUserId() { return reviewedByUserId; }

    public void setReviewedByUserId(String reviewedByUserId) { this.reviewedByUserId = reviewedByUserId; }

    public Date getReviewedAt() { return reviewedAt; }

    public void setReviewedAt(Date reviewedAt) { this.reviewedAt = reviewedAt; }

    public String getRejectionReason() { return rejectionReason; }

    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    public Date getCreatedAt() { return createdAt; }

    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getUpdatedAt() { return updatedAt; }

    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
}
