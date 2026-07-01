package com.ruoyi.framework.web.service;

import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.utils.ServletUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.ip.IpUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.service.ICupidTokenService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import jakarta.servlet.http.HttpServletRequest;

@Service
public class CupidTokenService implements ICupidTokenService
{
    private static final String SESSION_KEY_PREFIX = "cupid:session:";
    private static final String USER_SESSION_KEY_PREFIX = "cupid:user-sessions:";
    private static final String CLAIM_TOKEN_TYPE = "tokenType";
    private static final String CLAIM_SESSION_ID = "sessionId";
    private static final String CLAIM_USER_ID = "userId";
    private static final String TOKEN_TYPE = "cupid";
    private static final long MILLIS_MINUTE = 60 * 1000L;
    private static final long MILLIS_MINUTE_TWENTY = 20 * MILLIS_MINUTE;
    private static final String HEADER_DEVICE_ID = "X-Device-Id";
    private static final String HEADER_DEVICE_ID_ALT = "X-Device-ID";

    @Autowired
    private RedisCache redisCache;

    @Value("${token.secret}")
    private String secret;

    @Value("${token.header}")
    private String header;

    @Value("${token.expireTime}")
    private int expireTime;

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

    public void verifyToken(CupidLoginUser principal)
    {
        long now = System.currentTimeMillis();
        principal.setLastActiveAt(now);
        if (principal.getExpiresAt() - now <= MILLIS_MINUTE_TWENTY)
        {
            principal.setExpiresAt(now + expireTime * MILLIS_MINUTE);
        }
        storeSession(principal);
    }

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

    @Override
    public void deleteUserTokens(String userId)
    {
        if (userId == null)
        {
            return;
        }
        afterCommit(() -> deleteUserTokensNow(userId));
    }

    @Override
    public CupidLoginUser selectSession(String sessionId)
    {
        return StringUtils.hasText(sessionId) ? getSession(sessionId) : null;
    }

    @Override
    public List<CupidLoginUser> selectUserSessions(String userId)
    {
        if (!StringUtils.hasText(userId))
        {
            return List.of();
        }
        Set<String> sessionIds = redisCache.getCacheSet(getUserSessionKey(userId));
        if (sessionIds == null || sessionIds.isEmpty())
        {
            return List.of();
        }
        return sessionIds.stream()
                .map(this::getSession)
                .filter(session -> session != null && userId.equals(session.getUserId()))
                .sorted(Comparator.comparingLong(CupidLoginUser::getCreatedAt).reversed())
                .collect(Collectors.toList());
    }

    @Override
    public int countUserSessions(String userId)
    {
        return selectUserSessions(userId).size();
    }

    @Override
    public Set<String> selectOnlineUserIds()
    {
        Set<String> empty = Collections.emptySet();
        Collection<String> keys = redisCache.keys(USER_SESSION_KEY_PREFIX + "*");
        if (keys == null || keys.isEmpty())
        {
            return empty;
        }
        return keys.stream()
                .map(key -> key.substring(USER_SESSION_KEY_PREFIX.length()))
                .filter(StringUtils::hasText)
                .collect(Collectors.toSet());
    }

    @Override
    public boolean deleteUserSession(String userId, String sessionId)
    {
        CupidLoginUser session = selectSession(sessionId);
        if (session == null || !userId.equals(session.getUserId()))
        {
            return false;
        }
        deleteToken(sessionId);
        return true;
    }

    private CupidLoginUser createSession(String identityId, String userId)
    {
        long now = System.currentTimeMillis();
        HttpServletRequest request = ServletUtils.getRequest();
        CupidLoginUser session = new CupidLoginUser();
        session.setId(IdUtils.fastUUID());
        session.setIdentityId(identityId);
        session.setUserId(userId);
        session.setCreatedAt(now);
        session.setLastActiveAt(now);
        session.setExpiresAt(now + expireTime * MILLIS_MINUTE);
        session.setIp(resolveIp());
        session.setUserAgent(resolveUserAgent(request));
        session.setDeviceId(resolveDeviceId(request));
        afterCommit(() -> storeSession(session));
        return session;
    }

    private CupidLoginUser getSession(String sessionId)
    {
        return redisCache.getCacheObject(getSessionKey(sessionId));
    }

    private void storeSession(CupidLoginUser session)
    {
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

    private String resolveIp()
    {
        try
        {
            return IpUtils.getIpAddr();
        }
        catch (Exception e)
        {
            return null;
        }
    }

    private String resolveUserAgent(HttpServletRequest request)
    {
        if (request == null)
        {
            return null;
        }
        String userAgent = request.getHeader("User-Agent");
        return StringUtils.hasText(userAgent) ? userAgent.trim() : null;
    }

    private String resolveDeviceId(HttpServletRequest request)
    {
        if (request == null)
        {
            return null;
        }
        String deviceId = request.getHeader(HEADER_DEVICE_ID);
        if (!StringUtils.hasText(deviceId))
        {
            deviceId = request.getHeader(HEADER_DEVICE_ID_ALT);
        }
        return StringUtils.hasText(deviceId) ? deviceId.trim() : null;
    }
}
