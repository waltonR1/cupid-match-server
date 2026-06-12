package com.ruoyi.cupid.service;

import java.util.Map;

/**
 * Cupid Match 账户首页聚合服务。
 */
public interface ICupidDashboardService
{
    Map<String, Object> getDashboard(String userId, String locale);
}
