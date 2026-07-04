package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.service.ICupidBusinessMonitorService;
import com.ruoyi.cupid.service.ICupidOperationsService;

/**
 * Cupid 业务专项监控服务实现
 */
@Service
public class CupidBusinessMonitorServiceImpl implements ICupidBusinessMonitorService
{
    private static final Logger log = LoggerFactory.getLogger(CupidBusinessMonitorServiceImpl.class);

    private static final String ALL_CUPID_KEYS = "cupid:*";

    private static final List<MetricDefinition> REDIS_METRICS = List.of(
            new MetricDefinition("sessions", "用户会话", "cupid:session:*"),
            new MetricDefinition("sessionIndexes", "用户会话索引", "cupid:user-sessions:*"),
            new MetricDefinition("verificationCodes", "验证码", "cupid:verification-code:*"),
            new MetricDefinition("verificationCooldowns", "验证码发送冷却", "cupid:verification-cooldown:*"),
            new MetricDefinition("verificationReservations", "验证码事务占用", "cupid:verification-reservation:*"),
            new MetricDefinition("loginFailureCounters", "登录失败计数", "cupid:risk:login-fail:*"),
            new MetricDefinition("knownEnvironments", "已知登录环境", "cupid:risk:known-env:*"));

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private CupidAuthMapper authMapper;

    @Autowired
    private ICupidOperationsService operationsService;

    @Override
    public Map<String, Object> getOverview()
    {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("checkedAt", System.currentTimeMillis());

        try
        {
            long totalCupidKeys = countKeys(ALL_CUPID_KEYS);
            long knownKeyCount = 0;
            List<Map<String, Object>> redisMetrics = new ArrayList<>();
            for (MetricDefinition definition : REDIS_METRICS)
            {
                long count = countKeys(definition.pattern());
                knownKeyCount += count;
                redisMetrics.add(metric(definition.code(), definition.name(), definition.pattern(), count));
            }

            long otherCupidKeys = Math.max(0, totalCupidKeys - knownKeyCount);
            redisMetrics.add(metric("otherCupidKeys", "其他 Cupid 缓存", "cupid:*（未分类）", otherCupidKeys));

            result.put("status", "healthy");
            result.put("totalCupidKeys", totalCupidKeys);
            result.put("activeSessions", valueOf(redisMetrics, "sessions"));
            result.put("onlineUsers", valueOf(redisMetrics, "sessionIndexes"));
            result.put("verificationCodes", valueOf(redisMetrics, "verificationCodes"));
            result.put("riskCounters", valueOf(redisMetrics, "loginFailureCounters"));
            result.put("redisMetrics", redisMetrics);
        }
        catch (RuntimeException e)
        {
            log.warn("Failed to read Cupid Redis monitor metrics", e);
            result.put("status", "unavailable");
            result.put("totalCupidKeys", 0L);
            result.put("activeSessions", 0L);
            result.put("onlineUsers", 0L);
            result.put("verificationCodes", 0L);
            result.put("riskCounters", 0L);
            result.put("redisMetrics", List.of());
        }

        result.put("activeChallengeTokens", authMapper.countActiveSecurityChallenges());
        result.put("operations", operationsService.getOperationalStatistics());
        return result;
    }

    private long countKeys(String pattern)
    {
        return redisCache.countKeys(pattern);
    }

    private Map<String, Object> metric(String code, String name, String pattern, long count)
    {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("code", code);
        item.put("name", name);
        item.put("pattern", pattern);
        item.put("count", count);
        return item;
    }

    private long valueOf(List<Map<String, Object>> metrics, String code)
    {
        return metrics.stream()
                .filter(item -> code.equals(item.get("code")))
                .map(item -> (Number) item.get("count"))
                .mapToLong(Number::longValue)
                .findFirst()
                .orElse(0L);
    }

    private record MetricDefinition(String code, String name, String pattern)
    {
    }
}
