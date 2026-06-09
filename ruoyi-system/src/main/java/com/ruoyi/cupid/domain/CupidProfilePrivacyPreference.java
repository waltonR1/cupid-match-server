package com.ruoyi.cupid.domain;

import java.util.Date;

/**
 * Cupid Match 资料隐私设置 cm_profile_privacy_preferences
 */
public class CupidProfilePrivacyPreference
{
    private String id;
    private String profileId;
    private boolean hideMaritalStatus;
    private boolean hideHasChildren;
    private boolean hideChildrenPlan;
    private boolean hideAcceptsLongDistance;
    private boolean hideSmoking;
    private boolean hideDrinking;
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

    public boolean isHideMaritalStatus()
    {
        return hideMaritalStatus;
    }

    public void setHideMaritalStatus(boolean hideMaritalStatus)
    {
        this.hideMaritalStatus = hideMaritalStatus;
    }

    public boolean isHideHasChildren()
    {
        return hideHasChildren;
    }

    public void setHideHasChildren(boolean hideHasChildren)
    {
        this.hideHasChildren = hideHasChildren;
    }

    public boolean isHideChildrenPlan()
    {
        return hideChildrenPlan;
    }

    public void setHideChildrenPlan(boolean hideChildrenPlan)
    {
        this.hideChildrenPlan = hideChildrenPlan;
    }

    public boolean isHideAcceptsLongDistance()
    {
        return hideAcceptsLongDistance;
    }

    public void setHideAcceptsLongDistance(boolean hideAcceptsLongDistance)
    {
        this.hideAcceptsLongDistance = hideAcceptsLongDistance;
    }

    public boolean isHideSmoking()
    {
        return hideSmoking;
    }

    public void setHideSmoking(boolean hideSmoking)
    {
        this.hideSmoking = hideSmoking;
    }

    public boolean isHideDrinking()
    {
        return hideDrinking;
    }

    public void setHideDrinking(boolean hideDrinking)
    {
        this.hideDrinking = hideDrinking;
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
