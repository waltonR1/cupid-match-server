package com.ruoyi.web.controller.cupid.app;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
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
 * Cupid Match 收藏接口。
 */
@RestController
@RequestMapping("/api")
public class CupidFavoriteController
{
    @Autowired
    private ICupidRelationshipService relationshipService;

    /**
     * 收藏资料。
     */
    @PostMapping("/favorites/{profileId}")
    public AjaxResult add(@PathVariable String profileId,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(
                relationshipService.addFavorite(principal.getUserId(), profileId));
    }

    /**
     * 取消收藏资料。
     */
    @DeleteMapping("/favorites/{profileId}")
    public AjaxResult remove(@PathVariable String profileId,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(
                relationshipService.removeFavorite(principal.getUserId(), profileId));
    }

    /**
     * 查询账户收藏列表。
     */
    @GetMapping("/account/favorites")
    public AjaxResult list(@AuthenticationPrincipal CupidLoginUser principal,
            @RequestParam(value = "lang", defaultValue = "zh") String locale)
    {
        return AjaxResult.success(
                relationshipService.getFavorites(principal.getUserId(), locale));
    }
}
