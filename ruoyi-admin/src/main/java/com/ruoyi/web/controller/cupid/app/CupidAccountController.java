package com.ruoyi.web.controller.cupid.app;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.cupid.service.ICupidProfileService;
import com.ruoyi.cupid.service.ICupidDashboardService;
import com.ruoyi.cupid.service.ICupidUserService;
import com.ruoyi.framework.web.service.CupidAuthService;
import com.ruoyi.framework.web.service.CupidVerificationCodeService;

/**
 * Cupid Match 前台账户接口
 */
@RestController
@RequestMapping("/api/account")
public class CupidAccountController
{
    @Autowired
    private CupidAuthService authService;

    @Autowired
    private ICupidProfileService profileService;

    @Autowired
    private ICupidDashboardService dashboardService;

    @Autowired
    private ICupidUserService userService;

    @Autowired
    private CupidVerificationCodeService verificationCodeService;

    /**
     * 查询当前登录账户
     */
    @GetMapping("/me")
    public AjaxResult me(@AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(authService.getAccountMe(principal.getUserId()));
    }

    /**
     * 更新账户基本信息
     */
    @PostMapping("/me")
    public AjaxResult updateMe(@RequestBody Map<String, Object> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        com.ruoyi.cupid.domain.CupidUser user = userService.selectUserById(principal.getUserId());
        if (body.containsKey("accountName")) user.setAccountName((String) body.get("accountName"));
        if (body.containsKey("avatarUrl")) user.setAvatarUrl((String) body.get("avatarUrl"));
        if (body.containsKey("preferredLocale")) user.setPreferredLocale((String) body.get("preferredLocale"));
        userService.updateUser(user);
        return AjaxResult.success(authService.getAccountMe(principal.getUserId()));
    }

    /**
     * 获取账户设置
     */
    @GetMapping("/settings")
    public AjaxResult settings(@AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(authService.getSettings(principal.getUserId()));
    }

    /**
     * 更新通知偏好
     */
    @PostMapping("/settings/preferences")
    public AjaxResult updatePreferences(@RequestBody Map<String, Object> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        Map<String, Object> prefs = (Map) body.get("preferences");
        if (prefs != null) userService.updatePreferences(principal.getUserId(), prefs);
        return AjaxResult.success(authService.getSettings(principal.getUserId()));
    }

    /**
     * 修改密码
     */
    @PostMapping("/password/change")
    public AjaxResult changePassword(@RequestBody Map<String, String> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(authService.changePassword(principal.getUserId(),
                body.get("currentPassword"), body.get("newPassword"), body.get("challengeToken")));
    }

    /**
     * 绑定身份验证码
     */
    @PostMapping("/identities/verification-code")
    public AjaxResult identityVerificationCode(@RequestBody Map<String, String> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        String identifier = userService.validateIdentityBinding(
                principal.getUserId(), body.get("provider"), body.get("identifier"));
        return AjaxResult.success(verificationCodeService.create(
                "identity_bind",
                body.get("provider"), identifier));
    }

    /**
     * 绑定身份
     */
    @PostMapping("/identities")
    public AjaxResult bindIdentity(@RequestBody Map<String, String> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        String provider = body.get("provider");
        String identifier = body.get("identifier");
        String code = body.get("code");
        if (!"email".equals(provider) && !"phone".equals(provider))
        {
            return AjaxResult.error(400, "invalid_provider");
        }
        if (identifier == null || identifier.trim().isEmpty())
        {
            return AjaxResult.error(400, "invalid_identifier");
        }
        String normalizedIdentifier = userService.validateIdentityBinding(
                principal.getUserId(), provider, identifier);
        if (!verificationCodeService.verifyAndConsume("identity_bind",
                provider, normalizedIdentifier, code))
        {
            return AjaxResult.error(400, "invalid_or_expired_verification_code");
        }
        com.ruoyi.cupid.domain.CupidAuthIdentity identity =
                userService.bindIdentity(principal.getUserId(), provider, normalizedIdentifier, code);
        return AjaxResult.success(Map.of("identity", toIdentityDto(identity)));
    }

    /**
     * 解绑身份
     */
    @DeleteMapping("/identities/{id}")
    public AjaxResult unbindIdentity(@PathVariable String id,
            @RequestBody(required = false) Map<String, String> body,
            @RequestParam(value = "challengeToken", required = false) String challengeToken,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        authService.requireChallengeIfMfaEnabled(principal.getUserId(),
                "unbind_identity", body != null && body.get("challengeToken") != null
                        ? body.get("challengeToken") : challengeToken);
        userService.unbindIdentity(principal.getUserId(), id);
        return AjaxResult.success(Map.of("removed", true));
    }

    /**
     * 获取 MFA 状态
     */
    @GetMapping("/mfa/status")
    public AjaxResult mfaStatus(@AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(userService.getMfaStatus(principal.getUserId()));
    }

    /**
     * 发送 MFA 验证码
     */
    @PostMapping("/mfa/verification-code")
    public AjaxResult mfaVerificationCode(@RequestBody Map<String, String> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        String identityId = body.get("identityId");
        com.ruoyi.cupid.domain.CupidAuthIdentity identity =
                userService.selectIdentityById(identityId);
        if (identity == null || !principal.getUserId().equals(identity.getUserId())
                || identity.getVerifiedAt() == null
                || !identity.getProvider().equals(body.get("method")))
        {
            return AjaxResult.error(400, "invalid_identity");
        }
        return AjaxResult.success(verificationCodeService.create(
                "mfa",
                identity.getProvider(), identity.getIdentifier()));
    }

    /**
     * 启用 MFA
     */
    @PostMapping("/mfa/enable")
    public AjaxResult enableMfa(@RequestBody Map<String, String> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        com.ruoyi.cupid.domain.CupidAuthIdentity identity =
                userService.validateMfaEnable(principal.getUserId(), body.get("method"), body.get("identityId"));
        if (!verificationCodeService.verifyAndConsume("mfa",
                identity.getProvider(), identity.getIdentifier(), body.get("code")))
        {
            return AjaxResult.error(400, "invalid_or_expired_verification_code");
        }
        userService.enableMfa(principal.getUserId(),
                body.get("method"), body.get("identityId"), body.get("code"));
        return AjaxResult.success(userService.getMfaStatus(principal.getUserId()));
    }

    /**
     * 禁用 MFA
     */
    @PostMapping("/mfa/disable")
    public AjaxResult disableMfa(@RequestBody Map<String, String> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        com.ruoyi.cupid.domain.CupidAuthIdentity identity =
                userService.validateMfaDisable(principal.getUserId());
        if (!verificationCodeService.verifyAndConsume("mfa",
                identity.getProvider(), identity.getIdentifier(), body.get("code")))
        {
            return AjaxResult.error(400, "invalid_or_expired_verification_code");
        }
        userService.disableMfa(principal.getUserId(), body.get("code"));
        return AjaxResult.success(userService.getMfaStatus(principal.getUserId()));
    }

    /**
     * 请求安全挑战验证码
     */
    @PostMapping("/security/challenge-code")
    public AjaxResult securityChallengeCode(@RequestBody Map<String, String> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(authService.requestSecurityChallenge(principal.getUserId(),
                body.get("action"), body.get("identityId")));
    }

    /**
     * 验证安全挑战
     */
    @PostMapping("/security/challenge")
    public AjaxResult securityChallenge(@RequestBody Map<String, String> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(authService.verifySecurityChallenge(principal.getUserId(),
                body.get("action"), body.get("code")));
    }

    /**
     * 停用账户
     */
    @PostMapping("/deactivate")
    public AjaxResult deactivate(@RequestBody(required = false) Map<String, String> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(authService.deactivateAccount(principal.getUserId(),
                body == null ? null : body.get("challengeToken")));
    }

    /**
     * 导出账户数据
     */
    @PostMapping("/export")
    public AjaxResult exportData(@RequestBody(required = false) Map<String, String> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(authService.createAccountExport(principal.getUserId(),
                body == null ? null : body.get("challengeToken")));
    }

    /**
     * 下载导出数据
     */
    @GetMapping("/export/download")
    public AjaxResult downloadExport(@AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(authService.exportAccountData(principal.getUserId()));
    }

    private Map<String, Object> toIdentityDto(com.ruoyi.cupid.domain.CupidAuthIdentity identity)
    {
        Map<String, Object> dto = new java.util.LinkedHashMap<>();
        dto.put("id", identity.getId());
        dto.put("provider", identity.getProvider());
        dto.put("identifier", identity.getIdentifier());
        dto.put("verifiedAt", identity.getVerifiedAt());
        return dto;
    }

    /**
     * 查询当前用户管理的全部资料
     */
    @GetMapping("/profiles")
    public AjaxResult profiles(@AuthenticationPrincipal CupidLoginUser principal,
            @RequestParam(value = "lang", defaultValue = "zh") String locale)
    {
        return AjaxResult.success(profileService.getOwnerProfiles(principal.getUserId(), locale));
    }

    /**
     * 查询当前用户管理的资料详情
     */
    @GetMapping("/profiles/{profileId}")
    public AjaxResult profileDetail(@PathVariable String profileId,
            @AuthenticationPrincipal CupidLoginUser principal,
            @RequestParam(value = "lang", defaultValue = "zh") String locale)
    {
        Map<String, Object> detail =
                profileService.getOwnerProfileDetail(profileId, principal.getUserId(), locale);
        if (detail == null)
        {
            return AjaxResult.error(404, "profile_not_found");
        }
        return AjaxResult.success(detail);
    }

    /**
     * 新建或更新资料
     */
    @PostMapping("/profiles/save")
    public AjaxResult saveProfile(@RequestBody Map<String, Object> payload,
            @AuthenticationPrincipal CupidLoginUser principal,
            @RequestParam(value = "lang", defaultValue = "zh") String locale)
    {
        return AjaxResult.success(profileService.saveProfile(principal.getUserId(), payload, locale));
    }

    /**
     * 归档资料
     */
    @PostMapping("/profiles/{profileId}/archive")
    public AjaxResult archiveProfile(@PathVariable String profileId,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(profileService.archiveProfile(profileId, principal.getUserId()));
    }

    /**
     * 更新资料隐私偏好
     */
    @PostMapping("/profiles/{profileId}/privacy-preferences")
    public AjaxResult updatePrivacyPreferences(@PathVariable String profileId,
            @RequestBody Map<String, Object> prefs,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(
                profileService.updatePrivacyPreferences(profileId, principal.getUserId(), prefs));
    }
    /**
     * 聚合账户首页所需的只读领域数据。
     */
    @GetMapping("/dashboard")
    public AjaxResult dashboard(@AuthenticationPrincipal CupidLoginUser principal,
            @RequestParam(value = "lang", defaultValue = "zh") String locale)
    {
        return AjaxResult.success(
                dashboardService.getDashboard(principal.getUserId(), locale));
    }
}
