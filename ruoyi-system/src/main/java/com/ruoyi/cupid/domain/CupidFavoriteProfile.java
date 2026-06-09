package com.ruoyi.cupid.domain;

import java.util.Date;

/**
 * Cupid Match 收藏资料 cm_favorite_profiles。
 */
public class CupidFavoriteProfile
{
    private String id;
    private String userId;
    private String profileId;
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
