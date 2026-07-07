package com.ruoyi.framework.web.service.twilio;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "cupid.auth.verification-delivery.sms.twilio")
public class TwilioSmsProperties
{
    private String accountSid;
    private String authToken;
    private String apiKey;
    private String apiSecret;
    private String messagingServiceSid;

    public String getAccountSid()
    {
        return accountSid;
    }

    public void setAccountSid(String accountSid)
    {
        this.accountSid = accountSid;
    }

    public String getAuthToken()
    {
        return authToken;
    }

    public void setAuthToken(String authToken)
    {
        this.authToken = authToken;
    }

    public String getApiKey()
    {
        return apiKey;
    }

    public void setApiKey(String apiKey)
    {
        this.apiKey = apiKey;
    }

    public String getApiSecret()
    {
        return apiSecret;
    }

    public void setApiSecret(String apiSecret)
    {
        this.apiSecret = apiSecret;
    }

    public String getMessagingServiceSid()
    {
        return messagingServiceSid;
    }

    public void setMessagingServiceSid(String messagingServiceSid)
    {
        this.messagingServiceSid = messagingServiceSid;
    }
}
