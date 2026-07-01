package com.ruoyi.cupid.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.ServletUtils;
import com.ruoyi.common.utils.ip.IpUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.domain.CupidSecurityEvent;
import com.ruoyi.cupid.mapper.CupidSecurityEventMapper;
import com.ruoyi.cupid.service.ICupidSecurityEventService;
import jakarta.servlet.http.HttpServletRequest;

@Service
public class CupidSecurityEventServiceImpl implements ICupidSecurityEventService
{
    private static final Logger log = LoggerFactory.getLogger(CupidSecurityEventServiceImpl.class);

    @Autowired
    private CupidSecurityEventMapper securityEventMapper;

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordEvent(String userId, String identityId, String eventType, String eventResult,
            String riskLevel, String deviceId, Map<String, Object> detail)
    {
        try
        {
            CupidSecurityEvent event = new CupidSecurityEvent();
            event.setId(IdUtils.fastUUID());
            event.setUserId(trim(userId));
            event.setIdentityId(trim(identityId));
            event.setEventType(trim(eventType));
            event.setEventResult(trim(eventResult));
            event.setRiskLevel(trim(riskLevel));
            event.setDeviceId(trim(deviceId));
            event.setIp(resolveIp());
            event.setUserAgent(resolveUserAgent());
            event.setDetailJson(detail == null || detail.isEmpty() ? null : JSON.toJSONString(detail));
            securityEventMapper.insertSecurityEvent(event);
        }
        catch (Exception e)
        {
            log.warn("Failed to record Cupid security event: type={}, result={}, userId={}",
                    eventType, eventResult, userId, e);
        }
    }

    @Override
    public List<Map<String, Object>> selectAdminSecurityEvents(Map<String, Object> params)
    {
        Map<String, Object> query = new HashMap<>();
        query.put("userId", trim(params.get("userId")));
        query.put("eventType", trim(params.get("eventType")));
        query.put("eventResult", trim(params.get("eventResult")));
        query.put("dateFrom", trim(params.get("dateFrom")));
        query.put("dateTo", trim(params.get("dateTo")));
        query.put("keyword", trim(params.get("keyword")));
        return securityEventMapper.selectAdminSecurityEvents(query);
    }

    @Override
    public Map<String, Object> selectAdminSecurityEventById(String id)
    {
        Map<String, Object> detail = securityEventMapper.selectAdminSecurityEventById(id);
        if (detail == null)
        {
            throw new ServiceException("安全事件不存在");
        }
        return detail;
    }

    private String resolveIp()
    {
        try
        {
            return IpUtils.getIpAddr();
        }
        catch (Exception e)
        {
            return null;
        }
    }

    private String resolveUserAgent()
    {
        try
        {
            HttpServletRequest request = ServletUtils.getRequest();
            String userAgent = request == null ? null : request.getHeader("User-Agent");
            return StringUtils.hasText(userAgent) ? userAgent.trim() : null;
        }
        catch (Exception e)
        {
            return null;
        }
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
}
