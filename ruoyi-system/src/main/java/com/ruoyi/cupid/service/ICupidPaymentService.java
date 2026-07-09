package com.ruoyi.cupid.service;

import java.util.Map;

public interface ICupidPaymentService
{
    Map<String, Object> createMembershipSubscriptionCheckout(String userId, String tier);

    Map<String, Object> selectAccountOrder(String userId, String orderId);

    void handleStripeWebhook(String payload, String signatureHeader);
}
