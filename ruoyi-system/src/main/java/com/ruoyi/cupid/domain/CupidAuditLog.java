package com.ruoyi.cupid.domain;

import com.ruoyi.common.core.domain.BaseEntity;

public class CupidAuditLog extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private String id;

    private String actorType;

    private String actorUserId;

    private String subjectType;

    private String subjectId;

    private String action;

    private String beforeData;

    private String afterData;

    private String reason;

    public String getId()
    {
        return id;
    }

    public void setId(String id)
    {
        this.id = id;
    }

    public String getActorType()
    {
        return actorType;
    }

    public void setActorType(String actorType)
    {
        this.actorType = actorType;
    }

    public String getActorUserId()
    {
        return actorUserId;
    }

    public void setActorUserId(String actorUserId)
    {
        this.actorUserId = actorUserId;
    }

    public String getSubjectType()
    {
        return subjectType;
    }

    public void setSubjectType(String subjectType)
    {
        this.subjectType = subjectType;
    }

    public String getSubjectId()
    {
        return subjectId;
    }

    public void setSubjectId(String subjectId)
    {
        this.subjectId = subjectId;
    }

    public String getAction()
    {
        return action;
    }

    public void setAction(String action)
    {
        this.action = action;
    }

    public String getBeforeData()
    {
        return beforeData;
    }

    public void setBeforeData(String beforeData)
    {
        this.beforeData = beforeData;
    }

    public String getAfterData()
    {
        return afterData;
    }

    public void setAfterData(String afterData)
    {
        this.afterData = afterData;
    }

    public String getReason()
    {
        return reason;
    }

    public void setReason(String reason)
    {
        this.reason = reason;
    }
}
