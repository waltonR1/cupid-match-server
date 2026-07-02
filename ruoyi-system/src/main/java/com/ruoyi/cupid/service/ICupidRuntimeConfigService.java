package com.ruoyi.cupid.service;

/**
 * Cupid 可热更新运行参数服务
 */
public interface ICupidRuntimeConfigService
{
    int getVerificationCodeTtlMinutes();

    int getVerificationResendIntervalSeconds();

    int getIntroductionExpiryDays();

    int getIntroductionCooldownDays();
}
