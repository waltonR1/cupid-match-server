package com.ruoyi.framework.web.service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.utils.ServletUtils;
import com.ruoyi.cupid.constant.CupidSecurityEventConstants;
import com.ruoyi.cupid.domain.CupidAuthIdentity;
import com.ruoyi.cupid.domain.CupidUser;
import com.ruoyi.cupid.domain.CupidUserMembership;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.service.ICupidRuntimeConfigService;
import com.ruoyi.cupid.service.ICupidLegalService;
import com.ruoyi.cupid.service.ICupidSecurityEventService;
import com.ruoyi.cupid.service.ICupidUserService;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.ip.IpUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import jakarta.servlet.http.HttpServletRequest;

/**
 * Cupid Match 用户认证服务
 */
@Service
public class CupidAuthService
{
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^\\+?[1-9]\\d{6,14}$");
    private static final java.util.Set<String> SENSITIVE_ACTIONS = java.util.Set.of(
            "change_password", "deactivate_account", "export_data", "unbind_identity");
    private static final String LOGIN_FAIL_KEY_PREFIX = "cupid:risk:login-fail:";
    private static final String KNOWN_LOGIN_ENV_KEY_PREFIX = "cupid:risk:known-env:";
    private static final int LOGIN_FAIL_WINDOW_MINUTES = 10;
    private static final int LOGIN_FAIL_THRESHOLD = 5;
    private static final int KNOWN_LOGIN_ENV_DAYS = 90;

    @Autowired
    private ICupidUserService userService;

    @Autowired
    private ICupidLegalService legalService;

    @Autowired
    private CupidTokenService tokenService;

    @Autowired
    private CupidVerificationCodeService verificationCodeService;

    @Autowired
    private ICupidRuntimeConfigService runtimeConfigService;

    @Autowired
    private CupidAuthMapper authMapper;

    @Autowired
    private ICupidSecurityEventService securityEventService;

    @Autowired
    private RedisCache redisCache;

    @Transactional
    public Map<String, Object> login(String identifier, String password)
    {
        if (!StringUtils.hasText(identifier) || !StringUtils.hasText(password))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "missing_credentials");
        }

        String normalizedIdentifier = identifier.contains("@")
                ? normalizeIdentifier("email", identifier)
                : normalizeIdentifier("phone", identifier);
        String provider = identifier.contains("@") ? "email" : "phone";
        CupidAuthIdentity identity = userService.selectIdentityByProviderAndIdentifier(provider, normalizedIdentifier);
        if (identity == null || !SecurityUtils.matchesPassword(password, identity.getPasswordHash()))
        {
            int failCount = increaseLoginFailCount(provider, normalizedIdentifier, resolveIp());
            securityEventService.recordEvent(identity == null ? null : identity.getUserId(),
                    identity == null ? null : identity.getId(),
                    CupidSecurityEventConstants.EVENT_LOGIN_FAILED,
                    CupidSecurityEventConstants.RESULT_FAILED, null, null,
                    Map.of("provider", provider,
                            "maskedIdentifier", maskIdentifier(provider, normalizedIdentifier),
                            "reason", "invalid_credentials",
                            "failCountInWindow", failCount));
            if (failCount == LOGIN_FAIL_THRESHOLD)
            {
                securityEventService.recordEvent(identity == null ? null : identity.getUserId(),
                        identity == null ? null : identity.getId(),
                        CupidSecurityEventConstants.EVENT_RISK_DETECTED,
                        CupidSecurityEventConstants.RESULT_DETECTED, "high", resolveDeviceId(),
                        Map.of("rule", "login_failed_burst",
                                "provider", provider,
                                "maskedIdentifier", maskIdentifier(provider, normalizedIdentifier),
                                "failCountInWindow", failCount,
                                "windowMinutes", LOGIN_FAIL_WINDOW_MINUTES));
            }
            throw new CupidApiException(HttpStatus.UNAUTHORIZED, "invalid_credentials");
        }
        clearLoginFailCount(provider, normalizedIdentifier, resolveIp());

        CupidUser user;
        try
        {
            user = requireActiveUser(identity.getUserId());
        }
        catch (CupidApiException e)
        {
            if (e.getCode() == HttpStatus.FORBIDDEN)
            {
                securityEventService.recordEvent(identity.getUserId(), identity.getId(),
                        CupidSecurityEventConstants.EVENT_LOGIN_FAILED,
                        CupidSecurityEventConstants.RESULT_BLOCKED, null, null,
                        Map.of("provider", provider,
                                "maskedIdentifier", maskIdentifier(provider, normalizedIdentifier),
                                "reason", e.getMessage()));
            }
            throw e;
        }
        if ("deactivated".equals(user.getStatus()))
        {
            userService.reactivateUser(user.getId());
            user.setStatus("active");
        }

        legalService.acceptActiveDocuments(user.getId());

        Map<String, Object> response = new LinkedHashMap<>();
        List<CupidLoginUser> existingSessions = tokenService.selectUserSessions(user.getId());
        response.put("token", tokenService.createToken(identity.getId(), user.getId()));
        response.put("user", toUserDto(user));
        response.put("membership", toMembershipDto(userService.selectActiveMembershipByUserId(user.getId())));
        recordLoginRiskIfNeeded(user.getId(), identity.getId(), provider, normalizedIdentifier, existingSessions);
        securityEventService.recordEvent(user.getId(), identity.getId(),
                CupidSecurityEventConstants.EVENT_LOGIN_SUCCESS,
                CupidSecurityEventConstants.RESULT_SUCCESS, null, null,
                Map.of("provider", provider,
                        "maskedIdentifier", maskIdentifier(provider, normalizedIdentifier)));
        return response;
    }

    @Transactional
    public Map<String, Object> register(Map<String, String> body)
    {
        String path = trimmed(body.get("path"));
        String provider = trimmed(body.get("provider"));
        String identifier = normalizeIdentifier(provider, body.get("identifier"));
        String code = trimmed(body.get("code"));
        String password = body.get("password");
        String accountName = trimmed(body.get("accountName"));
        String preferredLocale = trimmed(body.get("preferredLocale"));

        if (!isRegistrationPath(path) || !isProvider(provider) || !StringUtils.hasText(identifier)
                || !StringUtils.hasText(code) || !StringUtils.hasText(password)
                || !StringUtils.hasText(accountName) || !isLocale(preferredLocale))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "missing_registration_fields");
        }
        validateIdentifier(provider, identifier);
        validatePassword(password);
        if (accountName.length() > 30)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_account_name");
        }
        if (userService.selectIdentityByProviderAndIdentifier(provider, identifier) != null)
        {
            throw new CupidApiException(HttpStatus.CONFLICT, "account_already_exists");
        }
        if (!verificationCodeService.verifyAndConsume(CupidVerificationCodeService.PURPOSE_REGISTRATION,
                provider, identifier, code))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_or_expired_verification_code");
        }

        String userId = IdUtils.fastUUID();
        String identityId = IdUtils.fastUUID();
        userService.createDefaultAccount(userId, identityId, accountName, preferredLocale,
                provider, identifier, SecurityUtils.encryptPassword(password));
        legalService.acceptActiveDocuments(userId);

        CupidUser user = userService.selectUserById(userId);
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("token", tokenService.createToken(identityId, userId));
        response.put("user", toUserDto(user));
        response.put("membership", toMembershipDto(userService.selectActiveMembershipByUserId(userId)));
        return response;
    }

    public Map<String, Object> requestVerificationCode(String purpose, String provider, String rawIdentifier)
    {
        String normalizedProvider = trimmed(provider);
        String identifier = normalizeIdentifier(normalizedProvider, rawIdentifier);
        if (!isProvider(normalizedProvider) || !StringUtils.hasText(identifier))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_verification_request");
        }
        validateIdentifier(normalizedProvider, identifier);

        CupidAuthIdentity existing = userService.selectIdentityByProviderAndIdentifier(
                normalizedProvider, identifier);
        if (CupidVerificationCodeService.PURPOSE_REGISTRATION.equals(purpose) && existing != null)
        {
            throw new CupidApiException(HttpStatus.CONFLICT, "account_already_exists");
        }
        if (CupidVerificationCodeService.PURPOSE_PASSWORD_RESET.equals(purpose) && existing == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "identity_not_found");
        }
        return verificationCodeService.create(purpose, normalizedProvider, identifier);
    }

    @Transactional
    public Map<String, Object> resetPassword(Map<String, String> body)
    {
        String provider = trimmed(body.get("provider"));
        String identifier = normalizeIdentifier(provider, body.get("identifier"));
        String code = trimmed(body.get("code"));
        String newPassword = body.get("newPassword");
        if (!isProvider(provider) || !StringUtils.hasText(identifier)
                || !StringUtils.hasText(code) || !StringUtils.hasText(newPassword))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "missing_password_reset_fields");
        }
        validateIdentifier(provider, identifier);
        validatePassword(newPassword);

        CupidAuthIdentity identity = userService.selectIdentityByProviderAndIdentifier(provider, identifier);
        if (identity == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "identity_not_found");
        }
        if (!verificationCodeService.verifyAndConsume(CupidVerificationCodeService.PURPOSE_PASSWORD_RESET,
                provider, identifier, code))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_or_expired_verification_code");
        }

        userService.updatePassword(identity.getId(), SecurityUtils.encryptPassword(newPassword));
        tokenService.deleteUserTokens(identity.getUserId());
        securityEventService.recordEvent(identity.getUserId(), identity.getId(),
                CupidSecurityEventConstants.EVENT_PASSWORD_RESET,
                CupidSecurityEventConstants.RESULT_SUCCESS, null, null,
                Map.of("provider", provider,
                        "maskedIdentifier", maskIdentifier(provider, identifier)));

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        return result;
    }

    public void logout(String sessionId)
    {
        tokenService.deleteToken(sessionId);
    }

    public Map<String, Object> getAccountMe(String userId)
    {
        CupidUser user = requireActiveUser(userId);
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("user", toUserDto(user));
        return response;
    }

    /**
     * 查询并校验用户状态（停用直接拒绝）
     */
    private CupidUser requireActiveUser(String userId)
    {
        CupidUser user = userService.selectUserById(userId);
        if (user == null)
        {
            throw new CupidApiException(HttpStatus.UNAUTHORIZED, "unauthorized");
        }
        if ("banned".equals(user.getStatus()))
        {
            throw new CupidApiException(HttpStatus.FORBIDDEN, "account_banned");
        }
        if ("suspended".equals(user.getStatus()))
        {
            throw new CupidApiException(HttpStatus.FORBIDDEN, "account_suspended");
        }
        return user;
    }

    /**
     * 用户领域对象转为响应结构
     */
    private Map<String, Object> toUserDto(CupidUser user)
    {
        Map<String, Object> dto = new LinkedHashMap<>();
        dto.put("id", user.getId());
        dto.put("accountName", user.getAccountName());
        dto.put("avatarUrl", user.getAvatarUrl());
        dto.put("preferredLocale", user.getPreferredLocale());
        dto.put("status", user.getStatus());
        return dto;
    }

    /**
     * 会员领域对象转为响应结构
     */
    private Map<String, Object> toMembershipDto(CupidUserMembership membership)
    {
        if (membership == null)
        {
            return null;
        }
        Map<String, Object> dto = new LinkedHashMap<>();
        dto.put("tier", membership.getTier());
        dto.put("status", membership.getStatus());
        return dto;
    }

    /**
     * 标准化登录标识（邮箱转小写、手机号去空格和横线）
     */
    private String normalizeIdentifier(String provider, String identifier)
    {
        String value = trimmed(identifier);
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

    /**
     * 校验登录标识格式
     */
    private void validateIdentifier(String provider, String identifier)
    {
        boolean valid = "email".equals(provider)
                ? EMAIL_PATTERN.matcher(identifier).matches()
                : PHONE_PATTERN.matcher(identifier).matches();
        if (!valid)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_identifier_format");
        }
    }

    /**
     * 校验密码强度
     */
    private void validatePassword(String password)
    {
        if (password.length() < 8 || !password.matches(".*[A-Za-z].*") || !password.matches(".*\\d.*"))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "weak_password");
        }
    }

    /**
     * 获取账户设置聚合（account + identities + password + mfa + preferences）
     */
    public Map<String, Object> getSettings(String userId)
    {
        CupidUser user = userService.selectUserById(userId);
        List<CupidAuthIdentity> identities = userService.getIdentities(userId);
        Map<String, Object> mfa = userService.getMfaStatus(userId);
        Map<String, Object> prefs = userService.getPreferences(userId);

        Map<String, Object> accountInfo = new LinkedHashMap<>();
        accountInfo.put("id", user.getId());
        accountInfo.put("accountName", user.getAccountName());
        accountInfo.put("avatarUrl", user.getAvatarUrl());
        accountInfo.put("preferredLocale", user.getPreferredLocale());
        accountInfo.put("status", user.getStatus());
        accountInfo.put("createdAt", user.getCreatedAt());
        accountInfo.put("updatedAt", user.getUpdatedAt());

        List<Map<String, Object>> identityList = new ArrayList<>();
        for (CupidAuthIdentity id : identities)
        {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", id.getId());
            item.put("provider", id.getProvider());
            item.put("identifier", id.getIdentifier());
            item.put("verifiedAt", id.getVerifiedAt());
            identityList.add(item);
        }

        Map<String, Object> passwordInfo = new LinkedHashMap<>();
        CupidAuthIdentity loginIdentity = findPasswordIdentity(identities);
        passwordInfo.put("isSet", loginIdentity != null && StringUtils.hasText(loginIdentity.getPasswordHash()));
        passwordInfo.put("lastChangedAt", loginIdentity != null ? loginIdentity.getUpdatedAt() : null);
        passwordInfo.put("canReset", loginIdentity != null && StringUtils.hasText(loginIdentity.getPasswordHash()));
        passwordInfo.put("requiresMfa", mfa != null && isTruthy(mfa.get("enabled")));

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("account", accountInfo);
        response.put("identities", identityList);
        response.put("password", passwordInfo);
        response.put("mfa", mfa);
        response.put("preferences", prefs);
        return response;
    }

    /**
     * 修改密码（需验证当前密码）
     */
    @Transactional
    public Map<String, Object> changePassword(String userId, String currentPassword, String newPassword,
            String challengeToken)
    {
        requireChallengeIfMfaEnabled(userId, "change_password", challengeToken);
        List<CupidAuthIdentity> identities = userService.getIdentities(userId);
        CupidAuthIdentity loginIdentity = findPasswordIdentity(identities);
        if (loginIdentity == null
                || !SecurityUtils.matchesPassword(currentPassword, loginIdentity.getPasswordHash()))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "incorrect_current_password");
        }
        validatePassword(newPassword);
        userService.updatePassword(loginIdentity.getId(), SecurityUtils.encryptPassword(newPassword));
        tokenService.deleteUserTokens(userId);
        securityEventService.recordEvent(userId, loginIdentity.getId(),
                CupidSecurityEventConstants.EVENT_PASSWORD_CHANGED,
                CupidSecurityEventConstants.RESULT_SUCCESS, null, null,
                Map.of("provider", loginIdentity.getProvider(),
                        "maskedIdentifier", maskIdentifier(loginIdentity.getProvider(), loginIdentity.getIdentifier()),
                        "challengeVerified", StringUtils.hasText(challengeToken)));
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("passwordUpdatedAt", Instant.now().toString());
        return result;
    }

    /**
     * 请求安全挑战验证码
     */
    public Map<String, Object> requestSecurityChallenge(String userId, String action, String identityId)
    {
        validateSensitiveAction(action);
        Map<String, Object> mfa = userService.getMfaStatus(userId);
        if (!isTruthy(mfa.get("enabled")) || mfa.get("identityId") == null)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "mfa_not_configured");
        }
        if (!StringUtils.hasText(identityId) && isTruthy(mfa.get("enabled"))
                && mfa.get("identityId") != null)
        {
            identityId = mfa.get("identityId").toString();
        }
        List<CupidAuthIdentity> identities = userService.getIdentities(userId);
        CupidAuthIdentity target = null;
        for (CupidAuthIdentity id : identities)
        {
            if (id.getId().equals(identityId)) { target = id; break; }
        }
        if (target == null)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_identity");
        }
        if (isTruthy(mfa.get("enabled")) && !identityId.equals(mfa.get("identityId")))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_mfa_identity");
        }
        Map<String, Object> result = verificationCodeService.create(
                "challenge_" + action, target.getProvider(), target.getIdentifier());
        result.put("maskedIdentifier", resolveMaskedIdentifier(mfa, target.getId()));
        int codeTtlMinutes = runtimeConfigService.getVerificationCodeTtlMinutes();
        authMapper.insertSecurityChallenge(IdUtils.fastUUID(), userId, action, target.getProvider(),
                target.getId(), new java.util.Date(System.currentTimeMillis()
                        + TimeUnit.MINUTES.toMillis(codeTtlMinutes)));
        return result;
    }

    /**
     * 验证安全挑战并返回一次性 token
     */
    public Map<String, Object> verifySecurityChallenge(String userId, String action, String code)
    {
        validateSensitiveAction(action);
        Map<String, Object> mfa = userService.getMfaStatus(userId);
        if (!isTruthy(mfa.get("enabled")))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "mfa_not_configured");
        }
        String mfaId = (String) mfa.get("identityId");
        CupidAuthIdentity mfaIdentity = null;
        for (CupidAuthIdentity id : userService.getIdentities(userId))
        {
            if (id.getId().equals(mfaId)) { mfaIdentity = id; break; }
        }
        if (mfaIdentity == null)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "identity_gone");
        }
        Map<String, Object> pending =
                authMapper.selectPendingSecurityChallenge(userId, action, mfaIdentity.getId());
        if (pending == null)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_or_expired_verification_code");
        }
        if (!verificationCodeService.verifyAndConsume("challenge_" + action,
                mfaIdentity.getProvider(), mfaIdentity.getIdentifier(), code))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_or_expired_verification_code");
        }
        String token = IdUtils.fastUUID();
        java.util.Date expiresAt = new java.util.Date(System.currentTimeMillis() + 5 * 60 * 1000L);
        if (authMapper.verifySecurityChallenge(pending.get("id").toString(), token, expiresAt) != 1)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_or_expired_verification_code");
        }
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("challengeToken", token);
        result.put("expiresAt", expiresAt);
        return result;
    }

    /**
     * 消费安全挑战 token
     */
    public void consumeChallengeToken(String userId, String action, String challengeToken)
    {
        validateSensitiveAction(action);
        if (authMapper.consumeSecurityChallenge(userId, action, challengeToken) != 1)
        {
            authMapper.expireSecurityChallenge(userId, action, challengeToken);
            throw new CupidApiException(HttpStatus.FORBIDDEN, "invalid_challenge");
        }
    }

    public void requireChallengeIfMfaEnabled(String userId, String action, String challengeToken)
    {
        validateSensitiveAction(action);
        Map<String, Object> mfa = userService.getMfaStatus(userId);
        if (isTruthy(mfa.get("enabled")))
        {
            consumeChallengeToken(userId, action, challengeToken);
        }
    }

    /**
     * 停用当前账号
     */
    @Transactional
    public Map<String, Object> deactivateAccount(String userId, String challengeToken)
    {
        requireChallengeIfMfaEnabled(userId, "deactivate_account", challengeToken);
        userService.deactivateUser(userId);
        tokenService.deleteUserTokens(userId);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", "deactivated");
        result.put("deactivatedAt", new java.util.Date());
        return result;
    }

    /**
     * 导出账户数据
     */
    public Map<String, Object> exportAccountData(String userId)
    {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("user", toUserDto(userService.selectUserById(userId)));
        List<Map<String, Object>> identities = new ArrayList<>();
        for (CupidAuthIdentity identity : userService.getIdentities(userId))
        {
            identities.add(toIdentityDto(identity));
        }
        data.put("identities", identities);
        data.put("preferences", userService.getPreferences(userId));
        data.put("mfa", userService.getMfaStatus(userId));
        return data;
    }

    public Map<String, Object> createAccountExport(String userId, String challengeToken)
    {
        requireChallengeIfMfaEnabled(userId, "export_data", challengeToken);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", "generated");
        result.put("downloadUrl", "/account/export/download");
        return result;
    }

    private void recordLoginRiskIfNeeded(String userId, String identityId, String provider, String normalizedIdentifier,
            List<CupidLoginUser> existingSessions)
    {
        String currentDeviceId = resolveDeviceId();
        String currentUserAgent = resolveUserAgent();
        String currentIp = resolveIp();
        String currentFingerprint = buildSessionFingerprint(currentDeviceId, currentUserAgent, currentIp);
        Set<String> activeFingerprints = new HashSet<>();
        for (CupidLoginUser session : existingSessions)
        {
            activeFingerprints.add(buildSessionFingerprint(session.getDeviceId(), session.getUserAgent(), session.getIp()));
        }

        String knownEnvironmentKey = KNOWN_LOGIN_ENV_KEY_PREFIX + userId;
        Set<String> knownFingerprints = redisCache.getCacheSet(knownEnvironmentKey);
        boolean hasKnownEnvironment = knownFingerprints != null && !knownFingerprints.isEmpty();
        boolean newEnvironment = hasKnownEnvironment && !knownFingerprints.contains(currentFingerprint);
        long otherEnvironmentCount = activeFingerprints.stream()
                .filter(item -> !item.equals(currentFingerprint))
                .count();
        boolean multipleActiveEnvironments = otherEnvironmentCount > 0;

        redisCache.setCacheSet(knownEnvironmentKey, Set.of(currentFingerprint));
        redisCache.expire(knownEnvironmentKey, KNOWN_LOGIN_ENV_DAYS, TimeUnit.DAYS);

        if (!newEnvironment && !multipleActiveEnvironments)
        {
            return;
        }

        Map<String, Object> detail = new LinkedHashMap<>();
        detail.put("rule", newEnvironment ? "new_login_environment" : "multi_active_login_environment");
        detail.put("provider", provider);
        detail.put("maskedIdentifier", maskIdentifier(provider, normalizedIdentifier));
        detail.put("activeSessionCount", existingSessions.size() + 1);
        detail.put("otherEnvironmentCount", otherEnvironmentCount);
        detail.put("newEnvironment", newEnvironment);
        detail.put("multipleActiveEnvironments", multipleActiveEnvironments);
        detail.put("currentIp", currentIp);
        detail.put("currentDeviceId", currentDeviceId);
        detail.put("currentUserAgent", currentUserAgent);
        securityEventService.recordEvent(userId, identityId,
                CupidSecurityEventConstants.EVENT_RISK_DETECTED,
                CupidSecurityEventConstants.RESULT_DETECTED,
                newEnvironment ? "medium" : "low",
                currentDeviceId, detail);
    }

    private int increaseLoginFailCount(String provider, String identifier, String ip)
    {
        String key = buildLoginFailKey(provider, identifier, ip);
        Integer current = redisCache.getCacheObject(key);
        int next = current == null ? 1 : current + 1;
        redisCache.setCacheObject(key, next, LOGIN_FAIL_WINDOW_MINUTES, TimeUnit.MINUTES);
        return next;
    }

    private void clearLoginFailCount(String provider, String identifier, String ip)
    {
        redisCache.deleteObject(buildLoginFailKey(provider, identifier, ip));
    }

    private String buildLoginFailKey(String provider, String identifier, String ip)
    {
        String safeIp = StringUtils.hasText(ip) ? ip : "unknown";
        return LOGIN_FAIL_KEY_PREFIX + provider + ":" + identifier + ":" + safeIp;
    }

    private String buildSessionFingerprint(String deviceId, String userAgent, String ip)
    {
        if (StringUtils.hasText(deviceId))
        {
            return "device:" + deviceId.trim();
        }
        if (StringUtils.hasText(userAgent))
        {
            return "ua:" + userAgent.trim();
        }
        return "ip:" + (StringUtils.hasText(ip) ? ip.trim() : "unknown");
    }

    private Map<String, Object> toIdentityDto(CupidAuthIdentity identity)
    {
        Map<String, Object> dto = new LinkedHashMap<>();
        dto.put("id", identity.getId());
        dto.put("provider", identity.getProvider());
        dto.put("identifier", identity.getIdentifier());
        dto.put("verifiedAt", identity.getVerifiedAt());
        return dto;
    }

    private void validateSensitiveAction(String action)
    {
        if (!SENSITIVE_ACTIONS.contains(action))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_action");
        }
    }

    private CupidAuthIdentity findPasswordIdentity(List<CupidAuthIdentity> identities)
    {
        for (CupidAuthIdentity identity : identities)
        {
            if (StringUtils.hasText(identity.getPasswordHash()))
            {
                return identity;
            }
        }
        return null;
    }

    private String resolveMaskedIdentifier(Map<String, Object> mfa, String identityId)
    {
        Object methods = mfa.get("availableMethods");
        if (methods instanceof List<?>)
        {
            for (Object item : (List<?>) methods)
            {
                if (item instanceof Map<?, ?> method
                        && identityId.equals(method.get("identityId")))
                {
                    Object maskedIdentifier = method.get("maskedIdentifier");
                    return maskedIdentifier == null ? "" : String.valueOf(maskedIdentifier);
                }
            }
        }
        return "";
    }

    private static boolean isTruthy(Object value)
    {
        if (value instanceof Boolean) return (Boolean) value;
        if (value instanceof Number) return ((Number) value).intValue() != 0;
        if (value instanceof String) return "true".equalsIgnoreCase((String) value) || "1".equals(value);
        return false;
    }

    private String resolveIp()
    {
        try
        {
            return IpUtils.getIpAddr();
        }
        catch (Exception e)
        {
            return null;
        }
    }

    private String resolveUserAgent()
    {
        HttpServletRequest request = ServletUtils.getRequest();
        if (request == null)
        {
            return null;
        }
        String userAgent = request.getHeader("User-Agent");
        return StringUtils.hasText(userAgent) ? userAgent.trim() : null;
    }

    private String resolveDeviceId()
    {
        HttpServletRequest request = ServletUtils.getRequest();
        if (request == null)
        {
            return null;
        }
        String deviceId = request.getHeader("X-Device-Id");
        if (!StringUtils.hasText(deviceId))
        {
            deviceId = request.getHeader("X-Device-ID");
        }
        return StringUtils.hasText(deviceId) ? deviceId.trim() : null;
    }

    /**
     * 校验认证方式是否为 email 或 phone
     */
    private boolean isProvider(String provider)
    {
        return "email".equals(provider) || "phone".equals(provider);
    }

    /**
     * 校验注册入口路径
     */
    private boolean isRegistrationPath(String path)
    {
        return "self".equals(path) || "family".equals(path);
    }

    /**
     * 校验 locale 是否在允许范围内
     */
    private boolean isLocale(String locale)
    {
        return "zh".equals(locale) || "fr".equals(locale) || "en".equals(locale);
    }

    /**
     * 安全去空白
     */
    private String maskIdentifier(String provider, String value)
    {
        if (!StringUtils.hasText(value))
        {
            return null;
        }
        if ("email".equals(provider))
        {
            int atIndex = value.indexOf("@");
            if (atIndex <= 2)
            {
                return "***" + (atIndex > 0 ? value.substring(atIndex) : "");
            }
            return value.substring(0, 2) + "***" + value.substring(atIndex);
        }
        if ("phone".equals(provider))
        {
            if (value.length() <= 7)
            {
                return value.substring(0, Math.min(2, value.length())) + "***";
            }
            return value.substring(0, 3) + "****" + value.substring(value.length() - 4);
        }
        return value.length() <= 2 ? "**" : value.substring(0, 2) + "***";
    }

    private String trimmed(String value)
    {
        return value == null ? "" : value.trim();
    }

}
