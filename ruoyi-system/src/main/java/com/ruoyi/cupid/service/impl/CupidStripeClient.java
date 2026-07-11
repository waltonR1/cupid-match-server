package com.ruoyi.cupid.service.impl;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.cupid.config.CupidStripeProperties;

@Component
public class CupidStripeClient
{
    private static final String API_BASE = "https://api.stripe.com";

    private final CupidStripeProperties properties;
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10)).build();

    public CupidStripeClient(CupidStripeProperties properties)
    {
        this.properties = properties;
    }

    public JSONObject createCustomer(String userId)
    {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("metadata[cupidUserId]", userId);
        return post("/v1/customers", params);
    }

    public JSONObject createSubscriptionCheckoutSession(String customerId, String priceId,
            String orderId, String userId, String planId, String tier)
    {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("mode", "subscription");
        params.put("customer", customerId);
        params.put("line_items[0][price]", priceId);
        params.put("line_items[0][quantity]", "1");
        params.put("client_reference_id", orderId);
        params.put("success_url", replaceUrl(properties.getSuccessUrl(), orderId));
        params.put("cancel_url", replaceUrl(properties.getCancelUrl(), orderId));
        params.put("metadata[orderId]", orderId);
        params.put("metadata[userId]", userId);
        params.put("metadata[planId]", planId);
        params.put("metadata[tier]", tier);
        params.put("subscription_data[metadata][orderId]", orderId);
        params.put("subscription_data[metadata][userId]", userId);
        params.put("subscription_data[metadata][planId]", planId);
        params.put("subscription_data[metadata][tier]", tier);
        return post("/v1/checkout/sessions", params);
    }

    public JSONObject cancelSubscriptionAtPeriodEnd(String subscriptionId)
    {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("cancel_at_period_end", "true");
        return post("/v1/subscriptions/" + subscriptionId, params);
    }

    public JSONObject retrieveCheckoutSession(String sessionId)
    {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("expand[0]", "payment_intent");
        params.put("expand[1]", "invoice");
        params.put("expand[2]", "invoice.payments");
        return get("/v1/checkout/sessions/" + sessionId, params);
    }

    public JSONObject retrieveSubscription(String subscriptionId)
    {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("expand[0]", "latest_invoice");
        params.put("expand[1]", "latest_invoice.payments");
        return get("/v1/subscriptions/" + subscriptionId, params);
    }

    public JSONObject retrieveInvoice(String invoiceId)
    {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("expand[0]", "payments");
        params.put("expand[1]", "payments.data.payment.payment_intent");
        params.put("expand[2]", "payments.data.payment.charge");
        return get("/v1/invoices/" + invoiceId, params);
    }

    public JSONObject retrievePaymentIntent(String paymentIntentId)
    {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("expand[0]", "latest_charge");
        return get("/v1/payment_intents/" + paymentIntentId, params);
    }

    public JSONObject createRefund(String chargeId, String paymentIntentId)
    {
        Map<String, String> params = new LinkedHashMap<>();
        if (StringUtils.hasText(chargeId))
        {
            params.put("charge", chargeId);
        }
        else if (StringUtils.hasText(paymentIntentId))
        {
            params.put("payment_intent", paymentIntentId);
        }
        else
        {
            throw new IllegalStateException("Stripe refund target is missing");
        }
        return post("/v1/refunds", params);
    }

    public void verifyWebhookSignature(String payload, String header)
    {
        String webhookSecret = StringUtils.trimWhitespace(properties.getWebhookSecret());
        if (!StringUtils.hasText(webhookSecret))
        {
            throw new IllegalStateException("Stripe webhook secret is not configured");
        }
        String timestamp = null;
        List<String> signatures = new ArrayList<>();
        for (String part : header.split(","))
        {
            String[] pair = part.split("=", 2);
            if (pair.length == 2 && "t".equals(pair[0]))
            {
                timestamp = pair[1];
            }
            else if (pair.length == 2 && "v1".equals(pair[0]))
            {
                signatures.add(pair[1]);
            }
        }
        if (!StringUtils.hasText(timestamp) || signatures.isEmpty())
        {
            throw new IllegalStateException("Invalid Stripe signature header");
        }
        String signedPayload = timestamp + "." + payload;
        String expected = hmacSha256(webhookSecret, signedPayload);
        boolean verified = signatures.stream()
                .anyMatch(signature -> constantTimeEquals(expected, signature));
        if (!verified)
        {
            throw new IllegalStateException("Invalid Stripe webhook signature");
        }
    }

    private JSONObject post(String path, Map<String, String> params)
    {
        ensureConfigured();
        HttpRequest request = HttpRequest.newBuilder(URI.create(API_BASE + path))
                .timeout(Duration.ofSeconds(30))
                .header("Authorization", "Basic " + basicAuth())
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(form(params), StandardCharsets.UTF_8))
                .build();
        try
        {
            HttpResponse<String> response = httpClient.send(request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            JSONObject body = JSON.parseObject(response.body());
            if (response.statusCode() < 200 || response.statusCode() >= 300)
            {
                String message = body != null && body.getJSONObject("error") != null
                        ? body.getJSONObject("error").getString("message")
                        : "Stripe API rejected request";
                throw new IllegalStateException(message);
            }
            return body;
        }
        catch (IOException e)
        {
            throw new IllegalStateException("Stripe API request failed", e);
        }
        catch (InterruptedException e)
        {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Stripe API request interrupted", e);
        }
    }

    private JSONObject get(String path)
    {
        return get(path, null);
    }

    private JSONObject get(String path, Map<String, String> params)
    {
        ensureConfigured();
        String query = params == null || params.isEmpty() ? "" : "?" + form(params);
        HttpRequest request = HttpRequest.newBuilder(URI.create(API_BASE + path + query))
                .timeout(Duration.ofSeconds(30))
                .header("Authorization", "Basic " + basicAuth())
                .GET()
                .build();
        try
        {
            HttpResponse<String> response = httpClient.send(request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            JSONObject body = JSON.parseObject(response.body());
            if (response.statusCode() < 200 || response.statusCode() >= 300)
            {
                String message = body != null && body.getJSONObject("error") != null
                        ? body.getJSONObject("error").getString("message")
                        : "Stripe API rejected request";
                throw new IllegalStateException(message);
            }
            return body;
        }
        catch (IOException e)
        {
            throw new IllegalStateException("Stripe API request failed", e);
        }
        catch (InterruptedException e)
        {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Stripe API request interrupted", e);
        }
    }

    private void ensureConfigured()
    {
        if (!properties.isEnabled() || !StringUtils.hasText(properties.getSecretKey()))
        {
            throw new IllegalStateException("Stripe is not enabled or secret key is missing");
        }
        if (!StringUtils.hasText(properties.getSuccessUrl())
                || !StringUtils.hasText(properties.getCancelUrl()))
        {
            throw new IllegalStateException("Stripe Checkout return URLs are missing");
        }
    }

    private String basicAuth()
    {
        return Base64.getEncoder().encodeToString(
                (properties.getSecretKey() + ":").getBytes(StandardCharsets.UTF_8));
    }

    private String form(Map<String, String> params)
    {
        StringBuilder builder = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet())
        {
            if (!StringUtils.hasText(entry.getValue()))
            {
                continue;
            }
            if (builder.length() > 0)
            {
                builder.append('&');
            }
            builder.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8));
            builder.append('=');
            builder.append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8));
        }
        return builder.toString();
    }

    private String replaceUrl(String url, String orderId)
    {
        return url.replace("{ORDER_ID}", orderId)
                .replace("{CHECKOUT_SESSION_ID}", "{CHECKOUT_SESSION_ID}");
    }

    private String hmacSha256(String secret, String value)
    {
        try
        {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] digest = mac.doFinal(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : digest)
            {
                hex.append(String.format("%02x", b & 0xff));
            }
            return hex.toString();
        }
        catch (Exception e)
        {
            throw new IllegalStateException("Unable to verify Stripe signature", e);
        }
    }

    private boolean constantTimeEquals(String a, String b)
    {
        if (a == null || b == null || a.length() != b.length())
        {
            return false;
        }
        int result = 0;
        for (int i = 0; i < a.length(); i++)
        {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        return result == 0;
    }
}
