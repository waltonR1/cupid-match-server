package com.ruoyi.cupid.service.impl;

import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.cupid.domain.CupidEvent;
import com.ruoyi.cupid.domain.CupidEventRegistration;
import com.ruoyi.cupid.domain.CupidUserMembership;
import com.ruoyi.cupid.mapper.CupidAdminStaffTaskMapper;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.mapper.CupidEventMapper;
import com.ruoyi.cupid.mapper.CupidMembershipMapper;
import com.ruoyi.cupid.mapper.CupidProfileMapper;
import com.ruoyi.cupid.service.ICupidInboxNotificationService;
import com.ruoyi.cupid.service.ICupidOperationsService;
import com.ruoyi.cupid.service.ICupidRuntimeConfigService;
import com.ruoyi.cupid.service.ICupidScheduledMaintenanceService;
import com.ruoyi.cupid.service.ICupidTranslationService;
import com.ruoyi.system.domain.SysNotice;
import com.ruoyi.system.mapper.SysNoticeMapper;

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
    private CupidMembershipMapper membershipMapper;

    @Autowired
    private CupidEventMapper eventMapper;

    @Autowired
    private CupidAdminStaffTaskMapper staffTaskMapper;

    @Autowired
    private ICupidInboxNotificationService inboxNotificationService;

    @Autowired
    private SysNoticeMapper noticeMapper;

    @Autowired
    private ICupidRuntimeConfigService runtimeConfigService;

    @Autowired
    private ICupidTranslationService translationService;

    @Autowired
    private ICupidOperationsService operationsService;

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

    @Override
    @Transactional
    public int expireMemberships()
    {
        int processed = membershipMapper.expireMemberships(
                runtimeConfigService.getScheduledMaintenanceBatchSize());
        log.info("Cupid 会员到期状态同步完成，本次处理 {} 条", processed);
        return processed;
    }

    @Override
    public int sendEventReminders()
    {
        List<Map<String, Object>> targets = eventMapper.selectUpcomingEventReminderTargets(
                runtimeConfigService.getScheduledMaintenanceBatchSize());
        int sent = 0;
        for (Map<String, Object> target : targets)
        {
            String userId = String.valueOf(target.get("userId"));
            String eventId = String.valueOf(target.get("eventId"));
            Map<String, Object> variables = Map.of(
                    "eventTitle", String.valueOf(target.get("eventTitle")),
                    "startsAt", String.valueOf(target.get("startsAt")));
            String dedupeKey = "event-reminder-24h:" + eventId + ":" + userId;
            try
            {
                String messageId = inboxNotificationService.sendSystemNotification(
                        userId, "event_reminder_24h", null, variables, eventId, dedupeKey);
                if (messageId != null)
                {
                    sent++;
                }
            }
            catch (RuntimeException error)
            {
                operationsService.recordSystemMessageFailure(
                        userId, "event_reminder_24h", variables, eventId, dedupeKey, error);
                log.error("Cupid event reminder failed: event={}, user={}", eventId, userId, error);
            }
        }
        log.info("Cupid 活动站内提醒完成，本次发送 {} 条", sent);
        return sent;
    }

    @Override
    public int sendOverdueStaffTaskReminders()
    {
        List<Map<String, Object>> targets = staffTaskMapper.selectOverdueStaffTaskReminderTargets(
                runtimeConfigService.getScheduledMaintenanceBatchSize());
        int sent = 0;
        for (Map<String, Object> target : targets)
        {
            SysNotice notice = new SysNotice();
            notice.setNoticeTitle("跟进事项已逾期");
            notice.setNoticeType("1");
            notice.setNoticeContent("跟进事项“" + target.get("note") + "”已超过截止时间，请及时处理。");
            notice.setStatus("0");
            notice.setCreateBy("system");
            String remark = "recipient:" + target.get("assigneeSysUserId")
                    + ":staff-task-overdue:" + target.get("taskId");
            notice.setRemark(remark);
            if (noticeMapper.countNoticeByRemark(remark) == 0)
            {
                sent += noticeMapper.insertNotice(notice);
            }
        }
        log.info("Cupid 跟进事项逾期提醒完成，本次发送 {} 条", sent);
        return sent;
    }

    @Override
    public int retryFailedTranslations()
    {
        int completed = translationService.retryFailedTranslations();
        log.info("Cupid translation retry completed, succeeded={}", completed);
        return completed;
    }

    @Override
    public int retryFailedMessages()
    {
        int completed = operationsService.retryFailedMessages();
        log.info("Cupid message retry completed, succeeded={}", completed);
        return completed;
    }

    @Override
    public int cleanupOperationalData()
    {
        int cleaned = operationsService.cleanupOperationalData();
        log.info("Cupid operational data cleanup completed, deleted={}", cleaned);
        return cleaned;
    }

    @Override
    @Transactional
    public int synchronizeEventLifecycle()
    {
        List<String> eventIds = eventMapper.selectEventLifecycleCandidates(
                runtimeConfigService.getScheduledMaintenanceBatchSize());
        int changed = 0;
        for (String eventId : eventIds)
        {
            CupidEvent event = eventMapper.selectEventByIdForUpdate(eventId);
            if (event == null)
            {
                continue;
            }
            if (eventMapper.markEventCompleted(eventId) == 1)
            {
                changed += eventMapper.markConfirmedRegistrationsAttended(eventId);
                changed++;
                continue;
            }

            int occupied = eventMapper.countEventOccupied(eventId);
            while (occupied < event.getCapacity())
            {
                CupidEventRegistration registration =
                        eventMapper.selectNextPendingRegistrationForUpdate(eventId);
                if (registration == null)
                {
                    break;
                }

                String balanceId = null;
                boolean consumeQuota = false;
                if (event.isConsumesMembershipQuota())
                {
                    CupidUserMembership membership =
                            authMapper.selectActiveMembershipByUserId(registration.getUserId());
                    if (membership == null)
                    {
                        break;
                    }
                    balanceId = eventMapper.selectAvailableEventEntitlementBalanceForUpdate(
                            registration.getUserId(), membership.getId());
                    if (balanceId == null
                            || eventMapper.consumeEventEntitlementById(balanceId) != 1)
                    {
                        break;
                    }
                    consumeQuota = true;
                }

                if (eventMapper.updateAdminRegistrationStatus(registration.getId(),
                        "confirmed", balanceId, consumeQuota, false) == 1)
                {
                    occupied++;
                    changed++;
                }
            }
        }
        log.info("Cupid 活动生命周期同步完成，本次状态变更 {} 条", changed);
        return changed;
    }
}
