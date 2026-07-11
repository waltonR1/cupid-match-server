package com.ruoyi.cupid.domain;

import java.util.Date;

/**
 * Cupid Match 前台用户
 */
public class CupidUser
{
    private String id;
    private String accountName;
    private String avatarUrl;
    private String preferredLocale;
    private String aliasWordCode;
    private String aliasTag;
    private String status;
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

    public String getAccountName()
    {
        return accountName;
    }

    public void setAccountName(String accountName)
    {
        this.accountName = accountName;
    }

    public String getAvatarUrl()
    {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl)
    {
        this.avatarUrl = avatarUrl;
    }

    public String getPreferredLocale()
    {
        return preferredLocale;
    }

    public void setPreferredLocale(String preferredLocale)
    {
        this.preferredLocale = preferredLocale;
    }

    public String getAliasWordCode()
    {
        return aliasWordCode;
    }

    public void setAliasWordCode(String aliasWordCode)
    {
        this.aliasWordCode = aliasWordCode;
    }

    public String getAliasTag()
    {
        return aliasTag;
    }

    public void setAliasTag(String aliasTag)
    {
        this.aliasTag = aliasTag;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
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
