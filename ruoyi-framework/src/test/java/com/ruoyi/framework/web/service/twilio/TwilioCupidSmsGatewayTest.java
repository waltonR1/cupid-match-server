package com.ruoyi.framework.web.service.twilio;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import java.net.http.HttpRequest;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import org.junit.jupiter.api.Test;

class TwilioCupidSmsGatewayTest
{
    @Test
    void shouldUseAccountSidAndAuthToken()
    {
        TwilioSmsProperties properties = validProperties();
        TwilioCupidSmsGateway gateway = new TwilioCupidSmsGateway(properties, null);

        gateway.validate();
        HttpRequest request = gateway.buildRequest("+33612345678", "Code 123456");

        assertEquals("https://api.twilio.com/2010-04-01/Accounts/AC123/Messages.json",
                request.uri().toString());
        assertEquals(basic("AC123", "token"),
                request.headers().firstValue("Authorization").orElseThrow());
    }

    @Test
    void shouldPreferCompleteApiKeyCredentials()
    {
        TwilioSmsProperties properties = validProperties();
        properties.setApiKey("SK123");
        properties.setApiSecret("secret");
        TwilioCupidSmsGateway gateway = new TwilioCupidSmsGateway(properties, null);

        gateway.validate();
        HttpRequest request = gateway.buildRequest("+33612345678", "Code 123456");

        assertEquals(basic("SK123", "secret"),
                request.headers().firstValue("Authorization").orElseThrow());
    }

    @Test
    void shouldRejectPartialApiKeyConfiguration()
    {
        TwilioSmsProperties properties = validProperties();
        properties.setApiKey("SK123");

        IllegalStateException exception = assertThrows(IllegalStateException.class,
                () -> new TwilioCupidSmsGateway(properties, null).validate());

        assertTrue(exception.getMessage().contains("configured together"));
    }

    @Test
    void shouldRejectInvalidPhoneFormat()
    {
        TwilioCupidSmsGateway gateway = new TwilioCupidSmsGateway(validProperties(), null);

        assertThrows(IllegalArgumentException.class,
                () -> gateway.buildRequest("0612345678", "Code 123456"));
    }

    private static TwilioSmsProperties validProperties()
    {
        TwilioSmsProperties properties = new TwilioSmsProperties();
        properties.setAccountSid("AC123");
        properties.setAuthToken("token");
        properties.setMessagingServiceSid("MG123");
        return properties;
    }

    private static String basic(String username, String password)
    {
        return "Basic " + Base64.getEncoder().encodeToString(
                (username + ":" + password).getBytes(StandardCharsets.UTF_8));
    }
}
