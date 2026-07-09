package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.cupid.domain.CupidMembershipPlan;
import com.ruoyi.cupid.domain.CupidUser;
import com.ruoyi.cupid.domain.CupidUserEntitlementBalance;
import com.ruoyi.cupid.domain.CupidUserMembership;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.mapper.CupidMembershipMapper;
import com.ruoyi.cupid.service.ICupidMembershipService;
import com.ruoyi.cupid.service.ICupidPaymentService;

/**
 * Cupid Match 会员服务实现
 */
@Service
public class CupidMembershipServiceImpl implements ICupidMembershipService
{
    @Autowired
    private CupidMembershipMapper membershipMapper;

    @Autowired
    private CupidAuthMapper authMapper;

    @Autowired
    private ICupidPaymentService paymentService;

    @Override
    public Map<String, Object> getCatalog(String locale)
    {
        List<CupidMembershipPlan> plans = membershipMapper.selectActivePlans();
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("plans", buildPlanDtos(plans, locale));
        return result;
    }

    @Override
    public Map<String, Object> getAccountMembership(String userId, String locale)
    {
        CupidUser user = authMapper.selectUserById(userId);
        if (user == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "account_not_found");
        }
        String loc = locale != null ? locale : user.getPreferredLocale();
        List<CupidMembershipPlan> allPlans = membershipMapper.selectActivePlans();
        CupidUserMembership activeMembership = authMapper.selectActiveMembershipByUserId(userId);
        CupidUserMembership displayedMembership = activeMembership != null
                ? activeMembership : membershipMapper.selectLatestMembershipByUserId(userId);
        CupidMembershipPlan currentPlan;
        if (displayedMembership != null)
        {
            currentPlan = membershipMapper.selectPlanById(displayedMembership.getPlanId());
            if (currentPlan == null)
            {
                throw new CupidApiException(HttpStatus.ERROR, "membership_plan_not_found");
            }
        }
        else
        {
            currentPlan = findFreePlan(allPlans);
            if (currentPlan == null)
            {
                throw new CupidApiException(HttpStatus.ERROR, "free_membership_plan_not_found");
            }
        }

        Map<String, Object> membershipDto = new LinkedHashMap<>();
        Map<String, String> names = loadNames(loc);
        membershipDto.put("tier", currentPlan.getTier());
        membershipDto.put("name", names.getOrDefault(currentPlan.getId() + ":name", currentPlan.getTier()));
        membershipDto.put("status", displayedMembership != null ? resolveMembershipStatus(displayedMembership) : "active");
        membershipDto.put("startedAt", displayedMembership != null ? displayedMembership.getStartedAt() : user.getCreatedAt());
        membershipDto.put("expiresAt", displayedMembership != null ? displayedMembership.getExpiresAt() : null);
        membershipDto.put("staffSupportLevel", currentPlan.getStaffSupportLevel());
        membershipDto.put("conciergePriority", currentPlan.isConciergePriority());

        List<CupidUserEntitlementBalance> balances = activeMembership == null
                ? new ArrayList<>()
                : membershipMapper.selectCurrentEntitlementBalances(userId, activeMembership.getId());
        List<Map<String, Object>> entitlements = new ArrayList<>();
        for (CupidUserEntitlementBalance b : balances)
        {
            Map<String, Object> e = new LinkedHashMap<>();
            e.put("code", b.getEntitlementCode());
            e.put("quotaTotal", b.getQuotaTotal());
            e.put("quotaUsed", b.getQuotaUsed());
            e.put("quotaRemaining", b.getQuotaRemaining());
            e.put("periodStartedAt", b.getPeriodStartedAt());
            e.put("periodEndsAt", b.getPeriodEndsAt());
            entitlements.add(e);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("membership", membershipDto);
        result.put("entitlements", entitlements);
        result.put("availablePlans", buildPlanDtos(allPlans, loc));
        return result;
    }

    @Override
    public Map<String, Object> requestUpgrade(String userId, String tier)
    {
        CupidUser user = authMapper.selectUserById(userId);
        if (user == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "account_not_found");
        }
        if (!"active".equals(user.getStatus()))
        {
            throw new CupidApiException(HttpStatus.FORBIDDEN, "account_not_active");
        }
        if (tier == null)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_tier");
        }
        List<CupidMembershipPlan> plans = membershipMapper.selectActivePlans();
        boolean found = false;
        for (CupidMembershipPlan p : plans)
        {
            if (tier.equals(p.getTier()))
            {
                found = true;
                break;
            }
        }
        if (!found)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_tier");
        }
        return paymentService.createMembershipSubscriptionCheckout(userId, tier);
    }

    private List<Map<String, Object>> buildPlanDtos(List<CupidMembershipPlan> plans, String locale)
    {
        Map<String, String> names = loadNames(locale);
        List<Map<String, Object>> dtos = new ArrayList<>();
        for (CupidMembershipPlan plan : plans)
        {
            Map<String, Object> dto = new LinkedHashMap<>();
            dto.put("id", plan.getId());
            dto.put("tier", plan.getTier());
            dto.put("name", names.getOrDefault(plan.getId() + ":name", plan.getTier()));
            dto.put("description", names.getOrDefault(plan.getId() + ":description", ""));
            dto.put("priceCents", plan.getPriceCents());
            dto.put("currency", plan.getCurrency());
            dto.put("cnyPriceCents", plan.getCnyPriceCents());
            dto.put("billingType", plan.getBillingType());
            dto.put("billingPeriod", plan.getBillingPeriod());
            dto.put("validityMonths", plan.getValidityMonths());
            dto.put("privateIntroductionQuota", plan.getPrivateIntroductionQuota());
            dto.put("privateIntroductionPeriod", plan.getPrivateIntroductionPeriod());
            dto.put("eventQuota", plan.getEventQuota());
            dto.put("eventPriorityEnabled", plan.isEventPriorityEnabled());
            dto.put("staffReviewEnabled", plan.isStaffReviewEnabled());
            dto.put("profileDetailAccessLevel", plan.getProfileDetailAccessLevel());
            dto.put("staffSupportLevel", plan.getStaffSupportLevel());
            dto.put("conciergePriority", plan.isConciergePriority());
            dto.put("featured", plan.isFeatured());
            dto.put("sortOrder", plan.getSortOrder());
            dtos.add(dto);
        }
        return dtos;
    }

    private Map<String, String> loadNames(String locale)
    {
        String loc = locale != null && (locale.equals("fr") || locale.equals("en")) ? locale : "zh";
        List<Map<String, Object>> rows = membershipMapper.selectPlanLocalizedNames(loc);
        if (rows.isEmpty() && !"zh".equals(loc))
        {
            rows = membershipMapper.selectPlanLocalizedNames("zh");
        }
        Map<String, String> names = new LinkedHashMap<>();
        for (Map<String, Object> row : rows)
        {
            names.putIfAbsent(row.get("planId") + ":" + row.get("fieldName"),
                    (String) row.get("value"));
        }
        return names;
    }

    private CupidMembershipPlan findFreePlan(List<CupidMembershipPlan> plans)
    {
        for (CupidMembershipPlan p : plans)
        {
            if ("free".equals(p.getTier())) return p;
        }
        return null;
    }

    private String resolveMembershipStatus(CupidUserMembership membership)
    {
        if ("active".equals(membership.getStatus())
                && membership.getExpiresAt() != null
                && !membership.getExpiresAt().after(new java.util.Date()))
        {
            return "expired";
        }
        return membership.getStatus();
    }
}
