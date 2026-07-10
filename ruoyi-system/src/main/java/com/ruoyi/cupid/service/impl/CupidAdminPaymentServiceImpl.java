package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.ruoyi.cupid.mapper.CupidPaymentMapper;
import com.ruoyi.cupid.service.ICupidAdminPaymentService;

@Service
public class CupidAdminPaymentServiceImpl implements ICupidAdminPaymentService
{
    private final CupidPaymentMapper paymentMapper;

    public CupidAdminPaymentServiceImpl(CupidPaymentMapper paymentMapper)
    {
        this.paymentMapper = paymentMapper;
    }

    @Override
    public List<Map<String, Object>> selectAdminOrders(Map<String, Object> params)
    {
        Map<String, Object> query = new HashMap<>();
        query.put("keyword", trim(params.get("keyword")));
        query.put("status", trim(params.get("status")));
        query.put("tier", trim(params.get("tier")));
        return paymentMapper.selectAdminOrders(query);
    }

    @Override
    public Map<String, Object> selectAdminOrderDetail(String id)
    {
        Map<String, Object> detail = paymentMapper.selectAdminOrderDetail(id);
        if (detail != null)
        {
            detail.put("payments", paymentMapper.selectAdminPaymentsByOrderId(id));
        }
        return detail;
    }

    @Override
    public Map<String, Object> selectAdminOrderStripeLinks(String id)
    {
        Map<String, Object> detail = selectAdminOrderDetail(id);
        Map<String, Object> result = new LinkedHashMap<>();
        List<Map<String, String>> links = new ArrayList<>();
        if (detail == null)
        {
            result.put("links", links);
            return result;
        }

        String baseUrl = stripeDashboardBaseUrl(trim(detail.get("environment")));
        addStripeLink(links, "customer", "查看 Stripe Customer",
                baseUrl, "customers", trim(detail.get("customerId")));
        addStripeLink(links, "subscription", "查看/取消 Stripe Subscription",
                baseUrl, "subscriptions", trim(detail.get("subscriptionId")));
        addStripeLink(links, "checkout_session", "查看 Checkout Session",
                baseUrl, "checkout/sessions", trim(detail.get("checkoutSessionId")));
        addStripeLink(links, "price", "查看 Stripe Price",
                baseUrl, "prices", trim(detail.get("priceId")));

        Object paymentsValue = detail.get("payments");
        if (paymentsValue instanceof List<?>)
        {
            for (Object item : (List<?>) paymentsValue)
            {
                if (item instanceof Map<?, ?>)
                {
                    Map<?, ?> payment = (Map<?, ?>) item;
                    addStripeLink(links, "payment", "查看/退款 Stripe Payment",
                            baseUrl, "payments", trim(payment.get("paymentId")));
                    addStripeLink(links, "invoice", "查看 Stripe Invoice",
                            baseUrl, "invoices", trim(payment.get("invoiceId")));
                    addStripeLink(links, "charge", "查看/退款 Stripe Charge",
                            baseUrl, "payments", trim(payment.get("chargeId")));
                }
            }
        }
        result.put("links", links);
        return result;
    }

    @Override
    public List<Map<String, Object>> selectAdminWebhookEvents(Map<String, Object> params)
    {
        Map<String, Object> query = new HashMap<>();
        query.put("eventType", trim(params.get("eventType")));
        query.put("processStatus", trim(params.get("processStatus")));
        return paymentMapper.selectAdminWebhookEvents(query);
    }

    @Override
    public Map<String, Object> selectAdminWebhookEventDetail(String id)
    {
        return paymentMapper.selectAdminWebhookEventDetail(id);
    }

    private String trim(Object value)
    {
        if (value == null)
        {
            return null;
        }
        String text = String.valueOf(value).trim();
        return StringUtils.hasText(text) ? text : null;
    }

    private String stripeDashboardBaseUrl(String environment)
    {
        return "live".equals(environment)
                ? "https://dashboard.stripe.com"
                : "https://dashboard.stripe.com/test";
    }

    private void addStripeLink(List<Map<String, String>> links, String type, String label,
            String baseUrl, String path, String id)
    {
        if (!StringUtils.hasText(id))
        {
            return;
        }
        for (Map<String, String> existing : links)
        {
            if (id.equals(existing.get("externalId")))
            {
                return;
            }
        }
        Map<String, String> link = new LinkedHashMap<>();
        link.put("type", type);
        link.put("label", label);
        link.put("externalId", id);
        link.put("url", baseUrl + "/" + path + "/" + id);
        links.add(link);
    }
}
