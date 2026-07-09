package com.ruoyi.cupid.service.impl;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.config.CupidStripeProperties;
import com.ruoyi.cupid.domain.CupidUser;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.mapper.CupidPaymentMapper;
import com.ruoyi.cupid.service.ICupidPaymentService;

@Service
public class CupidPaymentServiceImpl implements ICupidPaymentService
{
    private static final String PROVIDER_STRIPE = "stripe";
    private static final String MODE_SUBSCRIPTION = "subscription";

    private final CupidPaymentMapper paymentMapper;
    private final CupidAuthMapper authMapper;
    private final CupidStripeClient stripeClient;
    private final CupidStripeProperties stripeProperties;

    public CupidPaymentServiceImpl(CupidPaymentMapper paymentMapper, CupidAuthMapper authMapper,
            CupidStripeClient stripeClient, CupidStripeProperties stripeProperties)
    {
        this.paymentMapper = paymentMapper;
        this.authMapper = authMapper;
        this.stripeClient = stripeClient;
        this.stripeProperties = stripeProperties;
    }

    @Override
    @Transactional
    public Map<String, Object> createMembershipSubscriptionCheckout(String userId, String tier)
    {
        if (!stripeProperties.isEnabled())
        {
            throw new CupidApiException(HttpStatus.ERROR, "stripe_disabled");
        }
        CupidUser user = authMapper.selectUserById(userId);
        if (user == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "account_not_found");
        }
        if (!"active".equals(user.getStatus()))
        {
            throw new CupidApiException(HttpStatus.FORBIDDEN, "account_not_active");
        }
        Map<String, Object> plan = paymentMapper.selectPlanByTier(tier);
        if (plan == null || "free".equals(tier))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "invalid_tier");
        }
        if (!"recurring".equals(text(plan.get("billingType"))))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "membership_plan_not_recurring");
        }
        String environment = environment();
        String billingPeriod = text(plan.get("billingPeriod"));
        String currency = text(plan.get("currency"));
        Map<String, Object> price = paymentMapper.selectActiveStripePrice(text(plan.get("id")),
                environment, currency, billingPeriod);
        if (price == null)
        {
            throw new CupidApiException(HttpStatus.ERROR, "stripe_price_not_configured");
        }
        String customerId = ensureCustomer(userId);
        String orderId = IdUtils.fastUUID();
        paymentMapper.insertOrder(orderId, userId, text(plan.get("id")),
                PROVIDER_STRIPE, environment, "pending", integer(plan.get("priceCents")), currency);
        JSONObject session = stripeClient.createSubscriptionCheckoutSession(customerId,
                text(price.get("providerPriceId")), orderId, userId, text(plan.get("id")), tier);
        Date expiresAt = epoch(session.getLong("expires_at"));
        paymentMapper.updateOrderCheckoutCreated(orderId, session.getString("id"),
                session.getString("subscription"), customerId, expiresAt);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", "checkout_required");
        result.put("requestedTier", tier);
        result.put("orderId", orderId);
        result.put("checkoutUrl", session.getString("url"));
        return result;
    }

    @Override
    public Map<String, Object> selectAccountOrder(String userId, String orderId)
    {
        Map<String, Object> order = paymentMapper.selectAccountOrder(userId, orderId);
        if (order == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "order_not_found");
        }
        return order;
    }

    @Override
    @Transactional
    public void handleStripeWebhook(String payload, String signatureHeader)
    {
        stripeClient.verifyWebhookSignature(payload, signatureHeader);
        JSONObject event = JSON.parseObject(payload);
        String eventId = event.getString("id");
        String eventType = event.getString("type");
        String environment = environment();
        int inserted = paymentMapper.insertWebhookEvent(IdUtils.fastUUID(), PROVIDER_STRIPE,
                environment, eventId, eventType, payload);
        if (inserted == 0)
        {
            return;
        }
        try
        {
            JSONObject object = event.getJSONObject("data").getJSONObject("object");
            if ("checkout.session.completed".equals(eventType))
            {
                handleCheckoutCompleted(object);
            }
            else if ("checkout.session.expired".equals(eventType))
            {
                handleCheckoutExpired(object);
            }
            else if ("invoice.paid".equals(eventType)
                    || "invoice.payment_succeeded".equals(eventType))
            {
                handleInvoicePaid(object);
            }
            else if ("invoice.payment_failed".equals(eventType))
            {
                handleInvoicePaymentFailed(object);
            }
            else if ("customer.subscription.created".equals(eventType)
                    || "customer.subscription.updated".equals(eventType)
                    || "customer.subscription.deleted".equals(eventType))
            {
                handleSubscriptionChanged(object);
            }
            else
            {
                paymentMapper.updateWebhookEventStatus(PROVIDER_STRIPE, environment, eventId,
                        "ignored", "event ignored");
                return;
            }
            paymentMapper.updateWebhookEventStatus(PROVIDER_STRIPE, environment, eventId,
                    "processed", null);
        }
        catch (Exception e)
        {
            paymentMapper.updateWebhookEventStatus(PROVIDER_STRIPE, environment, eventId,
                    "failed", e.getMessage());
            throw e;
        }
    }

    private String ensureCustomer(String userId)
    {
        String environment = environment();
        Map<String, Object> existing = paymentMapper.selectPaymentCustomer(userId,
                PROVIDER_STRIPE, environment);
        if (existing != null && StringUtils.hasText(text(existing.get("providerCustomerId"))))
        {
            return text(existing.get("providerCustomerId"));
        }
        JSONObject customer = stripeClient.createCustomer(userId);
        String customerId = customer.getString("id");
        paymentMapper.insertPaymentCustomer(IdUtils.fastUUID(), userId, PROVIDER_STRIPE,
                environment, customerId);
        return customerId;
    }

    private void handleCheckoutCompleted(JSONObject session)
    {
        String environment = environment();
        String sessionId = session.getString("id");
        Map<String, Object> order = paymentMapper.selectOrderBySessionId(PROVIDER_STRIPE,
                environment, sessionId);
        if (order == null)
        {
            String orderId = metadata(session).getString("orderId");
            order = StringUtils.hasText(orderId) ? paymentMapper.selectOrderById(orderId) : null;
        }
        if (order == null)
        {
            throw new IllegalStateException("Checkout order not found");
        }
        String subscriptionId = session.getString("subscription");
        String customerId = session.getString("customer");
        paymentMapper.updateOrderSubscription(text(order.get("id")), subscriptionId, customerId);
        ensureSubscriptionFromOrder(order, subscriptionId, customerId, "incomplete",
                null, null, false, null);
    }

    private void handleCheckoutExpired(JSONObject session)
    {
        Map<String, Object> order = paymentMapper.selectOrderBySessionId(PROVIDER_STRIPE,
                environment(), session.getString("id"));
        if (order != null && !"paid".equals(text(order.get("status"))))
        {
            paymentMapper.updateOrderStatus(text(order.get("id")), "expired",
                    null, new Date(), "checkout_expired");
        }
    }

    private void handleInvoicePaid(JSONObject invoice)
    {
        String subscriptionId = firstText(invoice.get("subscription"),
                nestedString(invoice, "parent", "subscription_details", "subscription"));
        if (!StringUtils.hasText(subscriptionId))
        {
            throw new IllegalStateException("Stripe invoice missing subscription");
        }
        Map<String, Object> subscription = paymentMapper.selectSubscriptionByProviderId(
                PROVIDER_STRIPE, environment(), subscriptionId);
        Map<String, Object> order = findOrderForInvoice(invoice, subscriptionId);
        if (subscription == null && order != null)
        {
            subscription = ensureSubscriptionFromOrder(order, subscriptionId,
                    text(order.get("providerCustomerId")), "active",
                    null, null, false, null);
        }
        if (subscription == null)
        {
            throw new IllegalStateException("Local subscription not found");
        }
        Map<String, Object> plan = paymentMapper.selectPlanById(text(subscription.get("planId")));
        if (plan == null)
        {
            throw new IllegalStateException("Membership plan not found");
        }
        Date periodStart = invoicePeriodStart(invoice);
        Date periodEnd = invoicePeriodEnd(invoice);
        if (periodStart == null)
        {
            periodStart = new Date();
        }
        if (periodEnd == null || !periodEnd.after(periodStart))
        {
            periodEnd = fallbackPeriodEnd(periodStart, plan);
        }
        int insertedPayment = -1;
        if (order != null)
        {
            paymentMapper.updateOrderStatus(text(order.get("id")), "paid",
                    epoch(invoice.getLong("created")), null, null);
            insertedPayment = paymentMapper.insertPaymentIfAbsent(IdUtils.fastUUID(), text(order.get("id")),
                    PROVIDER_STRIPE, environment(), invoice.getString("payment_intent"),
                    invoice.getString("id"), subscriptionId, invoice.getString("charge"),
                    text(order.get("providerCheckoutSessionId")), "succeeded",
                    invoice.getString("status"), integer(invoice.get("amount_paid")),
                    upper(invoice.getString("currency")), null, epoch(invoice.getLong("created")));
            if (insertedPayment == 0)
            {
                return;
            }
        }
        String membershipId = text(subscription.get("membershipId"));
        Date currentPeriodEnd = (Date) subscription.get("currentPeriodEndsAt");
        if ((order == null || insertedPayment == 1)
                && (!StringUtils.hasText(membershipId)
                || currentPeriodEnd == null || periodEnd.after(currentPeriodEnd)))
        {
            paymentMapper.expireActiveMemberships(text(subscription.get("userId")));
            membershipId = IdUtils.fastUUID();
            paymentMapper.insertUserMembership(membershipId, text(subscription.get("userId")),
                    text(plan.get("id")), text(plan.get("tier")), "active", periodStart, periodEnd);
            createEntitlements(text(subscription.get("userId")), membershipId, plan,
                    periodStart, periodEnd);
        }
        paymentMapper.updateSubscription(text(subscription.get("id")), membershipId,
                text(plan.get("id")), text(subscription.get("providerPriceId")),
                "active", periodStart, periodEnd, false, null);
    }

    private void handleInvoicePaymentFailed(JSONObject invoice)
    {
        String subscriptionId = invoice.getString("subscription");
        Map<String, Object> order = paymentMapper.selectOrderBySubscriptionId(PROVIDER_STRIPE,
                environment(), subscriptionId);
        if (order != null)
        {
            paymentMapper.updateOrderStatus(text(order.get("id")), "failed",
                    null, null, "invoice_payment_failed");
            paymentMapper.insertPaymentIfAbsent(IdUtils.fastUUID(), text(order.get("id")),
                    PROVIDER_STRIPE, environment(), invoice.getString("payment_intent"),
                    invoice.getString("id"), subscriptionId, invoice.getString("charge"),
                    text(order.get("providerCheckoutSessionId")), "failed",
                    invoice.getString("status"), integer(invoice.get("amount_due")),
                    upper(invoice.getString("currency")), "invoice_payment_failed", null);
        }
    }

    private void handleSubscriptionChanged(JSONObject stripeSubscription)
    {
        String subscriptionId = stripeSubscription.getString("id");
        Map<String, Object> subscription = paymentMapper.selectSubscriptionByProviderId(
                PROVIDER_STRIPE, environment(), subscriptionId);
        if (subscription == null)
        {
            String orderId = metadata(stripeSubscription).getString("orderId");
            Map<String, Object> order = StringUtils.hasText(orderId)
                    ? paymentMapper.selectOrderById(orderId) : null;
            if (order != null)
            {
                ensureSubscriptionFromOrder(order, subscriptionId,
                        stripeSubscription.getString("customer"),
                        stripeSubscription.getString("status"),
                        epoch(stripeSubscription.getLong("current_period_start")),
                        epoch(stripeSubscription.getLong("current_period_end")),
                        stripeSubscription.getBooleanValue("cancel_at_period_end"),
                        epoch(stripeSubscription.getLong("canceled_at")));
            }
            return;
        }
        paymentMapper.updateSubscription(text(subscription.get("id")),
                text(subscription.get("membershipId")),
                text(subscription.get("planId")),
                text(subscription.get("providerPriceId")),
                stripeSubscription.getString("status"),
                epoch(stripeSubscription.getLong("current_period_start")),
                epoch(stripeSubscription.getLong("current_period_end")),
                stripeSubscription.getBooleanValue("cancel_at_period_end"),
                epoch(stripeSubscription.getLong("canceled_at")));
    }

    private Map<String, Object> ensureSubscriptionFromOrder(Map<String, Object> order,
            String subscriptionId, String customerId, String status, Date periodStart,
            Date periodEnd, boolean cancelAtPeriodEnd, Date cancelledAt)
    {
        if (!StringUtils.hasText(subscriptionId))
        {
            return null;
        }
        Map<String, Object> existing = paymentMapper.selectSubscriptionByProviderId(
                PROVIDER_STRIPE, environment(), subscriptionId);
        if (existing != null)
        {
            return existing;
        }
        Map<String, Object> plan = paymentMapper.selectPlanById(text(order.get("planId")));
        if (plan == null)
        {
            throw new IllegalStateException("Membership plan not found");
        }
        Map<String, Object> price = paymentMapper.selectActiveStripePrice(text(order.get("planId")),
                environment(), text(order.get("currency")), text(plan.get("billingPeriod")));
        if (price == null)
        {
            throw new IllegalStateException("Stripe price not configured");
        }
        String id = IdUtils.fastUUID();
        paymentMapper.insertSubscription(id, text(order.get("userId")), text(order.get("planId")),
                null, PROVIDER_STRIPE, environment(), customerId, subscriptionId,
                text(price.get("providerPriceId")), status, periodStart, periodEnd,
                cancelAtPeriodEnd, cancelledAt);
        return paymentMapper.selectSubscriptionByProviderId(PROVIDER_STRIPE, environment(), subscriptionId);
    }

    private Map<String, Object> findOrderForInvoice(JSONObject invoice, String subscriptionId)
    {
        Map<String, Object> order = paymentMapper.selectOrderBySubscriptionId(PROVIDER_STRIPE,
                environment(), subscriptionId);
        if (order != null)
        {
            return order;
        }

        String orderId = firstText(metadata(invoice).getString("orderId"),
                nestedString(invoice, "parent", "subscription_details", "metadata", "orderId"));
        if (!StringUtils.hasText(orderId))
        {
            orderId = firstInvoiceLineMetadata(invoice, "orderId");
        }
        if (!StringUtils.hasText(orderId))
        {
            return null;
        }

        order = paymentMapper.selectOrderById(orderId);
        if (order != null)
        {
            paymentMapper.updateOrderSubscription(text(order.get("id")), subscriptionId,
                    invoice.getString("customer"));
        }
        return order;
    }

    private String firstInvoiceLineMetadata(JSONObject invoice, String key)
    {
        JSONObject lines = invoice.getJSONObject("lines");
        if (lines == null || lines.getJSONArray("data") == null
                || lines.getJSONArray("data").isEmpty())
        {
            return null;
        }
        JSONObject metadata = lines.getJSONArray("data").getJSONObject(0).getJSONObject("metadata");
        return metadata == null ? null : metadata.getString(key);
    }

    private void createEntitlements(String userId, String membershipId, Map<String, Object> plan,
            Date periodStart, Date periodEnd)
    {
        int privateQuota = integer(plan.get("privateIntroductionQuota"));
        int eventQuota = integer(plan.get("eventQuota"));
        paymentMapper.insertEntitlementBalance(IdUtils.fastUUID(), userId, membershipId,
                "private_introduction", periodStart, periodEnd, privateQuota);
        paymentMapper.insertEntitlementBalance(IdUtils.fastUUID(), userId, membershipId,
                "event_registration", periodStart, periodEnd, eventQuota);
        paymentMapper.insertEntitlementBalance(IdUtils.fastUUID(), userId, membershipId,
                "event_priority", periodStart, periodEnd,
                truthy(plan.get("eventPriorityEnabled")) ? 1 : 0);
        paymentMapper.insertEntitlementBalance(IdUtils.fastUUID(), userId, membershipId,
                "staff_review", periodStart, periodEnd,
                truthy(plan.get("staffReviewEnabled")) ? 1 : 0);
    }

    private JSONObject metadata(JSONObject object)
    {
        JSONObject metadata = object.getJSONObject("metadata");
        return metadata == null ? new JSONObject() : metadata;
    }

    private Date invoicePeriodStart(JSONObject invoice)
    {
        Date value = firstInvoiceLinePeriod(invoice, "start");
        return value != null ? value : epoch(invoice.getLong("period_start"));
    }

    private Date invoicePeriodEnd(JSONObject invoice)
    {
        Date value = firstInvoiceLinePeriod(invoice, "end");
        return value != null ? value : epoch(invoice.getLong("period_end"));
    }

    private Date firstInvoiceLinePeriod(JSONObject invoice, String key)
    {
        JSONObject lines = invoice.getJSONObject("lines");
        if (lines == null || lines.getJSONArray("data") == null || lines.getJSONArray("data").isEmpty())
        {
            return null;
        }
        JSONObject period = lines.getJSONArray("data").getJSONObject(0).getJSONObject("period");
        return period == null ? null : epoch(period.getLong(key));
    }

    private Date fallbackPeriodEnd(Date periodStart, Map<String, Object> plan)
    {
        int validityMonths = integer(plan.get("validityMonths"));
        if (validityMonths > 0)
        {
            return addMonths(periodStart, validityMonths);
        }
        String billingPeriod = text(plan.get("billingPeriod"));
        if ("yearly".equals(billingPeriod) || "annual".equals(billingPeriod))
        {
            return addMonths(periodStart, 12);
        }
        return addMonths(periodStart, 1);
    }

    private String nestedString(JSONObject object, String... keys)
    {
        JSONObject current = object;
        for (int i = 0; i < keys.length; i++)
        {
            Object value = current.get(keys[i]);
            if (i == keys.length - 1)
            {
                return value == null ? null : String.valueOf(value);
            }
            if (!(value instanceof JSONObject))
            {
                return null;
            }
            current = (JSONObject) value;
        }
        return null;
    }

    private String firstText(Object first, String second)
    {
        String text = first == null ? null : String.valueOf(first);
        return StringUtils.hasText(text) ? text : second;
    }

    private String environment()
    {
        return StringUtils.hasText(stripeProperties.getEnvironment())
                ? stripeProperties.getEnvironment() : "test";
    }

    private String text(Object value)
    {
        return value == null ? null : String.valueOf(value);
    }

    private int integer(Object value)
    {
        if (value == null)
        {
            return 0;
        }
        if (value instanceof Number)
        {
            return ((Number) value).intValue();
        }
        return new BigDecimal(String.valueOf(value)).intValue();
    }

    private boolean truthy(Object value)
    {
        if (value instanceof Boolean)
        {
            return (Boolean) value;
        }
        if (value instanceof Number)
        {
            return ((Number) value).intValue() != 0;
        }
        return "true".equalsIgnoreCase(String.valueOf(value)) || "1".equals(String.valueOf(value));
    }

    private String upper(String value)
    {
        return value == null ? null : value.toUpperCase();
    }

    private Date epoch(Long value)
    {
        return value == null ? null : Date.from(Instant.ofEpochSecond(value));
    }

    private Date addMonths(Date value, int months)
    {
        return Date.from(value.toInstant().atZone(java.time.ZoneId.systemDefault())
                .plusMonths(months).toInstant());
    }
}
