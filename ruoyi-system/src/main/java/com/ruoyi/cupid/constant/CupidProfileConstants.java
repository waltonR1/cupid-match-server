package com.ruoyi.cupid.constant;

import java.util.Set;

/**
 * Cupid Match 资料查询与访问控制常量。
 */
public final class CupidProfileConstants
{
    public static final String PROFILE_STATUS_OPEN = "open";
    public static final String PROFILE_STATUS_REVIEW = "review";

    public static final String VIEWER_GUEST = "guest";
    public static final String VIEWER_FREE_USER = "free_user";
    public static final String VIEWER_MEMBER = "member";
    public static final String VIEWER_OWNER = "owner";

    public static final String FIELD_LOGIN_REQUIRED = "__LOGIN_REQUIRED__";
    public static final String FIELD_MEMBER_ONLY = "__MEMBER_ONLY__";
    public static final String FIELD_HIDDEN = "__HIDDEN__";

    public static final Set<String> SELF_LOGIN_REQUIRED_FIELDS = Set.of(
            "photos", "country", "nationality", "languages", "careerDirection",
            "maritalStatus", "acceptsLongDistance",
            "relationshipGoal", "relationshipValues", "smoking", "drinking",
            "exercise", "activityLevel", "weekendStyle", "pets", "interests");

    public static final Set<String> SELF_MEMBER_ONLY_FIELDS = Set.of(
            "hasChildren", "childrenPlan", "residencePlan", "relocation",
            "preferredAgeMin", "preferredAgeMax", "preferredLocation",
            "preferredEducation", "familyLife", "dealBreakers",
            "personalityTraits", "communicationStyle");

    public static final Set<String> FAMILY_LOGIN_REQUIRED_FIELDS = Set.of(
            "photos", "country", "nationality", "languages", "careerDirection", "maritalStatus",
            "relationshipGoal", "acceptsLongDistance", "smoking", "drinking",
            "exercise", "activityLevel", "weekendStyle", "pets");

    public static final Set<String> FAMILY_MEMBER_ONLY_FIELDS = Set.of(
            "hasChildren", "childrenPlan", "residencePlan", "relocation",
            "relationshipValues", "preferredAgeMin", "preferredAgeMax",
            "preferredLocation", "preferredEducation", "familyLife",
            "dealBreakers", "personalityTraits", "communicationStyle");

    private CupidProfileConstants()
    {
    }
}
