package com.ruoyi.framework.web.domain;

import java.io.Serial;
import java.io.Serializable;

/**
 * Cupid Match Redis验证码信息
 */
public class CupidVerificationCode implements Serializable
{
    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 验证码唯一标识
     */
    private String id;

    /**
     * 验证目的
     */
    private String purpose;

    /**
     * 认证方式
     */
    private String provider;

    /**
     * 目标标识（邮箱或手机号）
     */
    private String identifier;

    /**
     * 验证码哈希值
     */
    private String codeHash;

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

    public String getPurpose()
    {
        return purpose;
    }

    public void setPurpose(String purpose)
    {
        this.purpose = purpose;
    }

    public String getProvider()
    {
        return provider;
    }

    public void setProvider(String provider)
    {
        this.provider = provider;
    }

    public String getIdentifier()
    {
        return identifier;
    }

    public void setIdentifier(String identifier)
    {
        this.identifier = identifier;
    }

    public String getCodeHash()
    {
        return codeHash;
    }

    public void setCodeHash(String codeHash)
    {
        this.codeHash = codeHash;
    }

    public long getExpiresAt()
    {
        return expiresAt;
    }

    public void setExpiresAt(long expiresAt)
    {
        this.expiresAt = expiresAt;
    }
}
