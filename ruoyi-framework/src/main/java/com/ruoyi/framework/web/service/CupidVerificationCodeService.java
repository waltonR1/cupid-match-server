package com.ruoyi.framework.web.service;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
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
    private static final String RESERVATION_SUFFIX = ":reservation";
    private static final int CODE_TTL_MINUTES = 5;
    private static final int RESERVATION_TTL_MINUTES = 10;
    private static final SecureRandom RANDOM = new SecureRandom();

    @Autowired
    private RedisCache redisCache;

    @Value("${cupid.auth.verification-code-log-enabled:false}")
    private boolean verificationCodeLogEnabled;

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
        String code = String.format("%06d", RANDOM.nextInt(1_000_000));
        long expiresAt = System.currentTimeMillis() + TimeUnit.MINUTES.toMillis(CODE_TTL_MINUTES);

        CupidVerificationCode entry = new CupidVerificationCode();
        entry.setId(IdUtils.fastUUID());
        entry.setPurpose(purpose);
        entry.setProvider(provider);
        entry.setIdentifier(identifier);
        entry.setCodeHash(SecurityUtils.encryptPassword(code));
        entry.setExpiresAt(expiresAt);

        redisCache.setCacheObject(getKey(purpose, provider, identifier), entry,
                CODE_TTL_MINUTES, TimeUnit.MINUTES);

        // Phase-one delivery adapter: never returned by the product API and explicitly disabled in production.
        if (verificationCodeLogEnabled)
        {
            log.info("Cupid verification code purpose={}, provider={}, identifier={}, code={}",
                    purpose, provider, identifier, code);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", entry.getId());
        result.put("expiresAt", Instant.ofEpochMilli(expiresAt).toString());
        return result;
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

        String reservationKey = key + RESERVATION_SUFFIX;
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
}
