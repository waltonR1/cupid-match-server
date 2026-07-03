package com.ruoyi.cupid.service.impl;

import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.mapper.CupidProfileMapper;
import com.ruoyi.cupid.service.ICupidRuntimeConfigService;
import com.ruoyi.cupid.service.ICupidScheduledMaintenanceService;

/**
 * Cupid 定时维护服务实现。
 */
@Service
public class CupidScheduledMaintenanceServiceImpl
        implements ICupidScheduledMaintenanceService
{
    private static final Logger log =
            LoggerFactory.getLogger(CupidScheduledMaintenanceServiceImpl.class);

    @Autowired
    private CupidProfileMapper profileMapper;

    @Autowired
    private CupidAuthMapper authMapper;

    @Autowired
    private ICupidRuntimeConfigService runtimeConfigService;

    @Override
    @Transactional
    public int expireIntroductionRequests()
    {
        List<Map<String, Object>> requests =
                profileMapper.selectExpiredIntroductionRequestsForUpdate(
                        runtimeConfigService.getScheduledMaintenanceBatchSize());
        int processed = 0;
        for (Map<String, Object> request : requests)
        {
            String requestId = String.valueOf(request.get("requestId"));
            if (profileMapper.updateIntroductionRequestExpired(requestId) != 1)
            {
                continue;
            }
            Object balanceId = request.get("entitlementBalanceId");
            if (balanceId != null)
            {
                profileMapper.restoreIntroductionEntitlement(String.valueOf(balanceId));
            }
            processed++;
        }
        log.info("Cupid 私人介绍过期维护完成，本次处理 {} 条", processed);
        return processed;
    }

    @Override
    @Transactional
    public int expireSecurityChallenges()
    {
        int processed = authMapper.expireSecurityChallenges(
                runtimeConfigService.getScheduledMaintenanceBatchSize());
        log.info("Cupid 安全挑战过期维护完成，本次处理 {} 条", processed);
        return processed;
    }
}
