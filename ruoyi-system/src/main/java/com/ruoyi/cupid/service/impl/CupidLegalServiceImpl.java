package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.domain.CupidLegalDocument;
import com.ruoyi.cupid.domain.CupidLegalDocumentContent;
import com.ruoyi.cupid.mapper.CupidLegalMapper;
import com.ruoyi.cupid.service.ICupidLegalService;

/**
 * Cupid Match 法务文档服务实现
 */
@Service
public class CupidLegalServiceImpl implements ICupidLegalService
{
    @Autowired
    private CupidLegalMapper legalMapper;

    @Override
    public Map<String, Object> getDocument(String type, String locale)
    {
        CupidLegalDocument document = legalMapper.selectActiveDocumentByType(type);
        if (document == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "legal_document_not_found");
        }

        CupidLegalDocumentContent content = legalMapper.selectContentByLocale(document.getId(), normalizeLocale(locale));
        if (content == null)
        {
            content = legalMapper.selectFallbackContent(document.getId());
        }
        if (content == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "legal_content_not_found");
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("type", document.getType());
        response.put("version", document.getVersion());
        response.put("locale", content.getLocale());
        response.put("title", content.getTitle());
        response.put("sections", parseSections(content.getSections()));
        response.put("effectiveAt", formatDate(document.getEffectiveAt()));
        return response;
    }

    @Override
    @Transactional
    public void acceptActiveDocuments(String userId)
    {
        Date acceptedAt = new Date();
        for (CupidLegalDocument document : legalMapper.selectActiveDocuments())
        {
            legalMapper.upsertAcceptance(IdUtils.fastUUID(), userId, document.getType(), document.getVersion(), acceptedAt);
        }
    }

    private String normalizeLocale(String locale)
    {
        return StringUtils.hasText(locale) ? locale.trim() : "zh";
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> parseSections(String sectionsJson)
    {
        List<Map> rawSections = JSON.parseArray(sectionsJson, Map.class);
        rawSections.sort(Comparator.comparingInt(section -> asInt(section.get("sortOrder"))));

        List<Map<String, Object>> sections = new ArrayList<>();
        for (Map rawSection : rawSections)
        {
            Map<String, Object> section = new LinkedHashMap<>();
            section.put("heading", rawSection.get("heading"));
            section.put("clauses", rawSection.get("clauses"));
            sections.add(section);
        }
        return sections;
    }

    private int asInt(Object value)
    {
        if (value instanceof Number)
        {
            return ((Number) value).intValue();
        }
        return value == null ? 0 : Integer.parseInt(value.toString());
    }

    private String formatDate(Date date)
    {
        return date == null ? null : DateUtils.parseDateToStr(DateUtils.YYYY_MM_DD_HH_MM_SS, date);
    }
}
