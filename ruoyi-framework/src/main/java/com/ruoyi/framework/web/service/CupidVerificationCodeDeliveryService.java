package com.ruoyi.framework.web.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import java.util.Map;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.cupid.mapper.CupidInboxTemplateMapper;
import com.ruoyi.cupid.service.ICupidRuntimeConfigService;

/**
 * Cupid 验证码投递服务。
 */
@Service
public class CupidVerificationCodeDeliveryService
{
    private static final Logger log =
            LoggerFactory.getLogger(CupidVerificationCodeDeliveryService.class);

    @Autowired
    private ObjectProvider<JavaMailSender> mailSenderProvider;

    @Autowired
    private ObjectProvider<CupidSmsGateway> smsGatewayProvider;

    @Autowired
    private ICupidRuntimeConfigService runtimeConfigService;

    @Autowired
    private CupidInboxTemplateMapper templateMapper;

    @Value("${cupid.auth.verification-code-log-enabled:false}")
    private boolean logEnabled;

    @Value("${cupid.auth.verification-delivery.email.from:}")
    private String emailFrom;

    public void validate(String provider)
    {
        if (logEnabled)
        {
            return;
        }
        if ("email".equals(provider))
        {
            if (!runtimeConfigService.isVerificationEmailEnabled()
                    || mailSenderProvider.getIfAvailable() == null
                    || !StringUtils.hasText(emailFrom))
            {
                throw unavailable();
            }
            return;
        }
        if ("phone".equals(provider))
        {
            if (!runtimeConfigService.isVerificationSmsEnabled()
                    || smsGatewayProvider.getIfAvailable() == null)
            {
                throw unavailable();
            }
            return;
        }
        throw unavailable();
    }

    public void deliver(String purpose, String provider, String identifier,
            String code, int ttlMinutes, String locale)
    {
        if (logEnabled)
        {
            log.info("Cupid verification code purpose={}, provider={}, identifier={}, code={}",
                    purpose, provider, mask(identifier), code);
            return;
        }
        if ("email".equals(provider))
        {
            sendEmail(purpose, identifier, code, ttlMinutes, locale);
        }
        else if ("phone".equals(provider))
        {
            sendSms(purpose, identifier, code, ttlMinutes);
        }
        else
        {
            throw unavailable();
        }
        log.info("Cupid verification delivery succeeded: purpose={}, provider={}, identifier={}",
                purpose, provider, mask(identifier));
    }

    private void sendEmail(String purpose, String email, String code, int ttlMinutes, String locale)
    {
        JavaMailSender mailSender = runtimeConfigService.isVerificationEmailEnabled()
                ? mailSenderProvider.getIfAvailable() : null;
        if (mailSender == null || !StringUtils.hasText(emailFrom))
        {
            throw unavailable();
        }
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(emailFrom);
        message.setTo(email);
        Map<String, Object> template = resolveEmailTemplate(purpose, locale);
        if (template == null)
        {
            throw unavailable();
        }
        message.setSubject(render(String.valueOf(template.get("name")), purpose, code, ttlMinutes));
        message.setText(render(String.valueOf(template.get("body")), purpose, code, ttlMinutes));
        mailSender.send(message);
    }

    private Map<String, Object> resolveEmailTemplate(String purpose, String locale)
    {
        if (!"registration".equals(purpose) && !"password_reset".equals(purpose)
                && !"identity_bind".equals(purpose) && !"mfa".equals(purpose))
        {
            return null;
        }
        String templateCode = "verification_" + purpose;
        Map<String, Object> template = templateMapper.selectTemplateByCode(templateCode);
        if (template == null || !"enabled".equals(String.valueOf(template.get("status"))))
        {
            return null;
        }
        if (!"zh".equals(locale) && !"fr".equals(locale) && !"en".equals(locale))
        {
            locale = "en";
        }
        Map<String, Object> localized = templateMapper.selectLocalizedField(
                String.valueOf(template.get("id")), locale);
        return localized != null ? localized : templateMapper.selectLocalizedField(
                String.valueOf(template.get("id")), "en");
    }

    private String render(String value, String purpose, String code, int ttlMinutes)
    {
        return value.replace("{{code}}", code)
                .replace("{{ttlMinutes}}", String.valueOf(ttlMinutes))
                .replace("{{purpose}}", purpose);
    }

    private void sendSms(String purpose, String phone, String code, int ttlMinutes)
    {
        CupidSmsGateway gateway = runtimeConfigService.isVerificationSmsEnabled()
                ? smsGatewayProvider.getIfAvailable() : null;
        if (gateway == null)
        {
            throw unavailable();
        }
        gateway.sendVerificationCode(phone, purpose, code, ttlMinutes);
    }

    private CupidApiException unavailable()
    {
        return new CupidApiException(HttpStatus.ERROR, "verification_delivery_unavailable");
    }

    private String mask(String identifier)
    {
        if (!StringUtils.hasText(identifier) || identifier.length() <= 4)
        {
            return "****";
        }
        int at = identifier.indexOf('@');
        if (at > 1)
        {
            return identifier.substring(0, 2) + "***" + identifier.substring(at);
        }
        return "***" + identifier.substring(identifier.length() - 4);
    }
}
