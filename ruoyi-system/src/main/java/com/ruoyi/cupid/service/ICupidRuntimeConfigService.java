package com.ruoyi.cupid.service;

/**
 * Cupid 可热更新运行参数服务
 */
public interface ICupidRuntimeConfigService
{
    int getVerificationCodeTtlMinutes();

    int getVerificationResendIntervalSeconds();

    boolean isVerificationEmailEnabled();

    boolean isVerificationSmsEnabled();

    int getIntroductionExpiryDays();

    int getIntroductionCooldownDays();

    int getScheduledMaintenanceBatchSize();

    boolean isTranslationEnabled();

    String getTranslationApiUrl();

    int getTranslationConnectTimeoutSeconds();

    int getTranslationReadTimeoutSeconds();

    int getTranslationRetryMaxAttempts();

    int getTranslationRetryBatchSize();

    int getTranslationRetryBaseDelayMinutes();
}
