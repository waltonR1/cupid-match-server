package com.ruoyi.cupid.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "cupid.payment.stripe")
public class CupidStripeProperties
{
    private boolean enabled;
    private String environment = "test";
    private String secretKey;
    private String webhookSecret;
    private String successUrl;
    private String cancelUrl;

    public boolean isEnabled()
    {
        return enabled;
    }

    public void setEnabled(boolean enabled)
    {
        this.enabled = enabled;
    }

    public String getEnvironment()
    {
        return environment;
    }

    public void setEnvironment(String environment)
    {
        this.environment = environment;
    }

    public String getSecretKey()
    {
        return secretKey;
    }

    public void setSecretKey(String secretKey)
    {
        this.secretKey = secretKey;
    }

    public String getWebhookSecret()
    {
        return webhookSecret;
    }

    public void setWebhookSecret(String webhookSecret)
    {
        this.webhookSecret = webhookSecret;
    }

    public String getSuccessUrl()
    {
        return successUrl;
    }

    public void setSuccessUrl(String successUrl)
    {
        this.successUrl = successUrl;
    }

    public String getCancelUrl()
    {
        return cancelUrl;
    }

    public void setCancelUrl(String cancelUrl)
    {
        this.cancelUrl = cancelUrl;
    }
}
