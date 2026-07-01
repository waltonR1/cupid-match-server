package com.ruoyi.cupid.service.impl;

import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.constant.CupidSecurityEventConstants;
import com.ruoyi.cupid.domain.CupidAuthIdentity;
import com.ruoyi.cupid.domain.CupidUser;
import com.ruoyi.cupid.domain.CupidUserMembership;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.service.ICupidSecurityEventService;
import com.ruoyi.cupid.service.ICupidUserService;

/**
 * Cupid Match 前台用户服务实现
 */
@Service
public class CupidUserServiceImpl implements ICupidUserService
{
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^\\+?[1-9]\\d{6,14}$");

    @Autowired
    private CupidAuthMapper authMapper;

    @Autowired
    private ICupidSecurityEventService securityEventService;

    @Override
    public CupidAuthIdentity selectIdentityByProviderAndIdentifier(String provider, String identifier)
    {
        return authMapper.selectIdentityByProviderAndIdentifier(provider, identifier);
    }

    @Override
    public CupidUser selectUserById(String userId)
    {
        return authMapper.selectUserById(userId);
    }

    @Override
    public CupidUserMembership selectActiveMembershipByUserId(String userId)
    {
        return authMapper.selectActiveMembershipByUserId(userId);
    }

    @Override
    public void reactivateUser(String userId)
    {
        authMapper.reactivateUser(userId);
    }

    @Override
    @Transactional
    public void createDefaultAccount(String userId, String identityId, String accountName, String preferredLocale,
            String provider, String identifier, String passwordHash)
    {
        authMapper.insertUser(userId, accountName, preferredLocale);
        authMapper.insertIdentity(identityId, userId, provider, identifier, passwordHash);
        authMapper.insertSecuritySettings(IdUtils.fastUUID(), userId);
        authMapper.insertPreferences(IdUtils.fastUUID(), userId, provider);
        if (authMapper.insertFreeMembership(IdUtils.fastUUID(), userId) != 1)
        {
            throw new CupidApiException(HttpStatus.ERROR, "free_membership_plan_not_found");
        }
    }

    @Override
    public void updatePassword(String identityId, String passwordHash)
    {
        authMapper.updatePassword(identityId, passwordHash);
    }

    @Override
    public void updateUser(CupidUser user)
    {
        if (user.getAccountName() != null && user.getAccountName().length() > 30)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_account_name");
        }
        String loc = user.getPreferredLocale();
        if (loc != null && !"zh".equals(loc) && !"fr".equals(loc) && !"en".equals(loc))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_locale");
        }
        authMapper.updateUser(user);
    }

    @Override
    public void deactivateUser(String userId)
    {
        CupidUser user = authMapper.selectUserById(userId);
        if (!"active".equals(user.getStatus()))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "account_not_active");
        }
        authMapper.deactivateUser(userId);
    }

    @Override
    public List<CupidAuthIdentity> getIdentities(String userId)
    {
        return authMapper.selectIdentitiesByUserId(userId);
    }

    @Override
    public String validateIdentityBinding(String userId, String provider, String identifier)
    {
        if (!"email".equals(provider) && !"phone".equals(provider))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_provider");
        }
        String normalized = normalizeIdentifier(provider, identifier);
        if (!StringUtils.hasText(normalized) || !isValidIdentifier(provider, normalized))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_identifier");
        }
        if (authMapper.selectIdentityByProviderAndIdentifier(provider, normalized) != null)
        {
            throw new CupidApiException(HttpStatus.CONFLICT, "identity_already_exists");
        }
        if (!StringUtils.hasText(findReusablePasswordHash(userId)))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "no_login_identity");
        }
        return normalized;
    }

    @Override
    @Transactional
    public CupidAuthIdentity bindIdentity(String userId, String provider, String identifier, String code)
    {
        String normalized = validateIdentityBinding(userId, provider, identifier);
        String passwordHash = findReusablePasswordHash(userId);
        String identityId = IdUtils.fastUUID();
        authMapper.insertIdentity(identityId, userId, provider, normalized, passwordHash);
        CupidAuthIdentity identity = authMapper.selectIdentityById(identityId);
        securityEventService.recordEvent(userId, identityId,
                CupidSecurityEventConstants.EVENT_IDENTITY_BOUND,
                CupidSecurityEventConstants.RESULT_SUCCESS, null, null,
                Map.of("provider", provider,
                        "identityId", identityId,
                        "maskedIdentifier", maskIdentifier(normalized)));
        return identity;
    }

    @Override
    public void unbindIdentity(String userId, String identityId)
    {
        CupidAuthIdentity target = authMapper.selectIdentityById(identityId);
        if (target == null || !userId.equals(target.getUserId()))
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "identity_not_found");
        }
        if (StringUtils.hasText(target.getPasswordHash()) && countPasswordIdentities(userId) <= 1)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "last_identity");
        }
        Map<String, Object> mfa = authMapper.selectSecuritySettingsByUserId(userId);
        if (mfa != null && isTruthy(mfa.get("mfaEnabled"))
                && identityId.equals(mfa.get("mfaIdentityId")))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "mfa_identity");
        }
        String provider = target.getProvider();
        String maskedIdentifier = maskIdentifier(target.getIdentifier());
        authMapper.deleteIdentity(identityId);
        securityEventService.recordEvent(userId, identityId,
                CupidSecurityEventConstants.EVENT_IDENTITY_UNBOUND,
                CupidSecurityEventConstants.RESULT_SUCCESS, null, null,
                Map.of("provider", provider,
                        "identityId", identityId,
                        "maskedIdentifier", maskedIdentifier));
    }

    @Override
    public Map<String, Object> getPreferences(String userId)
    {
        return authMapper.selectPreferencesByUserId(userId);
    }

    @Override
    public void updatePreferences(String userId, Map<String, Object> prefs)
    {
        Map<String, Object> existing = authMapper.selectPreferencesByUserId(userId);
        if (existing == null)
        {
            existing = new java.util.LinkedHashMap<>();
        }
        authMapper.upsertPreferences(
                IdUtils.fastUUID(), userId,
                stringPatch(prefs, existing, "preferredCity", null),
                stringPatch(prefs, existing, "preferredContactChannel", null),
                boolPatch(prefs, existing, "staffContactEnabled", true),
                boolPatch(prefs, existing, "familyAssistEnabled", true),
                boolPatch(prefs, existing, "introductionUpdatesEnabled", true),
                boolPatch(prefs, existing, "eventRemindersEnabled", true),
                boolPatch(prefs, existing, "serviceAnnouncementsEnabled", true),
                boolPatch(prefs, existing, "marketingEmailsEnabled", false),
                boolPatch(prefs, existing, "analyticsConsentEnabled", false));
    }

    @Override
    public Map<String, Object> getMfaStatus(String userId)
    {
        Map<String, Object> settings = authMapper.selectSecuritySettingsByUserId(userId);
        if (settings == null)
        {
            settings = new java.util.LinkedHashMap<>();
            settings.put("mfaEnabled", false);
        }
        List<CupidAuthIdentity> identities = authMapper.selectIdentitiesByUserId(userId);
        java.util.List<Map<String, Object>> availableMethods = new java.util.ArrayList<>();
        for (CupidAuthIdentity id : identities)
        {
            if (id.getVerifiedAt() != null && ("email".equals(id.getProvider()) || "phone".equals(id.getProvider())))
            {
                Map<String, Object> m = new java.util.LinkedHashMap<>();
                m.put("method", id.getProvider());
                m.put("identityId", id.getId());
                m.put("maskedIdentifier", maskIdentifier(id.getIdentifier()));
                m.put("label", id.getProvider().equals("email") ? id.getIdentifier() : maskIdentifier(id.getIdentifier()));
                availableMethods.add(m);
            }
        }
        Map<String, Object> result = new java.util.LinkedHashMap<>();
        result.put("enabled", isTruthy(settings.get("mfaEnabled")));
        result.put("method", settings.get("mfaMethod"));
        result.put("identityId", settings.get("mfaIdentityId"));
        result.put("identityLabel", settings.get("mfaIdentityId") != null
                ? findIdentityLabel(settings.get("mfaIdentityId").toString(), identities) : null);
        result.put("enabledAt", settings.get("mfaEnabledAt"));
        result.put("availableMethods", availableMethods);
        return result;
    }

    @Override
    public CupidAuthIdentity selectIdentityById(String identityId)
    {
        return authMapper.selectIdentityById(identityId);
    }

    @Override
    public CupidAuthIdentity validateMfaEnable(String userId, String method, String identityId)
    {
        Map<String, Object> current = authMapper.selectSecuritySettingsByUserId(userId);
        if (current != null && isTruthy(current.get("mfaEnabled")))
        {
            throw new CupidApiException(HttpStatus.CONFLICT, "already_enabled");
        }
        CupidAuthIdentity identity = authMapper.selectIdentityById(identityId);
        if (identity == null || !userId.equals(identity.getUserId()) || identity.getVerifiedAt() == null
                || !method.equals(identity.getProvider()))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_identity");
        }
        return identity;
    }

    @Override
    public void enableMfa(String userId, String method, String identityId, String code)
    {
        CupidAuthIdentity identity = validateMfaEnable(userId, method, identityId);
        authMapper.updateMfaSettings(userId, true, identity.getProvider(), identityId);
    }

    @Override
    public CupidAuthIdentity validateMfaDisable(String userId)
    {
        Map<String, Object> current = authMapper.selectSecuritySettingsByUserId(userId);
        if (current == null || !isTruthy(current.get("mfaEnabled")))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "mfa_not_enabled");
        }
        String identityId = (String) current.get("mfaIdentityId");
        CupidAuthIdentity identity = authMapper.selectIdentityById(identityId);
        if (identity == null)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "identity_gone");
        }
        return identity;
    }

    @Override
    public void disableMfa(String userId, String code)
    {
        validateMfaDisable(userId);
        authMapper.updateMfaSettings(userId, false, null, null);
    }

    private static String string(Map<String, Object> map, String key, String def)
    {
        Object v = map.get(key);
        return v != null ? String.valueOf(v) : def;
    }

    private static boolean bool(Map<String, Object> map, String key, boolean def)
    {
        Object v = map.get(key);
        if (v instanceof Boolean) return (Boolean) v;
        if (v instanceof String) return "true".equalsIgnoreCase((String) v);
        return def;
    }

    private static String stringPatch(Map<String, Object> patch, Map<String, Object> existing, String key, String def)
    {
        if (patch.containsKey(key))
        {
            Object value = patch.get(key);
            return value == null ? null : String.valueOf(value);
        }
        Object value = existing.get(key);
        return value == null ? def : String.valueOf(value);
    }

    private static boolean boolPatch(Map<String, Object> patch, Map<String, Object> existing, String key, boolean def)
    {
        if (patch.containsKey(key))
        {
            return bool(patch, key, def);
        }
        Object value = existing.get(key);
        if (value instanceof Boolean) return (Boolean) value;
        if (value instanceof Number) return ((Number) value).intValue() != 0;
        if (value instanceof String) return "true".equalsIgnoreCase((String) value);
        return def;
    }

    private static boolean isTruthy(Object value)
    {
        if (value instanceof Boolean) return (Boolean) value;
        if (value instanceof Number) return ((Number) value).intValue() != 0;
        if (value instanceof String) return "true".equalsIgnoreCase((String) value) || "1".equals(value);
        return false;
    }

    private String findReusablePasswordHash(String userId)
    {
        for (CupidAuthIdentity identity : authMapper.selectIdentitiesByUserId(userId))
        {
            if (StringUtils.hasText(identity.getPasswordHash()))
            {
                return identity.getPasswordHash();
            }
        }
        return null;
    }

    private int countPasswordIdentities(String userId)
    {
        int count = 0;
        for (CupidAuthIdentity identity : authMapper.selectIdentitiesByUserId(userId))
        {
            if (StringUtils.hasText(identity.getPasswordHash()))
            {
                count++;
            }
        }
        return count;
    }

    private static String normalizeIdentifier(String provider, String identifier)
    {
        String value = identifier == null ? "" : identifier.trim();
        if ("email".equals(provider))
        {
            return value.toLowerCase();
        }
        if ("phone".equals(provider))
        {
            return value.replace(" ", "").replace("-", "");
        }
        return value;
    }

    private static boolean isValidIdentifier(String provider, String identifier)
    {
        return "email".equals(provider)
                ? EMAIL_PATTERN.matcher(identifier).matches()
                : PHONE_PATTERN.matcher(identifier).matches();
    }

    private static String maskIdentifier(String identifier)
    {
        if (identifier == null) return "";
        if (identifier.contains("@"))
        {
            String[] parts = identifier.split("@");
            String name = parts[0];
            return (name.length() > 2 ? name.charAt(0) + "***" + name.charAt(name.length() - 1) : "***") + "@" + parts[1];
        }
        if (identifier.length() > 4)
        {
            return identifier.substring(0, 2) + "****" + identifier.substring(identifier.length() - 2);
        }
        return "****";
    }

    private static String findIdentityLabel(String identityId, List<CupidAuthIdentity> identities)
    {
        for (CupidAuthIdentity id : identities)
        {
            if (identityId.equals(id.getId()))
            {
                return id.getProvider().equals("email") ? id.getIdentifier() : maskIdentifier(id.getIdentifier());
            }
        }
        return null;
    }
}
