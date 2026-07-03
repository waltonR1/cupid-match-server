package com.ruoyi.cupid.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.cupid.service.ICupidRuntimeConfigService;
import com.ruoyi.system.service.ISysConfigService;

/**
 * Cupid 可热更新运行参数。
 *
 * 统一负责参数键、默认值和安全边界，业务服务不得散读 sys_config。
 */
@Service
public class CupidRuntimeConfigServiceImpl implements ICupidRuntimeConfigService
{
    private static final Logger log = LoggerFactory.getLogger(CupidRuntimeConfigServiceImpl.class);

    private static final String KEY_VERIFICATION_CODE_TTL_MINUTES =
            "cupid.auth.verification.codeTtlMinutes";
    private static final String KEY_VERIFICATION_RESEND_INTERVAL_SECONDS =
            "cupid.auth.verification.resendIntervalSeconds";
    private static final String KEY_INTRODUCTION_EXPIRY_DAYS =
            "cupid.introduction.expiryDays";
    private static final String KEY_INTRODUCTION_COOLDOWN_DAYS =
            "cupid.introduction.cooldownDays";
    private static final String KEY_SCHEDULED_MAINTENANCE_BATCH_SIZE =
            "cupid.scheduler.batchSize";

    private static final int DEFAULT_CODE_TTL_MINUTES = 5;
    private static final int MIN_CODE_TTL_MINUTES = 1;
    private static final int MAX_CODE_TTL_MINUTES = 15;

    private static final int DEFAULT_RESEND_INTERVAL_SECONDS = 60;
    private static final int MIN_RESEND_INTERVAL_SECONDS = 30;
    private static final int MAX_RESEND_INTERVAL_SECONDS = 300;

    private static final int DEFAULT_INTRODUCTION_EXPIRY_DAYS = 7;
    private static final int MIN_INTRODUCTION_EXPIRY_DAYS = 1;
    private static final int MAX_INTRODUCTION_EXPIRY_DAYS = 30;

    private static final int DEFAULT_INTRODUCTION_COOLDOWN_DAYS = 90;
    private static final int MIN_INTRODUCTION_COOLDOWN_DAYS = 7;
    private static final int MAX_INTRODUCTION_COOLDOWN_DAYS = 365;

    private static final int DEFAULT_SCHEDULED_MAINTENANCE_BATCH_SIZE = 500;
    private static final int MIN_SCHEDULED_MAINTENANCE_BATCH_SIZE = 50;
    private static final int MAX_SCHEDULED_MAINTENANCE_BATCH_SIZE = 2000;

    @Autowired
    private ISysConfigService configService;

    @Override
    public int getVerificationCodeTtlMinutes()
    {
        return readBoundedInt(KEY_VERIFICATION_CODE_TTL_MINUTES, DEFAULT_CODE_TTL_MINUTES,
                MIN_CODE_TTL_MINUTES, MAX_CODE_TTL_MINUTES);
    }

    @Override
    public int getVerificationResendIntervalSeconds()
    {
        return readBoundedInt(KEY_VERIFICATION_RESEND_INTERVAL_SECONDS, DEFAULT_RESEND_INTERVAL_SECONDS,
                MIN_RESEND_INTERVAL_SECONDS, MAX_RESEND_INTERVAL_SECONDS);
    }

    @Override
    public int getIntroductionExpiryDays()
    {
        return readBoundedInt(KEY_INTRODUCTION_EXPIRY_DAYS, DEFAULT_INTRODUCTION_EXPIRY_DAYS,
                MIN_INTRODUCTION_EXPIRY_DAYS, MAX_INTRODUCTION_EXPIRY_DAYS);
    }

    @Override
    public int getIntroductionCooldownDays()
    {
        return readBoundedInt(KEY_INTRODUCTION_COOLDOWN_DAYS, DEFAULT_INTRODUCTION_COOLDOWN_DAYS,
                MIN_INTRODUCTION_COOLDOWN_DAYS, MAX_INTRODUCTION_COOLDOWN_DAYS);
    }

    @Override
    public int getScheduledMaintenanceBatchSize()
    {
        return readBoundedInt(KEY_SCHEDULED_MAINTENANCE_BATCH_SIZE,
                DEFAULT_SCHEDULED_MAINTENANCE_BATCH_SIZE,
                MIN_SCHEDULED_MAINTENANCE_BATCH_SIZE,
                MAX_SCHEDULED_MAINTENANCE_BATCH_SIZE);
    }

    private int readBoundedInt(String key, int defaultValue, int minValue, int maxValue)
    {
        String configuredValue = configService.selectConfigByKey(key);
        if (!StringUtils.hasText(configuredValue))
        {
            return defaultValue;
        }
        try
        {
            int parsedValue = Integer.parseInt(configuredValue.trim());
            if (parsedValue >= minValue && parsedValue <= maxValue)
            {
                return parsedValue;
            }
        }
        catch (NumberFormatException ignored)
        {
            // Fall through to the safe default.
        }
        log.warn("Invalid Cupid runtime config: key={}, value={}, fallback={}",
                key, configuredValue, defaultValue);
        return defaultValue;
    }
}
