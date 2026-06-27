package com.ruoyi.cupid.domain;

import java.util.Date;

/**
 * Cupid Match 活动报名 cm_event_registrations。
 */
public class CupidEventRegistration
{
    private String id;
    private String userId;
    private String eventId;
    private String entitlementBalanceId;
    private String status;
    private Date requestedAt;
    private Date confirmedAt;
    private Date declinedAt;
    private Date waitlistedAt;
    private Date cancelledAt;
    private Date attendedAt;
    private Date eventQuotaConsumedAt;
    private Date eventQuotaReleasedAt;
    private Date createdAt;
    private Date updatedAt;

    // -- service-assembled --
    private String userAccountName;
    private String eventTitle;
    private Date eventDate;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getEventId() { return eventId; }
    public void setEventId(String eventId) { this.eventId = eventId; }

    public String getEntitlementBalanceId() { return entitlementBalanceId; }
    public void setEntitlementBalanceId(String entitlementBalanceId) { this.entitlementBalanceId = entitlementBalanceId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getRequestedAt() { return requestedAt; }
    public void setRequestedAt(Date requestedAt) { this.requestedAt = requestedAt; }

    public Date getConfirmedAt() { return confirmedAt; }
    public void setConfirmedAt(Date confirmedAt) { this.confirmedAt = confirmedAt; }

    public Date getDeclinedAt() { return declinedAt; }
    public void setDeclinedAt(Date declinedAt) { this.declinedAt = declinedAt; }

    public Date getWaitlistedAt() { return waitlistedAt; }
    public void setWaitlistedAt(Date waitlistedAt) { this.waitlistedAt = waitlistedAt; }

    public Date getCancelledAt() { return cancelledAt; }
    public void setCancelledAt(Date cancelledAt) { this.cancelledAt = cancelledAt; }

    public Date getAttendedAt() { return attendedAt; }
    public void setAttendedAt(Date attendedAt) { this.attendedAt = attendedAt; }

    public Date getEventQuotaConsumedAt() { return eventQuotaConsumedAt; }
    public void setEventQuotaConsumedAt(Date eventQuotaConsumedAt) { this.eventQuotaConsumedAt = eventQuotaConsumedAt; }

    public Date getEventQuotaReleasedAt() { return eventQuotaReleasedAt; }
    public void setEventQuotaReleasedAt(Date eventQuotaReleasedAt) { this.eventQuotaReleasedAt = eventQuotaReleasedAt; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

    public String getUserAccountName() { return userAccountName; }
    public void setUserAccountName(String userAccountName) { this.userAccountName = userAccountName; }

    public String getEventTitle() { return eventTitle; }
    public void setEventTitle(String eventTitle) { this.eventTitle = eventTitle; }

    public Date getEventDate() { return eventDate; }
    public void setEventDate(Date eventDate) { this.eventDate = eventDate; }
}
