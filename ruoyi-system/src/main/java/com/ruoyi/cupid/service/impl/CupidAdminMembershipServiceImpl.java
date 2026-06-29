package com.ruoyi.cupid.service.impl;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.mapper.CupidAdminMembershipMapper;
import com.ruoyi.cupid.mapper.CupidCommonOptionMapper;
import com.ruoyi.cupid.service.ICupidAdminMembershipService;

@Service
public class CupidAdminMembershipServiceImpl implements ICupidAdminMembershipService
{
    private static final Set<String> ALLOWED_STATUSES = Set.of("active", "expired", "cancelled", "paused");

    @Autowired
    private CupidAdminMembershipMapper adminMembershipMapper;

    @Autowired
    private CupidCommonOptionMapper commonOptionMapper;

    @Override
    public List<Map<String, Object>> selectAdminMemberships(Map<String, Object> params)
    {
        Map<String, Object> query = new HashMap<>();
        query.put("keyword", trim(params.get("keyword")));
        query.put("status", trim(params.get("status")));
        query.put("tier", trim(params.get("tier")));
        return adminMembershipMapper.selectAdminMemberships(query);
    }

    @Override
    public Map<String, Object> selectAdminMembershipDetail(String id)
    {
        Map<String, Object> detail = adminMembershipMapper.selectAdminMembershipDetail(id);
        if (detail == null)
        {
            throw new ServiceException("会员记录不存在");
        }
        return detail;
    }

    @Override
    public void updateMembershipStatus(String id, String status, String reason, String operatorUserId)
    {
        Map<String, Object> before = selectAdminMembershipDetail(id);
        if (!ALLOWED_STATUSES.contains(status))
        {
            throw new ServiceException("会员状态无效");
        }
        if (!StringUtils.hasText(reason))
        {
            throw new ServiceException("请填写原因");
        }
        adminMembershipMapper.updateMembershipStatus(id, status);
        Map<String, Object> beforeAudit = new LinkedHashMap<>();
        beforeAudit.put("status", before.get("status"));
        Map<String, Object> afterAudit = new LinkedHashMap<>();
        afterAudit.put("status", status);
        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", operatorUserId,
                "membership", id, "cupid.membership.changeStatus",
                JSON.toJSONString(beforeAudit),
                JSON.toJSONString(afterAudit), reason.trim());
    }

    @Override
    public void updateMembershipFields(String id, String tier, String startedAt, String expiresAt,
            String reason, String operatorUserId)
    {
        Map<String, Object> before = selectAdminMembershipDetail(id);
        if (!StringUtils.hasText(reason))
        {
            throw new ServiceException("请填写原因");
        }
        if (!StringUtils.hasText(tier))
        {
            throw new ServiceException("请选择会员等级");
        }
        Map<String, Object> plan = adminMembershipMapper.selectPlanByTier(tier);
        if (plan == null)
        {
            throw new ServiceException("会员等级无效");
        }
        Date startedDate = parseDateTime(startedAt, "开始时间");
        Date expiresDate = parseOptionalDateTime(expiresAt, "到期时间");
        if (expiresDate != null && !expiresDate.after(startedDate))
        {
            throw new ServiceException("到期时间必须晚于开始时间");
        }
        adminMembershipMapper.updateMembershipFields(id, String.valueOf(plan.get("id")), tier, startedDate, expiresDate);
        Map<String, Object> beforeAudit = new LinkedHashMap<>();
        beforeAudit.put("tier", before.get("tier"));
        beforeAudit.put("startedAt", before.get("startedAt"));
        beforeAudit.put("expiresAt", before.get("expiresAt"));
        Map<String, Object> afterAudit = new LinkedHashMap<>();
        afterAudit.put("tier", tier);
        afterAudit.put("startedAt", startedDate);
        afterAudit.put("expiresAt", expiresDate);
        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", operatorUserId,
                "membership", id, "cupid.membership.edit",
                JSON.toJSONString(beforeAudit),
                JSON.toJSONString(afterAudit), reason.trim());
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

    private Date parseOptionalDateTime(String value, String fieldName)
    {
        String text = trim(value);
        return StringUtils.hasText(text) ? parseDateTime(text, fieldName) : null;
    }

    private Date parseDateTime(String value, String fieldName)
    {
        String text = trim(value);
        if (!StringUtils.hasText(text))
        {
            throw new ServiceException(fieldName + "不能为空");
        }
        try
        {
            if (text.endsWith("Z"))
            {
                return Date.from(Instant.parse(text));
            }
            DateTimeFormatter formatter = text.length() == 16
                    ? DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")
                    : DateTimeFormatter.ISO_LOCAL_DATE_TIME;
            LocalDateTime localDateTime = LocalDateTime.parse(text, formatter);
            return Date.from(localDateTime.atZone(ZoneId.systemDefault()).toInstant());
        }
        catch (DateTimeParseException ex)
        {
            throw new ServiceException(fieldName + "格式无效");
        }
    }
}
