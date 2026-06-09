package com.ruoyi.cupid.domain;

import java.util.Date;

/**
 * Cupid Match 资料认证 cm_profile_verifications
 */
public class CupidProfileVerification
{
    private String id;
    private String profileId;
    private String legalName;
    private Date dateOfBirth;
    private String identityStatus;
    private String educationStatus;
    private String incomeStatus;
    private String maritalVerificationStatus;
    private String reviewStatus;
    private Date verifiedAt;
    private String verifiedByUserId;
    private Date createdAt;
    private Date updatedAt;

    public String getId()
    {
        return id;
    }

    public void setId(String id)
    {
        this.id = id;
    }

    public String getProfileId()
    {
        return profileId;
    }

    public void setProfileId(String profileId)
    {
        this.profileId = profileId;
    }

    public String getLegalName()
    {
        return legalName;
    }

    public void setLegalName(String legalName)
    {
        this.legalName = legalName;
    }

    public Date getDateOfBirth()
    {
        return dateOfBirth;
    }

    public void setDateOfBirth(Date dateOfBirth)
    {
        this.dateOfBirth = dateOfBirth;
    }

    public String getIdentityStatus()
    {
        return identityStatus;
    }

    public void setIdentityStatus(String identityStatus)
    {
        this.identityStatus = identityStatus;
    }

    public String getEducationStatus()
    {
        return educationStatus;
    }

    public void setEducationStatus(String educationStatus)
    {
        this.educationStatus = educationStatus;
    }

    public String getIncomeStatus()
    {
        return incomeStatus;
    }

    public void setIncomeStatus(String incomeStatus)
    {
        this.incomeStatus = incomeStatus;
    }

    public String getMaritalVerificationStatus()
    {
        return maritalVerificationStatus;
    }

    public void setMaritalVerificationStatus(String maritalVerificationStatus)
    {
        this.maritalVerificationStatus = maritalVerificationStatus;
    }

    public String getReviewStatus()
    {
        return reviewStatus;
    }

    public void setReviewStatus(String reviewStatus)
    {
        this.reviewStatus = reviewStatus;
    }

    public Date getVerifiedAt()
    {
        return verifiedAt;
    }

    public void setVerifiedAt(Date verifiedAt)
    {
        this.verifiedAt = verifiedAt;
    }

    public String getVerifiedByUserId()
    {
        return verifiedByUserId;
    }

    public void setVerifiedByUserId(String verifiedByUserId)
    {
        this.verifiedByUserId = verifiedByUserId;
    }

    public Date getCreatedAt()
    {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt)
    {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt()
    {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt)
    {
        this.updatedAt = updatedAt;
    }
}
