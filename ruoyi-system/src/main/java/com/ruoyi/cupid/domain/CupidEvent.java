package com.ruoyi.cupid.domain;

import java.util.Date;
import java.util.List;

/**
 * Cupid Match 活动 cm_events
 */
public class CupidEvent
{
    private String id;
    private String slug;
    private String status;
    private String visibility;
    private boolean consumesMembershipQuota;
    private String cityCode;
    private String city;
    private String addressVisibility;
    private Date eventDate;
    private String startTime;
    private String endTime;
    private int capacity;
    private String coverImageUrl;
    private Date createdAt;
    private Date updatedAt;

    /** service 关联结果（来自 cm_event_localized_fields） */
    private String title;
    private String summary;
    private String venue;
    private String address;
    private String format;
    private String audience;
    private String curatorNote;
    private List<String> relationshipFocus;

    /** service 聚合的报名统计 */
    private int registeredCount;
    private int waitlistCount;
    private int remainingSeats;
    private String registrationStatus;
    private String registrationId;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getVisibility() { return visibility; }
    public void setVisibility(String visibility) { this.visibility = visibility; }
    public boolean isConsumesMembershipQuota() { return consumesMembershipQuota; }
    public void setConsumesMembershipQuota(boolean consumesMembershipQuota) { this.consumesMembershipQuota = consumesMembershipQuota; }
    public String getCityCode() { return cityCode; }
    public void setCityCode(String cityCode) { this.cityCode = cityCode; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getAddressVisibility() { return addressVisibility; }
    public void setAddressVisibility(String addressVisibility) { this.addressVisibility = addressVisibility; }
    public Date getEventDate() { return eventDate; }
    public void setEventDate(Date eventDate) { this.eventDate = eventDate; }
    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }
    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }
    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
    public String getCoverImageUrl() { return coverImageUrl; }
    public void setCoverImageUrl(String coverImageUrl) { this.coverImageUrl = coverImageUrl; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }
    public String getVenue() { return venue; }
    public void setVenue(String venue) { this.venue = venue; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getFormat() { return format; }
    public void setFormat(String format) { this.format = format; }
    public String getAudience() { return audience; }
    public void setAudience(String audience) { this.audience = audience; }
    public String getCuratorNote() { return curatorNote; }
    public void setCuratorNote(String curatorNote) { this.curatorNote = curatorNote; }
    public List<String> getRelationshipFocus() { return relationshipFocus; }
    public void setRelationshipFocus(List<String> relationshipFocus) { this.relationshipFocus = relationshipFocus; }
    public int getRegisteredCount() { return registeredCount; }
    public void setRegisteredCount(int registeredCount) { this.registeredCount = registeredCount; }
    public int getWaitlistCount() { return waitlistCount; }
    public void setWaitlistCount(int waitlistCount) { this.waitlistCount = waitlistCount; }
    public int getRemainingSeats() { return remainingSeats; }
    public void setRemainingSeats(int remainingSeats) { this.remainingSeats = remainingSeats; }
    public String getRegistrationStatus() { return registrationStatus; }
    public void setRegistrationStatus(String registrationStatus) { this.registrationStatus = registrationStatus; }
    public String getRegistrationId() { return registrationId; }
    public void setRegistrationId(String registrationId) { this.registrationId = registrationId; }
}
