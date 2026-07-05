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
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
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
            String code, int ttlMinutes)
    {
        if (logEnabled)
        {
            log.info("Cupid verification code purpose={}, provider={}, identifier={}, code={}",
                    purpose, provider, mask(identifier), code);
            return;
        }
        if ("email".equals(provider))
        {
            sendEmail(purpose, identifier, code, ttlMinutes);
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

    private void sendEmail(String purpose, String email, String code, int ttlMinutes)
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
        message.setSubject("Cupid Match verification code");
        message.setText(buildEmailBody(purpose, code, ttlMinutes));
        mailSender.send(message);
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

    private String buildEmailBody(String purpose, String code, int ttlMinutes)
    {
        return "Cupid Match\n\n"
                + "验证码 / Code de vérification / Verification code: " + code + "\n"
                + "用途 / Objet / Purpose: " + purpose + "\n"
                + "有效期 / Validité / Valid for: " + ttlMinutes + " minutes\n\n"
                + "如果不是您本人操作，请忽略此邮件。\n"
                + "Si vous n'êtes pas à l'origine de cette demande, ignorez cet e-mail.\n"
                + "If you did not request this code, ignore this email.";
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
