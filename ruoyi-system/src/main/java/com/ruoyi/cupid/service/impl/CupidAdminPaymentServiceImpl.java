package com.ruoyi.cupid.service.impl;

import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.cupid.mapper.CupidPaymentMapper;
import com.ruoyi.cupid.service.ICupidAdminPaymentService;

@Service
public class CupidAdminPaymentServiceImpl implements ICupidAdminPaymentService
{
    private final CupidPaymentMapper paymentMapper;
    private final CupidStripeClient stripeClient;

    public CupidAdminPaymentServiceImpl(CupidPaymentMapper paymentMapper, CupidStripeClient stripeClient)
    {
        this.paymentMapper = paymentMapper;
        this.stripeClient = stripeClient;
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
            throw new CupidApiException(HttpStatus.BAD_REQUEST, "payment_not_refundable");
        }

        String chargeId = trim(payment.get("chargeId"));
        String paymentId = trim(payment.get("paymentId"));
        JSONObject refund = stripeClient.createRefund(chargeId, paymentId);
        paymentMapper.updatePaymentRefunded(trim(payment.get("provider")), trim(payment.get("environment")),
                paymentId, chargeId, refund.getString("status"));
        paymentMapper.updateOrderStatus(id, "refunded", (Date) detail.get("paidAt"), null, null);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", "refunded");
        result.put("orderId", id);
        result.put("refundId", refund.getString("id"));
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
