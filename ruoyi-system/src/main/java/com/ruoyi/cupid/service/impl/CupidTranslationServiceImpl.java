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
import org.springframework.beans.factory.InitializingBean;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.domain.CupidProfileLocalizedField;
import com.ruoyi.cupid.mapper.CupidProfileMapper;
import com.ruoyi.cupid.service.ICupidTranslationService;

/**
 * Cupid Match 翻译服务 — LibreTranslate 实现
 */
@Service
public class CupidTranslationServiceImpl implements ICupidTranslationService, InitializingBean
{
    private static final Logger log = LoggerFactory.getLogger(CupidTranslationServiceImpl.class);
    private static final List<String> ALL_LOCALES = Arrays.asList("zh", "fr", "en");

    @Autowired
    private CupidProfileMapper profileMapper;

    @Value("${cupid.translation.api-url:http://localhost:5000}")
    private String apiUrl;

    @Value("${cupid.translation.enabled:true}")
    private boolean enabled;

    @Value("${cupid.translation.fail-fast:false}")
    private boolean failFast;

    @Value("${cupid.translation.connect-timeout:3s}")
    private Duration connectTimeout;

    @Value("${cupid.translation.read-timeout:10s}")
    private Duration readTimeout;

    private RestTemplate restTemplate;

    @Override
    public void afterPropertiesSet()
    {
        this.restTemplate = createRestTemplate();
        if (enabled && failFast)
        {
            checkTranslatorAvailable();
        }
    }

    @Override
    public void prepareTranslations(String profileId, String sourceLocale, List<String> fieldNames)
    {
        if (!enabled || fieldNames == null || fieldNames.isEmpty())
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
        if (!enabled || fieldNames == null || fieldNames.isEmpty())
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
            }
        }
    }

    @Override
    public void prepareInternalTranslations(String internalRecordId, String sourceLocale, List<String> fieldNames)
    {
        if (!enabled || fieldNames == null || fieldNames.isEmpty())
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
        if (!enabled || fieldNames == null || fieldNames.isEmpty())
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
                    continue;
                }

                profileMapper.upsertAdminInternalLocalizedFieldWithMeta(
                        IdUtils.fastUUID(), internalRecordId, fieldName, targetLocale,
                        translated, "machine", "libretranslate", "ready");
            }
        }
    }

    private RestTemplate createRestTemplate()
    {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(connectTimeout);
        factory.setReadTimeout(readTimeout);
        return new RestTemplate(factory);
    }

    private void checkTranslatorAvailable()
    {
        try
        {
            restTemplate.getForObject(normalizedApiUrl() + "/languages", Object.class);
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

            Map<String, Object> response = restTemplate.postForObject(
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
        if (apiUrl != null && apiUrl.endsWith("/"))
        {
            return apiUrl.substring(0, apiUrl.length() - 1);
        }
        return apiUrl;
    }

    private static String toLtCode(String internal)
    {
        if ("zh".equals(internal)) return "zh-Hans";
        return internal;
    }
}
