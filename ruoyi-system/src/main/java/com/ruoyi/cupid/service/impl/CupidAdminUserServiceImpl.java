package com.ruoyi.cupid.service.impl;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.constant.CupidSecurityEventConstants;
import com.ruoyi.cupid.domain.CupidAuthIdentity;
import com.ruoyi.cupid.domain.CupidUser;
import com.ruoyi.cupid.mapper.CupidAdminUserMapper;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.mapper.CupidCommonOptionMapper;
import com.ruoyi.cupid.service.ICupidAdminUserService;
import com.ruoyi.cupid.service.ICupidSecurityEventService;
import com.ruoyi.cupid.service.ICupidTokenService;

@Service
public class CupidAdminUserServiceImpl implements ICupidAdminUserService
{
    @Autowired
    private CupidAdminUserMapper adminUserMapper;

    @Autowired
    private CupidAuthMapper authMapper;

    @Autowired
    private CupidCommonOptionMapper commonOptionMapper;

    @Autowired
    private ICupidTokenService cupidTokenService;

    @Autowired
    private ICupidSecurityEventService securityEventService;

    @Override
    public List<Map<String, Object>> selectAdminUsers(Map<String, Object> params)
    {
        Map<String, Object> query = normalizeListParams(params);
        List<Map<String, Object>> rows = adminUserMapper.selectAdminUsers(query);
        Map<String, Integer> sessionCounts = buildSessionCountMap(rows.stream()
                .map(row -> String.valueOf(row.get("id")))
                .collect(Collectors.toSet()));
        for (Map<String, Object> row : rows)
        {
            String userId = String.valueOf(row.get("id"));
            List<Map<String, Object>> sessions = buildSessionViewList(userId);
            row.put("sessionCount", sessionCounts.getOrDefault(userId, 0));
            row.put("lastLoginAt", sessions.isEmpty() ? null : sessions.get(0).get("createdAt"));
            row.put("online", !sessions.isEmpty());
        }
        return rows;
    }

    @Override
    public Map<String, Object> selectAdminUserDetail(String id)
    {
        Map<String, Object> detail = adminUserMapper.selectAdminUserDetail(id);
        if (detail == null)
        {
            throw new ServiceException("用户不存在");
        }
        List<Map<String, Object>> identities = adminUserMapper.selectUserIdentities(id);
        detail.put("identities", identities);
        detail.put("profiles", adminUserMapper.selectUserProfiles(id));
        detail.put("recentEvents", adminUserMapper.selectUserRecentEvents(id));
        detail.put("profileContacts", maskContacts(adminUserMapper.selectUserProfileContacts(id)));
        List<Map<String, Object>> sessions = buildSessionViewList(id);
        detail.put("sessions", sessions);
        detail.put("sessionCount", sessions.size());
        detail.put("lastLoginAt", sessions.isEmpty() ? null : sessions.get(0).get("createdAt"));
        return detail;
    }

    @Override
    public List<Map<String, Object>> selectUserSessions(String userId)
    {
        ensureUserExists(userId);
        return buildSessionViewList(userId);
    }

    @Override
    public void updateUserStatus(String userId, String status, String reason, String operatorUserId)
    {
        ensureUserExists(userId);
        if (!StringUtils.hasText(reason))
        {
            throw new ServiceException("请填写原因");
        }
        if (!"active".equals(status) && !"banned".equals(status))
        {
            throw new ServiceException("用户状态无效");
        }

        String targetStatus = status;
        adminUserMapper.updateUserStatus(userId, targetStatus);
        if ("banned".equals(status))
        {
            cupidTokenService.deleteUserTokens(userId);
        }

        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", operatorUserId,
                "user", userId, "cupid.user.changeStatus", null,
                JSON.toJSONString(Map.of("status", targetStatus)), reason);
    }

    @Override
    public void deleteUserSession(String userId, String sessionId, String reason, String operatorUserId)
    {
        ensureUserExists(userId);
        if (!cupidTokenService.deleteUserSession(userId, sessionId))
        {
            throw new ServiceException("会话不存在或不属于该用户");
        }
        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", operatorUserId,
                "user", userId, "cupid.user.kickSession", null,
                JSON.toJSONString(Map.of("sessionId", sessionId)), emptyToNull(reason));
        Map<String, Object> detail = new LinkedHashMap<>();
        detail.put("sessionId", sessionId);
        detail.put("operatorUserId", operatorUserId);
        detail.put("reason", emptyToNull(reason));
        detail.put("allSessions", false);
        securityEventService.recordEvent(userId, null,
                CupidSecurityEventConstants.EVENT_SESSION_KICKED,
                CupidSecurityEventConstants.RESULT_SUCCESS, null, null, detail);
    }

    @Override
    public void deleteAllUserSessions(String userId, String reason, String operatorUserId)
    {
        ensureUserExists(userId);
        cupidTokenService.deleteUserTokens(userId);
        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", operatorUserId,
                "user", userId, "cupid.user.kickAllSessions", null,
                JSON.toJSONString(Map.of("allSessions", true)), emptyToNull(reason));
        Map<String, Object> detail = new LinkedHashMap<>();
        detail.put("operatorUserId", operatorUserId);
        detail.put("reason", emptyToNull(reason));
        detail.put("allSessions", true);
        securityEventService.recordEvent(userId, null,
                CupidSecurityEventConstants.EVENT_SESSION_KICKED,
                CupidSecurityEventConstants.RESULT_SUCCESS, null, null, detail);
    }

    @Override
    public Map<String, Object> viewSensitive(String userId, String reason, String operatorUserId)
    {
        ensureUserExists(userId);
        if (!StringUtils.hasText(reason))
        {
            throw new ServiceException("请填写查看原因");
        }
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("identities", adminUserMapper.selectUserIdentities(userId).stream().map(identity -> {
            Map<String, Object> item = new LinkedHashMap<>(identity);
            item.remove("maskedIdentifier");
            return item;
        }).toList());
        result.put("profileContacts", adminUserMapper.selectUserProfileContacts(userId));
        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", operatorUserId,
                "user", userId, "cupid.user.viewSensitive", null,
                JSON.toJSONString(Map.of("fields", List.of("identities", "profileContacts"))), reason);
        return result;
    }

    private CupidUser ensureUserExists(String userId)
    {
        CupidUser user = authMapper.selectUserById(userId);
        if (user == null)
        {
            throw new ServiceException("用户不存在");
        }
        return user;
    }

    private Map<String, Object> normalizeListParams(Map<String, Object> params)
    {
        Map<String, Object> query = new HashMap<>();
        query.put("keyword", trim(params.get("keyword")));
        query.put("status", trim(params.get("status")));
        query.put("membershipTier", trim(params.get("membershipTier")));
        String online = trim(params.get("online"));
        boolean onlineOnly = "1".equals(online) || "true".equalsIgnoreCase(String.valueOf(online));
        boolean offlineOnly = "0".equals(online) || "false".equalsIgnoreCase(String.valueOf(online));
        query.put("onlineOnly", onlineOnly);
        query.put("offlineOnly", offlineOnly);
        if (onlineOnly || offlineOnly)
        {
            query.put("onlineUserIds", cupidTokenService.selectOnlineUserIds());
        }
        return query;
    }

    private Map<String, Integer> buildSessionCountMap(Set<String> userIds)
    {
        Map<String, Integer> result = new HashMap<>();
        Set<String> onlineUserIds = cupidTokenService.selectOnlineUserIds();
        for (String userId : userIds)
        {
            if (onlineUserIds.contains(userId))
            {
                result.put(userId, cupidTokenService.countUserSessions(userId));
            }
            else
            {
                result.put(userId, 0);
            }
        }
        return result;
    }

    private List<Map<String, Object>> buildSessionViewList(String userId)
    {
        List<CupidLoginUser> sessions = cupidTokenService.selectUserSessions(userId);
        if (sessions.isEmpty())
        {
            return List.of();
        }
        Map<String, CupidAuthIdentity> identities = authMapper.selectIdentitiesByUserId(userId).stream()
                .collect(Collectors.toMap(CupidAuthIdentity::getId, item -> item, (left, right) -> left));
        return sessions.stream().map(session -> {
            Map<String, Object> row = new LinkedHashMap<>();
            CupidAuthIdentity identity = identities.get(session.getIdentityId());
            row.put("sessionId", session.getSessionId());
            row.put("identityId", session.getIdentityId());
            row.put("provider", identity == null ? null : identity.getProvider());
            row.put("maskedIdentifier", identity == null ? null : maskIdentifier(identity.getProvider(),
                    identity.getIdentifier()));
            row.put("createdAt", session.getCreatedAt());
            row.put("expiresAt", session.getExpiresAt());
            return row;
        }).toList();
    }

    private List<Map<String, Object>> maskContacts(List<Map<String, Object>> contacts)
    {
        return contacts.stream().map(item -> {
            Map<String, Object> masked = new LinkedHashMap<>(item);
            masked.put("phone",
                    maskIdentifier("phone", item.get("phone") == null ? null : String.valueOf(item.get("phone"))));
            masked.put("email",
                    maskIdentifier("email", item.get("email") == null ? null : String.valueOf(item.get("email"))));
            if (item.get("wechat") != null)
            {
                String wechat = String.valueOf(item.get("wechat"));
                masked.put("wechat", wechat.length() <= 2 ? "**" : wechat.substring(0, 2) + "***");
            }
            return masked;
        }).toList();
    }

    private String trim(Object value)
    {
        if (value == null)
        {
            return null;
        }
        String text = String.valueOf(value).trim();
        return StringUtils.hasText(text) ? text : null;
    }

    private String emptyToNull(String value)
    {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private String maskIdentifier(String provider, String value)
    {
        if (!StringUtils.hasText(value))
        {
            return null;
        }
        if ("email".equals(provider))
        {
            int atIndex = value.indexOf("@");
            if (atIndex <= 2)
            {
                return "***" + (atIndex > 0 ? value.substring(atIndex) : "");
            }
            return value.substring(0, 2) + "***" + value.substring(atIndex);
        }
        if ("phone".equals(provider))
        {
            if (value.length() <= 7)
            {
                return value.substring(0, Math.min(2, value.length())) + "***";
            }
            return value.substring(0, 3) + "****" + value.substring(value.length() - 4);
        }
        return value.length() <= 2 ? "**" : value.substring(0, 2) + "***";
    }
}
