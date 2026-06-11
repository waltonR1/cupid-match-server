package com.ruoyi.cupid.domain;

import java.util.Date;

/**
 * Cupid Match 会员套餐 cm_membership_plans
 */
public class CupidMembershipPlan
{
    private String id;
    private String tier;
    private int priceCents;
    private String currency;
    private int cnyPriceCents;
    private String billingType;
    private String billingPeriod;
    private Integer validityMonths;
    private int privateIntroductionQuota;
    private String privateIntroductionPeriod;
    private int eventQuota;
    private boolean eventPriorityEnabled;
    private boolean staffReviewEnabled;
    private String profileDetailAccessLevel;
    private String staffSupportLevel;
    private boolean conciergePriority;
    private boolean featured;
    private int sortOrder;
    private boolean isActive;
    private Date createdAt;
    private Date updatedAt;

    /** service 关联结果 */
    private String name;
    private String description;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getTier() { return tier; }
    public void setTier(String tier) { this.tier = tier; }
    public int getPriceCents() { return priceCents; }
    public void setPriceCents(int priceCents) { this.priceCents = priceCents; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public int getCnyPriceCents() { return cnyPriceCents; }
    public void setCnyPriceCents(int cnyPriceCents) { this.cnyPriceCents = cnyPriceCents; }
    public String getBillingType() { return billingType; }
    public void setBillingType(String billingType) { this.billingType = billingType; }
    public String getBillingPeriod() { return billingPeriod; }
    public void setBillingPeriod(String billingPeriod) { this.billingPeriod = billingPeriod; }
    public Integer getValidityMonths() { return validityMonths; }
    public void setValidityMonths(Integer validityMonths) { this.validityMonths = validityMonths; }
    public int getPrivateIntroductionQuota() { return privateIntroductionQuota; }
    public void setPrivateIntroductionQuota(int privateIntroductionQuota) { this.privateIntroductionQuota = privateIntroductionQuota; }
    public String getPrivateIntroductionPeriod() { return privateIntroductionPeriod; }
    public void setPrivateIntroductionPeriod(String privateIntroductionPeriod) { this.privateIntroductionPeriod = privateIntroductionPeriod; }
    public int getEventQuota() { return eventQuota; }
    public void setEventQuota(int eventQuota) { this.eventQuota = eventQuota; }
    public boolean isEventPriorityEnabled() { return eventPriorityEnabled; }
    public void setEventPriorityEnabled(boolean eventPriorityEnabled) { this.eventPriorityEnabled = eventPriorityEnabled; }
    public boolean isStaffReviewEnabled() { return staffReviewEnabled; }
    public void setStaffReviewEnabled(boolean staffReviewEnabled) { this.staffReviewEnabled = staffReviewEnabled; }
    public String getProfileDetailAccessLevel() { return profileDetailAccessLevel; }
    public void setProfileDetailAccessLevel(String profileDetailAccessLevel) { this.profileDetailAccessLevel = profileDetailAccessLevel; }
    public String getStaffSupportLevel() { return staffSupportLevel; }
    public void setStaffSupportLevel(String staffSupportLevel) { this.staffSupportLevel = staffSupportLevel; }
    public boolean isConciergePriority() { return conciergePriority; }
    public void setConciergePriority(boolean conciergePriority) { this.conciergePriority = conciergePriority; }
    public boolean isFeatured() { return featured; }
    public void setFeatured(boolean featured) { this.featured = featured; }
    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }
    public boolean getIsActive() { return isActive; }
    public void setIsActive(boolean isActive) { this.isActive = isActive; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
