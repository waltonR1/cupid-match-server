package com.ruoyi.framework.web.service;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.cupid.domain.CupidAuthIdentity;
import com.ruoyi.cupid.domain.CupidUser;
import com.ruoyi.cupid.domain.CupidUserMembership;
import com.ruoyi.cupid.service.ICupidLegalService;
import com.ruoyi.cupid.service.ICupidUserService;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.uuid.IdUtils;

/**
 * Cupid Match 用户认证服务
 */
@Service
public class CupidAuthService
{
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^\\+?[1-9]\\d{6,14}$");

    @Autowired
    private ICupidUserService userService;

    @Autowired
    private ICupidLegalService legalService;

    @Autowired
    private CupidTokenService tokenService;

    @Autowired
    private CupidVerificationCodeService verificationCodeService;

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
            throw new CupidApiException(HttpStatus.UNAUTHORIZED, "invalid_credentials");
        }

        CupidUser user = requireActiveUser(identity.getUserId());
        if ("deactivated".equals(user.getStatus()))
        {
            userService.reactivateUser(user.getId());
            user.setStatus("active");
        }

        legalService.acceptActiveDocuments(user.getId());

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("token", tokenService.createToken(identity.getId(), user.getId()));
        response.put("user", toUserDto(user));
        response.put("membership", toMembershipDto(userService.selectActiveMembershipByUserId(user.getId())));
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

    private CupidUser requireActiveUser(String userId)
    {
        CupidUser user = userService.selectUserById(userId);
        if (user == null)
        {
            throw new CupidApiException(HttpStatus.UNAUTHORIZED, "unauthorized");
        }
        if ("suspended".equals(user.getStatus()))
        {
            throw new CupidApiException(HttpStatus.FORBIDDEN, "account_suspended");
        }
        return user;
    }

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

    private void validatePassword(String password)
    {
        if (password.length() < 8 || !password.matches(".*[A-Za-z].*") || !password.matches(".*\\d.*"))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "weak_password");
        }
    }

    private boolean isProvider(String provider)
    {
        return "email".equals(provider) || "phone".equals(provider);
    }

    private boolean isRegistrationPath(String path)
    {
        return "self".equals(path) || "family".equals(path);
    }

    private boolean isLocale(String locale)
    {
        return "zh".equals(locale) || "fr".equals(locale) || "en".equals(locale);
    }

    private String trimmed(String value)
    {
        return value == null ? "" : value.trim();
    }

}
