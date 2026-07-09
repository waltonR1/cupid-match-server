package com.ruoyi.cupid.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.ruoyi.cupid.mapper.CupidPaymentMapper;
import com.ruoyi.cupid.service.ICupidAdminPaymentService;

@Service
public class CupidAdminPaymentServiceImpl implements ICupidAdminPaymentService
{
    private final CupidPaymentMapper paymentMapper;

    public CupidAdminPaymentServiceImpl(CupidPaymentMapper paymentMapper)
    {
        this.paymentMapper = paymentMapper;
    }

    @Override
    public List<Map<String, Object>> selectAdminOrders(Map<String, Object> params)
    {
        Map<String, Object> query = new HashMap<>();
        query.put("keyword", trim(params.get("keyword")));
        query.put("status", trim(params.get("status")));
        query.put("tier", trim(params.get("tier")));
        return paymentMapper.selectAdminOrders(query);
    }

    @Override
    public List<Map<String, Object>> selectAdminWebhookEvents(Map<String, Object> params)
    {
        Map<String, Object> query = new HashMap<>();
        query.put("eventType", trim(params.get("eventType")));
        query.put("processStatus", trim(params.get("processStatus")));
        return paymentMapper.selectAdminWebhookEvents(query);
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
