package com.ruoyi.web.controller.cupid.app;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
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

    /**
     * 查询当前登录账户
     */
    @GetMapping("/me")
    public AjaxResult me(@AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(authService.getAccountMe(principal.getUserId()));
    }
}
