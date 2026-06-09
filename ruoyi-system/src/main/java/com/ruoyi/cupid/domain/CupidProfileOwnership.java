package com.ruoyi.cupid.domain;

import java.util.Date;

/**
 * Cupid Match 资料归属 cm_profile_ownerships
 */
public class CupidProfileOwnership
{
    private String id;
    private String userId;
    private String profileId;
    private String relationshipToProfile;
    private String permission;
    private String status;
    private String invitedByUserId;
    private Date acceptedAt;
    private Date revokedAt;
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

    public String getProfileId()
    {
        return profileId;
    }

    public void setProfileId(String profileId)
    {
        this.profileId = profileId;
    }

    public String getRelationshipToProfile()
    {
        return relationshipToProfile;
    }

    public void setRelationshipToProfile(String relationshipToProfile)
    {
        this.relationshipToProfile = relationshipToProfile;
    }

    public String getPermission()
    {
        return permission;
    }

    public void setPermission(String permission)
    {
        this.permission = permission;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getInvitedByUserId()
    {
        return invitedByUserId;
    }

    public void setInvitedByUserId(String invitedByUserId)
    {
        this.invitedByUserId = invitedByUserId;
    }

    public Date getAcceptedAt()
    {
        return acceptedAt;
    }

    public void setAcceptedAt(Date acceptedAt)
    {
        this.acceptedAt = acceptedAt;
    }

    public Date getRevokedAt()
    {
        return revokedAt;
    }

    public void setRevokedAt(Date revokedAt)
    {
        this.revokedAt = revokedAt;
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
