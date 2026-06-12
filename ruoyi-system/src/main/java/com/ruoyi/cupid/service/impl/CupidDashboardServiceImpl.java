package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.cupid.domain.CupidUser;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.service.ICupidDashboardService;
import com.ruoyi.cupid.service.ICupidEventService;
import com.ruoyi.cupid.service.ICupidMembershipService;
import com.ruoyi.cupid.service.ICupidProfileService;
import com.ruoyi.cupid.service.ICupidRelationshipService;

/**
 * Cupid Match 账户首页聚合服务实现。
 */
@Service
public class CupidDashboardServiceImpl implements ICupidDashboardService
{
    @Autowired
    private CupidAuthMapper authMapper;

    @Autowired
    private ICupidProfileService profileService;

    @Autowired
    private ICupidMembershipService membershipService;

    @Autowired
    private ICupidEventService eventService;

    @Autowired
    private ICupidRelationshipService relationshipService;

    @Override
    public Map<String, Object> getDashboard(String userId, String locale)
    {
        CupidUser user = authMapper.selectUserById(userId);
        if (user == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "account_not_found");
        }

        Map<String, Object> membership =
                membershipService.getAccountMembership(userId, locale);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("user", userSummary(user));
        result.put("profiles", profileService.getOwnerProfiles(userId, locale).get("profiles"));
        result.put("membership", membership.get("membership"));
        result.put("entitlements", membership.get("entitlements"));
        result.put("upcomingEvents", upcomingEvents(eventService.getMyEvents(userId, locale)));
        result.put("recentIntroductions",
                relationshipService.getIntroductions(userId, locale).stream().limit(3).toList());
        result.put("favoriteCount", relationshipService.countFavorites(userId));
        return result;
    }

    private Map<String, Object> userSummary(CupidUser user)
    {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", user.getId());
        result.put("accountName", user.getAccountName());
        result.put("avatarUrl", user.getAvatarUrl());
        result.put("preferredLocale", user.getPreferredLocale());
        result.put("status", user.getStatus());
        return result;
    }

    private List<Map<String, Object>> upcomingEvents(List<Map<String, Object>> events)
    {
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map<String, Object> event : events)
        {
            Object status = event.get("status");
            if ("requested".equals(status) || "confirmed".equals(status)
                    || "waitlist".equals(status))
            {
                result.add(event);
                if (result.size() == 3)
                {
                    break;
                }
            }
        }
        return result;
    }
}
