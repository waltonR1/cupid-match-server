package com.ruoyi.framework.web.service.twilio;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
import java.util.Map;
import jakarta.annotation.PostConstruct;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.ruoyi.cupid.mapper.CupidInboxTemplateMapper;
import com.ruoyi.framework.web.service.CupidSmsGateway;

@Service
@ConditionalOnProperty(prefix = "cupid.auth.verification-delivery.sms",
        name = "provider", havingValue = "twilio")
public class TwilioCupidSmsGateway implements CupidSmsGateway
{
    private final TwilioSmsProperties properties;
    private final CupidInboxTemplateMapper templateMapper;
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10)).build();

    public TwilioCupidSmsGateway(TwilioSmsProperties properties,
            CupidInboxTemplateMapper templateMapper)
    {
        this.properties = properties;
        this.templateMapper = templateMapper;
    }

    @PostConstruct
    public void validate()
    {
        require(properties.getAccountSid(), "Twilio account SID");
        require(properties.getMessagingServiceSid(), "Twilio Messaging Service SID");
        requirePrefix(properties.getAccountSid(), "AC", "Twilio account SID");
        requirePrefix(properties.getMessagingServiceSid(), "MG", "Twilio Messaging Service SID");
        boolean authToken = StringUtils.hasText(properties.getAuthToken());
        boolean apiKey = hasApiKeyCredentials();
        boolean partialApiKey = StringUtils.hasText(properties.getApiKey())
                || StringUtils.hasText(properties.getApiSecret());
        if (partialApiKey && !apiKey)
        {
            throw new IllegalStateException("Twilio API Key and API Secret must be configured together");
        }
        if (!authToken && !apiKey)
        {
            throw new IllegalStateException("Twilio Auth Token or API Key credentials are required");
        }
    }

    @Override
    public String getProvider()
    {
        return "twilio";
    }

    @Override
    public void sendVerificationCode(String phone, String purpose, String code, int ttlMinutes,
            String locale)
    {
        String body = resolveBody(purpose, locale)
                .replace("{{code}}", code)
                .replace("{{ttlMinutes}}", String.valueOf(ttlMinutes))
                .replace("{{purpose}}", purpose);
        try
        {
            HttpRequest request = buildRequest(phone, body);
            HttpResponse<String> response = httpClient.send(request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (response.statusCode() < 200 || response.statusCode() >= 300)
            {
                throw new IllegalStateException("Twilio rejected SMS: HTTP " + response.statusCode());
            }
        }
        catch (InterruptedException e)
        {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Twilio SMS interrupted", e);
        }
        catch (Exception e)
        {
            throw new IllegalStateException("Twilio SMS failed", e);
        }
    }

    HttpRequest buildRequest(String phone, String body)
    {
        if (phone == null || !phone.matches("^\\+[1-9]\\d{7,14}$"))
        {
            throw new IllegalArgumentException("SMS phone must use E.164 format");
        }
        String username = hasApiKeyCredentials()
                ? properties.getApiKey() : properties.getAccountSid();
        String password = hasApiKeyCredentials()
                ? properties.getApiSecret() : properties.getAuthToken();
        String form = "To=" + encode(phone)
                + "&MessagingServiceSid=" + encode(properties.getMessagingServiceSid())
                + "&Body=" + encode(body);
        String auth = Base64.getEncoder().encodeToString(
                (username + ":" + password).getBytes(StandardCharsets.UTF_8));
        return HttpRequest.newBuilder(URI.create("https://api.twilio.com/2010-04-01/Accounts/"
                        + properties.getAccountSid() + "/Messages.json"))
                .timeout(Duration.ofSeconds(30))
                .header("Authorization", "Basic " + auth)
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(form, StandardCharsets.UTF_8))
                .build();
    }

    private String resolveBody(String purpose, String locale)
    {
        String templateCode = "verification_" + purpose;
        Map<String, Object> template = templateMapper.selectTemplateByCode(templateCode);
        if (template == null || !"enabled".equals(String.valueOf(template.get("status"))))
        {
            throw new IllegalStateException("SMS template unavailable");
        }
        String selected = "zh".equals(locale) || "fr".equals(locale) ? locale : "en";
        Map<String, Object> localized = templateMapper.selectLocalizedField(
                String.valueOf(template.get("id")), selected);
        if (localized == null)
        {
            localized = templateMapper.selectLocalizedField(String.valueOf(template.get("id")), "en");
        }
        if (localized == null)
        {
            throw new IllegalStateException("SMS template locale unavailable");
        }
        return String.valueOf(localized.get("body"));
    }

    private static String encode(String value)
    {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static void require(String value, String name)
    {
        if (!StringUtils.hasText(value))
        {
            throw new IllegalStateException(name + " is required");
        }
    }

    private boolean hasApiKeyCredentials()
    {
        return StringUtils.hasText(properties.getApiKey())
                && StringUtils.hasText(properties.getApiSecret());
    }

    private static void requirePrefix(String value, String prefix, String name)
    {
        if (!value.startsWith(prefix))
        {
            throw new IllegalStateException(name + " must start with " + prefix);
        }
    }
}
