package com.ruoyi.cupid.domain;

/**
 * Cupid Match 通用选项值 cm_option_values。
 */
public class CupidCommonOptionValue
{
    private String groupKey;

    private String optionValue;

    private String labelZh;

    private String labelFr;

    private String labelEn;

    private Integer requiresExtraText;

    private String status;

    private String groupStatus;

    public String getGroupKey()
    {
        return groupKey;
    }

    public void setGroupKey(String groupKey)
    {
        this.groupKey = groupKey;
    }

    public String getOptionValue()
    {
        return optionValue;
    }

    public void setOptionValue(String optionValue)
    {
        this.optionValue = optionValue;
    }

    public String getLabelZh()
    {
        return labelZh;
    }

    public void setLabelZh(String labelZh)
    {
        this.labelZh = labelZh;
    }

    public String getLabelFr()
    {
        return labelFr;
    }

    public void setLabelFr(String labelFr)
    {
        this.labelFr = labelFr;
    }

    public String getLabelEn()
    {
        return labelEn;
    }

    public void setLabelEn(String labelEn)
    {
        this.labelEn = labelEn;
    }

    public Integer getRequiresExtraText()
    {
        return requiresExtraText;
    }

    public void setRequiresExtraText(Integer requiresExtraText)
    {
        this.requiresExtraText = requiresExtraText;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getGroupStatus()
    {
        return groupStatus;
    }

    public void setGroupStatus(String groupStatus)
    {
        this.groupStatus = groupStatus;
    }
}
