package com.ruoyi.cupid.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.cupid.mapper.CupidAdminAuditMapper;
import com.ruoyi.cupid.service.ICupidAdminAuditService;

@Service
public class CupidAdminAuditServiceImpl implements ICupidAdminAuditService
{
    @Autowired
    private CupidAdminAuditMapper adminAuditMapper;

    @Override
    public List<Map<String, Object>> selectAdminAuditLogs(Map<String, Object> params)
    {
        Map<String, Object> query = new HashMap<>();
        query.put("action", trim(params.get("action")));
        query.put("subjectType", trim(params.get("subjectType")));
        query.put("subjectId", trim(params.get("subjectId")));
        query.put("operatorKeyword", trim(params.get("operatorKeyword")));
        query.put("dateFrom", trim(params.get("dateFrom")));
        query.put("dateTo", trim(params.get("dateTo")));
        return adminAuditMapper.selectAdminAuditLogs(query);
    }

    @Override
    public Map<String, Object> selectAdminAuditLogById(String id)
    {
        Map<String, Object> detail = adminAuditMapper.selectAdminAuditLogById(id);
        if (detail == null)
        {
            throw new ServiceException("审计记录不存在");
        }
        return detail;
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
