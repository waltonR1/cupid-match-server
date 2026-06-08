package com.ruoyi.framework.web.service;

import java.util.Collections;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import jakarta.servlet.http.HttpServletRequest;

/**
 * Cupid Match 用户令牌服务
 */
@Service
public class CupidTokenService
{
    private static final String SESSION_KEY_PREFIX = "cupid:session:";
    private static final String USER_SESSION_KEY_PREFIX = "cupid:user-sessions:";
    private static final String CLAIM_TOKEN_TYPE = "tokenType";
    private static final String CLAIM_SESSION_ID = "sessionId";
    private static final String CLAIM_USER_ID = "userId";
    private static final String TOKEN_TYPE = "cupid";
    private static final long MILLIS_MINUTE = 60 * 1000L;
    private static final long MILLIS_MINUTE_TWENTY = 20 * MILLIS_MINUTE;

    @Autowired
    private RedisCache redisCache;

    @Value("${token.secret}")
    private String secret;

    @Value("${token.header}")
    private String header;

    @Value("${token.expireTime}")
    private int expireTime;

    /**
     * 创建前台用户会话和JWT
     */
    public String createToken(String identityId, String userId)
    {
        CupidLoginUser session = createSession(identityId, userId);
        return Jwts.builder()
                .setSubject(userId)
                .claim(CLAIM_TOKEN_TYPE, TOKEN_TYPE)
                .claim(CLAIM_SESSION_ID, session.getId())
                .claim(CLAIM_USER_ID, userId)
                .signWith(SignatureAlgorithm.HS512, secret)
                .compact();
    }

    /**
     * 从JWT和Redis会话中恢复已认证用户身份
     *
     * @param request HTTP请求
     * @return 用户身份，令牌或会话无效时返回null
     */
    public CupidLoginUser getUserPrincipal(HttpServletRequest request)
    {
        String token = getToken(request);
        Claims claims = parseClaims(token);
        if (claims == null)
        {
            return null;
        }

        String sessionId = claims.get(CLAIM_SESSION_ID, String.class);
        String userId = claims.get(CLAIM_USER_ID, String.class);
        if (!StringUtils.hasText(sessionId))
        {
            return null;
        }

        CupidLoginUser session = getSession(sessionId);
        if (session == null || !StringUtils.hasText(session.getIdentityId())
                || !StringUtils.hasText(session.getUserId()) || !session.getUserId().equals(userId))
        {
            return null;
        }
        return session;
    }

    /**
     * 会话剩余时间不足20分钟时自动续期
     *
     * @param principal 已认证用户身份
     */
    public void verifyToken(CupidLoginUser principal)
    {
        if (principal.getExpiresAt() - System.currentTimeMillis() <= MILLIS_MINUTE_TWENTY)
        {
            principal.setExpiresAt(System.currentTimeMillis() + expireTime * MILLIS_MINUTE);
            storeSession(principal);
        }
    }

    /**
     * 注销单个令牌对应的会话
     */
    public void deleteToken(String sessionId)
    {
        if (sessionId == null)
        {
            return;
        }
        CupidLoginUser session = getSession(sessionId);
        redisCache.deleteObject(getSessionKey(sessionId));
        if (session != null)
        {
            redisCache.deleteCacheSetValue(getUserSessionKey(session.getUserId()), sessionId);
        }
    }

    /**
     * 注销用户的全部令牌会话
     */
    public void deleteUserTokens(String userId)
    {
        if (userId == null)
        {
            return;
        }
        afterCommit(() -> deleteUserTokensNow(userId));
    }

    private CupidLoginUser createSession(String identityId, String userId)
    {
        long now = System.currentTimeMillis();
        CupidLoginUser session = new CupidLoginUser();
        session.setId(IdUtils.fastUUID());
        session.setIdentityId(identityId);
        session.setUserId(userId);
        session.setCreatedAt(now);
        session.setExpiresAt(now + expireTime * MILLIS_MINUTE);
        afterCommit(() -> storeSession(session));
        return session;
    }

    private CupidLoginUser getSession(String sessionId)
    {
        return redisCache.getCacheObject(getSessionKey(sessionId));
    }

    private void storeSession(CupidLoginUser session)
    {
        // 会话详情用于JWT认证，用户会话集合用于批量注销该用户的全部登录设备。
        redisCache.setCacheObject(getSessionKey(session.getId()), session, expireTime, TimeUnit.MINUTES);
        String userSessionKey = getUserSessionKey(session.getUserId());
        redisCache.setCacheSet(userSessionKey, Collections.singleton(session.getId()));
        redisCache.expire(userSessionKey, expireTime, TimeUnit.MINUTES);
    }

    private String getToken(HttpServletRequest request)
    {
        String token = request.getHeader(header);
        if (StringUtils.isNotEmpty(token) && token.startsWith(Constants.TOKEN_PREFIX))
        {
            token = token.replace(Constants.TOKEN_PREFIX, "");
        }
        return token;
    }

    private void deleteUserTokensNow(String userId)
    {
        String userSessionKey = getUserSessionKey(userId);
        Set<String> sessionIds = redisCache.getCacheSet(userSessionKey);
        if (sessionIds != null && !sessionIds.isEmpty())
        {
            redisCache.deleteObject(sessionIds.stream().map(this::getSessionKey).toList());
        }
        redisCache.deleteObject(userSessionKey);
    }

    private Claims parseClaims(String token)
    {
        if (!StringUtils.hasText(token))
        {
            return null;
        }
        try
        {
            Claims claims = Jwts.parser()
                    .setSigningKey(secret)
                    .parseClaimsJws(token)
                    .getBody();
            return TOKEN_TYPE.equals(claims.get(CLAIM_TOKEN_TYPE)) ? claims : null;
        }
        catch (RuntimeException e)
        {
            return null;
        }
    }

    private void afterCommit(Runnable operation)
    {
        // 避免数据库事务回滚后Redis中仍然保留无效会话。
        if (!TransactionSynchronizationManager.isSynchronizationActive())
        {
            operation.run();
            return;
        }
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization()
        {
            @Override
            public void afterCommit()
            {
                operation.run();
            }
        });
    }

    private String getSessionKey(String sessionId)
    {
        return SESSION_KEY_PREFIX + sessionId;
    }

    private String getUserSessionKey(String userId)
    {
        return USER_SESSION_KEY_PREFIX + userId;
    }
}
