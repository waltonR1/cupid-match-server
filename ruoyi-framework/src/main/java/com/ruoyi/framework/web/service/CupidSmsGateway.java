package com.ruoyi.framework.web.service;

/**
 * Cupid 短信网关扩展点。
 *
 * 外部短信服务商确定后，实现本接口并注册为 Spring Bean 即可。
 */
public interface CupidSmsGateway
{
    /**
     * 发送验证码短信。
     *
     * @param phone 手机号
     * @param purpose 验证目的
     * @param code 验证码
     * @param ttlMinutes 有效期（分钟）
     */
    void sendVerificationCode(String phone, String purpose, String code, int ttlMinutes);
}
