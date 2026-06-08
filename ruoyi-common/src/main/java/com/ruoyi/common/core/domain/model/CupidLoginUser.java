package com.ruoyi.common.core.domain.model;

import java.io.Serial;
import java.io.Serializable;

/**
 * Cupid Match 前台登录用户身份
 */
public class CupidLoginUser implements Serializable
{
    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 会话唯一标识
     */
    private String id;

    /**
     * 认证身份ID
     */
    private String identityId;

    /**
     * 用户ID
     */
    private String userId;

    /**
     * 创建时间
     */
    private long createdAt;

    /**
     * 过期时间
     */
    private long expiresAt;

    public String getId()
    {
        return id;
    }

    public void setId(String id)
    {
        this.id = id;
    }

    public String getIdentityId()
    {
        return identityId;
    }

    public void setIdentityId(String identityId)
    {
        this.identityId = identityId;
    }

    public String getUserId()
    {
        return userId;
    }

    public void setUserId(String userId)
    {
        this.userId = userId;
    }

    public long getCreatedAt()
    {
        return createdAt;
    }

    public void setCreatedAt(long createdAt)
    {
        this.createdAt = createdAt;
    }

    public long getExpiresAt()
    {
        return expiresAt;
    }

    public void setExpiresAt(long expiresAt)
    {
        this.expiresAt = expiresAt;
    }

    /**
     * 会话ID，与 {@link #getId()} 等价，便于Spring Security上下文使用
     */
    public String getSessionId()
    {
        return id;
    }
}
