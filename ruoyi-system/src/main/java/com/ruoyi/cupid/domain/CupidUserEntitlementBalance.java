package com.ruoyi.cupid.domain;

import java.util.Date;

/**
 * Cupid Match 用户权益余额 cm_user_entitlement_balances。
 */
public class CupidUserEntitlementBalance
{
    private String id;
    private String userId;
    private String membershipId;
    private String entitlementCode;
    private Date periodStartedAt;
    private Date periodEndsAt;
    private int quotaTotal;
    private int quotaUsed;
    private int quotaRemaining;
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

    public String getUserId()
    {
        return userId;
    }

    public void setUserId(String userId)
    {
        this.userId = userId;
    }

    public String getMembershipId()
    {
        return membershipId;
    }

    public void setMembershipId(String membershipId)
    {
        this.membershipId = membershipId;
    }

    public String getEntitlementCode()
    {
        return entitlementCode;
    }

    public void setEntitlementCode(String entitlementCode)
    {
        this.entitlementCode = entitlementCode;
    }

    public Date getPeriodStartedAt()
    {
        return periodStartedAt;
    }

    public void setPeriodStartedAt(Date periodStartedAt)
    {
        this.periodStartedAt = periodStartedAt;
    }

    public Date getPeriodEndsAt()
    {
        return periodEndsAt;
    }

    public void setPeriodEndsAt(Date periodEndsAt)
    {
        this.periodEndsAt = periodEndsAt;
    }

    public int getQuotaTotal()
    {
        return quotaTotal;
    }

    public void setQuotaTotal(int quotaTotal)
    {
        this.quotaTotal = quotaTotal;
    }

    public int getQuotaUsed()
    {
        return quotaUsed;
    }

    public void setQuotaUsed(int quotaUsed)
    {
        this.quotaUsed = quotaUsed;
    }

    public int getQuotaRemaining()
    {
        return quotaRemaining;
    }

    public void setQuotaRemaining(int quotaRemaining)
    {
        this.quotaRemaining = quotaRemaining;
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
