package com.ruoyi.cupid.domain;

import java.util.Date;

/**
 * Cupid Match 私人介绍请求 cm_private_introduction_requests。
 */
public class CupidPrivateIntroductionRequest
{
    private String id;
    private String requesterUserId;
    private String requesterProfileId;
    private String targetProfileId;
    private String status;
    private String message;
    private Date requestedAt;
    private Date expiresAt;
    private Date respondedAt;
    private Date cooldownUntil;
    private String entitlementBalanceId;
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

    public String getRequesterUserId()
    {
        return requesterUserId;
    }

    public void setRequesterUserId(String requesterUserId)
    {
        this.requesterUserId = requesterUserId;
    }

    public String getRequesterProfileId()
    {
        return requesterProfileId;
    }

    public void setRequesterProfileId(String requesterProfileId)
    {
        this.requesterProfileId = requesterProfileId;
    }

    public String getTargetProfileId()
    {
        return targetProfileId;
    }

    public void setTargetProfileId(String targetProfileId)
    {
        this.targetProfileId = targetProfileId;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getMessage()
    {
        return message;
    }

    public void setMessage(String message)
    {
        this.message = message;
    }

    public Date getRequestedAt()
    {
        return requestedAt;
    }

    public void setRequestedAt(Date requestedAt)
    {
        this.requestedAt = requestedAt;
    }

    public Date getExpiresAt()
    {
        return expiresAt;
    }

    public void setExpiresAt(Date expiresAt)
    {
        this.expiresAt = expiresAt;
    }

    public Date getRespondedAt()
    {
        return respondedAt;
    }

    public void setRespondedAt(Date respondedAt)
    {
        this.respondedAt = respondedAt;
    }

    public Date getCooldownUntil()
    {
        return cooldownUntil;
    }

    public void setCooldownUntil(Date cooldownUntil)
    {
        this.cooldownUntil = cooldownUntil;
    }

    public String getEntitlementBalanceId()
    {
        return entitlementBalanceId;
    }

    public void setEntitlementBalanceId(String entitlementBalanceId)
    {
        this.entitlementBalanceId = entitlementBalanceId;
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
