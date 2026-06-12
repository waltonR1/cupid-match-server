package com.ruoyi.web.controller.cupid.app;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.cupid.service.ICupidRelationshipService;

/**
 * Cupid Match 私人介绍接口。
 */
@RestController
@RequestMapping("/api")
public class CupidPrivateIntroductionController
{
    @Autowired
    private ICupidRelationshipService relationshipService;

    /**
     * 对本人类型资料申请私人介绍。
     */
    @PostMapping("/profiles/self/{id}/private-introduction")
    public AjaxResult selfIntro(@PathVariable String id,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(relationshipService.requestIntroduction(
                principal.getUserId(), id, "self"));
    }

    /**
     * 对家庭类型资料申请私人介绍。
     */
    @PostMapping("/profiles/family/{id}/private-introduction")
    public AjaxResult familyIntro(@PathVariable String id,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(relationshipService.requestIntroduction(
                principal.getUserId(), id, "family"));
    }

    /**
     * 查询当前账户发出的私人介绍申请。
     */
    @GetMapping("/account/private-introductions")
    public AjaxResult list(@AuthenticationPrincipal CupidLoginUser principal,
            @RequestParam(value = "lang", defaultValue = "zh") String locale)
    {
        return AjaxResult.success(
                relationshipService.getIntroductions(principal.getUserId(), locale));
    }

    /**
     * 查询已接受私人介绍的联系方式。
     */
    @GetMapping("/account/private-introductions/{requestId}/contact")
    public AjaxResult contact(@PathVariable String requestId,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(relationshipService.getIntroductionContact(
                principal.getUserId(), requestId));
    }
}
