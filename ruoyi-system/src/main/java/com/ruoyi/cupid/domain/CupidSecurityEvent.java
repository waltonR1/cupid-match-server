package com.ruoyi.cupid.domain;

import com.ruoyi.common.core.domain.BaseEntity;

public class CupidSecurityEvent extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private String id;
    private String userId;
    private String identityId;
    private String eventType;
    private String eventResult;
    private String riskLevel;
    private String ip;
    private String userAgent;
    private String deviceId;
    private String detailJson;

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

    public String getIdentityId()
    {
        return identityId;
    }

    public void setIdentityId(String identityId)
    {
        this.identityId = identityId;
    }

    public String getEventType()
    {
        return eventType;
    }

    public void setEventType(String eventType)
    {
        this.eventType = eventType;
    }

    public String getEventResult()
    {
        return eventResult;
    }

    public void setEventResult(String eventResult)
    {
        this.eventResult = eventResult;
    }

    public String getRiskLevel()
    {
        return riskLevel;
    }

    public void setRiskLevel(String riskLevel)
    {
        this.riskLevel = riskLevel;
    }

    public String getIp()
    {
        return ip;
    }

    public void setIp(String ip)
    {
        this.ip = ip;
    }

    public String getUserAgent()
    {
        return userAgent;
    }

    public void setUserAgent(String userAgent)
    {
        this.userAgent = userAgent;
    }

    public String getDeviceId()
    {
        return deviceId;
    }

    public void setDeviceId(String deviceId)
    {
        this.deviceId = deviceId;
    }

    public String getDetailJson()
    {
        return detailJson;
    }

    public void setDetailJson(String detailJson)
    {
        this.detailJson = detailJson;
    }
}
