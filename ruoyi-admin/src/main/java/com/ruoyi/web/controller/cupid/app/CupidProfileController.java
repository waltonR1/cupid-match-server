package com.ruoyi.web.controller.cupid.app;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.cupid.service.ICupidProfileService;

/**
 * Cupid Match 前台资料接口
 */
@RestController
@RequestMapping("/api/profiles")
public class CupidProfileController
{
    @Autowired
    private ICupidProfileService profileService;

    /**
     * 自助征婚资料目录
     */
    @GetMapping("/self")
    public AjaxResult selfDirectory(@RequestParam Map<String, String> params,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(profileService.getSelfProfileDirectory(params, getUserId(principal)));
    }

    /**
     * 家庭征婚资料目录
     */
    @GetMapping("/family")
    public AjaxResult familyDirectory(@RequestParam Map<String, String> params,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(profileService.getFamilyProfileDirectory(params, getUserId(principal)));
    }

    /**
     * 首页精选资料
     */
    @GetMapping("/featured")
    public AjaxResult featured(@RequestParam Map<String, String> params)
    {
        return AjaxResult.success(profileService.getFeaturedProfiles(params));
    }

    /**
     * 自助征婚资料详情
     */
    @GetMapping("/self/{id}")
    public AjaxResult selfDetail(@PathVariable String id,
            @RequestParam(value = "lang", defaultValue = "zh") String locale,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        Map<String, Object> detail = profileService.getSelfProfileDetail(id, getUserId(principal), locale);
        if (detail == null)
        {
            return AjaxResult.error(404, "profile_not_found");
        }
        return AjaxResult.success(detail);
    }

    /**
     * 家庭征婚资料详情
     */
    @GetMapping("/family/{id}")
    public AjaxResult familyDetail(@PathVariable String id,
            @RequestParam(value = "lang", defaultValue = "zh") String locale,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        Map<String, Object> detail = profileService.getFamilyProfileDetail(id, getUserId(principal), locale);
        if (detail == null)
        {
            return AjaxResult.error(404, "profile_not_found");
        }
        return AjaxResult.success(detail);
    }

    private String getUserId(CupidLoginUser principal)
    {
        return principal == null ? null : principal.getUserId();
    }
}
