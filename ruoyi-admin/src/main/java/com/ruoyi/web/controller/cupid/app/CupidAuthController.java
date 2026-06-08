package com.ruoyi.web.controller.cupid.app;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.framework.web.service.CupidAuthService;

/**
 * Cupid Match 前台认证接口
 */
@RestController
@RequestMapping("/api/auth")
public class CupidAuthController
{
    @Autowired
    private CupidAuthService authService;

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public AjaxResult login(@RequestBody Map<String, String> body)
    {
        return AjaxResult.success(authService.login(body.get("identifier"), body.get("password")));
    }

    /**
     * 用户注册
     */
    @PostMapping("/register")
    public AjaxResult register(@RequestBody Map<String, String> body)
    {
        return AjaxResult.success(authService.register(body));
    }

    /**
     * 发送注册验证码
     */
    @PostMapping("/verification-code")
    public AjaxResult requestRegistrationVerificationCode(@RequestBody Map<String, String> body)
    {
        return AjaxResult.success(authService.requestVerificationCode(
                "registration", body.get("provider"), body.get("identifier")));
    }

    /**
     * 发送密码重置验证码
     */
    @PostMapping("/password-reset-code")
    public AjaxResult requestPasswordResetCode(@RequestBody Map<String, String> body)
    {
        return AjaxResult.success(authService.requestVerificationCode(
                "password_reset", body.get("provider"), body.get("identifier")));
    }

    /**
     * 重置用户密码
     */
    @PostMapping("/password/reset")
    public AjaxResult resetPassword(@RequestBody Map<String, String> body)
    {
        return AjaxResult.success(authService.resetPassword(body));
    }

    /**
     * 注销当前会话
     */
    @PostMapping("/logout")
    public AjaxResult logout(@AuthenticationPrincipal CupidLoginUser principal)
    {
        authService.logout(principal.getSessionId());
        return AjaxResult.success();
    }
}
