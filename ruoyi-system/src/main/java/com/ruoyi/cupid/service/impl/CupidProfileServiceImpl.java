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
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.domain.CupidFavoriteProfile;
import com.ruoyi.cupid.domain.CupidMembershipPlan;
import com.ruoyi.cupid.domain.CupidProfileContact;
import com.ruoyi.cupid.domain.CupidPrivateIntroductionRequest;
import com.ruoyi.cupid.domain.CupidProfile;
import com.ruoyi.cupid.domain.CupidProfileLanguage;
import com.ruoyi.cupid.domain.CupidProfileLocalizedField;
import com.ruoyi.cupid.domain.CupidProfileLocalizedItem;
import com.ruoyi.cupid.domain.CupidProfileOptionExtraText;
import com.ruoyi.cupid.domain.CupidProfileOwnership;
import com.ruoyi.cupid.domain.CupidProfilePhoto;
import com.ruoyi.cupid.domain.CupidProfilePrivacyPreference;
import com.ruoyi.cupid.domain.CupidProfileRelationshipValue;
import com.ruoyi.cupid.domain.CupidProfileVerification;
import com.ruoyi.cupid.domain.CupidProfileVerificationMaterial;
import com.ruoyi.cupid.domain.CupidUserEntitlementBalance;
import com.ruoyi.cupid.domain.CupidUserMembership;
import com.ruoyi.cupid.mapper.CupidMembershipMapper;
import com.ruoyi.cupid.mapper.CupidProfileMapper;
import com.ruoyi.cupid.service.ICupidProfileOptionService;
import com.ruoyi.cupid.service.ICupidProfileService;
import com.ruoyi.cupid.service.ICupidTranslationService;
import com.ruoyi.cupid.service.ICupidUserService;

/**
 * Cupid Match 用户资料服务实现。
 */
@Service
public class CupidProfileServiceImpl implements ICupidProfileService
{
    private static final List<String> DIRECTORY_FIELD_NAMES =
            Arrays.asList("summary");
    private static final List<String> FAMILY_DIRECTORY_FIELD_NAMES =
            Arrays.asList("summary");
    private static final List<String> TAG_FIELD_NAMES = Arrays.asList("tags");
    private static final List<String> VERIFICATION_MATERIAL_TYPES =
            Arrays.asList("identity", "education", "income", "marital");
    private static final Pattern VERIFICATION_MATERIAL_FILE_PATTERN =
            Pattern.compile("(?i)^private://verification/.+\\.(pdf|jpg|jpeg|png|webp)$");

    /** 本地化单值字段：DB snake_case → 前端 camelCase */
    private static final Map<String, String> LOCALIZED_FIELD_MAP = new LinkedHashMap<>();
    static {
        LOCALIZED_FIELD_MAP.put("career_direction", "careerDirection");
        LOCALIZED_FIELD_MAP.put("summary", "summary");
        LOCALIZED_FIELD_MAP.put("profile_name", "profileName");
    }

    /** 枚举字段“其他”补充说明：前端 camelCase -> DB snake_case。 */
    private static final Map<String, String> OPTION_EXTRA_FIELD_MAP = new LinkedHashMap<>();
    static {
        OPTION_EXTRA_FIELD_MAP.put("education", "education");
        OPTION_EXTRA_FIELD_MAP.put("industry", "industry");
        OPTION_EXTRA_FIELD_MAP.put("relationshipGoal", "relationship_goal");
        OPTION_EXTRA_FIELD_MAP.put("residencePlan", "residence_plan");
        OPTION_EXTRA_FIELD_MAP.put("preferredEducation", "preferred_education");
        OPTION_EXTRA_FIELD_MAP.put("familyLife", "family_life");
        OPTION_EXTRA_FIELD_MAP.put("exercise", "exercise");
    }

    /** 本地化列表字段 */
    private static final Map<String, String> LOCALIZED_ITEM_MAP = new LinkedHashMap<>();
    static {
        LOCALIZED_ITEM_MAP.put("deal_breakers", "dealBreakers");
        LOCALIZED_ITEM_MAP.put("personality_traits", "personalityTraits");
        LOCALIZED_ITEM_MAP.put("interests", "interests");
        LOCALIZED_ITEM_MAP.put("tags", "tags");
    }
    private static final int DEFAULT_PAGE_SIZE = 6;
    private static final int MAX_PAGE_SIZE = 100;
    private static final int DEFAULT_FEATURED_SIZE = 3;
    private static final int MAX_FEATURED_SIZE = 12;
    private static final int INTRODUCTION_COOLDOWN_DAYS = 90;

    @Autowired
    private CupidProfileMapper profileMapper;

    @Autowired
    private ICupidUserService userService;

    @Autowired
    private ICupidTranslationService translationService;

    @Autowired
    private ICupidProfileOptionService profileOptionService;

    @Autowired
    private CupidMembershipMapper membershipMapper;

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

    @Override
    public Map<String, Object> getOwnerProfiles(String userId, String locale)
    {
        List<CupidProfileOwnership> ownerships = profileMapper.selectOwnershipsByUserId(userId);
        if (ownerships.isEmpty())
        {
            Map<String, Object> response = new LinkedHashMap<>();
            response.put("profiles", new ArrayList<>());
            return response;
        }

        List<String> profileIds = new ArrayList<>();
        Map<String, CupidProfileOwnership> ownershipByProfileId = new LinkedHashMap<>();
        for (CupidProfileOwnership ownership : ownerships)
        {
            profileIds.add(ownership.getProfileId());
            ownershipByProfileId.put(ownership.getProfileId(), ownership);
        }

        List<CupidProfile> profiles = profileMapper.selectProfilesByIds(profileIds);
        // 过滤已归档
        profiles.removeIf(p -> p.getArchivedAt() != null);
        String loc = normalizeLocale(locale);
        List<String> fieldNames = Arrays.asList("profile_name");
        Map<String, List<CupidProfilePhoto>> photosByProfile = loadPhotosByProfile(profileIds);
        Map<String, Map<String, String>> localizedByProfile =
                loadLocalizedFieldsByProfile(profileIds, fieldNames, loc);

        List<Map<String, Object>> items = new ArrayList<>();
        for (CupidProfile profile : profiles)
        {
            CupidProfileOwnership ownership = ownershipByProfileId.get(profile.getId());
            CupidProfileVerification verification =
                    profileMapper.selectVerificationByProfileId(profile.getId());

            Map<String, Object> item = new LinkedHashMap<>();
            item.put("profileId", profile.getId());
            item.put("profileType", profile.getProfileType());
            Map<String, String> fields =
                    localizedByProfile.getOrDefault(profile.getId(), new LinkedHashMap<>());
            item.put("profileName", fields.getOrDefault("profile_name", ""));
            List<CupidProfilePhoto> photos =
                    photosByProfile.getOrDefault(profile.getId(), new ArrayList<>());
            item.put("avatarUrl", findPrimaryPhotoUrl(photos));
            item.put("age", calculateAge(profile.getBirthYear()));
            item.put("city", profileOptionService.label("city", profile.getCityCode(), loc));
            item.put("relationshipToProfile", ownership.getRelationshipToProfile());
            item.put("permission", ownership.getPermission());
            item.put("ownershipStatus", ownership.getStatus());
            item.put("profileStatus", profile.getProfileStatus());
            item.put("verification", buildVerificationDTO(verification));
            items.add(item);
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("profiles", items);
        return response;
    }

    @Override
    public Map<String, Object> getOwnerProfileDetail(String profileId, String userId, String locale)
    {
        CupidProfileOwnership ownership =
                profileMapper.selectOwnershipByUserAndProfile(userId, profileId);
        if (ownership == null)
        {
            return null;
        }

        CupidProfile profile = profileMapper.selectProfileById(profileId);
        if (profile == null || profile.getArchivedAt() != null)
        {
            return null;
        }

        String loc = normalizeLocale(locale);
        List<CupidProfilePhoto> photos = profileMapper.selectAllPhotosByProfileIds(
                java.util.Collections.singletonList(profileId));
        List<CupidProfileLocalizedField> localizedFields =
                profileMapper.selectAllLocalizedFieldsByProfileId(profileId, loc);
        List<CupidProfileLocalizedItem> localizedItems =
                profileMapper.selectAllLocalizedItemsByProfileId(profileId, loc);
        List<CupidProfileOptionExtraText> optionExtraTexts =
                profileMapper.selectOptionExtraTextsByProfileId(profileId, loc);
        CupidProfileVerification verification =
                profileMapper.selectVerificationByProfileId(profileId);
        CupidProfilePrivacyPreference privacy =
                profileMapper.selectPrivacyPreferenceByProfileId(profileId);
        CupidProfileContact contact = profileMapper.selectContactByProfileId(profileId);

        Map<String, String> fields = resolveEditableLocalizedFields(localizedFields, loc);
        Map<String, List<String>> items = resolveEditableLocalizedItems(localizedItems, loc);
        Map<String, String> extraTexts = resolveEditableOptionExtraTexts(optionExtraTexts, loc);
        List<CupidProfileLanguage> languages = profileMapper.selectLanguagesByProfileId(profileId);
        List<CupidProfileRelationshipValue> relationshipValues =
                profileMapper.selectRelationshipValuesByProfileId(profileId);

        Map<String, Object> detail = new LinkedHashMap<>();
        detail.put("profileId", profile.getId());
        detail.put("profileType", profile.getProfileType());
        detail.put("profileName", value(fields, "profile_name", ""));
        detail.put("avatarUrl", findPrimaryPhotoUrl(photos));
        detail.put("ownership", buildOwnershipDTO(ownership));
        detail.put("verification", buildVerificationDTO(verification));
        detail.put("privacyPreferences", buildPrivacyPreferencesDTO(privacy));
        detail.put("localizedMeta", buildLocalizedMeta(localizedFields, localizedItems, loc));
        detail.put("optionExtraTexts", buildOptionExtraTextDTO(extraTexts));
        detail.put("contact", buildContactDTO(contact));
        detail.put("photos", buildPhotoListWithStatus(photos));

        // 使用可编辑本地化值（raw value，不回落）
        putOptionCodeField(detail, "city", profile.getCityCode());
        putOptionCodeField(detail, "country", profile.getCountryCode());
        putOptionCodeField(detail, "nationality", profile.getNationalityCode());
        putOptionCodeField(detail, "education", profile.getEducationCode());
        putOptionCodeField(detail, "industry", profile.getIndustryCode());
        detail.put("careerDirection", fields.containsKey("career_direction")
                ? value(fields, "career_direction", "") : null);
        putOptionCodeField(detail, "relationshipGoal", profile.getRelationshipGoalCode());
        putOptionCodeField(detail, "residencePlan", profile.getResidencePlanCode());
        putOptionCodeField(detail, "preferredEducation", profile.getPreferredEducationCode());
        putOptionCodeField(detail, "familyLife", profile.getFamilyLifeCode());
        putOptionCodeField(detail, "exercise", profile.getExerciseCode());
        detail.put("summary", value(fields, "summary", ""));
        detail.put("dealBreakers", items.getOrDefault("deal_breakers", new ArrayList<>()));
        detail.put("personalityTraits", items.getOrDefault("personality_traits", new ArrayList<>()));
        detail.put("interests", items.getOrDefault("interests", new ArrayList<>()));
        detail.put("tags", items.getOrDefault("tags", new ArrayList<>()));

        // 资料基础字段
        detail.put("gender", profile.getGender());
        detail.put("birthYear", profile.getBirthYear());
        detail.put("height", profile.getHeight());
        detail.put("profileStatus", profile.getProfileStatus());
        detail.put("lastActiveAt", profile.getLastActiveAt());
        detail.put("familyVisible", profile.isFamilyVisible());
        detail.put("degreeLevel", profile.getDegreeLevel());
        detail.put("maritalStatus", profile.getMaritalStatus());
        detail.put("hasChildren", profile.isHasChildren());
        detail.put("childrenPlan", profile.getChildrenPlan());
        detail.put("acceptsLongDistance", profile.isAcceptsLongDistance());
        detail.put("datingIntentionCode", profile.getDatingIntentionCode());
        detail.put("relocation", profile.getRelocation());
        detail.put("preferredAgeMin", profile.getPreferredAgeMin());
        detail.put("preferredAgeMax", profile.getPreferredAgeMax());
        detail.put("preferredLocation", profile.getPreferredLocation());
        detail.put("smoking", profile.getSmoking());
        detail.put("drinking", profile.getDrinking());
        detail.put("activityLevel", profile.getActivityLevel());
        detail.put("weekendStyle", profile.getWeekendStyle());
        detail.put("pets", profile.getPets());
        detail.put("communicationStyle", profile.getCommunicationStyle());
        detail.put("relationshipValues", toValueCodes(relationshipValues));
        detail.put("languages", toLanguageCodes(languages));
        detail.put("createdAt", profile.getCreatedAt());
        detail.put("updatedAt", profile.getUpdatedAt());
        boolean blankDraft = "draft".equals(profile.getProfileStatus())
                && profile.getBirthYear() == 0
                && profile.getHeight() == 0
                && languages.isEmpty()
                && !StringUtils.hasText(profile.getCityCode())
                && !StringUtils.hasText(profile.getEducationCode())
                && !hasLocalizedValue(profileId, "summary");
        detail.put("isBlankDraft", blankDraft);

        return detail;
    }

    @Override
    public Map<String, Object> getProfileOptions(String locale, String clientVersion)
    {
        return profileOptionService.getProfileOptions(locale, clientVersion);
    }

    @Override
    @Transactional
    public Map<String, Object> saveProfile(String userId, Map<String, Object> payload, String locale)
    {
        return saveProfileWithLocale(userId, payload, locale);
    }

    private Map<String, Object> saveProfileWithLocale(String userId, Map<String, Object> payload, String locale)
    {
        String profileId = (String) payload.get("profileId");
        String profileType = string(payload, "profileType", "self");
        boolean isNew = !StringUtils.hasText(profileId);

        if (isNew)
        {
            if ("self".equals(profileType))
            {
                List<CupidProfileOwnership> existingOwnerships =
                        profileMapper.selectOwnershipsByUserId(userId);
                for (CupidProfileOwnership o : existingOwnerships)
                {
                    CupidProfile existing = profileMapper.selectProfileById(o.getProfileId());
                    if (existing != null && "self".equals(existing.getProfileType())
                            && existing.getArchivedAt() == null)
                    {
                        throw new CupidApiException(HttpStatus.CONFLICT, "duplicate_self");
                    }
                }
            }
            profileId = IdUtils.fastUUID();
        }
        else
        {
            CupidProfileOwnership existing =
                    profileMapper.selectOwnershipByUserAndProfile(userId, profileId);
            if (existing == null)
            {
                throw new CupidApiException(HttpStatus.NOT_FOUND, "profile_not_found");
            }
            if (!"owner".equals(existing.getPermission())
                    && !"manager".equals(existing.getPermission()))
            {
                throw new CupidApiException(HttpStatus.FORBIDDEN, "not_profile_owner");
            }
            CupidProfile target = profileMapper.selectProfileById(profileId);
            if (target != null && target.getArchivedAt() != null)
            {
                throw new CupidApiException(HttpStatus.NOT_FOUND, "profile_not_found");
            }
        }

        Map<String, Object> profileData = (Map) payload.get("profile");
        CupidProfile profile = buildProfileFromPayload(profileId, profileType, profileData, isNew);
        if (isNew)
        {
            profileMapper.insertProfile(profile);
            CupidProfileOwnership ownership = new CupidProfileOwnership();
            ownership.setId(IdUtils.fastUUID());
            ownership.setUserId(userId);
            ownership.setProfileId(profileId);
            Map<String, Object> ownershipData = (Map) payload.get("ownership");
            ownership.setRelationshipToProfile(
                    String.valueOf(ownershipData != null
                            ? ownershipData.getOrDefault("relationshipToProfile",
                                    "self".equals(profileType) ? "self" : "relative")
                            : "self".equals(profileType) ? "self" : "relative"));
            ownership.setPermission("owner");
            profileMapper.insertOwnership(ownership);
            profileMapper.upsertVerification(buildInitialVerification(profileId));
            saveInternalRecord(profileId);
        }
        else
        {
            // 部分更新：仅写入 payload 中存在的字段
            CupidProfile existing = profileMapper.selectProfileById(profileId);
            applyProfileChanges(existing, profileData);
            profileMapper.updateProfile(existing);
        }

        // 本地化单值字段写入（camelCase payload key → snake_case DB field，仅删当前 locale）
        List<String> translatedFields = new ArrayList<>();
        for (String dbField : LOCALIZED_FIELD_MAP.keySet())
        {
            String camelKey = LOCALIZED_FIELD_MAP.get(dbField);
            if (!profileData.containsKey(camelKey))
            {
                continue;
            }
            String value = string(profileData, camelKey, null);
            profileMapper.deleteLocalizedFieldsByProfileAndField(profileId, dbField, locale);
            if (value != null)
            {
                CupidProfileLocalizedField field = new CupidProfileLocalizedField();
                field.setId(IdUtils.fastUUID());
                field.setProfileId(profileId);
                field.setFieldName(dbField);
                field.setLocale(locale);
                field.setValue(value);
                field.setSource("manual");
                field.setProvider("human");
                field.setStatus("ready");
                profileMapper.upsertLocalizedField(field);
                translatedFields.add(dbField);
            }
        }

        // 本地化列表字段写入（仅删当前 locale）
        saveOptionExtraTexts(profileId, profileData, locale);

        for (String dbField : LOCALIZED_ITEM_MAP.keySet())
        {
            String camelKey = LOCALIZED_ITEM_MAP.get(dbField);
            if (!profileData.containsKey(camelKey))
            {
                continue;
            }
            profileMapper.deleteLocalizedItemsByProfileAndField(profileId, dbField, locale);
            List<String> values = (List) profileData.get(camelKey);
            if (values != null)
            {
                for (int i = 0; i < values.size(); i++)
                {
                    CupidProfileLocalizedItem item = new CupidProfileLocalizedItem();
                    item.setId(IdUtils.fastUUID());
                    item.setProfileId(profileId);
                    item.setFieldName(dbField);
                    item.setItemOrder(i);
                    item.setLocale(locale);
                    item.setValue(values.get(i));
                    item.setSource("manual");
                    item.setProvider("human");
                    item.setStatus("ready");
                    profileMapper.insertLocalizedItem(item);
                }
            }
        }

        // 请求其他语言的机器翻译
        if (!translatedFields.isEmpty())
        {
            translationService.prepareTranslations(profileId, locale, new ArrayList<>(translatedFields));
            requestTranslationsAfterCommit(profileId, locale, new ArrayList<>(translatedFields));
        }

        // 语言写入
        List<String> languages = (List) profileData.get("languages");
        if (languages != null)
        {
            profileMapper.deleteLanguagesByProfileId(profileId);
            for (String lang : languages)
            {
                profileMapper.insertLanguage(profileId, lang);
            }
        }

        // 关系价值观写入
        List<String> relationshipValues = (List) profileData.get("relationshipValues");
        if (relationshipValues != null)
        {
            profileMapper.deleteRelationshipValuesByProfileId(profileId);
            for (String v : relationshipValues)
            {
                profileMapper.insertRelationshipValue(profileId, v);
            }
        }

        // 联系方式（更新时保留未传入的字段）
        Map<String, Object> contactData = (Map) payload.get("contact");
        if (contactData != null)
        {
            CupidProfileContact contact = buildContactFromPayload(profileId, contactData, isNew
                    ? null : profileMapper.selectContactByProfileId(profileId));
            profileMapper.upsertContact(contact);
        }

        // 照片对账
        List<Map<String, Object>> photosPayload = (List) payload.get("photos");
        if (photosPayload != null)
        {
            reconcilePhotos(profileId, photosPayload);
        }

        return getOwnerProfileDetail(profileId, userId, locale);
    }

    @Override
    public Map<String, Object> archiveProfile(String profileId, String userId)
    {
        CupidProfileOwnership ownership =
                profileMapper.selectOwnershipByUserAndProfile(userId, profileId);
        if (ownership == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "profile_not_found");
        }
        if (!"owner".equals(ownership.getPermission()))
        {
            throw new CupidApiException(HttpStatus.FORBIDDEN, "not_profile_owner");
        }
        CupidProfile archivedProfile = profileMapper.selectProfileById(profileId);
        if (archivedProfile != null && archivedProfile.getArchivedAt() != null)
        {
            throw new CupidApiException(HttpStatus.CONFLICT, "already_archived");
        }
        int active = profileMapper.countActiveIntroductionsByProfileId(profileId);
        if (active > 0)
        {
            throw new CupidApiException(HttpStatus.CONFLICT, "active_introductions_exist");
        }
        profileMapper.archiveProfile(profileId);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("profileId", profileId);
        result.put("archivedAt", new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(new Date()));
        return result;
    }

    @Override
    @Transactional
    public Map<String, Object> submitProfileForReview(String profileId, String userId, String locale)
    {
        requireOwnedEditableProfile(profileId, userId);
        CupidProfile profile = profileMapper.selectProfileById(profileId);
        String status = profile.getProfileStatus();
        if ("review".equals(status))
        {
            throw new CupidApiException(HttpStatus.CONFLICT, "profile_review_pending");
        }
        if ("open".equals(status))
        {
            throw new CupidApiException(HttpStatus.CONFLICT, "profile_already_open");
        }
        if (!"draft".equals(status) && !"hidden".equals(status))
        {
            throw new CupidApiException(HttpStatus.CONFLICT, "profile_status_not_submittable");
        }
        profileMapper.updateAdminProfileReviewStatus(profileId, "review");
        return getOwnerProfileDetail(profileId, userId, locale);
    }

    @Override
    public Map<String, Object> updatePrivacyPreferences(String profileId, String userId, Map<String, Object> prefs)
    {
        CupidProfileOwnership ownership =
                profileMapper.selectOwnershipByUserAndProfile(userId, profileId);
        if (ownership == null
                || (!"owner".equals(ownership.getPermission())
                && !"manager".equals(ownership.getPermission())))
        {
            throw new CupidApiException(HttpStatus.FORBIDDEN, "not_profile_owner");
        }
        CupidProfilePrivacyPreference record = new CupidProfilePrivacyPreference();
        record.setId(IdUtils.fastUUID());
        record.setProfileId(profileId);
        CupidProfilePrivacyPreference existing =
                profileMapper.selectPrivacyPreferenceByProfileId(profileId);
        record.setHideMaritalStatus(booleanPatch(prefs, "hideMaritalStatus",
                existing != null && existing.isHideMaritalStatus()));
        record.setHideHasChildren(booleanPatch(prefs, "hideHasChildren",
                existing != null && existing.isHideHasChildren()));
        record.setHideChildrenPlan(booleanPatch(prefs, "hideChildrenPlan",
                existing != null && existing.isHideChildrenPlan()));
        record.setHideAcceptsLongDistance(booleanPatch(prefs, "hideAcceptsLongDistance",
                existing != null && existing.isHideAcceptsLongDistance()));
        record.setHideSmoking(booleanPatch(prefs, "hideSmoking",
                existing != null && existing.isHideSmoking()));
        record.setHideDrinking(booleanPatch(prefs, "hideDrinking",
                existing != null && existing.isHideDrinking()));
        profileMapper.upsertPrivacyPreference(record);
        return buildPrivacyPreferencesDTO(
                profileMapper.selectPrivacyPreferenceByProfileId(profileId));
    }

    @Override
    public Map<String, Object> getVerificationMaterials(String profileId, String userId)
    {
        requireOwnedEditableProfile(profileId, userId);
        Map<String, Object> dto = new LinkedHashMap<>();
        dto.put("profileId", profileId);
        dto.put("verification", buildVerificationDTO(profileMapper.selectVerificationByProfileId(profileId)));
        dto.put("materials", buildVerificationMaterialList(
                profileMapper.selectVerificationMaterialsByProfileId(profileId)));
        return dto;
    }

    @Override
    @Transactional
    public Map<String, Object> submitVerificationMaterial(String profileId, String userId, Map<String, Object> payload)
    {
        requireOwnedEditableProfile(profileId, userId);
        String materialType = string(payload, "materialType", "");
        if (!VERIFICATION_MATERIAL_TYPES.contains(materialType))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_verification_material_type");
        }

        CupidProfileVerification verification = profileMapper.selectVerificationByProfileId(profileId);
        if (verification != null)
        {
            String currentStatus = verificationStatusOf(verification, materialType);
            if ("verified".equals(currentStatus))
            {
                throw new CupidApiException(HttpStatus.CONFLICT, "verification_already_verified");
            }
            if ("pending".equals(currentStatus))
            {
                throw new CupidApiException(HttpStatus.CONFLICT, "verification_pending");
            }
        }

        CupidProfileVerificationMaterial material = new CupidProfileVerificationMaterial();
        material.setId(IdUtils.fastUUID());
        material.setProfileId(profileId);
        material.setMaterialType(materialType);
        material.setStatus("pending");
        material.setSubmittedByUserId(userId);
        material.setLegalName(string(payload, "legalName", null));
        material.setDateOfBirth(parseSqlDate(string(payload, "dateOfBirth", null)));
        material.setMaterialName(string(payload, "materialName", null));
        material.setMaterialUrl(string(payload, "materialUrl", null));
        material.setScanStatus("passed");
        material.setScanMessage("upload_signature_checked");
        material.setReviewNote(string(payload, "reviewNote", null));
        validateVerificationMaterialFile(material.getMaterialUrl());

        if ("identity".equals(materialType))
        {
            if (!StringUtils.hasText(material.getLegalName())
                    || material.getDateOfBirth() == null
                    || !StringUtils.hasText(material.getMaterialUrl()))
            {
                throw new CupidApiException(HttpStatus.BAD_REQUEST, "identity_material_required");
            }
        }
        else if (!StringUtils.hasText(material.getMaterialName())
                || !StringUtils.hasText(material.getMaterialUrl()))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "verification_material_required");
        }

        CupidProfileVerification initial = buildInitialVerification(profileId);
        profileMapper.upsertVerification(initial);
        profileMapper.insertVerificationMaterial(material);
        profileMapper.markVerificationMaterialPending(profileId, materialType,
                material.getLegalName(), material.getDateOfBirth(), userId);
        return getVerificationMaterials(profileId, userId);
    }

    private void validateVerificationMaterialFile(String materialUrl)
    {
        if (!StringUtils.hasText(materialUrl))
        {
            return;
        }
        if (!VERIFICATION_MATERIAL_FILE_PATTERN.matcher(materialUrl.trim()).matches())
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_verification_material_file_type");
        }
    }

    private void requireOwnedEditableProfile(String profileId, String userId)
    {
        CupidProfileOwnership ownership =
                profileMapper.selectOwnershipByUserAndProfile(userId, profileId);
        if (ownership == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "profile_not_found");
        }
        if (!"owner".equals(ownership.getPermission())
                && !"manager".equals(ownership.getPermission()))
        {
            throw new CupidApiException(HttpStatus.FORBIDDEN, "not_profile_owner");
        }
        CupidProfile profile = profileMapper.selectProfileById(profileId);
        if (profile == null || profile.getArchivedAt() != null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "profile_not_found");
        }
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
            profile.setCity(profileOptionService.label("city", profile.getCityCode(), locale));
            profile.setEducation(profileOptionService.label("education", profile.getEducationCode(), locale));
            profile.setIndustry(profileOptionService.label("industry", profile.getIndustryCode(), locale));
            profile.setDatingIntentionLabel(deriveDatingIntentionLabel(
                    profile.getDatingIntentionCode(), locale));
            profile.setSummary(fields.getOrDefault("summary", ""));
            profile.setRelationshipGoal(profileOptionService.label(
                    "relationshipGoal", profile.getRelationshipGoalCode(), locale));
            profile.setResidencePlan(profileOptionService.label(
                    "residencePlan", profile.getResidencePlanCode(), locale));
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
        detail.put("city", profileOptionService.label("city", profile.getCityCode(), locale));
        detail.put("country", mask(profileOptionService.label("country", profile.getCountryCode(), locale),
                "country", viewerRole, privacy, selfProfile));
        detail.put("nationality", mask(profileOptionService.label("nationality", profile.getNationalityCode(), locale),
                "nationality", viewerRole, privacy, selfProfile));
        detail.put("languages", mask(toLanguageCodes(languages),
                "languages", viewerRole, privacy, selfProfile));
        detail.put("profileStatus", profile.getProfileStatus());
        detail.put("isVerified", verification != null
                && "verified".equals(verification.getIdentityStatus())
                && "approved".equals(verification.getReviewStatus()));
        detail.put("degreeLevel", profile.getDegreeLevel());
        detail.put("familyVisible", profile.isFamilyVisible());
        detail.put("education", profileOptionService.label("education", profile.getEducationCode(), locale));
        detail.put("industry", mask(profileOptionService.label("industry", profile.getIndustryCode(), locale),
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
        detail.put("relationshipGoal", mask(profileOptionService.label(
                        "relationshipGoal", profile.getRelationshipGoalCode(), locale),
                "relationshipGoal", viewerRole, privacy, selfProfile));
        detail.put("residencePlan", mask(profileOptionService.label(
                        "residencePlan", profile.getResidencePlanCode(), locale),
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
        detail.put("preferredEducation", mask(profileOptionService.label(
                        "preferredEducation", profile.getPreferredEducationCode(), locale),
                "preferredEducation", viewerRole, privacy, selfProfile));
        detail.put("familyLife", mask(profileOptionService.label(
                        "familyLife", profile.getFamilyLifeCode(), locale),
                "familyLife", viewerRole, privacy, selfProfile));
        detail.put("dealBreakers", mask(items.getOrDefault("deal_breakers", new ArrayList<>()),
                "dealBreakers", viewerRole, privacy, selfProfile));
        detail.put("smoking", mask(profile.getSmoking(),
                "smoking", viewerRole, privacy, selfProfile));
        detail.put("drinking", mask(profile.getDrinking(),
                "drinking", viewerRole, privacy, selfProfile));
        detail.put("exercise", mask(profileOptionService.label("exercise", profile.getExerciseCode(), locale),
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
        if (membership == null)
        {
            return VIEWER_FREE_USER;
        }
        CupidMembershipPlan plan = membershipMapper.selectPlanById(membership.getPlanId());
        return plan != null && "premium".equals(plan.getProfileDetailAccessLevel())
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
        CupidUserEntitlementBalance balance = membership == null ? null
                : profileMapper.selectCurrentEntitlementBalance(
                        userId, membership.getId(), "private_introduction");
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
                option.put("label", profileOptionService.label("city", row.getCityCode(), locale));
            }
            else if ("education".equals(field))
            {
                option.put("value", row.getEducationCode());
                option.put("label", profileOptionService.label("education", row.getEducationCode(), locale));
            }
            else if ("gender".equals(field))
            {
                option.put("value", row.getGender());
                option.put("label", deriveGenderLabel(row.getGender(), locale));
            }
            else
            {
                option.put("value", row.getIndustryCode());
                option.put("label", profileOptionService.label("industry", row.getIndustryCode(), locale));
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
            if (!"ready".equals(field.getStatus()) || !StringUtils.hasText(field.getValue()))
            {
                continue;
            }
            selected.putIfAbsent(field.getFieldName(), field.getValue());
        }
        return selected;
    }

    /**
     * 解析 owner 编辑页当前语言槽位，不使用其他语言回退。
     */
    private Map<String, String> resolveEditableLocalizedFields(
            List<CupidProfileLocalizedField> fields, String locale)
    {
        Map<String, String> selected = new LinkedHashMap<>();
        for (CupidProfileLocalizedField field : fields)
        {
            if (locale.equals(field.getLocale()))
            {
                selected.putIfAbsent(field.getFieldName(),
                        field.getValue() == null ? "" : field.getValue());
            }
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
     * 解析 owner 编辑页当前语言列表项，不使用其他语言回退。
     */
    private Map<String, List<String>> resolveEditableLocalizedItems(
            List<CupidProfileLocalizedItem> items, String locale)
    {
        Map<String, Map<Integer, String>> selected = new LinkedHashMap<>();
        for (CupidProfileLocalizedItem item : items)
        {
            if (!locale.equals(item.getLocale()))
            {
                continue;
            }
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

    private void putOptionCodeField(Map<String, Object> detail, String fieldName, String code)
    {
        String safeCode = code == null ? "" : code;
        detail.put(fieldName + "Code", safeCode);
    }

    private Map<String, String> resolveEditableOptionExtraTexts(
            List<CupidProfileOptionExtraText> extraTexts, String locale)
    {
        Map<String, String> selected = new LinkedHashMap<>();
        for (CupidProfileOptionExtraText extraText : extraTexts)
        {
            if (locale.equals(extraText.getLocale()))
            {
                selected.putIfAbsent(extraText.getFieldName(),
                        extraText.getValue() == null ? "" : extraText.getValue());
            }
        }
        return selected;
    }

    private Map<String, Object> buildOptionExtraTextDTO(Map<String, String> extraTexts)
    {
        Map<String, Object> dto = new LinkedHashMap<>();
        for (Map.Entry<String, String> entry : OPTION_EXTRA_FIELD_MAP.entrySet())
        {
            dto.put(entry.getKey(), extraTexts.getOrDefault(entry.getValue(), ""));
        }
        return dto;
    }

    private void saveOptionExtraTexts(String profileId, Map<String, Object> profileData, String locale)
    {
        Object raw = profileData.get("optionExtraTexts");
        Map<String, Object> extraTexts = raw instanceof Map ? (Map<String, Object>) raw : new LinkedHashMap<>();
        for (Map.Entry<String, String> entry : OPTION_EXTRA_FIELD_MAP.entrySet())
        {
            String camelKey = entry.getKey();
            String dbField = entry.getValue();
            if (!profileData.containsKey(camelKey + "Code") && !extraTexts.containsKey(camelKey))
            {
                continue;
            }

            String code = string(profileData, camelKey + "Code", "");
            if (!"other".equals(code))
            {
                profileMapper.deleteOptionExtraText(profileId, dbField, locale);
                continue;
            }

            String value = String.valueOf(extraTexts.getOrDefault(camelKey, "")).trim();
            if (!StringUtils.hasText(value))
            {
                profileMapper.deleteOptionExtraText(profileId, dbField, locale);
                continue;
            }

            CupidProfileOptionExtraText extraText = new CupidProfileOptionExtraText();
            extraText.setId(IdUtils.fastUUID());
            extraText.setProfileId(profileId);
            extraText.setFieldName(dbField);
            extraText.setLocale(locale);
            extraText.setValue(value);
            extraText.setSource("manual");
            extraText.setProvider("human");
            extraText.setStatus("ready");
            profileMapper.upsertOptionExtraText(extraText);
        }
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

    /**
     * 构建认证信息响应
     */
    private Map<String, Object> buildVerificationDTO(CupidProfileVerification verification)
    {
        Map<String, Object> dto = new LinkedHashMap<>();
        if (verification == null)
        {
            dto.put("identityStatus", "unverified");
            dto.put("educationStatus", "unverified");
            dto.put("incomeStatus", "unverified");
            dto.put("maritalStatus", "unverified");
            dto.put("reviewStatus", "unreviewed");
            return dto;
        }
        dto.put("legalName", verification.getLegalName());
        dto.put("dateOfBirth", verification.getDateOfBirth());
        dto.put("identityStatus", verification.getIdentityStatus());
        dto.put("educationStatus", verification.getEducationStatus());
        dto.put("incomeStatus", verification.getIncomeStatus());
        dto.put("maritalStatus", verification.getMaritalVerificationStatus());
        dto.put("reviewStatus", verification.getReviewStatus());
        dto.put("verifiedByUserId", verification.getVerifiedByUserId());
        return dto;
    }

    private List<Map<String, Object>> buildVerificationMaterialList(
            List<CupidProfileVerificationMaterial> materials)
    {
        List<Map<String, Object>> list = new ArrayList<>();
        if (materials == null)
        {
            return list;
        }
        for (CupidProfileVerificationMaterial material : materials)
        {
            Map<String, Object> dto = new LinkedHashMap<>();
            dto.put("materialId", material.getId());
            dto.put("profileId", material.getProfileId());
            dto.put("materialType", material.getMaterialType());
            dto.put("status", material.getStatus());
            dto.put("legalName", material.getLegalName());
            dto.put("dateOfBirth", material.getDateOfBirth());
            dto.put("materialName", material.getMaterialName());
            dto.put("materialUrl", material.getMaterialUrl());
            dto.put("scanStatus", material.getScanStatus());
            dto.put("scanMessage", material.getScanMessage());
            dto.put("scannedAt", material.getScannedAt());
            dto.put("reviewNote", material.getReviewNote());
            dto.put("submittedAt", material.getSubmittedAt());
            dto.put("reviewedAt", material.getReviewedAt());
            dto.put("rejectionReason", material.getRejectionReason());
            list.add(dto);
        }
        return list;
    }

    private String verificationStatusOf(CupidProfileVerification verification, String materialType)
    {
        if ("identity".equals(materialType))
        {
            return verification.getIdentityStatus();
        }
        if ("education".equals(materialType))
        {
            return verification.getEducationStatus();
        }
        if ("income".equals(materialType))
        {
            return verification.getIncomeStatus();
        }
        if ("marital".equals(materialType))
        {
            return verification.getMaritalVerificationStatus();
        }
        return "unverified";
    }

    /**
     * 构建资料归属信息响应
     */
    private Map<String, Object> buildOwnershipDTO(CupidProfileOwnership ownership)
    {
        Map<String, Object> dto = new LinkedHashMap<>();
        dto.put("relationshipToProfile", ownership.getRelationshipToProfile());
        dto.put("permission", ownership.getPermission());
        dto.put("status", ownership.getStatus());
        dto.put("invitedByUserId", ownership.getInvitedByUserId());
        dto.put("acceptedAt", ownership.getAcceptedAt());
        dto.put("revokedAt", ownership.getRevokedAt());
        return dto;
    }

    /**
     * 构建隐私偏好响应
     */
    private Map<String, Object> buildPrivacyPreferencesDTO(CupidProfilePrivacyPreference privacy)
    {
        Map<String, Object> dto = new LinkedHashMap<>();
        if (privacy == null)
        {
            dto.put("hideMaritalStatus", false);
            dto.put("hideHasChildren", false);
            dto.put("hideChildrenPlan", false);
            dto.put("hideAcceptsLongDistance", false);
            dto.put("hideSmoking", false);
            dto.put("hideDrinking", false);
            return dto;
        }
        dto.put("hideMaritalStatus", privacy.isHideMaritalStatus());
        dto.put("hideHasChildren", privacy.isHideHasChildren());
        dto.put("hideChildrenPlan", privacy.isHideChildrenPlan());
        dto.put("hideAcceptsLongDistance", privacy.isHideAcceptsLongDistance());
        dto.put("hideSmoking", privacy.isHideSmoking());
        dto.put("hideDrinking", privacy.isHideDrinking());
        return dto;
    }

    /**
     * 构建可编辑本地化元数据响应（camelCase 字段名 + 单 locale 对象）
     */
    private Map<String, Object> buildLocalizedMeta(
            List<CupidProfileLocalizedField> fields,
            List<CupidProfileLocalizedItem> items, String locale)
    {
        Map<String, Object> meta = new LinkedHashMap<>();
        meta.put("editLocale", locale);
        Map<String, Object> fieldMeta = new LinkedHashMap<>();

        for (CupidProfileLocalizedField field : fields)
        {
            String camelKey = toCamelCase(field.getFieldName());
            if (!field.getLocale().equals(locale))
            {
                continue;
            }
            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("locale", field.getLocale());
            entry.put("source", field.getSource());
            entry.put("provider", field.getProvider());
            entry.put("status", field.getStatus());
            entry.put("updatedAt", field.getUpdatedAt());
            entry.put("hasValue", StringUtils.hasText(field.getValue()));
            fieldMeta.putIfAbsent(camelKey, entry);
        }

        for (CupidProfileLocalizedItem item : items)
        {
            if (!item.getLocale().equals(locale))
            {
                continue;
            }
            String camelKey = toCamelCase(item.getFieldName());
            Map<String, Object> entry = (Map<String, Object>) fieldMeta.get(camelKey);
            if (entry == null)
            {
                entry = new LinkedHashMap<>();
                entry.put("locale", item.getLocale());
                entry.put("source", item.getSource());
                entry.put("provider", item.getProvider());
                entry.put("status", item.getStatus());
                entry.put("updatedAt", item.getUpdatedAt());
                entry.put("hasValue", false);
                fieldMeta.put(camelKey, entry);
            }
            if (StringUtils.hasText(item.getValue()))
            {
                entry.put("hasValue", true);
            }
        }

        // 为所有支持的 field 补充 missing 状态
        String[] allFields = {"profileName", "careerDirection", "summary",
                "dealBreakers", "personalityTraits", "interests", "tags"};
        for (String fn : allFields)
        {
            if (!fieldMeta.containsKey(fn))
            {
                Map<String, Object> missing = new LinkedHashMap<>();
                missing.put("locale", locale);
                missing.put("source", null);
                missing.put("provider", null);
                missing.put("status", "missing");
                missing.put("hasValue", false);
                fieldMeta.put(fn, missing);
            }
        }

        meta.put("fields", fieldMeta);
        return meta;
    }

    /**
     * snake_case 转 camelCase
     */
    private String toCamelCase(String snake)
    {
        StringBuilder sb = new StringBuilder();
        boolean up = false;
        for (int i = 0; i < snake.length(); i++)
        {
            char c = snake.charAt(i);
            if (c == '_')
            {
                up = true;
            }
            else if (up)
            {
                sb.append(Character.toUpperCase(c));
                up = false;
            }
            else
            {
                sb.append(c);
            }
        }
        return sb.toString();
    }

    /**
     * 构建联系方式响应（仅 owner 可见）
     */
    private Map<String, Object> buildContactDTO(CupidProfileContact contact)
    {
        Map<String, Object> dto = new LinkedHashMap<>();
        if (contact == null)
        {
            dto.put("phone", null);
            dto.put("email", null);
            dto.put("wechat", null);
            dto.put("preferredChannel", null);
            dto.put("visibility", "after_introduction");
            return dto;
        }
        dto.put("phone", contact.getPhone());
        dto.put("email", contact.getEmail());
        dto.put("wechat", contact.getWechat());
        dto.put("preferredChannel", contact.getPreferredChannel());
        dto.put("visibility", contact.getVisibility());
        return dto;
    }

    /**
     * 构建照片列表响应（含审核状态）
     */
    private List<Map<String, Object>> buildPhotoListWithStatus(List<CupidProfilePhoto> photos)
    {
        List<Map<String, Object>> result = new ArrayList<>();
        for (CupidProfilePhoto photo : photos)
        {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", photo.getId());
            item.put("url", photo.getUrl());
            item.put("isPrimary", photo.getIsPrimary());
            item.put("sortOrder", photo.getSortOrder());
            item.put("status", photo.getStatus());
            result.add(item);
        }
        return result;
    }

    /**
     * 从保存 payload 构建 CupidProfile
     */
    private CupidProfile buildProfileFromPayload(String profileId, String profileType,
            Map<String, Object> data, boolean isNew)
    {
        CupidProfile p = new CupidProfile();
        p.setId(profileId);
        p.setProfileType(profileType);
        p.setGender(string(data, "gender", "female"));
        p.setBirthYear(intValue(data, "birthYear", 0));
        p.setHeight(intValue(data, "height", 0));
        p.setCityCode(string(data, "cityCode", ""));
        p.setCountryCode(string(data, "countryCode", ""));
        p.setNationalityCode(string(data, "nationalityCode", ""));
        p.setDegreeLevel(string(data, "degreeLevel", "bachelor"));
        p.setEducationCode(string(data, "educationCode", ""));
        p.setIndustryCode(string(data, "industryCode", ""));
        p.setRelationshipGoalCode(string(data, "relationshipGoalCode", ""));
        p.setResidencePlanCode(string(data, "residencePlanCode", ""));
        p.setPreferredEducationCode(string(data, "preferredEducationCode", ""));
        p.setFamilyLifeCode(string(data, "familyLifeCode", ""));
        p.setExerciseCode(string(data, "exerciseCode", ""));
        p.setMaritalStatus(string(data, "maritalStatus", "never_married"));
        p.setHasChildren(Boolean.TRUE.equals(data.get("hasChildren")));
        p.setChildrenPlan(string(data, "childrenPlan", "open_to_discuss"));
        p.setAcceptsLongDistance(Boolean.TRUE.equals(data.get("acceptsLongDistance")));
        p.setDatingIntentionCode(string(data, "datingIntentionCode", "serious"));
        p.setRelocation(string(data, "relocation", "willing"));
        p.setPreferredAgeMin(intValue(data, "preferredAgeMin", 0));
        p.setPreferredAgeMax(intValue(data, "preferredAgeMax", 0));
        p.setPreferredLocation(string(data, "preferredLocation", "local"));
        p.setSmoking(string(data, "smoking", "never"));
        p.setDrinking(string(data, "drinking", "never"));
        p.setActivityLevel(string(data, "activityLevel", "moderate"));
        p.setWeekendStyle(string(data, "weekendStyle", "flexible"));
        p.setPets(string(data, "pets", "none"));
        p.setCommunicationStyle(string(data, "communicationStyle", "balanced"));
        p.setFamilyVisible(Boolean.TRUE.equals(data.get("familyVisible")));
        return p;
    }

    /**
     * 从保存 payload 构建 CupidProfileContact
     */
    private CupidProfileContact buildContactFromPayload(
            String profileId, Map<String, Object> data, CupidProfileContact existing)
    {
        CupidProfileContact c = new CupidProfileContact();
        c.setId(IdUtils.fastUUID());
        c.setProfileId(profileId);
        c.setPhone(string(data, "phone", existing == null ? null : existing.getPhone()));
        c.setEmail(string(data, "email", existing == null ? null : existing.getEmail()));
        c.setWechat(string(data, "wechat", existing == null ? null : existing.getWechat()));
        c.setPreferredChannel(string(data, "preferredChannel",
                existing == null ? null : existing.getPreferredChannel()));
        c.setVisibility(string(data, "visibility",
                existing == null ? "after_introduction" : existing.getVisibility()));
        return c;
    }

    /**
     * 从部分认证 payload 构建认证草稿，未提交字段保留旧值。
     */
    private CupidProfileVerification buildVerificationFromPayload(
            String profileId, Map<String, Object> data, CupidProfileVerification existing)
    {
        CupidProfileVerification v = new CupidProfileVerification();
        v.setId(IdUtils.fastUUID());
        v.setProfileId(profileId);

        String legalName = string(data, "legalName",
                existing == null ? null : existing.getLegalName());
        Date dateOfBirth = existing == null ? null : existing.getDateOfBirth();
        if (data.containsKey("dateOfBirth"))
        {
            dateOfBirth = parseSqlDate(string(data, "dateOfBirth", null));
        }

        boolean identityChanged = existing == null
                || !equalsNullable(legalName, existing.getLegalName())
                || !equalsNullable(dateOfBirth, existing.getDateOfBirth());
        boolean hasIdentityData = StringUtils.hasText(legalName) || dateOfBirth != null;

        v.setLegalName(legalName);
        v.setDateOfBirth(dateOfBirth);
        v.setIdentityStatus(identityChanged
                ? (hasIdentityData ? "pending" : "unverified")
                : existing.getIdentityStatus());
        v.setEducationStatus(existing == null ? "unverified" : existing.getEducationStatus());
        v.setIncomeStatus(existing == null ? "unverified" : existing.getIncomeStatus());
        v.setMaritalVerificationStatus(existing == null
                ? "unverified" : existing.getMaritalVerificationStatus());
        v.setReviewStatus(identityChanged ? "unreviewed" : existing.getReviewStatus());
        if (!identityChanged && existing != null)
        {
            v.setVerifiedAt(existing.getVerifiedAt());
            v.setVerifiedByUserId(existing.getVerifiedByUserId());
        }
        return v;
    }

    /**
     * 新建内部记录
     */
    private void saveInternalRecord(String profileId)
    {
        profileMapper.insertInternalRecord(IdUtils.fastUUID(), profileId);
    }

    /**
     * 仅将 payload 中存在的字段覆盖到已有 profile（部分更新）
     */
    private void applyProfileChanges(CupidProfile target, Map<String, Object> data)
    {
        if (data.containsKey("gender")) target.setGender(string(data, "gender", target.getGender()));
        if (data.containsKey("birthYear")) target.setBirthYear(intValue(data, "birthYear", target.getBirthYear()));
        if (data.containsKey("height")) target.setHeight(intValue(data, "height", target.getHeight()));
        if (data.containsKey("cityCode")) target.setCityCode(string(data, "cityCode", target.getCityCode()));
        if (data.containsKey("countryCode")) target.setCountryCode(string(data, "countryCode", target.getCountryCode()));
        if (data.containsKey("nationalityCode")) target.setNationalityCode(string(data, "nationalityCode", target.getNationalityCode()));
        if (data.containsKey("degreeLevel")) target.setDegreeLevel(string(data, "degreeLevel", target.getDegreeLevel()));
        if (data.containsKey("educationCode")) target.setEducationCode(string(data, "educationCode", target.getEducationCode()));
        if (data.containsKey("industryCode")) target.setIndustryCode(string(data, "industryCode", target.getIndustryCode()));
        if (data.containsKey("relationshipGoalCode")) target.setRelationshipGoalCode(string(data, "relationshipGoalCode", target.getRelationshipGoalCode()));
        if (data.containsKey("residencePlanCode")) target.setResidencePlanCode(string(data, "residencePlanCode", target.getResidencePlanCode()));
        if (data.containsKey("preferredEducationCode")) target.setPreferredEducationCode(string(data, "preferredEducationCode", target.getPreferredEducationCode()));
        if (data.containsKey("familyLifeCode")) target.setFamilyLifeCode(string(data, "familyLifeCode", target.getFamilyLifeCode()));
        if (data.containsKey("exerciseCode")) target.setExerciseCode(string(data, "exerciseCode", target.getExerciseCode()));
        if (data.containsKey("maritalStatus")) target.setMaritalStatus(string(data, "maritalStatus", target.getMaritalStatus()));
        if (data.containsKey("hasChildren")) target.setHasChildren(Boolean.TRUE.equals(data.get("hasChildren")));
        if (data.containsKey("childrenPlan")) target.setChildrenPlan(string(data, "childrenPlan", target.getChildrenPlan()));
        if (data.containsKey("acceptsLongDistance")) target.setAcceptsLongDistance(Boolean.TRUE.equals(data.get("acceptsLongDistance")));
        if (data.containsKey("datingIntentionCode")) target.setDatingIntentionCode(string(data, "datingIntentionCode", target.getDatingIntentionCode()));
        if (data.containsKey("relocation")) target.setRelocation(string(data, "relocation", target.getRelocation()));
        if (data.containsKey("preferredAgeMin")) target.setPreferredAgeMin(intValue(data, "preferredAgeMin", target.getPreferredAgeMin()));
        if (data.containsKey("preferredAgeMax")) target.setPreferredAgeMax(intValue(data, "preferredAgeMax", target.getPreferredAgeMax()));
        if (data.containsKey("preferredLocation")) target.setPreferredLocation(string(data, "preferredLocation", target.getPreferredLocation()));
        if (data.containsKey("smoking")) target.setSmoking(string(data, "smoking", target.getSmoking()));
        if (data.containsKey("drinking")) target.setDrinking(string(data, "drinking", target.getDrinking()));
        if (data.containsKey("activityLevel")) target.setActivityLevel(string(data, "activityLevel", target.getActivityLevel()));
        if (data.containsKey("weekendStyle")) target.setWeekendStyle(string(data, "weekendStyle", target.getWeekendStyle()));
        if (data.containsKey("pets")) target.setPets(string(data, "pets", target.getPets()));
        if (data.containsKey("communicationStyle")) target.setCommunicationStyle(string(data, "communicationStyle", target.getCommunicationStyle()));
        if (data.containsKey("familyVisible")) target.setFamilyVisible(Boolean.TRUE.equals(data.get("familyVisible")));
    }

    /**
     * 照片对账：仅保留 payload 中的照片，删除未包含的已有照片
     */
    private void reconcilePhotos(String profileId, List<Map<String, Object>> photosPayload)
    {
        List<CupidProfilePhoto> existingPhotos =
                profileMapper.selectAllPhotosByProfileIds(
                        java.util.Collections.singletonList(profileId));
        for (Map<String, Object> p : photosPayload)
        {
            String photoId = string(p, "id", null);
            if (booleanValue(p.get("delete")))
            {
                if (StringUtils.hasText(photoId))
                {
                    profileMapper.deletePhotoByProfileAndId(profileId, photoId);
                }
                continue;
            }

            String url = string(p, "url", "").trim();
            if (url.isEmpty())
            {
                continue;
            }
            CupidProfilePhoto existingPhoto = findExistingPhoto(existingPhotos, photoId);
            if (existingPhoto != null)
            {
                boolean urlChanged = !url.equals(existingPhoto.getUrl());
                existingPhoto.setUrl(url);
                existingPhoto.setIsPrimary(booleanValue(p.get("isPrimary")));
                existingPhoto.setSortOrder(intValue(p, "sortOrder", existingPhoto.getSortOrder()));
                if (urlChanged)
                {
                    existingPhoto.setStatus("review");
                }
                profileMapper.upsertPhoto(existingPhoto);
            }
            else
            {
                CupidProfilePhoto photo = new CupidProfilePhoto();
                photo.setId(StringUtils.hasText(photoId) ? photoId : IdUtils.fastUUID());
                photo.setProfileId(profileId);
                photo.setUrl(url);
                photo.setIsPrimary(booleanValue(p.get("isPrimary")));
                photo.setSortOrder(intValue(p, "sortOrder", 0));
                profileMapper.insertPhoto(photo);
            }
        }
    }

    private CupidProfilePhoto findExistingPhoto(List<CupidProfilePhoto> existing, String photoId)
    {
        if (photoId == null)
        {
            return null;
        }
        for (CupidProfilePhoto p : existing)
        {
            if (photoId.equals(p.getId()))
            {
                return p;
            }
        }
        return null;
    }

    /**
     * 检查指定字段在任意 locale 是否有非空值
     */
    private boolean hasLocalizedValue(String profileId, String fieldName)
    {
        for (String loc : new String[]{"zh", "fr", "en"})
        {
            List<CupidProfileLocalizedField> result =
                    profileMapper.selectLocalizedFieldsByProfileIds(
                            java.util.Collections.singletonList(profileId),
                            java.util.Collections.singletonList(fieldName), loc);
            if (!result.isEmpty() && StringUtils.hasText(result.get(0).getValue()))
            {
                return true;
            }
        }
        return false;
    }

    /**
     * 构建初始认证记录
     */
    private CupidProfileVerification buildInitialVerification(String profileId)
    {
        CupidProfileVerification v = new CupidProfileVerification();
        v.setId(IdUtils.fastUUID());
        v.setProfileId(profileId);
        v.setIdentityStatus("unverified");
        v.setEducationStatus("unverified");
        v.setIncomeStatus("unverified");
        v.setMaritalVerificationStatus("unverified");
        v.setReviewStatus("unreviewed");
        return v;
    }

    /**
     * 从 Map 安全取字符串值
     */
    private String string(Map<String, Object> data, String key, String defaultValue)
    {
        Object value = data.get(key);
        return value != null ? String.valueOf(value) : defaultValue;
    }

    /**
     * 从 Map 安全取整数值
     */
    private int intValue(Map<String, Object> data, String key, int defaultValue)
    {
        Object value = data.get(key);
        if (value instanceof Number)
        {
            return ((Number) value).intValue();
        }
        if (value != null)
        {
            try
            {
                return Integer.parseInt(String.valueOf(value));
            }
            catch (NumberFormatException ignored)
            {
            }
        }
        return defaultValue;
    }

    private boolean booleanPatch(Map<String, Object> data, String key, boolean defaultValue)
    {
        return data.containsKey(key) ? booleanValue(data.get(key)) : defaultValue;
    }

    private boolean booleanValue(Object value)
    {
        return Boolean.TRUE.equals(value) || "true".equalsIgnoreCase(String.valueOf(value));
    }

    private Date parseSqlDate(String value)
    {
        if (!StringUtils.hasText(value))
        {
            return null;
        }
        try
        {
            return java.sql.Date.valueOf(value);
        }
        catch (IllegalArgumentException ignored)
        {
            return null;
        }
    }

    private boolean equalsNullable(Object left, Object right)
    {
        return left == null ? right == null : left.equals(right);
    }

    private void requestTranslationsAfterCommit(
            String profileId, String locale, List<String> translatedFields)
    {
        if (TransactionSynchronizationManager.isSynchronizationActive())
        {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization()
            {
                @Override
                public void afterCommit()
                {
                    translationService.requestTranslations(profileId, locale, translatedFields);
                }
            });
            return;
        }
        translationService.requestTranslations(profileId, locale, translatedFields);
    }
}
