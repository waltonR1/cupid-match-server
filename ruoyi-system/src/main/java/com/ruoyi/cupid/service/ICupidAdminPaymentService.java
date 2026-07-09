package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

public interface ICupidAdminPaymentService
{
    List<Map<String, Object>> selectAdminOrders(Map<String, Object> params);

    List<Map<String, Object>> selectAdminWebhookEvents(Map<String, Object> params);
}
