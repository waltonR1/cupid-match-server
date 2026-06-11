package com.ruoyi.web.controller.cupid.app;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.cupid.service.ICupidMembershipService;

/**
 * Cupid Match 会员接口
 */
@RestController
@RequestMapping("/api")
public class CupidMembershipController
{
    @Autowired
    private ICupidMembershipService membershipService;

    /**
     * 公共会员套餐目录（无需登录）
     */
    @GetMapping("/membership/catalog")
    public AjaxResult catalog(@RequestParam(value = "lang", defaultValue = "zh") String locale)
    {
        return AjaxResult.success(membershipService.getCatalog(locale));
    }

    /**
     * 当前用户会员信息
     */
    @GetMapping("/account/membership")
    public AjaxResult accountMembership(@AuthenticationPrincipal CupidLoginUser principal,
            @RequestParam(value = "lang", defaultValue = "zh") String locale)
    {
        return AjaxResult.success(
                membershipService.getAccountMembership(principal.getUserId(), locale));
    }

    /**
     * 请求升级会员
     */
    @PostMapping("/account/membership/upgrade")
    public AjaxResult upgrade(@RequestBody Map<String, String> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(
                membershipService.requestUpgrade(principal.getUserId(), body.get("tier")));
    }
}
