package com.ruoyi.cupid.domain;

/**
 * Cupid Match 资料关系价值观 cm_profile_relationship_values
 */
public class CupidProfileRelationshipValue
{
    private String profileId;
    private String valueCode;

    public String getProfileId()
    {
        return profileId;
    }

    public void setProfileId(String profileId)
    {
        this.profileId = profileId;
    }

    public String getValueCode()
    {
        return valueCode;
    }

    public void setValueCode(String valueCode)
    {
        this.valueCode = valueCode;
    }
}
