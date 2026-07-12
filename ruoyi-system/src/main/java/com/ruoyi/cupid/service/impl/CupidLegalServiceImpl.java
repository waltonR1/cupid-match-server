package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONException;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.exception.ServiceException;
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
    private static final Set<String> ALLOWED_TYPES = Set.of("terms", "privacy");
    private static final Set<String> ALLOWED_LOCALES = Set.of("zh", "en", "fr");
    private static final Set<String> ALLOWED_STATUSES = Set.of("draft", "active", "archived");

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
    public List<Map<String, Object>> selectAdminDocuments(Map<String, Object> params)
    {
        String type = trim(params == null ? null : params.get("type"));
        if (StringUtils.hasText(type) && !ALLOWED_TYPES.contains(type))
        {
            throw new ServiceException("legal_type_invalid");
        }

        List<Map<String, Object>> rows = new ArrayList<>();
        for (CupidLegalDocument document : legalMapper.selectAdminDocuments(type))
        {
            Map<String, Object> row = buildDocumentMap(document);
            CupidLegalDocumentContent zhContent = legalMapper.selectContentByLocale(document.getId(), "zh");
            CupidLegalDocumentContent fallbackContent = zhContent == null
                    ? legalMapper.selectFallbackContent(document.getId())
                    : zhContent;
            row.put("title", fallbackContent == null ? null : fallbackContent.getTitle());
            row.put("localeCount", countLocales(document.getId()));
            rows.add(row);
        }
        return rows;
    }

    @Override
    public Map<String, Object> selectAdminDocumentById(String id)
    {
        CupidLegalDocument document = legalMapper.selectDocumentById(id);
        if (document == null)
        {
            throw new ServiceException("legal_document_not_found");
        }

        Map<String, Object> detail = buildDocumentMap(document);
        List<Map<String, Object>> contents = new ArrayList<>();
        for (String locale : List.of("zh", "en", "fr"))
        {
            CupidLegalDocumentContent content = legalMapper.selectContentByLocale(id, locale);
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("locale", locale);
            item.put("title", content == null ? "" : content.getTitle());
            item.put("sections", content == null ? new ArrayList<>() : parseAdminSections(content.getSections()));
            item.put("updatedAt", content == null ? null : formatDate(content.getUpdatedAt()));
            contents.add(item);
        }
        detail.put("contents", contents);
        return detail;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateAdminDocument(String id, Map<String, Object> body)
    {
        CupidLegalDocument document = legalMapper.selectDocumentById(id);
        if (document == null)
        {
            throw new ServiceException("legal_document_not_found");
        }
        if (!"draft".equals(document.getStatus()))
        {
            throw new ServiceException("legal_document_locked");
        }

        document.setVersion(document.getVersion());
        document.setStatus("draft");
        document.setEffectiveAt(parseRequiredDate(body.get("effectiveAt")));
        legalMapper.updateDocument(document);

        Object contentsValue = body.get("contents");
        if (!(contentsValue instanceof List))
        {
            throw new ServiceException("contents_required");
        }

        for (Object rawContent : (List<?>) contentsValue)
        {
            if (!(rawContent instanceof Map))
            {
                throw new ServiceException("content_invalid");
            }
            Map<?, ?> contentMap = (Map<?, ?>) rawContent;
            String locale = requireAllowed(contentMap.get("locale"), "locale", ALLOWED_LOCALES);
            String title = requireText(contentMap.get("title"), "title", 255);
            String sections = normalizeSections(contentMap.get("sections"));

            CupidLegalDocumentContent content = new CupidLegalDocumentContent();
            content.setId(IdUtils.fastUUID());
            content.setDocumentId(id);
            content.setLocale(locale);
            content.setTitle(title);
            content.setSections(sections);
            legalMapper.upsertContent(content);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> createAdminDraft(String type)
    {
        String documentType = requireAllowed(type, "type", ALLOWED_TYPES);
        if (legalMapper.selectDraftDocumentByType(documentType) != null)
        {
            throw new ServiceException("legal_draft_exists");
        }

        List<CupidLegalDocument> documents = legalMapper.selectAdminDocuments(documentType);
        if (documents.isEmpty())
        {
            throw new ServiceException("legal_source_not_found");
        }

        CupidLegalDocument source = selectCopySource(documents);
        CupidLegalDocument draft = new CupidLegalDocument();
        draft.setId(IdUtils.fastUUID());
        draft.setType(documentType);
        draft.setVersion(nextVersion(documents));
        draft.setStatus("draft");
        draft.setEffectiveAt(new Date());
        legalMapper.insertDocument(draft);

        for (String locale : List.of("zh", "en", "fr"))
        {
            CupidLegalDocumentContent sourceContent = legalMapper.selectContentByLocale(source.getId(), locale);
            if (sourceContent == null)
            {
                continue;
            }
            CupidLegalDocumentContent content = new CupidLegalDocumentContent();
            content.setId(IdUtils.fastUUID());
            content.setDocumentId(draft.getId());
            content.setLocale(locale);
            content.setTitle(sourceContent.getTitle());
            content.setSections(sourceContent.getSections());
            legalMapper.upsertContent(content);
        }

        return selectAdminDocumentById(draft.getId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void publishAdminDraft(String id, Map<String, Object> body)
    {
        CupidLegalDocument document = legalMapper.selectDocumentById(id);
        if (document == null)
        {
            throw new ServiceException("legal_document_not_found");
        }
        if (!"draft".equals(document.getStatus()))
        {
            throw new ServiceException("legal_publish_requires_draft");
        }
        assertVersionGreaterThanExisting(document);

        Date effectiveAt = body == null || !StringUtils.hasText(trim(body.get("effectiveAt")))
                ? new Date()
                : parseRequiredDate(body.get("effectiveAt"));
        legalMapper.archiveActiveDocumentByType(document.getType());
        document.setStatus("active");
        document.setEffectiveAt(effectiveAt);
        legalMapper.updateDocument(document);
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

    private Map<String, Object> buildDocumentMap(CupidLegalDocument document)
    {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("id", document.getId());
        row.put("type", document.getType());
        row.put("version", document.getVersion());
        row.put("status", document.getStatus());
        row.put("effectiveAt", formatDate(document.getEffectiveAt()));
        row.put("createdAt", formatDate(document.getCreatedAt()));
        row.put("updatedAt", formatDate(document.getUpdatedAt()));
        return row;
    }

    private int countLocales(String documentId)
    {
        int count = 0;
        for (String locale : ALLOWED_LOCALES)
        {
            if (legalMapper.selectContentByLocale(documentId, locale) != null)
            {
                count++;
            }
        }
        return count;
    }

    private CupidLegalDocument selectCopySource(List<CupidLegalDocument> documents)
    {
        for (CupidLegalDocument document : documents)
        {
            if ("active".equals(document.getStatus()))
            {
                return document;
            }
        }
        return documents.get(0);
    }

    private String nextVersion(List<CupidLegalDocument> documents)
    {
        String maxVersion = "0.0";
        for (CupidLegalDocument document : documents)
        {
            if (compareVersion(document.getVersion(), maxVersion) > 0)
            {
                maxVersion = document.getVersion();
            }
        }

        String[] parts = maxVersion.split("\\.");
        if (parts.length == 0)
        {
            return "1.0";
        }
        int lastIndex = parts.length - 1;
        try
        {
            parts[lastIndex] = String.valueOf(Integer.parseInt(parts[lastIndex]) + 1);
            return String.join(".", parts);
        }
        catch (NumberFormatException e)
        {
            return maxVersion + ".1";
        }
    }

    private void assertVersionGreaterThanExisting(CupidLegalDocument draft)
    {
        for (CupidLegalDocument document : legalMapper.selectAdminDocuments(draft.getType()))
        {
            if (draft.getId().equals(document.getId()))
            {
                continue;
            }
            if (!"draft".equals(document.getStatus()) && compareVersion(draft.getVersion(), document.getVersion()) <= 0)
            {
                throw new ServiceException("legal_version_not_incremented");
            }
        }
    }

    private int compareVersion(String left, String right)
    {
        String[] leftParts = StringUtils.defaultString(left, "0").split("\\.");
        String[] rightParts = StringUtils.defaultString(right, "0").split("\\.");
        int max = Math.max(leftParts.length, rightParts.length);
        for (int i = 0; i < max; i++)
        {
            int leftValue = parseVersionPart(leftParts, i);
            int rightValue = parseVersionPart(rightParts, i);
            if (leftValue != rightValue)
            {
                return Integer.compare(leftValue, rightValue);
            }
        }
        return 0;
    }

    private int parseVersionPart(String[] parts, int index)
    {
        if (index >= parts.length)
        {
            return 0;
        }
        String value = parts[index].replaceAll("[^0-9]", "");
        return StringUtils.hasText(value) ? Integer.parseInt(value) : 0;
    }

    private Date parseRequiredDate(Object value)
    {
        String text = requireText(value, "effectiveAt", 30);
        Date date = DateUtils.parseDate(text);
        if (date == null)
        {
            throw new ServiceException("effective_at_invalid");
        }
        return date;
    }

    private void validateSectionsJson(String sections)
    {
        try
        {
            JSON.parseArray(sections);
        }
        catch (JSONException e)
        {
            throw new ServiceException("sections_json_invalid");
        }
    }

    private String normalizeSections(Object value)
    {
        if (value instanceof List)
        {
            String json = JSON.toJSONString(value);
            validateSectionsJson(json);
            return json;
        }
        String text = requireText(value, "sections", 65535);
        validateSectionsJson(text);
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

    private String trim(Object value)
    {
        if (value == null)
        {
            return null;
        }
        String text = String.valueOf(value).trim();
        return StringUtils.hasText(text) ? text : null;
    }

    /**
     * 标准化 locale 参数
     */
    private String normalizeLocale(String locale)
    {
        return StringUtils.hasText(locale) ? locale.trim() : "zh";
    }

    @SuppressWarnings("unchecked")
    /**
     * 解析法务文档 JSON 章节结构
     */
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

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> parseAdminSections(String sectionsJson)
    {
        List<Map> rawSections = JSON.parseArray(sectionsJson, Map.class);
        rawSections.sort(Comparator.comparingInt(section -> asInt(section.get("sortOrder"))));

        List<Map<String, Object>> sections = new ArrayList<>();
        for (Map rawSection : rawSections)
        {
            Map<String, Object> section = new LinkedHashMap<>();
            section.put("heading", rawSection.get("heading"));
            section.put("clauses", rawSection.get("clauses"));
            section.put("sortOrder", rawSection.get("sortOrder"));
            sections.add(section);
        }
        return sections;
    }

    /**
     * 安全转换为 int
     */
    private int asInt(Object value)
    {
        if (value instanceof Number)
        {
            return ((Number) value).intValue();
        }
        return value == null ? 0 : Integer.parseInt(value.toString());
    }

    /**
     * 格式化日期为字符串
     */
    private String formatDate(Date date)
    {
        return date == null ? null : DateUtils.parseDateToStr(DateUtils.YYYY_MM_DD_HH_MM_SS, date);
    }
}
