package com.ruoyi.cupid.event;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;
import com.ruoyi.cupid.service.ICupidInboxNotificationService;
import com.ruoyi.cupid.service.ICupidOperationsService;

/** 在业务事务提交后发送站内通知；发送失败不回滚核心业务。 */
@Component
public class CupidInboxNotificationListener
{
    private static final Logger log = LoggerFactory.getLogger(CupidInboxNotificationListener.class);

    @Autowired
    private ICupidInboxNotificationService notificationService;

    @Autowired
    private ICupidOperationsService operationsService;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onNotification(CupidInboxNotificationEvent event)
    {
        try
        {
            notificationService.sendSystemNotification(event.getUserId(), event.getTemplateCode(), null,
                    event.getVariables(), event.getSubjectId(), event.getDedupeKey());
        }
        catch (RuntimeException ex)
        {
            try
            {
                operationsService.recordSystemMessageFailure(event.getUserId(), event.getTemplateCode(),
                        event.getVariables(), event.getSubjectId(), event.getDedupeKey(), ex);
            }
            catch (RuntimeException persistError)
            {
                log.error("Cupid Inbox failure record could not be persisted: template={}, subject={}",
                        event.getTemplateCode(), event.getSubjectId(), persistError);
            }
            log.error("Cupid Inbox automatic notification failed: template={}, subject={}",
                    event.getTemplateCode(), event.getSubjectId(), ex);
        }
    }

}
