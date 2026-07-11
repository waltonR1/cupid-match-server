package com.ruoyi.cupid.service.impl;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.mapper.CupidPaymentMapper;
import com.ruoyi.cupid.service.ICupidAdminPaymentService;
import com.ruoyi.cupid.service.ICupidPaymentService;

@Service
public class CupidAdminPaymentServiceImpl implements ICupidAdminPaymentService
{
    private static final Logger log = LoggerFactory.getLogger(CupidAdminPaymentServiceImpl.class);

    private final CupidPaymentMapper paymentMapper;
    private final CupidStripeClient stripeClient;
    private final ICupidPaymentService paymentService;

    public CupidAdminPaymentServiceImpl(CupidPaymentMapper paymentMapper, CupidStripeClient stripeClient,
            ICupidPaymentService paymentService)
    {
        this.paymentMapper = paymentMapper;
        this.stripeClient = stripeClient;
        this.paymentService = paymentService;
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
        if (shouldTryCheckoutFallback(detail))
        {
            paymentService.selectAccountOrder(trim(detail.get("userId")), id);
            detail = paymentMapper.selectAdminOrderDetail(id);
        }
        if (detail != null)
        {
            List<Map<String, Object>> payments = paymentMapper.selectAdminPaymentsByOrderId(id);
            if (shouldTryPaymentBackfill(detail, payments))
            {
                backfillPaymentFromStripe(detail);
                payments = paymentMapper.selectAdminPaymentsByOrderId(id);
            }
            detail.put("payments", payments);
        }
        return detail;
    }

    private boolean shouldTryCheckoutFallback(Map<String, Object> detail)
    {
        if (detail == null)
        {
            return false;
        }
        String status = trim(detail.get("status"));
        return ("pending".equals(status) || "checkout_created".equals(status))
                && StringUtils.hasText(trim(detail.get("checkoutSessionId")))
                && StringUtils.hasText(trim(detail.get("userId")));
    }

    private boolean shouldTryPaymentBackfill(Map<String, Object> detail,
            List<Map<String, Object>> payments)
    {
        return detail != null
                && "paid".equals(trim(detail.get("status")))
                && StringUtils.hasText(trim(detail.get("checkoutSessionId")))
                && (payments == null || payments.isEmpty());
    }

    private void backfillPaymentFromStripe(Map<String, Object> detail)
    {
        Map<String, Object> payment = refundablePaymentFromStripe(detail);
        if (payment == null || !StringUtils.hasText(trim(payment.get("invoiceId"))))
        {
            return;
        }
        paymentMapper.insertPaymentIfAbsent(IdUtils.fastUUID(), trim(detail.get("id")),
                trim(detail.get("provider")), trim(detail.get("environment")),
                trim(payment.get("paymentId")), trim(payment.get("invoiceId")),
                trim(detail.get("subscriptionId")), trim(payment.get("chargeId")),
                trim(detail.get("checkoutSessionId")), "succeeded", "stripe_backfill",
                integer(detail.get("amountCents")), trim(detail.get("currency")),
                null, date(detail.get("paidAt")));
    }

    @Override
    @Transactional
    public Map<String, Object> cancelAdminOrderRenewal(String id)
    {
        Map<String, Object> detail = paymentMapper.selectAdminOrderDetail(id);
        if (detail == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "order_not_found");
        }

        String subscriptionId = trim(detail.get("subscriptionId"));
        String localSubscriptionId = trim(detail.get("localSubscriptionId"));
        if (!StringUtils.hasText(subscriptionId) || !StringUtils.hasText(localSubscriptionId))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "subscription_not_found");
        }

        JSONObject stripeSubscription = stripeClient.cancelSubscriptionAtPeriodEnd(subscriptionId);
        updateLocalSubscription(detail, stripeSubscription);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", "renewal_cancelled");
        result.put("orderId", id);
        result.put("subscriptionId", subscriptionId);
        result.put("cancelAtPeriodEnd", true);
        return result;
    }

    @Override
    @Transactional
    public Map<String, Object> refundAdminOrder(String id)
    {
        Map<String, Object> detail = selectAdminOrderDetail(id);
        if (detail == null)
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "order_not_found");
        }
        if ("refunded".equals(trim(detail.get("status"))))
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "order_already_refunded");
        }

        Map<String, Object> payment = firstRefundablePayment(detail);
        if (payment == null)
        {
            payment = refundablePaymentFromStripe(detail);
        }
        if (payment == null)
        {
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "payment_not_refundable");
        }

        String chargeId = trim(payment.get("chargeId"));
        String paymentId = trim(payment.get("paymentId"));
        JSONObject refund = null;
        try
        {
            refund = stripeClient.createRefund(chargeId, paymentId);
            markOrderRefunded(id, detail, payment, refund.getString("status"));
        }
        catch (IllegalStateException e)
        {
            if (!isStripeAlreadyRefunded(e))
            {
                throw e;
            }
            markOrderRefunded(id, detail, payment, "already_refunded");
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", "refunded");
        result.put("orderId", id);
        result.put("refundId", refund == null ? null : refund.getString("id"));
        result.put("renewalCancelled", cancelRenewalAfterRefund(detail));
        return result;
    }

    private boolean cancelRenewalAfterRefund(Map<String, Object> detail)
    {
        String subscriptionId = trim(detail.get("subscriptionId"));
        String localSubscriptionId = trim(detail.get("localSubscriptionId"));
        if (!StringUtils.hasText(subscriptionId) || !StringUtils.hasText(localSubscriptionId)
                || truthy(detail.get("cancelAtPeriodEnd")))
        {
            return false;
        }
        try
        {
            JSONObject stripeSubscription = stripeClient.cancelSubscriptionAtPeriodEnd(subscriptionId);
            updateLocalSubscription(detail, stripeSubscription);
            return true;
        }
        catch (RuntimeException e)
        {
            log.warn("Cupid Stripe renewal cancellation after refund failed: orderId={}, subscriptionId={}, message={}",
                    trim(detail.get("id")), subscriptionId, e.getMessage());
            return false;
        }
    }

    private void markOrderRefunded(String orderId, Map<String, Object> detail,
            Map<String, Object> payment, String rawStatus)
    {
        String chargeId = trim(payment.get("chargeId"));
        String paymentId = trim(payment.get("paymentId"));
        if (StringUtils.hasText(trim(payment.get("invoiceId"))))
        {
            paymentMapper.insertPaymentIfAbsent(IdUtils.fastUUID(), orderId,
                    trim(detail.get("provider")), trim(detail.get("environment")),
                    paymentId, trim(payment.get("invoiceId")), trim(detail.get("subscriptionId")),
                    chargeId, trim(detail.get("checkoutSessionId")), "refunded",
                    rawStatus, integer(detail.get("amountCents")),
                    trim(detail.get("currency")), null, date(detail.get("paidAt")));
        }
        paymentMapper.updatePaymentRefunded(trim(payment.get("provider")),
                trim(payment.get("environment")), paymentId, chargeId, rawStatus);
        paymentMapper.updateOrderStatus(orderId, "refunded", date(detail.get("paidAt")), null, null);
    }

    private boolean isStripeAlreadyRefunded(RuntimeException e)
    {
        String message = e.getMessage();
        return message != null && message.contains("has already been refunded");
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

    private Map<String, Object> firstRefundablePayment(Map<String, Object> detail)
    {
        Object paymentsValue = detail.get("payments");
        if (!(paymentsValue instanceof List<?>))
        {
            return null;
        }
        for (Object item : (List<?>) paymentsValue)
        {
            if (!(item instanceof Map<?, ?>))
            {
                continue;
            }
            Map<?, ?> payment = (Map<?, ?>) item;
            if (!"succeeded".equals(trim(payment.get("status"))))
            {
                continue;
            }
            if (StringUtils.hasText(trim(payment.get("chargeId")))
                    || StringUtils.hasText(trim(payment.get("paymentId"))))
            {
                Map<String, Object> result = new LinkedHashMap<>();
                for (Map.Entry<?, ?> entry : payment.entrySet())
                {
                    if (entry.getKey() != null)
                    {
                        result.put(String.valueOf(entry.getKey()), entry.getValue());
                    }
                }
                return result;
            }
        }
        return null;
    }

    private Map<String, Object> refundablePaymentFromStripe(Map<String, Object> detail)
    {
        String sessionId = trim(detail.get("checkoutSessionId"));
        if (!StringUtils.hasText(sessionId) || !"paid".equals(trim(detail.get("status"))))
        {
            return null;
        }
        JSONObject session = stripeClient.retrieveCheckoutSession(sessionId);
        if (!"complete".equals(session.getString("status"))
                || !"paid".equals(session.getString("payment_status")))
        {
            return null;
        }

        StripePaymentReference paymentReference = paymentReferenceFromCheckout(session);
        if (!StringUtils.hasText(paymentReference.paymentId)
                && !StringUtils.hasText(paymentReference.chargeId))
        {
            return null;
        }

        Map<String, Object> payment = new LinkedHashMap<>();
        payment.put("provider", trim(detail.get("provider")));
        payment.put("environment", trim(detail.get("environment")));
        payment.put("paymentId", paymentReference.paymentId);
        payment.put("invoiceId", paymentReference.invoiceId);
        payment.put("chargeId", paymentReference.chargeId);
        return payment;
    }

    private StripePaymentReference paymentReferenceFromCheckout(JSONObject session)
    {
        String invoiceId = objectId(session.get("invoice"));
        JSONObject invoice = session.get("invoice") instanceof JSONObject
                ? (JSONObject) session.get("invoice") : null;
        if (invoice == null && StringUtils.hasText(invoiceId))
        {
            invoice = stripeClient.retrieveInvoice(invoiceId);
        }

        StripePaymentReference reference = invoice == null
                ? new StripePaymentReference() : paymentReferenceFromInvoice(invoice);
        reference.invoiceId = firstText(reference.invoiceId, invoiceId);
        reference.paymentId = firstText(reference.paymentId, objectId(session.get("payment_intent")));
        if (!StringUtils.hasText(reference.chargeId)
                && StringUtils.hasText(reference.paymentId))
        {
            reference.chargeId = latestChargeFromPaymentIntent(reference.paymentId);
        }
        return reference;
    }

    private StripePaymentReference paymentReferenceFromInvoice(JSONObject invoice)
    {
        StripePaymentReference reference = new StripePaymentReference();
        reference.invoiceId = invoice.getString("id");
        reference.paymentId = objectId(invoice.get("payment_intent"));
        reference.chargeId = objectId(invoice.get("charge"));

        JSONObject payments = invoice.getJSONObject("payments");
        JSONArray data = payments == null ? null : payments.getJSONArray("data");
        if (data != null)
        {
            for (int i = 0; i < data.size(); i++)
            {
                JSONObject invoicePayment = data.getJSONObject(i);
                if (invoicePayment == null)
                {
                    continue;
                }
                if (!"paid".equals(invoicePayment.getString("status"))
                        && StringUtils.hasText(reference.paymentId))
                {
                    continue;
                }
                JSONObject payment = invoicePayment.getJSONObject("payment");
                if (payment == null)
                {
                    continue;
                }
                reference.paymentId = firstText(reference.paymentId,
                        objectId(payment.get("payment_intent")));
                reference.chargeId = firstText(reference.chargeId,
                        objectId(payment.get("charge")));
                if (StringUtils.hasText(reference.paymentId)
                        || StringUtils.hasText(reference.chargeId))
                {
                    break;
                }
            }
        }

        if (!StringUtils.hasText(reference.chargeId)
                && StringUtils.hasText(reference.paymentId))
        {
            reference.chargeId = latestChargeFromPaymentIntent(reference.paymentId);
        }
        return reference;
    }

    private String latestChargeFromPaymentIntent(String paymentIntentId)
    {
        try
        {
            JSONObject paymentIntent = stripeClient.retrievePaymentIntent(paymentIntentId);
            return objectId(paymentIntent.get("latest_charge"));
        }
        catch (RuntimeException e)
        {
            return null;
        }
    }

    private static class StripePaymentReference
    {
        private String invoiceId;
        private String paymentId;
        private String chargeId;
    }

    private String nestedString(JSONObject object, String... keys)
    {
        JSONObject current = object;
        for (int i = 0; i < keys.length; i++)
        {
            Object value = current.get(keys[i]);
            if (i == keys.length - 1)
            {
                return objectId(value);
            }
            if (!(value instanceof JSONObject))
            {
                return null;
            }
            current = (JSONObject) value;
        }
        return null;
    }

    private String objectId(Object value)
    {
        if (value instanceof JSONObject)
        {
            return ((JSONObject) value).getString("id");
        }
        return value == null ? null : String.valueOf(value);
    }

    private String firstText(Object first, String second)
    {
        String text = first == null ? null : String.valueOf(first);
        return StringUtils.hasText(text) ? text : second;
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
        return Integer.parseInt(String.valueOf(value));
    }

    private Date date(Object value)
    {
        if (value == null)
        {
            return null;
        }
        if (value instanceof Date)
        {
            return (Date) value;
        }
        if (value instanceof Timestamp)
        {
            return new Date(((Timestamp) value).getTime());
        }
        if (value instanceof LocalDateTime)
        {
            return Date.from(((LocalDateTime) value).atZone(ZoneId.systemDefault()).toInstant());
        }
        throw new IllegalArgumentException("Unsupported date value: " + value.getClass().getName());
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

    private void updateLocalSubscription(Map<String, Object> detail, JSONObject stripeSubscription)
    {
        String status = stripeSubscription.getString("status");
        Date periodStart = epoch(stripeSubscription.getLong("current_period_start"));
        Date periodEnd = epoch(stripeSubscription.getLong("current_period_end"));
        boolean cancelAtPeriodEnd = stripeSubscription.getBooleanValue("cancel_at_period_end");
        Date cancelledAt = epoch(stripeSubscription.getLong("canceled_at"));
        paymentMapper.updateSubscription(trim(detail.get("localSubscriptionId")),
                trim(detail.get("membershipId")),
                trim(detail.get("planId")),
                trim(detail.get("priceId")),
                status, periodStart, periodEnd, cancelAtPeriodEnd, cancelledAt);
        if (StringUtils.hasText(trim(detail.get("membershipId"))))
        {
            paymentMapper.updateMembershipLifecycle(trim(detail.get("membershipId")),
                    membershipStatusForSubscription(status, periodEnd, cancelAtPeriodEnd),
                    membershipExpiresAtForSubscription(status, periodEnd, cancelledAt, cancelAtPeriodEnd));
        }
    }

    private String membershipStatusForSubscription(String stripeStatus, Date periodEnd,
            boolean cancelAtPeriodEnd)
    {
        if ("active".equals(stripeStatus) || "trialing".equals(stripeStatus))
        {
            return "active";
        }
        if ("past_due".equals(stripeStatus) || "incomplete".equals(stripeStatus))
        {
            return periodEnd != null && periodEnd.after(new Date()) ? "active" : "paused";
        }
        if ("canceled".equals(stripeStatus) && cancelAtPeriodEnd
                && periodEnd != null && periodEnd.after(new Date()))
        {
            return "active";
        }
        if ("canceled".equals(stripeStatus) || "cancelled".equals(stripeStatus))
        {
            return "cancelled";
        }
        if ("unpaid".equals(stripeStatus) || "incomplete_expired".equals(stripeStatus))
        {
            return periodEnd != null && periodEnd.after(new Date()) ? "active" : "expired";
        }
        return "paused";
    }

    private Date membershipExpiresAtForSubscription(String stripeStatus, Date periodEnd,
            Date cancelledAt, boolean cancelAtPeriodEnd)
    {
        if ("canceled".equals(stripeStatus) || "cancelled".equals(stripeStatus))
        {
            if (cancelAtPeriodEnd && periodEnd != null && periodEnd.after(new Date()))
            {
                return periodEnd;
            }
            return cancelledAt != null ? cancelledAt : new Date();
        }
        return periodEnd;
    }

    private Date epoch(Long seconds)
    {
        return seconds == null ? null : new Date(seconds * 1000L);
    }
}
