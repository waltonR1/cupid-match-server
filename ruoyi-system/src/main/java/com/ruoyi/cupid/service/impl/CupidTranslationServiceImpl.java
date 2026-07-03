package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.time.Duration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.domain.CupidProfileLocalizedField;
import com.ruoyi.cupid.mapper.CupidProfileMapper;
import com.ruoyi.cupid.mapper.CupidTranslationRetryMapper;
import com.ruoyi.cupid.service.ICupidRuntimeConfigService;
import com.ruoyi.cupid.service.ICupidTranslationService;

/**
 * Cupid Match 翻译服务 — LibreTranslate 实现
 */
@Service
public class CupidTranslationServiceImpl implements ICupidTranslationService
{
    private static final Logger log = LoggerFactory.getLogger(CupidTranslationServiceImpl.class);
    private static final List<String> ALL_LOCALES = Arrays.asList("zh", "fr", "en");

    @Autowired
    private CupidProfileMapper profileMapper;

    @Value("${cupid.translation.fail-fast:false}")
    private boolean failFast;

    @Autowired
    private CupidTranslationRetryMapper retryMapper;

    @Autowired
    private ICupidRuntimeConfigService runtimeConfigService;

    @EventListener(ApplicationReadyEvent.class)
    public void checkTranslatorAfterStartup()
    {
        if (failFast && runtimeConfigService.isTranslationEnabled())
        {
            checkTranslatorAvailable();
        }
    }

    @Override
    public void prepareTranslations(String profileId, String sourceLocale, List<String> fieldNames)
    {
        if (!runtimeConfigService.isTranslationEnabled() || fieldNames == null || fieldNames.isEmpty())
        {
            return;
        }

        for (String fieldName : fieldNames)
        {
            String sourceText = findLocalizedFieldValue(profileId, fieldName, sourceLocale);
            if (!StringUtils.hasText(sourceText))
            {
                continue;
            }

            for (String targetLocale : ALL_LOCALES)
            {
                if (targetLocale.equals(sourceLocale)
                        || StringUtils.hasText(findLocalizedFieldValue(profileId, fieldName, targetLocale)))
                {
                    continue;
                }
                profileMapper.upsertPendingLocalizedField(buildPendingField(profileId, fieldName, targetLocale));
            }
        }
    }

    @Override
    @Async("threadPoolTaskExecutor")
    public void requestTranslations(String profileId, String sourceLocale, List<String> fieldNames)
    {
        if (!runtimeConfigService.isTranslationEnabled() || fieldNames == null || fieldNames.isEmpty())
        {
            return;
        }

        for (String fieldName : fieldNames)
        {
            String sourceText = findLocalizedFieldValue(profileId, fieldName, sourceLocale);
            if (!StringUtils.hasText(sourceText))
            {
                continue;
            }

            for (String targetLocale : ALL_LOCALES)
            {
                if (targetLocale.equals(sourceLocale))
                {
                    continue;
                }

                if (StringUtils.hasText(findLocalizedFieldValue(profileId, fieldName, targetLocale)))
                {
                    continue;
                }

                String translated = callLibreTranslate(sourceText, sourceLocale, targetLocale);
                if (translated == null)
                {
                    profileMapper.updatePendingLocalizedFieldStatus(profileId, fieldName, targetLocale, "failed");
                    recordFailure("profile", profileId, fieldName, sourceLocale, targetLocale);
                    continue;
                }

                CupidProfileLocalizedField field = new CupidProfileLocalizedField();
                field.setId(IdUtils.fastUUID());
                field.setProfileId(profileId);
                field.setFieldName(fieldName);
                field.setLocale(targetLocale);
                field.setValue(translated);
                field.setSource("machine");
                field.setProvider("libretranslate");
                field.setStatus("ready");
                profileMapper.upsertLocalizedField(field);
                retryMapper.deleteRetry("profile", profileId, fieldName, targetLocale);
            }
        }
    }

    @Override
    public void prepareInternalTranslations(String internalRecordId, String sourceLocale, List<String> fieldNames)
    {
        if (!runtimeConfigService.isTranslationEnabled() || fieldNames == null || fieldNames.isEmpty())
        {
            return;
        }

        for (String fieldName : fieldNames)
        {
            String sourceText = findInternalLocalizedFieldValue(internalRecordId, fieldName, sourceLocale);
            if (!StringUtils.hasText(sourceText))
            {
                continue;
            }

            for (String targetLocale : ALL_LOCALES)
            {
                if (targetLocale.equals(sourceLocale)
                        || StringUtils.hasText(findInternalLocalizedFieldValue(internalRecordId, fieldName, targetLocale)))
                {
                    continue;
                }
                profileMapper.upsertPendingAdminInternalLocalizedField(
                        IdUtils.fastUUID(), internalRecordId, fieldName, targetLocale);
            }
        }
    }

    @Override
    @Async("threadPoolTaskExecutor")
    public void requestInternalTranslations(String internalRecordId, String sourceLocale, List<String> fieldNames)
    {
        if (!runtimeConfigService.isTranslationEnabled() || fieldNames == null || fieldNames.isEmpty())
        {
            return;
        }

        for (String fieldName : fieldNames)
        {
            String sourceText = findInternalLocalizedFieldValue(internalRecordId, fieldName, sourceLocale);
            if (!StringUtils.hasText(sourceText))
            {
                continue;
            }

            for (String targetLocale : ALL_LOCALES)
            {
                if (targetLocale.equals(sourceLocale))
                {
                    continue;
                }

                if (StringUtils.hasText(findInternalLocalizedFieldValue(internalRecordId, fieldName, targetLocale)))
                {
                    continue;
                }

                String translated = callLibreTranslate(sourceText, sourceLocale, targetLocale);
                if (translated == null)
                {
                    profileMapper.updatePendingAdminInternalLocalizedFieldStatus(
                            internalRecordId, fieldName, targetLocale, "failed");
                    recordFailure("profile_internal", internalRecordId,
                            fieldName, sourceLocale, targetLocale);
                    continue;
                }

                profileMapper.upsertAdminInternalLocalizedFieldWithMeta(
                        IdUtils.fastUUID(), internalRecordId, fieldName, targetLocale,
                        translated, "machine", "libretranslate", "ready");
                retryMapper.deleteRetry("profile_internal", internalRecordId, fieldName, targetLocale);
            }
        }
    }

    @Override
    public int retryFailedTranslations()
    {
        if (!runtimeConfigService.isTranslationEnabled())
        {
            return 0;
        }
        List<Map<String, Object>> retries = retryMapper.selectDueRetries(
                runtimeConfigService.getTranslationRetryBatchSize(),
                runtimeConfigService.getTranslationRetryMaxAttempts());
        int completed = 0;
        for (Map<String, Object> retry : retries)
        {
            String entityType = String.valueOf(retry.get("entityType"));
            String entityId = String.valueOf(retry.get("entityId"));
            String fieldName = String.valueOf(retry.get("fieldName"));
            String sourceLocale = String.valueOf(retry.get("sourceLocale"));
            String targetLocale = String.valueOf(retry.get("targetLocale"));
            String existingTarget = "profile_internal".equals(entityType)
                    ? findInternalLocalizedFieldValue(entityId, fieldName, targetLocale)
                    : findLocalizedFieldValue(entityId, fieldName, targetLocale);
            if (StringUtils.hasText(existingTarget))
            {
                retryMapper.deleteRetry(entityType, entityId, fieldName, targetLocale);
                continue;
            }
            String sourceText = "profile_internal".equals(entityType)
                    ? findInternalLocalizedFieldValue(entityId, fieldName, sourceLocale)
                    : findLocalizedFieldValue(entityId, fieldName, sourceLocale);
            if (!StringUtils.hasText(sourceText))
            {
                recordFailure(entityType, entityId, fieldName, sourceLocale, targetLocale);
                continue;
            }
            String translated = callLibreTranslate(sourceText, sourceLocale, targetLocale);
            if (translated == null)
            {
                recordFailure(entityType, entityId, fieldName, sourceLocale, targetLocale);
                continue;
            }
            if ("profile_internal".equals(entityType))
            {
                profileMapper.upsertAdminInternalLocalizedFieldWithMeta(
                        IdUtils.fastUUID(), entityId, fieldName, targetLocale,
                        translated, "machine", "libretranslate", "ready");
            }
            else
            {
                CupidProfileLocalizedField field = new CupidProfileLocalizedField();
                field.setId(IdUtils.fastUUID());
                field.setProfileId(entityId);
                field.setFieldName(fieldName);
                field.setLocale(targetLocale);
                field.setValue(translated);
                field.setSource("machine");
                field.setProvider("libretranslate");
                field.setStatus("ready");
                profileMapper.upsertLocalizedField(field);
            }
            retryMapper.deleteRetry(entityType, entityId, fieldName, targetLocale);
            completed++;
        }
        return completed;
    }

    private RestTemplate createRestTemplate()
    {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(Duration.ofSeconds(
                runtimeConfigService.getTranslationConnectTimeoutSeconds()));
        factory.setReadTimeout(Duration.ofSeconds(
                runtimeConfigService.getTranslationReadTimeoutSeconds()));
        return new RestTemplate(factory);
    }

    private void checkTranslatorAvailable()
    {
        try
        {
            createRestTemplate().getForObject(normalizedApiUrl() + "/languages", Object.class);
        }
        catch (Exception e)
        {
            throw new IllegalStateException("LibreTranslate is unavailable: " + e.getMessage(), e);
        }
    }

    private CupidProfileLocalizedField buildPendingField(String profileId, String fieldName, String locale)
    {
        CupidProfileLocalizedField field = new CupidProfileLocalizedField();
        field.setId(IdUtils.fastUUID());
        field.setProfileId(profileId);
        field.setFieldName(fieldName);
        field.setLocale(locale);
        field.setValue("");
        field.setSource("machine");
        field.setProvider("libretranslate");
        field.setStatus("pending");
        return field;
    }

    private String findLocalizedFieldValue(String profileId, String fieldName, String locale)
    {
        List<CupidProfileLocalizedField> rows =
                profileMapper.selectAllLocalizedFieldsByProfileId(profileId, locale);
        for (CupidProfileLocalizedField row : rows)
        {
            if (fieldName.equals(row.getFieldName())
                    && locale.equals(row.getLocale())
                    && "ready".equals(row.getStatus())
                    && StringUtils.hasText(row.getValue()))
            {
                return row.getValue();
            }
        }
        return "";
    }

    private String findInternalLocalizedFieldValue(String internalRecordId, String fieldName, String locale)
    {
        List<Map<String, Object>> rows =
                profileMapper.selectAdminInternalLocalizedFieldsByRecordId(internalRecordId);
        for (Map<String, Object> row : rows)
        {
            if (fieldName.equals(row.get("fieldName"))
                    && locale.equals(row.get("locale"))
                    && "ready".equals(row.get("status"))
                    && StringUtils.hasText(String.valueOf(row.get("value"))))
            {
                return String.valueOf(row.get("value"));
            }
        }
        return "";
    }

    private String callLibreTranslate(String text, String sourceLang, String targetLang)
    {
        try
        {
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("q", text);
            body.put("source", toLtCode(sourceLang));
            body.put("target", toLtCode(targetLang));

            Map<String, Object> response = createRestTemplate().postForObject(
                    normalizedApiUrl() + "/translate", body, Map.class);

            if (response != null && response.get("translatedText") != null)
            {
                return response.get("translatedText").toString();
            }
        }
        catch (Exception e)
        {
            log.warn("LibreTranslate failed for {}→{}: {}", sourceLang, targetLang, e.getMessage());
        }
        return null;
    }

    private String normalizedApiUrl()
    {
        String apiUrl = runtimeConfigService.getTranslationApiUrl();
        if (apiUrl != null && apiUrl.endsWith("/"))
        {
            return apiUrl.substring(0, apiUrl.length() - 1);
        }
        return apiUrl;
    }

    private void recordFailure(String entityType, String entityId, String fieldName,
            String sourceLocale, String targetLocale)
    {
        retryMapper.recordFailure(IdUtils.fastUUID(), entityType, entityId, fieldName,
                sourceLocale, targetLocale, "LibreTranslate request failed",
                runtimeConfigService.getTranslationRetryMaxAttempts(),
                runtimeConfigService.getTranslationRetryBaseDelayMinutes());
    }

    private static String toLtCode(String internal)
    {
        if ("zh".equals(internal)) return "zh-Hans";
        return internal;
    }
}
