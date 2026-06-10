package com.ruoyi.web.controller.cupid.app;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
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
import com.ruoyi.framework.web.service.CupidAuthService;

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

    /**
     * 查询当前登录账户
     */
    @GetMapping("/me")
    public AjaxResult me(@AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(authService.getAccountMe(principal.getUserId()));
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
}
