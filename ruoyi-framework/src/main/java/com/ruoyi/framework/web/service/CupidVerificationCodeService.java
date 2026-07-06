package com.ruoyi.framework.web.service;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.task.TaskExecutor;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.service.ICupidRuntimeConfigService;
import com.ruoyi.framework.web.domain.CupidVerificationCode;

/**
 * Cupid Match 一次性验证码服务
 */
@Service
public class CupidVerificationCodeService
{
    public static final String PURPOSE_REGISTRATION = "registration";
    public static final String PURPOSE_PASSWORD_RESET = "password_reset";

    private static final Logger log = LoggerFactory.getLogger(CupidVerificationCodeService.class);
    private static final String KEY_PREFIX = "cupid:verification-code:";
    private static final String COOLDOWN_KEY_PREFIX = "cupid:verification-cooldown:";
    private static final String RESERVATION_KEY_PREFIX = "cupid:verification-reservation:";
    private static final int RESERVATION_TTL_MINUTES = 10;
    private static final SecureRandom RANDOM = new SecureRandom();

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private ICupidRuntimeConfigService runtimeConfigService;

    @Autowired
    private CupidVerificationCodeDeliveryService deliveryService;

    @Autowired
    @Qualifier("verificationDeliveryTaskExecutor")
    private TaskExecutor verificationDeliveryTaskExecutor;

    /**
     * 创建并缓存一次性验证码
     *
     * @param purpose 验证目的
     * @param provider 认证方式
     * @param identifier 邮箱或手机号
     * @return 验证码发送结果
     */
    public Map<String, Object> create(String purpose, String provider, String identifier)
    {
        deliveryService.validate(provider);

        int codeTtlMinutes = runtimeConfigService.getVerificationCodeTtlMinutes();
        int resendIntervalSeconds = runtimeConfigService.getVerificationResendIntervalSeconds();
        String key = getKey(purpose, provider, identifier);
        String cooldownKey = getCooldownKey(purpose, provider, identifier);
        String entryId = IdUtils.fastUUID();
        if (!redisCache.setCacheObjectIfAbsent(cooldownKey, entryId,
                resendIntervalSeconds, TimeUnit.SECONDS))
        {
            throw new CupidApiException(HttpStatus.TOO_MANY_REQUESTS, "verification_code_too_frequent");
        }

        String code = String.format("%06d", RANDOM.nextInt(1_000_000));
        long expiresAt = System.currentTimeMillis() + TimeUnit.MINUTES.toMillis(codeTtlMinutes);

        CupidVerificationCode entry = new CupidVerificationCode();
        entry.setId(entryId);
        entry.setPurpose(purpose);
        entry.setProvider(provider);
        entry.setIdentifier(identifier);
        entry.setCodeHash(SecurityUtils.encryptPassword(code));
        entry.setExpiresAt(expiresAt);

        try
        {
            redisCache.setCacheObject(key, entry, codeTtlMinutes, TimeUnit.MINUTES);
        }
        catch (RuntimeException e)
        {
            redisCache.deleteObject(cooldownKey);
            throw e;
        }

        try
        {
            String locale = LocaleContextHolder.getLocale().getLanguage();
            verificationDeliveryTaskExecutor.execute(() ->
                    deliverAndCleanupOnFailure(entryId, key, cooldownKey, purpose,
                            provider, identifier, code, codeTtlMinutes, locale));
        }
        catch (RuntimeException e)
        {
            redisCache.deleteObject(key);
            redisCache.deleteObject(cooldownKey);
            log.warn("Cupid verification delivery task rejected: purpose={}, provider={}",
                    purpose, provider, e);
            throw new CupidApiException(HttpStatus.ERROR, "verification_delivery_unavailable");
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", entry.getId());
        result.put("expiresAt", Instant.ofEpochMilli(expiresAt).toString());
        result.put("resendAvailableAt",
                Instant.ofEpochMilli(System.currentTimeMillis()
                        + TimeUnit.SECONDS.toMillis(resendIntervalSeconds)).toString());
        return result;
    }

    private void deliverAndCleanupOnFailure(String entryId, String key, String cooldownKey,
            String purpose, String provider, String identifier, String code, int codeTtlMinutes,
            String locale)
    {
        try
        {
            deliveryService.deliver(purpose, provider, identifier, code, codeTtlMinutes, locale);
        }
        catch (RuntimeException e)
        {
            CupidVerificationCode currentEntry = redisCache.getCacheObject(key);
            if (currentEntry != null && entryId.equals(currentEntry.getId()))
            {
                redisCache.deleteObject(key);
            }
            String currentCooldown = redisCache.getCacheObject(cooldownKey);
            if (entryId.equals(currentCooldown))
            {
                redisCache.deleteObject(cooldownKey);
            }
            log.warn("Cupid verification delivery failed asynchronously: purpose={}, provider={}",
                    purpose, provider, e);
        }
    }

    /**
     * 校验并原子占用一次性验证码
     *
     * @param purpose 验证目的
     * @param provider 认证方式
     * @param identifier 邮箱或手机号
     * @param code 验证码
     * @return true=校验并占用成功，false=验证码无效、过期或已被占用
     */
    public boolean verifyAndConsume(String purpose, String provider, String identifier, String code)
    {
        String key = getKey(purpose, provider, identifier);
        CupidVerificationCode entry = redisCache.getCacheObject(key);
        if (entry == null || entry.getExpiresAt() < System.currentTimeMillis()
                || !SecurityUtils.matchesPassword(code, entry.getCodeHash()))
        {
            return false;
        }

        String reservationKey = getReservationKey(purpose, provider, identifier);
        if (!redisCache.setCacheObjectIfAbsent(reservationKey, entry.getId(),
                RESERVATION_TTL_MINUTES, TimeUnit.MINUTES))
        {
            return false;
        }

        if (!TransactionSynchronizationManager.isSynchronizationActive())
        {
            redisCache.deleteObject(key);
            redisCache.deleteObject(reservationKey);
            return true;
        }
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization()
        {
            @Override
            public void afterCompletion(int status)
            {
                if (status == TransactionSynchronization.STATUS_COMMITTED)
                {
                    redisCache.deleteObject(key);
                }
                redisCache.deleteObject(reservationKey);
            }
        });
        return true;
    }

    private String getKey(String purpose, String provider, String identifier)
    {
        return KEY_PREFIX + purpose + ":" + provider + ":" + identifier;
    }

    private String getCooldownKey(String purpose, String provider, String identifier)
    {
        return COOLDOWN_KEY_PREFIX + purpose + ":" + provider + ":" + identifier;
    }

    private String getReservationKey(String purpose, String provider, String identifier)
    {
        return RESERVATION_KEY_PREFIX + purpose + ":" + provider + ":" + identifier;
    }
}
