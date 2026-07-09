package com.ruoyi.cupid.mapper;

import java.util.Date;
import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface CupidPaymentMapper
{
    Map<String, Object> selectPlanByTier(@Param("tier") String tier);

    Map<String, Object> selectPlanById(@Param("planId") String planId);

    Map<String, Object> selectActiveStripePrice(@Param("planId") String planId,
            @Param("environment") String environment,
            @Param("currency") String currency,
            @Param("billingPeriod") String billingPeriod);

    Map<String, Object> selectPaymentCustomer(@Param("userId") String userId,
            @Param("provider") String provider,
            @Param("environment") String environment);

    int insertPaymentCustomer(@Param("id") String id,
            @Param("userId") String userId,
            @Param("provider") String provider,
            @Param("environment") String environment,
            @Param("providerCustomerId") String providerCustomerId);

    int insertOrder(@Param("id") String id,
            @Param("userId") String userId,
            @Param("planId") String planId,
            @Param("provider") String provider,
            @Param("environment") String environment,
            @Param("status") String status,
            @Param("amountCents") int amountCents,
            @Param("currency") String currency);

    int updateOrderCheckoutCreated(@Param("id") String id,
            @Param("checkoutSessionId") String checkoutSessionId,
            @Param("subscriptionId") String subscriptionId,
            @Param("customerId") String customerId,
            @Param("expiresAt") Date expiresAt);

    Map<String, Object> selectOrderById(@Param("id") String id);

    Map<String, Object> selectOrderBySessionId(@Param("provider") String provider,
            @Param("environment") String environment,
            @Param("checkoutSessionId") String checkoutSessionId);

    Map<String, Object> selectOrderBySubscriptionId(@Param("provider") String provider,
            @Param("environment") String environment,
            @Param("subscriptionId") String subscriptionId);

    Map<String, Object> selectAccountOrder(@Param("userId") String userId,
            @Param("orderId") String orderId);

    int updateOrderStatus(@Param("id") String id,
            @Param("status") String status,
            @Param("paidAt") Date paidAt,
            @Param("cancelledAt") Date cancelledAt,
            @Param("failureReason") String failureReason);

    int updateOrderSubscription(@Param("id") String id,
            @Param("subscriptionId") String subscriptionId,
            @Param("customerId") String customerId);

    int insertWebhookEvent(@Param("id") String id,
            @Param("provider") String provider,
            @Param("environment") String environment,
            @Param("eventId") String eventId,
            @Param("eventType") String eventType,
            @Param("payloadJson") String payloadJson);

    int updateWebhookEventStatus(@Param("provider") String provider,
            @Param("environment") String environment,
            @Param("eventId") String eventId,
            @Param("processStatus") String processStatus,
            @Param("processMessage") String processMessage);

    Map<String, Object> selectSubscriptionByProviderId(@Param("provider") String provider,
            @Param("environment") String environment,
            @Param("subscriptionId") String subscriptionId);

    int insertSubscription(@Param("id") String id,
            @Param("userId") String userId,
            @Param("planId") String planId,
            @Param("membershipId") String membershipId,
            @Param("provider") String provider,
            @Param("environment") String environment,
            @Param("customerId") String customerId,
            @Param("subscriptionId") String subscriptionId,
            @Param("priceId") String priceId,
            @Param("status") String status,
            @Param("periodStart") Date periodStart,
            @Param("periodEnd") Date periodEnd,
            @Param("cancelAtPeriodEnd") boolean cancelAtPeriodEnd,
            @Param("cancelledAt") Date cancelledAt);

    int updateSubscription(@Param("id") String id,
            @Param("membershipId") String membershipId,
            @Param("planId") String planId,
            @Param("priceId") String priceId,
            @Param("status") String status,
            @Param("periodStart") Date periodStart,
            @Param("periodEnd") Date periodEnd,
            @Param("cancelAtPeriodEnd") boolean cancelAtPeriodEnd,
            @Param("cancelledAt") Date cancelledAt);

    int expireActiveMemberships(@Param("userId") String userId);

    int insertUserMembership(@Param("id") String id,
            @Param("userId") String userId,
            @Param("planId") String planId,
            @Param("tier") String tier,
            @Param("status") String status,
            @Param("startedAt") Date startedAt,
            @Param("expiresAt") Date expiresAt);

    int insertEntitlementBalance(@Param("id") String id,
            @Param("userId") String userId,
            @Param("membershipId") String membershipId,
            @Param("entitlementCode") String entitlementCode,
            @Param("periodStartedAt") Date periodStartedAt,
            @Param("periodEndsAt") Date periodEndsAt,
            @Param("quotaTotal") int quotaTotal);

    int insertPaymentIfAbsent(@Param("id") String id,
            @Param("orderId") String orderId,
            @Param("provider") String provider,
            @Param("environment") String environment,
            @Param("paymentId") String paymentId,
            @Param("invoiceId") String invoiceId,
            @Param("subscriptionId") String subscriptionId,
            @Param("chargeId") String chargeId,
            @Param("checkoutSessionId") String checkoutSessionId,
            @Param("status") String status,
            @Param("rawStatus") String rawStatus,
            @Param("amountCents") int amountCents,
            @Param("currency") String currency,
            @Param("failureReason") String failureReason,
            @Param("paidAt") Date paidAt);

    List<Map<String, Object>> selectAdminOrders(Map<String, Object> params);

    List<Map<String, Object>> selectAdminWebhookEvents(Map<String, Object> params);
}
