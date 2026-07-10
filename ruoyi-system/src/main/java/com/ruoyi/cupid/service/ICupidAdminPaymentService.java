package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

public interface ICupidAdminPaymentService
{
    List<Map<String, Object>> selectAdminOrders(Map<String, Object> params);

    Map<String, Object> selectAdminOrderDetail(String id);

    Map<String, Object> selectAdminOrderStripeLinks(String id);

    List<Map<String, Object>> selectAdminWebhookEvents(Map<String, Object> params);

    Map<String, Object> selectAdminWebhookEventDetail(String id);
}
