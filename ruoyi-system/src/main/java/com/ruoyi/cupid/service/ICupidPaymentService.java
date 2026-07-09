package com.ruoyi.cupid.service;

import java.util.Map;

public interface ICupidPaymentService
{
    Map<String, Object> createMembershipSubscriptionCheckout(String userId, String tier);

    Map<String, Object> selectAccountOrder(String userId, String orderId);

    Map<String, Object> cancelAccountMembershipRenewal(String userId);

    void handleStripeWebhook(String payload, String signatureHeader);
}
