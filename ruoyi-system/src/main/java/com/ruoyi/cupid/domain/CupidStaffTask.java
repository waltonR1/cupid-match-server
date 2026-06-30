package com.ruoyi.cupid.domain;

import com.ruoyi.common.core.domain.BaseEntity;

public class CupidStaffTask extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private String id;

    private Long assigneeSysUserId;

    private String subjectType;

    private String subjectId;

    private String status;

    private String priority;

    private String noteZh;

    private String noteFr;

    private String noteEn;

    public String getId()
    {
        return id;
    }

    public void setId(String id)
    {
        this.id = id;
    }

    public Long getAssigneeSysUserId()
    {
        return assigneeSysUserId;
    }

    public void setAssigneeSysUserId(Long assigneeSysUserId)
    {
        this.assigneeSysUserId = assigneeSysUserId;
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

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getPriority()
    {
        return priority;
    }

    public void setPriority(String priority)
    {
        this.priority = priority;
    }

    public String getNoteZh()
    {
        return noteZh;
    }

    public void setNoteZh(String noteZh)
    {
        this.noteZh = noteZh;
    }

    public String getNoteFr()
    {
        return noteFr;
    }

    public void setNoteFr(String noteFr)
    {
        this.noteFr = noteFr;
    }

    public String getNoteEn()
    {
        return noteEn;
    }

    public void setNoteEn(String noteEn)
    {
        this.noteEn = noteEn;
    }
}
