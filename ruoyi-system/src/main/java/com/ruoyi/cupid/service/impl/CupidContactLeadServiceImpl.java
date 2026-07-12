package com.ruoyi.cupid.service.impl;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.mapper.CupidCommonOptionMapper;
import com.ruoyi.cupid.mapper.CupidContactLeadMapper;
import com.ruoyi.cupid.service.ICupidAdminContactLeadService;
import com.ruoyi.cupid.service.ICupidContactLeadService;

/**
 * Cupid Match contact lead service.
 */
@Service
public class CupidContactLeadServiceImpl implements ICupidContactLeadService, ICupidAdminContactLeadService
{
    private static final Set<String> ALLOWED_INQUIRY_TYPES = Set.of(
            "platform", "membership", "event", "advisor", "partnership", "complaint", "privacy", "other");
    private static final Set<String> ALLOWED_CONTACT_CHANNELS = Set.of("email", "phone", "wechat");
    private static final Set<String> ALLOWED_STATUSES = Set.of("new", "processing", "resolved", "ignored");

    @Autowired
    private CupidContactLeadMapper contactLeadMapper;

    @Autowired
    private CupidCommonOptionMapper commonOptionMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> createContactLead(Map<String, Object> body)
    {
        String id = IdUtils.fastUUID();
        String inquiryType = requireAllowedWithDefault(body.get("inquiryType"), "platform", "inquiryType", ALLOWED_INQUIRY_TYPES);
        String name = optionalText(body.get("name"), 80, "name");
        String contactChannel = requireAllowed(body.get("contactChannel"), "contactChannel", ALLOWED_CONTACT_CHANNELS);
        String contactValue = requireText(body.get("contactValue"), "contactValue", 191);
        String message = requireText(body.get("message"), "message", 1000);
        validateContactValue(contactChannel, contactValue);

        contactLeadMapper.insertContactLead(id, "contact_page", inquiryType, name, contactChannel, contactValue, message);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", id);
        result.put("status", "new");
        return result;
    }

    @Override
    public List<Map<String, Object>> selectAdminContactLeads(Map<String, Object> params)
    {
        Map<String, Object> query = new HashMap<>();
        query.put("keyword", trim(params.get("keyword")));
        query.put("inquiryType", trim(params.get("inquiryType")));
        query.put("contactChannel", trim(params.get("contactChannel")));
        query.put("status", trim(params.get("status")));
        return contactLeadMapper.selectAdminContactLeads(query);
    }

    @Override
    public Map<String, Object> selectAdminContactLeadById(String id)
    {
        Map<String, Object> detail = contactLeadMapper.selectAdminContactLeadById(id);
        if (detail == null)
        {
            throw new ServiceException("contact_lead_not_found");
        }
        return detail;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleAdminContactLead(String id, Map<String, Object> body, String operatorUserId)
    {
        Map<String, Object> before = selectAdminContactLeadById(id);
        String status = requireAllowed(body.get("status"), "status", ALLOWED_STATUSES);
        String handlerNote = optionalText(body.get("handlerNote"), 1000, "handlerNote");
        if (("resolved".equals(status) || "ignored".equals(status)) && !StringUtils.hasText(handlerNote))
        {
            throw new ServiceException("handler_note_required");
        }

        contactLeadMapper.updateAdminContactLead(id, status, operatorUserId, handlerNote);

        Map<String, Object> after = new LinkedHashMap<>();
        after.put("status", status);
        after.put("handlerNote", handlerNote);
        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", operatorUserId,
                "contact_lead", id, "cupid.contactLead.handle",
                JSON.toJSONString(before), JSON.toJSONString(after), null);
    }

    private String requireText(Object value, String fieldName, int maxLength)
    {
        String text = trim(value);
        if (!StringUtils.hasText(text))
        {
            throw new ServiceException(fieldName + "_required");
        }
        if (text.length() > maxLength)
        {
            throw new ServiceException(fieldName + "_too_long");
        }
        return text;
    }

    private String optionalText(Object value, int maxLength, String fieldName)
    {
        String text = trim(value);
        if (!StringUtils.hasText(text))
        {
            return null;
        }
        if (text.length() > maxLength)
        {
            throw new ServiceException(fieldName + "_too_long");
        }
        return text;
    }

    private String requireAllowed(Object value, String fieldName, Set<String> allowedValues)
    {
        String text = requireText(value, fieldName, 40);
        if (!allowedValues.contains(text))
        {
            throw new ServiceException(fieldName + "_invalid");
        }
        return text;
    }

    private String requireAllowedWithDefault(Object value, String defaultValue, String fieldName, Set<String> allowedValues)
    {
        String text = trim(value);
        if (!StringUtils.hasText(text))
        {
            text = defaultValue;
        }
        if (!allowedValues.contains(text))
        {
            throw new ServiceException(fieldName + "_invalid");
        }
        return text;
    }

    private void validateContactValue(String contactChannel, String contactValue)
    {
        if ("email".equals(contactChannel) && !contactValue.contains("@"))
        {
            throw new ServiceException("email_invalid");
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
