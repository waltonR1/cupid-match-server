package com.ruoyi.cupid.service;

/**
 * Cupid 定时维护服务。
 */
public interface ICupidScheduledMaintenanceService
{
    /**
     * 处理过期的私人介绍申请并返还已消耗的权益。
     *
     * @return 本次处理数量
     */
    int expireIntroductionRequests();

    /**
     * 标记已超过有效期的安全挑战。
     *
     * @return 本次处理数量
     */
    int expireSecurityChallenges();

    /**
     * 同步已超过有效期的会员状态。
     *
     * @return 本次处理数量
     */
    int expireMemberships();

    int sendEventReminders();

    int sendOverdueStaffTaskReminders();

    int retryFailedTranslations();

    int retryFailedMessages();

    int cleanupOperationalData();
}
