package com.ruoyi.quartz.task;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.cupid.service.ICupidScheduledMaintenanceService;

/**
 * Cupid 业务定时任务入口。
 */
@Component("cupidTask")
public class CupidTask
{
    @Autowired
    private ICupidScheduledMaintenanceService scheduledMaintenanceService;

    public void expireIntroductionRequests()
    {
        scheduledMaintenanceService.expireIntroductionRequests();
    }

    public void expireSecurityChallenges()
    {
        scheduledMaintenanceService.expireSecurityChallenges();
    }
}
