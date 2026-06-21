package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.mapper.CupidProfileMapper;
import com.ruoyi.cupid.service.ICupidProfileManageService;
import com.ruoyi.cupid.service.ICupidTranslationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

/**
 * Cupid Match 后台资料运营管理服务实现
 */
@Service
public class CupidProfileManageServiceImpl implements ICupidProfileManageService
{
    private static final Set<String> INTERNAL_FIELD_NAMES = Set.of("employer", "income_range");

    private static final Set<String> NOTE_FIELD_NAMES = Set.of("staff_notes");

    private static final Set<String> LOCALES = Set.of("zh", "fr", "en");

    @Autowired
    private CupidProfileMapper profileMapper;

    @Autowired
    private ICupidTranslationService translationService;

    @Override
    public List<Map<String, Object>> selectProfileList(Map<String, Object> params)
    {
        return profileMapper.selectAdminProfileManageList(params);
    }

    @Override
    public Map<String, Object> selectProfileDetail(String profileId)
    {
        Map<String, Object> profile = profileMapper.selectAdminProfileDetail(profileId);
        if (profile == null)
        {
            profile = requireProfile(profileId);
        }
        else
        {
            profile.putAll(requireProfile(profileId));
        }
        profile.put("photos", profileMapper.selectApprovedPhotosByProfileId(profileId));
        profile.put("localizedFields", profileMapper.selectAdminLocalizedFieldsByProfileId(profileId));
        profile.put("localizedItems", profileMapper.selectAdminLocalizedItemsByProfileId(profileId));
        profile.put("languages", profileMapper.selectLanguagesByProfileId(profileId));
        profile.put("relationshipValues", profileMapper.selectRelationshipValuesByProfileId(profileId));
        profile.put("privacyPreferences", profileMapper.selectPrivacyPreferenceByProfileId(profileId));
        profile.put("contact", profileMapper.selectContactByProfileId(profileId));
        profile.put("internalFields", visibleInternalFields(profileId));
        return profile;
    }

    @Override
    public List<Map<String, Object>> selectProfileNotes(String profileId)
    {
        requireProfile(profileId);
        return profileMapper.selectAdminInternalLocalizedFieldsByProfileId(profileId).stream()
                .filter(row -> NOTE_FIELD_NAMES.contains(row.get("fieldName")))
                .toList();
    }

    @Override
    @Transactional
    public void updateInternalFields(String profileId, Map<String, Object> body, String staffUserId)
    {
        Map<String, Object> before = internalSnapshot(profileId);
        assertNoLocalizedFields(body);
        ensureInternalRecord(profileId, body, staffUserId);
        Map<String, Object> after = internalSnapshot(profileId);
        insertAudit("profile", profileId, "cupid.profile.internal.update", staffUserId, before, after, null);
    }

    @Override
    @Transactional
    public void updateNotes(String profileId, Map<String, Object> body, String staffUserId)
    {
        Map<String, Object> before = notesSnapshot(profileId);
        String internalRecordId = ensureInternalRecord(profileId, Map.of(), staffUserId);
        upsertLocalizedFields(internalRecordId, body, NOTE_FIELD_NAMES);
        requestInternalTranslations(internalRecordId, body, NOTE_FIELD_NAMES);
        Map<String, Object> after = notesSnapshot(profileId);
        insertAudit("profile", profileId, "cupid.profile.internal.notes.update", staffUserId, before, after, null);
    }

    private Map<String, Object> requireProfile(String profileId)
    {
        Map<String, Object> profile = profileMapper.selectAdminProfileManageDetail(profileId);
        if (profile == null)
        {
            throw new ServiceException("资料不存在");
        }
        return profile;
    }

    private String ensureInternalRecord(String profileId, Map<String, Object> body, String staffUserId)
    {
        requireProfile(profileId);
        Map<String, Object> record = profileMapper.selectAdminInternalRecordByProfileId(profileId);
        String internalRecordId = record == null ? IdUtils.fastUUID() : String.valueOf(record.get("internalRecordId"));
        Integer isFeatured = parseFeatured(body.get("isFeatured"), record);
        String source = record == null ? null : (String) record.get("source");
        profileMapper.upsertAdminInternalRecord(internalRecordId, profileId, isFeatured, source, staffUserId);
        return internalRecordId;
    }

    private void assertNoLocalizedFields(Map<String, Object> body)
    {
        Object rows = body.get("localizedFields");
        if (rows instanceof List<?> list && !list.isEmpty())
        {
            throw new ServiceException("雇主信息和收入范围请在认证审核中维护");
        }
    }

    private Integer parseFeatured(Object value, Map<String, Object> currentRecord)
    {
        if (value == null)
        {
            Object current = currentRecord == null ? null : currentRecord.get("isFeatured");
            return current == null ? 0 : parseBooleanLike(current);
        }
        return parseBooleanLike(value);
    }

    private Integer parseBooleanLike(Object value)
    {
        if (value instanceof Boolean)
        {
            return Boolean.TRUE.equals(value) ? 1 : 0;
        }
        return "1".equals(String.valueOf(value)) || "true".equalsIgnoreCase(String.valueOf(value)) ? 1 : 0;
    }

    @SuppressWarnings("unchecked")
    private void upsertLocalizedFields(String internalRecordId, Map<String, Object> body, Set<String> allowedFields)
    {
        Object rows = body.get("localizedFields");
        if (!(rows instanceof List<?>))
        {
            return;
        }
        for (Object item : (List<Object>) rows)
        {
            if (!(item instanceof Map<?, ?> row))
            {
                continue;
            }
            String fieldName = stringValue(row.get("fieldName"));
            String locale = stringValue(row.get("locale"));
            if (!allowedFields.contains(fieldName) || !LOCALES.contains(locale))
            {
                throw new ServiceException("内部字段不正确");
            }
            profileMapper.upsertAdminInternalLocalizedField(IdUtils.fastUUID(), internalRecordId, fieldName,
                    locale, StringUtils.defaultString(stringValue(row.get("value"))));
        }
    }

    @SuppressWarnings("unchecked")
    private void requestInternalTranslations(String internalRecordId, Map<String, Object> body, Set<String> allowedFields)
    {
        Object rows = body.get("localizedFields");
        if (!(rows instanceof List<?>))
        {
            return;
        }

        Map<String, List<String>> fieldsBySourceLocale = new LinkedHashMap<>();
        for (String fieldName : allowedFields)
        {
            String sourceLocale = inferSourceLocale((List<Object>) rows, fieldName);
            if (sourceLocale != null)
            {
                fieldsBySourceLocale.computeIfAbsent(sourceLocale, key -> new ArrayList<>()).add(fieldName);
            }
        }

        for (Map.Entry<String, List<String>> entry : fieldsBySourceLocale.entrySet())
        {
            translationService.prepareInternalTranslations(internalRecordId, entry.getKey(), entry.getValue());
            requestInternalTranslationsAfterCommit(internalRecordId, entry.getKey(), entry.getValue());
        }
    }

    private String inferSourceLocale(List<Object> rows, String fieldName)
    {
        for (String locale : List.of("zh", "fr", "en"))
        {
            for (Object item : rows)
            {
                if (!(item instanceof Map<?, ?> row))
                {
                    continue;
                }
                if (fieldName.equals(stringValue(row.get("fieldName")))
                        && locale.equals(stringValue(row.get("locale")))
                        && StringUtils.hasText(stringValue(row.get("value"))))
                {
                    return locale;
                }
            }
        }
        return null;
    }

    private void requestInternalTranslationsAfterCommit(String internalRecordId, String locale, List<String> fieldNames)
    {
        if (TransactionSynchronizationManager.isSynchronizationActive())
        {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization()
            {
                @Override
                public void afterCommit()
                {
                    translationService.requestInternalTranslations(internalRecordId, locale, fieldNames);
                }
            });
            return;
        }
        translationService.requestInternalTranslations(internalRecordId, locale, fieldNames);
    }

    private Map<String, Object> internalSnapshot(String profileId)
    {
        Map<String, Object> snapshot = new HashMap<>();
        snapshot.put("record", profileMapper.selectAdminInternalRecordByProfileId(profileId));
        snapshot.put("fields", visibleInternalFields(profileId));
        return snapshot;
    }

    private Map<String, Object> notesSnapshot(String profileId)
    {
        Map<String, Object> snapshot = new HashMap<>();
        snapshot.put("record", profileMapper.selectAdminInternalRecordByProfileId(profileId));
        snapshot.put("fields", selectProfileNotes(profileId));
        return snapshot;
    }

    private List<Map<String, Object>> visibleInternalFields(String profileId)
    {
        return profileMapper.selectAdminInternalLocalizedFieldsByProfileId(profileId).stream()
                .filter(row -> INTERNAL_FIELD_NAMES.contains(row.get("fieldName")))
                .toList();
    }

    private String stringValue(Object value)
    {
        return value == null ? null : String.valueOf(value);
    }

    private void insertAudit(String subjectType, String subjectId, String action, String actorUserId,
            Map<String, Object> before, Map<String, Object> after, String reason)
    {
        profileMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", actorUserId, subjectType, subjectId,
                action, JSON.toJSONString(before), JSON.toJSONString(after), reason);
    }
}
