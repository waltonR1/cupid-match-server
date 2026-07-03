package com.ruoyi.cupid.service.impl;

import java.time.Year;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.domain.CupidFavoriteProfile;
import com.ruoyi.cupid.domain.CupidPrivateIntroductionRequest;
import com.ruoyi.cupid.domain.CupidProfile;
import com.ruoyi.cupid.domain.CupidProfileContact;
import com.ruoyi.cupid.domain.CupidProfileLocalizedField;
import com.ruoyi.cupid.domain.CupidProfileLocalizedItem;
import com.ruoyi.cupid.domain.CupidProfileOwnership;
import com.ruoyi.cupid.domain.CupidProfilePhoto;
import com.ruoyi.cupid.domain.CupidUserEntitlementBalance;
import com.ruoyi.cupid.domain.CupidUserMembership;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.mapper.CupidProfileMapper;
import com.ruoyi.cupid.service.ICupidCommonOptionService;
import com.ruoyi.cupid.service.ICupidRelationshipService;
import com.ruoyi.cupid.service.ICupidRuntimeConfigService;

/**
 * Cupid Match 收藏与私人介绍服务实现。
 */
@Service
public class CupidRelationshipServiceImpl implements ICupidRelationshipService
{
    private static final String INTRODUCTION_ENTITLEMENT = "private_introduction";
    private static final List<String> SUMMARY_FIELDS =
            List.of("profile_name", "summary");

    @Autowired
    private ICupidCommonOptionService commonOptionService;

    @Autowired
    private CupidProfileMapper profileMapper;

    @Autowired
    private CupidAuthMapper authMapper;

    @Autowired
    private ICupidRuntimeConfigService runtimeConfigService;

    @Override
    public Map<String, Object> addFavorite(String userId, String profileId)
    {
        requireAvailableProfile(userId, profileId, null);
        CupidFavoriteProfile existing =
                profileMapper.selectFavoriteByUserAndProfile(userId, profileId);
        if (existing != null)
        {
            return favoriteAction(existing.getId(), true);
        }

        String favoriteId = IdUtils.fastUUID();
        try
        {
            profileMapper.insertFavorite(favoriteId, userId, profileId);
            return favoriteAction(favoriteId, false);
        }
        catch (DuplicateKeyException exception)
        {
            existing = profileMapper.selectFavoriteByUserAndProfile(userId, profileId);
            if (existing == null)
            {
                throw exception;
            }
            return favoriteAction(existing.getId(), true);
        }
    }

    @Override
    public Map<String, Object> removeFavorite(String userId, String profileId)
    {
        return Map.of("removed", profileMapper.deleteFavorite(userId, profileId) > 0);
    }

    @Override
    public List<Map<String, Object>> getFavorites(String userId, String locale)
    {
        List<CupidFavoriteProfile> favorites = profileMapper.selectFavoritesByUserId(userId);
        if (favorites.isEmpty())
        {
            return Collections.emptyList();
        }

        List<String> profileIds = favorites.stream().map(CupidFavoriteProfile::getProfileId).toList();
        Map<String, CupidProfile> profiles = indexProfiles(profileMapper.selectProfilesByIds(profileIds));
        Map<String, String> photos = primaryPhotos(profileMapper.selectApprovedPhotosByProfileIds(profileIds));
        Map<String, Map<String, String>> fields = localizedFields(profileIds, normalizeLocale(locale));
        Map<String, List<String>> tags = localizedItems(profileIds, normalizeLocale(locale));

        List<Map<String, Object>> result = new ArrayList<>();
        for (CupidFavoriteProfile favorite : favorites)
        {
            CupidProfile profile = profiles.get(favorite.getProfileId());
            if (profile == null || profile.getArchivedAt() != null)
            {
                continue;
            }
            Map<String, String> localized = fields.getOrDefault(profile.getId(), Map.of());
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("favoriteId", favorite.getId());
            item.put("profileId", profile.getId());
            item.put("profileType", profile.getProfileType());
            item.put("displayName", deriveDisplayName(profile.getId()));
            item.put("avatarUrl", photos.getOrDefault(profile.getId(), ""));
            item.put("age", Math.max(0, Year.now().getValue() - profile.getBirthYear()));
            String loc = normalizeLocale(locale);
            item.put("city", commonOptionService.label("city", profile.getCityCode(), loc));
            item.put("education", commonOptionService.label("education", profile.getEducationCode(), loc));
            item.put("industry", commonOptionService.label("industry", profile.getIndustryCode(), loc));
            item.put("summary", localized.getOrDefault("summary", ""));
            item.put("tags", tags.getOrDefault(profile.getId(), List.of()).stream().limit(3).toList());
            item.put("createdAt", favorite.getCreatedAt());
            result.add(item);
        }
        return result;
    }

    @Override
    @Transactional
    public Map<String, Object> requestIntroduction(
            String userId, String profileId, String expectedProfileType)
    {
        requireAvailableProfile(userId, profileId, expectedProfileType);
        CupidUserMembership membership = authMapper.selectActiveMembershipByUserId(userId);
        String tier = membership == null ? "free" : membership.getTier();
        if (membership == null)
        {
            return introductionState("quota_exhausted", tier, null, false, false, null);
        }

        CupidPrivateIntroductionRequest latest =
                profileMapper.selectLatestIntroductionRequestForUpdate(userId, profileId);
        Date now = new Date();
        if (latest != null)
        {
            if ("requested".equals(latest.getStatus())
                    && latest.getExpiresAt() != null && latest.getExpiresAt().after(now))
            {
                return introductionState("requested", tier,
                        currentBalance(userId, membership), true, false, null);
            }
            if ("accepted".equals(latest.getStatus()))
            {
                return introductionState("accepted", tier,
                        currentBalance(userId, membership), true, false, null);
            }
            if ("declined".equals(latest.getStatus()))
            {
                Date cooldownUntil = cooldownUntil(latest);
                if (cooldownUntil != null && cooldownUntil.after(now))
                {
                    return introductionState("cooldown", tier,
                            currentBalance(userId, membership), true, false, cooldownUntil);
                }
            }
            if ("requested".equals(latest.getStatus()))
            {
                if (profileMapper.expireIntroductionRequest(latest.getId()) == 1
                        && latest.getEntitlementBalanceId() != null)
                {
                    profileMapper.restoreIntroductionEntitlement(
                            latest.getEntitlementBalanceId());
                }
            }
        }

        CupidUserEntitlementBalance balance = currentBalance(userId, membership);
        if (balance == null || balance.getQuotaRemaining() <= 0)
        {
            return introductionState("quota_exhausted", tier, balance, false, false, null);
        }
        if (profileMapper.consumeIntroductionEntitlement(balance.getId()) != 1)
        {
            return introductionState("quota_exhausted", tier, balance, false, false, null);
        }

        profileMapper.insertIntroductionRequest(
                IdUtils.fastUUID(), userId, profileId, "requested",
                Date.from(now.toInstant().plus(
                        runtimeConfigService.getIntroductionExpiryDays(), ChronoUnit.DAYS)),
                balance.getId());
        balance.setQuotaUsed(balance.getQuotaUsed() + 1);
        balance.setQuotaRemaining(balance.getQuotaRemaining() - 1);
        return introductionState("requested", tier, balance, true, false, null);
    }

    @Override
    public List<Map<String, Object>> getIntroductions(String userId, String locale)
    {
        List<CupidPrivateIntroductionRequest> requests =
                profileMapper.selectIntroductionsByUserId(userId);
        if (requests.isEmpty())
        {
            return Collections.emptyList();
        }
        List<String> profileIds = requests.stream()
                .map(CupidPrivateIntroductionRequest::getTargetProfileId).distinct().toList();
        Map<String, String> photos = primaryPhotos(profileMapper.selectApprovedPhotosByProfileIds(profileIds));
        Date now = new Date();
        List<Map<String, Object>> result = new ArrayList<>();
        for (CupidPrivateIntroductionRequest request : requests)
        {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("requestId", request.getId());
            item.put("targetProfileId", request.getTargetProfileId());
            item.put("targetDisplayName", deriveDisplayName(request.getTargetProfileId()));
            item.put("targetAvatarUrl", photos.getOrDefault(request.getTargetProfileId(), ""));
            item.put("status", effectiveStatus(request, now));
            item.put("requestedAt", request.getRequestedAt());
            putIfNotNull(item, "expiresAt", request.getExpiresAt());
            putIfNotNull(item, "respondedAt", request.getRespondedAt());
            putIfNotNull(item, "cooldownUntil", cooldownUntil(request));
            result.add(item);
        }
        return result;
    }

    @Override
    public Map<String, Object> getIntroductionContact(String userId, String requestId)
    {
        CupidPrivateIntroductionRequest request =
                profileMapper.selectIntroductionRequestById(requestId);
        if (request == null)
        {
            return unavailableContact("not_found");
        }
        if (!userId.equals(request.getRequesterUserId()))
        {
            return unavailableContact("forbidden");
        }
        if (!"accepted".equals(request.getStatus()))
        {
            return unavailableContact("not_accepted");
        }
        CupidProfileContact contact =
                profileMapper.selectContactByProfileId(request.getTargetProfileId());
        if (contact == null)
        {
            return unavailableContact("contact_unavailable");
        }
        if (!"after_introduction".equals(contact.getVisibility()))
        {
            return unavailableContact("visibility_restricted");
        }
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("available", true);
        result.put("phone", contact.getPhone());
        result.put("email", contact.getEmail());
        result.put("wechat", contact.getWechat());
        result.put("preferredChannel", contact.getPreferredChannel());
        result.put("visibility", contact.getVisibility());
        return result;
    }

    @Override
    public int countFavorites(String userId)
    {
        return profileMapper.countFavoritesByUserId(userId);
    }

    private CupidProfile requireAvailableProfile(
            String userId, String profileId, String expectedProfileType)
    {
        CupidProfile profile = profileMapper.selectProfileById(profileId);
        boolean visible = profile != null && profile.getArchivedAt() == null
                && ("open".equals(profile.getProfileStatus())
                || "review".equals(profile.getProfileStatus()));
        if (!visible || (expectedProfileType != null
                && !expectedProfileType.equals(profile.getProfileType()))
                || ("family".equals(expectedProfileType) && !profile.isFamilyVisible()))
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "profile_not_found");
        }
        CupidProfileOwnership ownership =
                profileMapper.selectOwnershipByUserAndProfile(userId, profileId);
        if (ownership != null)
        {
            throw new CupidApiException(HttpStatus.CONFLICT, "own_profile");
        }
        return profile;
    }

    private CupidUserEntitlementBalance currentBalance(
            String userId, CupidUserMembership membership)
    {
        return profileMapper.selectCurrentEntitlementBalance(
                userId, membership.getId(), INTRODUCTION_ENTITLEMENT);
    }

    private Map<String, Object> introductionState(String status, String tier,
            CupidUserEntitlementBalance balance, boolean alreadyRequested,
            boolean canRequest, Date cooldownUntil)
    {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", status);
        result.put("membership", tier);
        result.put("quotaTotal", balance == null ? 0 : Math.max(0, balance.getQuotaTotal()));
        result.put("quotaRemaining", balance == null ? 0 : Math.max(0, balance.getQuotaRemaining()));
        result.put("alreadyRequested", alreadyRequested);
        result.put("canRequest", canRequest);
        putIfNotNull(result, "cooldownUntil", cooldownUntil);
        return result;
    }

    private Date cooldownUntil(CupidPrivateIntroductionRequest request)
    {
        if (!"declined".equals(request.getStatus()))
        {
            return request.getCooldownUntil();
        }
        if (request.getCooldownUntil() != null)
        {
            return request.getCooldownUntil();
        }
        Date base = request.getRespondedAt() != null
                ? request.getRespondedAt() : request.getRequestedAt();
        return base == null ? null
                : Date.from(base.toInstant().plus(
                        runtimeConfigService.getIntroductionCooldownDays(), ChronoUnit.DAYS));
    }

    private String effectiveStatus(CupidPrivateIntroductionRequest request, Date now)
    {
        return "requested".equals(request.getStatus()) && request.getExpiresAt() != null
                && !request.getExpiresAt().after(now) ? "expired" : request.getStatus();
    }

    private Map<String, Object> favoriteAction(String favoriteId, boolean alreadyFavorited)
    {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("favoriteId", favoriteId);
        result.put("alreadyFavorited", alreadyFavorited);
        return result;
    }

    private Map<String, Object> unavailableContact(String reason)
    {
        return Map.of("available", false, "reason", reason);
    }

    private Map<String, CupidProfile> indexProfiles(List<CupidProfile> profiles)
    {
        Map<String, CupidProfile> result = new HashMap<>();
        profiles.forEach(profile -> result.put(profile.getId(), profile));
        return result;
    }

    private Map<String, String> primaryPhotos(List<CupidProfilePhoto> photos)
    {
        Map<String, String> result = new HashMap<>();
        for (CupidProfilePhoto photo : photos)
        {
            if (photo.getIsPrimary() || !result.containsKey(photo.getProfileId()))
            {
                result.put(photo.getProfileId(), photo.getUrl());
            }
        }
        return result;
    }

    private Map<String, Map<String, String>> localizedFields(
            List<String> profileIds, String locale)
    {
        Map<String, Map<String, String>> result = new HashMap<>();
        for (CupidProfileLocalizedField field :
                profileMapper.selectLocalizedFieldsByProfileIds(profileIds, SUMMARY_FIELDS, locale))
        {
            result.computeIfAbsent(field.getProfileId(), key -> new HashMap<>())
                    .putIfAbsent(field.getFieldName(), field.getValue());
        }
        return result;
    }

    private Map<String, List<String>> localizedItems(List<String> profileIds, String locale)
    {
        Map<String, Map<Integer, String>> selected = new HashMap<>();
        for (CupidProfileLocalizedItem item :
                profileMapper.selectLocalizedItemsByProfileIds(profileIds, List.of("tags"), locale))
        {
            selected.computeIfAbsent(item.getProfileId(), key -> new TreeMap<>())
                    .putIfAbsent(item.getItemOrder(), item.getValue());
        }
        Map<String, List<String>> result = new HashMap<>();
        selected.forEach((profileId, values) ->
                result.put(profileId, new ArrayList<>(values.values())));
        return result;
    }

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

    private String normalizeLocale(String locale)
    {
        return "fr".equals(locale) || "en".equals(locale) ? locale : "zh";
    }

    private void putIfNotNull(Map<String, Object> target, String key, Object value)
    {
        if (value != null)
        {
            target.put(key, value);
        }
    }
}
