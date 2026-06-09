package com.ruoyi.cupid.service.impl;

import static com.ruoyi.cupid.constant.CupidProfileConstants.*;

import java.time.Year;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.cupid.domain.CupidFavoriteProfile;
import com.ruoyi.cupid.domain.CupidPrivateIntroductionRequest;
import com.ruoyi.cupid.domain.CupidProfile;
import com.ruoyi.cupid.domain.CupidProfileLanguage;
import com.ruoyi.cupid.domain.CupidProfileLocalizedField;
import com.ruoyi.cupid.domain.CupidProfileLocalizedItem;
import com.ruoyi.cupid.domain.CupidProfileOwnership;
import com.ruoyi.cupid.domain.CupidProfilePhoto;
import com.ruoyi.cupid.domain.CupidProfilePrivacyPreference;
import com.ruoyi.cupid.domain.CupidProfileRelationshipValue;
import com.ruoyi.cupid.domain.CupidProfileVerification;
import com.ruoyi.cupid.domain.CupidUserEntitlementBalance;
import com.ruoyi.cupid.domain.CupidUserMembership;
import com.ruoyi.cupid.mapper.CupidProfileMapper;
import com.ruoyi.cupid.service.ICupidProfileService;
import com.ruoyi.cupid.service.ICupidUserService;

/**
 * Cupid Match 用户资料服务实现。
 */
@Service
public class CupidProfileServiceImpl implements ICupidProfileService
{
    private static final List<String> DIRECTORY_FIELD_NAMES =
            Arrays.asList("city", "education", "industry", "summary");
    private static final List<String> FAMILY_DIRECTORY_FIELD_NAMES =
            Arrays.asList("city", "education", "industry", "summary", "relationship_goal", "residence_plan");
    private static final List<String> TAG_FIELD_NAMES = Arrays.asList("tags");
    private static final int DEFAULT_PAGE_SIZE = 6;
    private static final int MAX_PAGE_SIZE = 100;
    private static final int DEFAULT_FEATURED_SIZE = 3;
    private static final int MAX_FEATURED_SIZE = 12;
    private static final int INTRODUCTION_COOLDOWN_DAYS = 90;

    @Autowired
    private CupidProfileMapper profileMapper;

    @Autowired
    private ICupidUserService userService;

    @Override
    public Map<String, Object> getSelfProfileDirectory(Map<String, String> params, String userId)
    {
        CupidProfile query = buildSelfQuery(params, userId);
        List<CupidProfile> profiles = profileMapper.selectSelfDirectoryProfiles(query);
        int total = profileMapper.countSelfDirectoryProfiles(query);
        batchEnrichDirectory(profiles, query.getLocale(), true);

        Map<String, Object> response = buildDirectoryResponse(profiles, query, total, true);
        response.put("facets", buildSelfFacets(buildFacetQuery(query)));
        return response;
    }

    @Override
    public Map<String, Object> getFamilyProfileDirectory(Map<String, String> params, String userId)
    {
        CupidProfile query = buildFamilyQuery(params, userId);
        List<CupidProfile> profiles = profileMapper.selectFamilyDirectoryProfiles(query);
        int total = profileMapper.countFamilyDirectoryProfiles(query);
        batchEnrichDirectory(profiles, query.getLocale(), false);

        Map<String, Object> response = buildDirectoryResponse(profiles, query, total, false);
        response.put("facets", buildFamilyFacets(buildFacetQuery(query)));
        return response;
    }

    @Override
    public Map<String, Object> getFeaturedProfiles(Map<String, String> params)
    {
        CupidProfile query = new CupidProfile();
        query.setLocale(normalizeLocale(params.get("lang")));
        query.setPage(1);
        query.setPageSize(clamp(parseInt(params.get("pageSize"), DEFAULT_FEATURED_SIZE), 1, MAX_FEATURED_SIZE));
        query.setOffset(0);
        query.setSort("recentActive");

        List<CupidProfile> profiles = profileMapper.selectFeaturedDirectoryProfiles(query);
        batchEnrichDirectory(profiles, query.getLocale(), true);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("items", buildDirectoryItems(profiles, true));
        return response;
    }

    @Override
    public Map<String, Object> getSelfProfileDetail(String profileId, String userId, String locale)
    {
        CupidProfile profile = profileMapper.selectProfileById(profileId);
        if (!isBusinessActive(profile))
        {
            return null;
        }
        return buildDetail(profile, userId, normalizeLocale(locale), true);
    }

    @Override
    public Map<String, Object> getFamilyProfileDetail(String profileId, String userId, String locale)
    {
        CupidProfile profile = profileMapper.selectProfileById(profileId);
        if (!isBusinessActive(profile) || !profile.isFamilyVisible())
        {
            return null;
        }
        return buildDetail(profile, userId, normalizeLocale(locale), false);
    }

    /**
     * 业务活跃资料判断（未归档且状态为 open 或 review）
     */
    private boolean isBusinessActive(CupidProfile profile)
    {
        return profile != null
                && profile.getArchivedAt() == null
                && (PROFILE_STATUS_OPEN.equals(profile.getProfileStatus())
                        || PROFILE_STATUS_REVIEW.equals(profile.getProfileStatus()));
    }

    /**
     * 构建自助征婚目录查询参数
     */
    private CupidProfile buildSelfQuery(Map<String, String> params, String userId)
    {
        CupidProfile query = buildCommonQuery(params, userId, "recentActive");
        query.setLanguage(params.get("language"));
        query.setVerified(params.get("verified"));
        parseHeightRange(params.get("heightRange"), query);
        return query;
    }

    /**
     * 构建家庭征婚目录查询参数
     */
    private CupidProfile buildFamilyQuery(Map<String, String> params, String userId)
    {
        CupidProfile query = buildCommonQuery(params, userId, "priorityFirst");
        query.setFamilyMode(params.get("familyMode"));
        return query;
    }

    /**
     * 构建目录公共查询参数
     */
    private CupidProfile buildCommonQuery(Map<String, String> params, String userId, String defaultSort)
    {
        CupidProfile query = new CupidProfile();
        query.setGender(params.get("gender"));
        query.setCity(params.get("city"));
        query.setEducation(params.get("education"));
        query.setIndustry(params.get("industry"));
        query.setMaritalStatus(params.get("maritalStatus"));
        query.setDatingIntentionCode(params.get("datingIntentionCode"));
        query.setSort(StringUtils.hasText(params.get("sort")) ? params.get("sort") : defaultSort);
        query.setLocale(normalizeLocale(params.get("lang")));
        query.setViewerUserId(userId);
        query.setHasChildrenFilter(parseBooleanFilter(params.get("hasChildren")));
        query.setAcceptsLongDistanceFilter(parseBooleanFilter(params.get("acceptsLongDistance")));
        parseAgeRange(params.get("ageRange"), query);

        int page = Math.max(1, parseInt(params.get("page"), 1));
        int pageSize = clamp(parseInt(params.get("pageSize"), DEFAULT_PAGE_SIZE), 1, MAX_PAGE_SIZE);
        query.setPage(page);
        query.setPageSize(pageSize);
        query.setOffset((page - 1) * pageSize);
        return query;
    }

    /**
     * 构建筛选面查询参数（仅保留 locale 和 viewer，排除业务筛选条件）
     */
    private CupidProfile buildFacetQuery(CupidProfile source)
    {
        CupidProfile query = new CupidProfile();
        query.setLocale(source.getLocale());
        query.setViewerUserId(source.getViewerUserId());
        return query;
    }

    /**
     * 批量填充目录资料的关联数据（头像、本地化、标签等）
     */
    private void batchEnrichDirectory(List<CupidProfile> profiles, String locale, boolean includeLanguages)
    {
        if (profiles.isEmpty())
        {
            return;
        }

        List<String> profileIds = collectIds(profiles);
        Map<String, List<CupidProfilePhoto>> photosByProfile = loadPhotosByProfile(profileIds);
        Map<String, List<String>> languagesByProfile = includeLanguages
                ? loadLanguagesByProfile(profileIds) : new LinkedHashMap<>();
        List<String> fieldNames = includeLanguages ? DIRECTORY_FIELD_NAMES : FAMILY_DIRECTORY_FIELD_NAMES;
        Map<String, Map<String, String>> localizedByProfile =
                loadLocalizedFieldsByProfile(profileIds, fieldNames, locale);
        Map<String, Map<String, List<String>>> itemsByProfile =
                loadLocalizedItemsByProfile(profileIds, TAG_FIELD_NAMES, locale);

        for (CupidProfile profile : profiles)
        {
            List<CupidProfilePhoto> photos =
                    photosByProfile.getOrDefault(profile.getId(), new ArrayList<>());
            profile.setPhotos(photos);
            profile.setAvatarUrl(findPrimaryPhotoUrl(photos));
            profile.setAge(calculateAge(profile.getBirthYear()));
            if (includeLanguages)
            {
                profile.setLanguages(languagesByProfile.getOrDefault(profile.getId(), new ArrayList<>()));
            }

            Map<String, String> fields =
                    localizedByProfile.getOrDefault(profile.getId(), new LinkedHashMap<>());
            profile.setDisplayName(deriveDisplayName(profile.getId()));
            profile.setCity(fields.getOrDefault("city", profile.getCityCode()));
            profile.setEducation(fields.getOrDefault("education", profile.getEducationCode()));
            profile.setIndustry(fields.getOrDefault("industry", profile.getIndustryCode()));
            profile.setDatingIntentionLabel(deriveDatingIntentionLabel(
                    profile.getDatingIntentionCode(), locale));
            profile.setSummary(fields.getOrDefault("summary", ""));
            profile.setRelationshipGoal(fields.getOrDefault("relationship_goal", ""));
            profile.setResidencePlan(fields.getOrDefault("residence_plan", ""));
            profile.setTags(itemsByProfile
                    .getOrDefault(profile.getId(), new LinkedHashMap<>())
                    .getOrDefault("tags", new ArrayList<>()));
        }
    }

    /**
     * 组装资料详情响应
     */
    private Map<String, Object> buildDetail(
            CupidProfile profile, String userId, String locale, boolean selfProfile)
    {
        String viewerRole = determineViewerRole(userId, profile);

        List<CupidProfilePhoto> photos = profileMapper.selectApprovedPhotosByProfileId(profile.getId());
        List<CupidProfileLanguage> languages = profileMapper.selectLanguagesByProfileId(profile.getId());
        Map<String, String> fields = resolveLocalizedFields(
                profileMapper.selectAllLocalizedFieldsByProfileId(profile.getId(), locale));
        Map<String, List<String>> items = resolveLocalizedItems(
                profileMapper.selectAllLocalizedItemsByProfileId(profile.getId(), locale));
        List<CupidProfileRelationshipValue> relationshipValues =
                profileMapper.selectRelationshipValuesByProfileId(profile.getId());
        CupidProfileVerification verification = profileMapper.selectVerificationByProfileId(profile.getId());
        CupidProfilePrivacyPreference privacy = profileMapper.selectPrivacyPreferenceByProfileId(profile.getId());

        Map<String, Object> privateIntroduction =
                buildPrivateIntroduction(userId, profile.getId(), viewerRole);
        Map<String, Object> detail = new LinkedHashMap<>();
        detail.put("id", profile.getId());
        detail.put("displayName", deriveDisplayName(profile.getId()));
        detail.put("avatarUrl", findPrimaryPhotoUrl(photos));
        detail.put("photos", mask(buildPhotoList(photos),
                "photos", viewerRole, privacy, selfProfile));
        detail.put("photoCount", photos.size());
        detail.put("gender", profile.getGender());
        detail.put("age", selfProfile
                ? mask(calculateAge(profile.getBirthYear()), "age", viewerRole, privacy, true)
                : calculateAge(profile.getBirthYear()));
        detail.put("height", profile.getHeight());
        detail.put("city", value(fields, "city", profile.getCityCode()));
        detail.put("country", mask(value(fields, "country", profile.getCountryCode()),
                "country", viewerRole, privacy, selfProfile));
        detail.put("nationality", mask(value(fields, "nationality", profile.getNationalityCode()),
                "nationality", viewerRole, privacy, selfProfile));
        detail.put("languages", mask(toLanguageCodes(languages),
                "languages", viewerRole, privacy, selfProfile));
        detail.put("profileStatus", profile.getProfileStatus());
        detail.put("isVerified", verification != null
                && "verified".equals(verification.getIdentityStatus())
                && "approved".equals(verification.getReviewStatus()));
        detail.put("degreeLevel", profile.getDegreeLevel());
        detail.put("familyVisible", profile.isFamilyVisible());
        detail.put("education", value(fields, "education", profile.getEducationCode()));
        detail.put("industry", mask(value(fields, "industry", profile.getIndustryCode()),
                "industry", viewerRole, privacy, selfProfile));
        if (fields.containsKey("career_direction"))
        {
            detail.put("careerDirection", mask(fields.get("career_direction"),
                    "careerDirection", viewerRole, privacy, selfProfile));
        }
        detail.put("maritalStatus", mask(profile.getMaritalStatus(),
                "maritalStatus", viewerRole, privacy, selfProfile));
        detail.put("hasChildren", mask(profile.isHasChildren(),
                "hasChildren", viewerRole, privacy, selfProfile));
        detail.put("childrenPlan", mask(profile.getChildrenPlan(),
                "childrenPlan", viewerRole, privacy, selfProfile));
        detail.put("acceptsLongDistance", mask(profile.isAcceptsLongDistance(),
                "acceptsLongDistance", viewerRole, privacy, selfProfile));
        detail.put("datingIntentionCode", profile.getDatingIntentionCode());
        detail.put("datingIntentionLabel",
                deriveDatingIntentionLabel(profile.getDatingIntentionCode(), locale));
        detail.put("relationshipGoal", mask(value(fields, "relationship_goal", ""),
                "relationshipGoal", viewerRole, privacy, selfProfile));
        detail.put("residencePlan", mask(value(fields, "residence_plan", ""),
                "residencePlan", viewerRole, privacy, selfProfile));
        detail.put("relocation", mask(profile.getRelocation(),
                "relocation", viewerRole, privacy, selfProfile));
        detail.put("relationshipValues", mask(toValueCodes(relationshipValues),
                "relationshipValues", viewerRole, privacy, selfProfile));
        detail.put("preferredAgeMin", mask(profile.getPreferredAgeMin(),
                "preferredAgeMin", viewerRole, privacy, selfProfile));
        detail.put("preferredAgeMax", mask(profile.getPreferredAgeMax(),
                "preferredAgeMax", viewerRole, privacy, selfProfile));
        detail.put("preferredLocation", mask(profile.getPreferredLocation(),
                "preferredLocation", viewerRole, privacy, selfProfile));
        detail.put("preferredEducation", mask(value(fields, "preferred_education", ""),
                "preferredEducation", viewerRole, privacy, selfProfile));
        detail.put("familyLife", mask(value(fields, "family_life", ""),
                "familyLife", viewerRole, privacy, selfProfile));
        detail.put("dealBreakers", mask(items.getOrDefault("deal_breakers", new ArrayList<>()),
                "dealBreakers", viewerRole, privacy, selfProfile));
        detail.put("smoking", mask(profile.getSmoking(),
                "smoking", viewerRole, privacy, selfProfile));
        detail.put("drinking", mask(profile.getDrinking(),
                "drinking", viewerRole, privacy, selfProfile));
        detail.put("exercise", mask(value(fields, "exercise", ""),
                "exercise", viewerRole, privacy, selfProfile));
        detail.put("activityLevel", mask(profile.getActivityLevel(),
                "activityLevel", viewerRole, privacy, selfProfile));
        detail.put("weekendStyle", mask(profile.getWeekendStyle(),
                "weekendStyle", viewerRole, privacy, selfProfile));
        detail.put("pets", mask(profile.getPets(),
                "pets", viewerRole, privacy, selfProfile));
        detail.put("personalityTraits", mask(
                items.getOrDefault("personality_traits", new ArrayList<>()),
                "personalityTraits", viewerRole, privacy, selfProfile));
        if (selfProfile)
        {
            detail.put("interests", mask(items.getOrDefault("interests", new ArrayList<>()),
                    "interests", viewerRole, privacy, true));
        }
        detail.put("communicationStyle", mask(profile.getCommunicationStyle(),
                "communicationStyle", viewerRole, privacy, selfProfile));
        detail.put("summary", value(fields, "summary", ""));
        detail.put("tags", items.getOrDefault("tags", new ArrayList<>()));
        detail.put("privateIntroduction", privateIntroduction);
        detail.put("favorite", buildFavorite(userId, profile.getId(), VIEWER_OWNER.equals(viewerRole)));
        detail.put("access", buildAccess(viewerRole, privacy, selfProfile,
                Boolean.TRUE.equals(privateIntroduction.get("canRequest"))));
        return detail;
    }

    /**
     * 判断当前用户对指定资料的查看角色（guest / free_user / member / owner）
     */
    private String determineViewerRole(String userId, CupidProfile profile)
    {
        if (!StringUtils.hasText(userId))
        {
            return VIEWER_GUEST;
        }
        CupidProfileOwnership ownership =
                profileMapper.selectOwnershipByUserAndProfile(userId, profile.getId());
        if (ownership != null)
        {
            return VIEWER_OWNER;
        }
        CupidUserMembership membership = userService.selectActiveMembershipByUserId(userId);
        return membership != null && !"free".equals(membership.getTier())
                ? VIEWER_MEMBER : VIEWER_FREE_USER;
    }

    /**
     * 按查看角色和隐私偏好对受限字段执行遮罩
     */
    private Object mask(Object source, String fieldCode, String viewerRole,
            CupidProfilePrivacyPreference privacy, boolean selfProfile)
    {
        if (VIEWER_OWNER.equals(viewerRole))
        {
            return source;
        }

        boolean loginRequired = selfProfile
                ? SELF_LOGIN_REQUIRED_FIELDS.contains(fieldCode)
                : FAMILY_LOGIN_REQUIRED_FIELDS.contains(fieldCode);
        boolean memberOnly = selfProfile
                ? SELF_MEMBER_ONLY_FIELDS.contains(fieldCode)
                : FAMILY_MEMBER_ONLY_FIELDS.contains(fieldCode);

        if (VIEWER_GUEST.equals(viewerRole) && (loginRequired || memberOnly))
        {
            return FIELD_LOGIN_REQUIRED;
        }
        if (VIEWER_FREE_USER.equals(viewerRole) && memberOnly)
        {
            return FIELD_MEMBER_ONLY;
        }
        return applyPrivacy(source, fieldCode, privacy);
    }

    /**
     * 应用资料隐私偏好隐藏设置
     */
    private Object applyPrivacy(Object source, String fieldCode, CupidProfilePrivacyPreference privacy)
    {
        if (privacy == null)
        {
            return source;
        }
        if ("maritalStatus".equals(fieldCode) && privacy.isHideMaritalStatus()) return FIELD_HIDDEN;
        if ("hasChildren".equals(fieldCode) && privacy.isHideHasChildren()) return FIELD_HIDDEN;
        if ("childrenPlan".equals(fieldCode) && privacy.isHideChildrenPlan()) return FIELD_HIDDEN;
        if ("acceptsLongDistance".equals(fieldCode) && privacy.isHideAcceptsLongDistance()) return FIELD_HIDDEN;
        if ("smoking".equals(fieldCode) && privacy.isHideSmoking()) return FIELD_HIDDEN;
        if ("drinking".equals(fieldCode) && privacy.isHideDrinking()) return FIELD_HIDDEN;
        return source;
    }

    /**
     * 构建资料收藏状态
     */
    private Map<String, Object> buildFavorite(String userId, String profileId, boolean owner)
    {
        Map<String, Object> favorite = new LinkedHashMap<>();
        if (!StringUtils.hasText(userId))
        {
            favorite.put("isFavorite", false);
            favorite.put("canFavorite", false);
            favorite.put("unavailableReason", "visitor");
            return favorite;
        }
        if (owner)
        {
            favorite.put("isFavorite", false);
            favorite.put("canFavorite", false);
            favorite.put("unavailableReason", "own_profile");
            return favorite;
        }

        CupidFavoriteProfile record =
                profileMapper.selectFavoriteByUserAndProfile(userId, profileId);
        favorite.put("isFavorite", record != null);
        if (record != null)
        {
            favorite.put("favoriteId", record.getId());
        }
        favorite.put("canFavorite", true);
        return favorite;
    }

    /**
     * 构建私人介绍申请状态
     */
    private Map<String, Object> buildPrivateIntroduction(
            String userId, String profileId, String viewerRole)
    {
        Map<String, Object> result = new LinkedHashMap<>();
        if (!StringUtils.hasText(userId))
        {
            fillIntroduction(result, "login_required", "guest", 0, 0, false, false);
            return result;
        }

        CupidUserMembership membership = userService.selectActiveMembershipByUserId(userId);
        String tier = membership == null ? "free" : membership.getTier();
        CupidUserEntitlementBalance balance = profileMapper.selectCurrentEntitlementBalance(
                userId, "private_introduction");
        int quotaTotal = balance == null ? 0 : Math.max(0, balance.getQuotaTotal());
        int quotaRemaining = balance == null ? 0 : Math.max(0, balance.getQuotaRemaining());
        boolean owner = VIEWER_OWNER.equals(viewerRole);
        CupidPrivateIntroductionRequest request =
                profileMapper.selectLatestIntroductionRequest(userId, profileId);
        Date now = new Date();

        if (request != null && "requested".equals(request.getStatus())
                && request.getExpiresAt() != null && request.getExpiresAt().before(now))
        {
            fillIntroduction(result, "expired", tier, quotaTotal, quotaRemaining,
                    true, !owner && quotaRemaining > 0);
            return result;
        }
        if (request != null && ("requested".equals(request.getStatus())
                || "accepted".equals(request.getStatus())))
        {
            fillIntroduction(result, request.getStatus(), tier, quotaTotal, quotaRemaining, true, false);
            return result;
        }
        if (request != null && "declined".equals(request.getStatus()))
        {
            Date cooldownUntil = resolveCooldownUntil(request);
            if (cooldownUntil != null && cooldownUntil.after(now))
            {
                fillIntroduction(result, "cooldown", tier, quotaTotal, quotaRemaining, true, false);
                result.put("cooldownUntil", cooldownUntil);
                return result;
            }
        }
        if (quotaRemaining <= 0)
        {
            fillIntroduction(result, "quota_exhausted", tier, quotaTotal, quotaRemaining, false, false);
            return result;
        }

        fillIntroduction(result, "available", tier, quotaTotal, quotaRemaining, false, !owner);
        return result;
    }

    /**
     * 填充私人介绍状态字段
     */
    private void fillIntroduction(Map<String, Object> target, String status, String membership,
            int quotaTotal, int quotaRemaining, boolean alreadyRequested, boolean canRequest)
    {
        target.put("status", status);
        target.put("membership", membership);
        target.put("quotaTotal", quotaTotal);
        target.put("quotaRemaining", quotaRemaining);
        target.put("alreadyRequested", alreadyRequested);
        target.put("canRequest", canRequest);
    }

    /**
     * 计算私人介绍拒绝后的冷静期截止时间
     */
    private Date resolveCooldownUntil(CupidPrivateIntroductionRequest request)
    {
        if (request.getCooldownUntil() != null)
        {
            return request.getCooldownUntil();
        }
        Date base = request.getRespondedAt() != null ? request.getRespondedAt() : request.getRequestedAt();
        if (base == null)
        {
            return null;
        }
        return Date.from(base.toInstant().plus(INTRODUCTION_COOLDOWN_DAYS, ChronoUnit.DAYS));
    }

    /**
     * 构建资料访问权限信息
     */
    private Map<String, Object> buildAccess(String viewerRole, CupidProfilePrivacyPreference privacy,
            boolean selfProfile, boolean canRequestIntroduction)
    {
        Map<String, Object> access = new LinkedHashMap<>();
        access.put("viewerRole", viewerRole);
        access.put("accessLevel", VIEWER_OWNER.equals(viewerRole) ? "owner"
                : VIEWER_MEMBER.equals(viewerRole) ? "premium"
                : VIEWER_FREE_USER.equals(viewerRole) ? "registered" : "visitor");
        boolean full = VIEWER_OWNER.equals(viewerRole) || VIEWER_MEMBER.equals(viewerRole);
        access.put("canViewFullProfile", full);
        access.put("canViewFamilySection", full);
        access.put("canRequestIntroduction", canRequestIntroduction);

        Map<String, String> locks = new LinkedHashMap<>();
        if (VIEWER_GUEST.equals(viewerRole))
        {
            (selfProfile ? SELF_LOGIN_REQUIRED_FIELDS : FAMILY_LOGIN_REQUIRED_FIELDS)
                    .forEach(field -> locks.put(field, "login"));
            (selfProfile ? SELF_MEMBER_ONLY_FIELDS : FAMILY_MEMBER_ONLY_FIELDS)
                    .forEach(field -> locks.put(field, "login"));
        }
        else if (VIEWER_FREE_USER.equals(viewerRole))
        {
            (selfProfile ? SELF_MEMBER_ONLY_FIELDS : FAMILY_MEMBER_ONLY_FIELDS)
                    .forEach(field -> locks.put(field, "member"));
        }
        addPrivacyLocks(locks, privacy);

        List<Map<String, String>> lockedFields = new ArrayList<>();
        locks.forEach((field, reason) -> lockedFields.add(lockField(field, reason)));
        access.put("lockedFields", lockedFields);
        access.put("hiddenFields", privacyHiddenFields(privacy));
        return access;
    }

    /**
     * 将隐私偏好中的隐藏字段加入锁定集合
     */
    private void addPrivacyLocks(Map<String, String> locks, CupidProfilePrivacyPreference privacy)
    {
        if (privacy == null)
        {
            return;
        }
        if (privacy.isHideMaritalStatus()) locks.put("maritalStatus", "hidden");
        if (privacy.isHideHasChildren()) locks.put("hasChildren", "hidden");
        if (privacy.isHideChildrenPlan()) locks.put("childrenPlan", "hidden");
        if (privacy.isHideAcceptsLongDistance()) locks.put("acceptsLongDistance", "hidden");
        if (privacy.isHideSmoking()) locks.put("smoking", "hidden");
        if (privacy.isHideDrinking()) locks.put("drinking", "hidden");
    }

    /**
     * 收集隐私偏好中设为隐藏的字段列表
     */
    private List<String> privacyHiddenFields(CupidProfilePrivacyPreference privacy)
    {
        List<String> fields = new ArrayList<>();
        if (privacy == null) return fields;
        if (privacy.isHideMaritalStatus()) fields.add("maritalStatus");
        if (privacy.isHideHasChildren()) fields.add("hasChildren");
        if (privacy.isHideChildrenPlan()) fields.add("childrenPlan");
        if (privacy.isHideAcceptsLongDistance()) fields.add("acceptsLongDistance");
        if (privacy.isHideSmoking()) fields.add("smoking");
        if (privacy.isHideDrinking()) fields.add("drinking");
        return fields;
    }

    /**
     * 构建字段锁定信息
     */
    private Map<String, String> lockField(String fieldCode, String reason)
    {
        Map<String, String> lock = new LinkedHashMap<>();
        lock.put("fieldCode", fieldCode);
        lock.put("reason", reason);
        return lock;
    }

    /**
     * 构建自助征婚目录筛选面
     */
    private Map<String, Object> buildSelfFacets(CupidProfile query)
    {
        Map<String, Object> facets = new LinkedHashMap<>();
        facets.put("gender", toFacetOptions(
                profileMapper.selectSelfFacetGender(query), "gender", query.getLocale()));
        facets.put("cities", toFacetOptions(
                profileMapper.selectSelfFacetCity(query), "city", query.getLocale()));
        facets.put("education", toFacetOptions(
                profileMapper.selectSelfFacetEducation(query), "education", query.getLocale()));
        facets.put("industries", toFacetOptions(
                profileMapper.selectSelfFacetIndustry(query), "industry", query.getLocale()));
        facets.put("intents", toIntentFacets(
                profileMapper.selectSelfDistinctIntentions(query), query.getLocale()));
        facets.put("languages", profileMapper.selectSelfDistinctLanguages(query));
        return facets;
    }

    /**
     * 构建家庭征婚目录筛选面
     */
    private Map<String, Object> buildFamilyFacets(CupidProfile query)
    {
        Map<String, Object> facets = new LinkedHashMap<>();
        facets.put("gender", toFacetOptions(
                profileMapper.selectFamilyFacetGender(query), "gender", query.getLocale()));
        facets.put("cities", toFacetOptions(
                profileMapper.selectFamilyFacetCity(query), "city", query.getLocale()));
        facets.put("education", toFacetOptions(
                profileMapper.selectFamilyFacetEducation(query), "education", query.getLocale()));
        facets.put("industries", toFacetOptions(
                profileMapper.selectFamilyFacetIndustry(query), "industry", query.getLocale()));
        facets.put("intents", toIntentFacets(
                profileMapper.selectFamilyDistinctIntentions(query), query.getLocale()));
        return facets;
    }

    /**
     * 将筛选面聚合结果转为选项列表
     */
    private List<Map<String, Object>> toFacetOptions(
            List<CupidProfile> rows, String field, String locale)
    {
        List<Map<String, Object>> options = new ArrayList<>();
        for (CupidProfile row : rows)
        {
            Map<String, Object> option = new LinkedHashMap<>();
            if ("city".equals(field))
            {
                option.put("value", row.getCityCode());
                option.put("label", row.getCity());
            }
            else if ("education".equals(field))
            {
                option.put("value", row.getDegreeLevel());
                option.put("label", row.getEducation());
            }
            else if ("gender".equals(field))
            {
                option.put("value", row.getGender());
                option.put("label", deriveGenderLabel(row.getGender(), locale));
            }
            else
            {
                option.put("value", row.getIndustryCode());
                option.put("label", row.getIndustry());
            }
            option.put("count", row.getCount());
            options.add(option);
        }
        return options;
    }

    /**
     * 将交友意向代码列表转为筛选面选项
     */
    private List<Map<String, String>> toIntentFacets(List<String> codes, String locale)
    {
        List<Map<String, String>> result = new ArrayList<>();
        for (String code : codes)
        {
            Map<String, String> item = new LinkedHashMap<>();
            item.put("code", code);
            item.put("label", deriveDatingIntentionLabel(code, locale));
            result.add(item);
        }
        return result;
    }

    /**
     * 构建目录分页响应
     */
    private Map<String, Object> buildDirectoryResponse(
            List<CupidProfile> profiles, CupidProfile query, int total, boolean includeLanguages)
    {
        Map<String, Object> pagination = new LinkedHashMap<>();
        pagination.put("page", query.getPage());
        pagination.put("pageSize", query.getPageSize());
        pagination.put("total", total);
        pagination.put("totalPages", (int) Math.ceil((double) total / query.getPageSize()));

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("items", buildDirectoryItems(profiles, includeLanguages));
        response.put("pagination", pagination);
        return response;
    }

    /**
     * 构建目录资料卡片列表
     */
    private List<Map<String, Object>> buildDirectoryItems(
            List<CupidProfile> profiles, boolean includeLanguages)
    {
        List<Map<String, Object>> items = new ArrayList<>();
        for (CupidProfile profile : profiles)
        {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", profile.getId());
            item.put("displayName", profile.getDisplayName());
            item.put("avatarUrl", profile.getAvatarUrl());
            item.put("gender", profile.getGender());
            item.put("age", profile.getAge());
            item.put("city", profile.getCity());
            item.put("profileStatus", profile.getProfileStatus());
            item.put("education", profile.getEducation());
            item.put("industry", profile.getIndustry());
            item.put("datingIntentionCode", profile.getDatingIntentionCode());
            item.put("datingIntentionLabel", profile.getDatingIntentionLabel());
            item.put("summary", profile.getSummary());
            item.put("tags", profile.getTags());
            if (includeLanguages)
            {
                item.put("languages", profile.getLanguages());
            }
            else
            {
                item.put("maritalStatus", profile.getMaritalStatus());
                item.put("hasChildren", profile.isHasChildren());
                item.put("acceptsLongDistance", profile.isAcceptsLongDistance());
                item.put("relationshipGoal", profile.getRelationshipGoal());
                item.put("residencePlan", profile.getResidencePlan());
            }
            items.add(item);
        }
        return items;
    }

    /**
     * 批量加载资料照片并按 profileId 分组
     */
    private Map<String, List<CupidProfilePhoto>> loadPhotosByProfile(List<String> profileIds)
    {
        Map<String, List<CupidProfilePhoto>> grouped = new LinkedHashMap<>();
        for (CupidProfilePhoto photo : profileMapper.selectApprovedPhotosByProfileIds(profileIds))
        {
            grouped.computeIfAbsent(photo.getProfileId(), key -> new ArrayList<>()).add(photo);
        }
        return grouped;
    }

    /**
     * 批量加载资料语言并按 profileId 分组
     */
    private Map<String, List<String>> loadLanguagesByProfile(List<String> profileIds)
    {
        Map<String, List<String>> grouped = new LinkedHashMap<>();
        for (CupidProfileLanguage language : profileMapper.selectLanguagesByProfileIds(profileIds))
        {
            grouped.computeIfAbsent(language.getProfileId(), key -> new ArrayList<>())
                    .add(language.getLanguageCode());
        }
        return grouped;
    }

    /**
     * 批量加载本地化字段并按 profileId 分组
     */
    private Map<String, Map<String, String>> loadLocalizedFieldsByProfile(
            List<String> profileIds, List<String> fieldNames, String locale)
    {
        Map<String, Map<String, String>> grouped = new LinkedHashMap<>();
        for (CupidProfileLocalizedField field :
                profileMapper.selectLocalizedFieldsByProfileIds(profileIds, fieldNames, locale))
        {
            grouped.computeIfAbsent(field.getProfileId(), key -> new LinkedHashMap<>())
                    .putIfAbsent(field.getFieldName(), field.getValue());
        }
        return grouped;
    }

    /**
     * 批量加载本地化列表项并按 profileId 排序分组
     */
    private Map<String, Map<String, List<String>>> loadLocalizedItemsByProfile(
            List<String> profileIds, List<String> fieldNames, String locale)
    {
        Map<String, Map<String, Map<Integer, String>>> selected = new LinkedHashMap<>();
        for (CupidProfileLocalizedItem item :
                profileMapper.selectLocalizedItemsByProfileIds(profileIds, fieldNames, locale))
        {
            selected.computeIfAbsent(item.getProfileId(), key -> new LinkedHashMap<>())
                    .computeIfAbsent(item.getFieldName(), key -> new TreeMap<>())
                    .putIfAbsent(item.getItemOrder(), item.getValue());
        }

        Map<String, Map<String, List<String>>> grouped = new LinkedHashMap<>();
        selected.forEach((profileId, fields) -> {
            Map<String, List<String>> values = new LinkedHashMap<>();
            fields.forEach((fieldName, items) -> values.put(fieldName, new ArrayList<>(items.values())));
            grouped.put(profileId, values);
        });
        return grouped;
    }

    /**
     * 将本地化字段列表解析为 fieldName 到 value 的映射
     */
    private Map<String, String> resolveLocalizedFields(List<CupidProfileLocalizedField> fields)
    {
        Map<String, String> selected = new LinkedHashMap<>();
        for (CupidProfileLocalizedField field : fields)
        {
            selected.putIfAbsent(field.getFieldName(), field.getValue());
        }
        return selected;
    }

    /**
     * 将本地化列表项解析为 fieldName 到 values 的映射
     */
    private Map<String, List<String>> resolveLocalizedItems(List<CupidProfileLocalizedItem> items)
    {
        Map<String, Map<Integer, String>> selected = new LinkedHashMap<>();
        for (CupidProfileLocalizedItem item : items)
        {
            selected.computeIfAbsent(item.getFieldName(), key -> new TreeMap<>())
                    .putIfAbsent(item.getItemOrder(), item.getValue());
        }
        Map<String, List<String>> result = new LinkedHashMap<>();
        selected.forEach((fieldName, values) ->
                result.put(fieldName, new ArrayList<>(values.values())));
        return result;
    }

    /**
     * 从照片列表中获取主图地址
     */
    private String findPrimaryPhotoUrl(List<CupidProfilePhoto> photos)
    {
        for (CupidProfilePhoto photo : photos)
        {
            if (photo.getIsPrimary())
            {
                return photo.getUrl();
            }
        }
        return photos.isEmpty() ? "" : photos.get(0).getUrl();
    }

    /**
     * 将照片领域对象转为列表
     */
    private List<Map<String, Object>> buildPhotoList(List<CupidProfilePhoto> photos)
    {
        List<Map<String, Object>> result = new ArrayList<>();
        for (CupidProfilePhoto photo : photos)
        {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", photo.getId());
            item.put("url", photo.getUrl());
            item.put("isPrimary", photo.getIsPrimary());
            item.put("sortOrder", photo.getSortOrder());
            result.add(item);
        }
        return result;
    }

    /**
     * 将语言领域对象列表转为语言代码列表
     */
    private List<String> toLanguageCodes(List<CupidProfileLanguage> languages)
    {
        List<String> result = new ArrayList<>();
        for (CupidProfileLanguage language : languages)
        {
            result.add(language.getLanguageCode());
        }
        return result;
    }

    /**
     * 将关系价值观领域对象列表转为值代码列表
     */
    private List<String> toValueCodes(List<CupidProfileRelationshipValue> values)
    {
        List<String> result = new ArrayList<>();
        for (CupidProfileRelationshipValue value : values)
        {
            result.add(value.getValueCode());
        }
        return result;
    }

    /**
     * 收集资料 ID 列表
     */
    private List<String> collectIds(List<CupidProfile> profiles)
    {
        List<String> ids = new ArrayList<>(profiles.size());
        for (CupidProfile profile : profiles)
        {
            ids.add(profile.getId());
        }
        return ids;
    }

    /**
     * 从本地化字段映射中取值，缺失时返回回退值
     */
    private String value(Map<String, String> fields, String fieldName, String fallback)
    {
        return fields.getOrDefault(fieldName, fallback == null ? "" : fallback);
    }

    /**
     * 根据出生年份计算当前年龄
     */
    private int calculateAge(int birthYear)
    {
        return Year.now().getValue() - birthYear;
    }

    /**
     * 标准化 locale 参数（仅允许 zh / fr / en，其余回退 zh）
     */
    private String normalizeLocale(String locale)
    {
        return "fr".equals(locale) || "en".equals(locale) ? locale : "zh";
    }

    /**
     * 解析 yes / no 布尔筛选参数
     */
    private Boolean parseBooleanFilter(String value)
    {
        if ("yes".equalsIgnoreCase(value)) return Boolean.TRUE;
        if ("no".equalsIgnoreCase(value)) return Boolean.FALSE;
        return null;
    }

    /**
     * 解析年龄段筛选参数并设置到查询对象
     */
    private void parseAgeRange(String range, CupidProfile query)
    {
        if ("under25".equals(range)) query.setAgeMax(24);
        else if ("25to29".equals(range)) { query.setAgeMin(25); query.setAgeMax(29); }
        else if ("30to34".equals(range)) { query.setAgeMin(30); query.setAgeMax(34); }
        else if ("35to39".equals(range)) { query.setAgeMin(35); query.setAgeMax(39); }
        else if ("40plus".equals(range)) query.setAgeMin(40);
    }

    /**
     * 解析身高段筛选参数并设置到查询对象
     */
    private void parseHeightRange(String range, CupidProfile query)
    {
        if ("under165".equals(range)) query.setHeightMax(164);
        else if ("165to169".equals(range)) { query.setHeightMin(165); query.setHeightMax(169); }
        else if ("170to174".equals(range)) { query.setHeightMin(170); query.setHeightMax(174); }
        else if ("175to179".equals(range)) { query.setHeightMin(175); query.setHeightMax(179); }
        else if ("180plus".equals(range)) query.setHeightMin(180);
    }

    /**
     * 根据资料 ID 生成匿名展示名（CM-XXXXXX）
     */
    private String deriveDisplayName(String profileId)
    {
        int hash = 0;
        for (int i = 0; i < profileId.length(); i++)
        {
            hash = (hash << 5) - hash + profileId.charAt(i);
        }
        String suffix = Integer.toString(Math.abs(hash), 36).toUpperCase();
        while (suffix.length() < 6)
        {
            suffix = "0" + suffix;
        }
        return "CM-" + suffix.substring(0, 6);
    }

    /**
     * 根据交友意向代码和 locale 派生展示文案
     */
    private String deriveDatingIntentionLabel(String code, String locale)
    {
        if ("fr".equals(locale))
        {
            if ("marriage".equals(code)) return "Projet de mariage";
            if ("exclusive".equals(code)) return "Relation exclusive";
            if ("cross_border".equals(code)) return "Relation internationale";
            return "Relation serieuse";
        }
        if ("en".equals(locale))
        {
            if ("marriage".equals(code)) return "Marriage-minded";
            if ("exclusive".equals(code)) return "Exclusive relationship";
            if ("cross_border".equals(code)) return "Cross-border relationship";
            return "Serious relationship";
        }
        if ("marriage".equals(code)) return "婚姻导向";
        if ("exclusive".equals(code)) return "稳定专属关系";
        if ("cross_border".equals(code)) return "跨境发展";
        return "认真关系";
    }

    /**
     * 根据性别和 locale 派生展示文案
     */
    private String deriveGenderLabel(String gender, String locale)
    {
        if ("fr".equals(locale))
        {
            return "female".equals(gender) ? "Femme" : "Homme";
        }
        if ("en".equals(locale))
        {
            return "female".equals(gender) ? "Female" : "Male";
        }
        return "female".equals(gender) ? "女" : "男";
    }

    /**
     * 安全解析整数字符串
     */
    private int parseInt(String value, int defaultValue)
    {
        if (!StringUtils.hasText(value))
        {
            return defaultValue;
        }
        try
        {
            return Integer.parseInt(value);
        }
        catch (NumberFormatException ignored)
        {
            return defaultValue;
        }
    }

    /**
     * 将值限制在指定范围内
     */
    private int clamp(int value, int minimum, int maximum)
    {
        return Math.max(minimum, Math.min(maximum, value));
    }
}
