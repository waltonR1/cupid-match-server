package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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
public class CupidTranslationServiceImpl implements ICupidTranslationService
{
    private static final Logger log = LoggerFactory.getLogger(CupidTranslationServiceImpl.class);
    private static final List<String> ALL_LOCALES = Arrays.asList("zh", "fr", "en");

    @Autowired
    private CupidProfileMapper profileMapper;

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${cupid.translation.api-url:http://localhost:5000}")
    private String apiUrl;

    @Override
    @Async("threadPoolTaskExecutor")
    public void requestTranslations(String profileId, String sourceLocale, List<String> fieldNames)
    {
        if (fieldNames == null || fieldNames.isEmpty())
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

    private String callLibreTranslate(String text, String sourceLang, String targetLang)
    {
        try
        {
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("q", text);
            body.put("source", toLtCode(sourceLang));
            body.put("target", toLtCode(targetLang));

            Map<String, Object> response = restTemplate.postForObject(
                    apiUrl + "/translate", body, Map.class);

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

    private static String toLtCode(String internal)
    {
        if ("zh".equals(internal)) return "zh-Hans";
        return internal;
    }
}
