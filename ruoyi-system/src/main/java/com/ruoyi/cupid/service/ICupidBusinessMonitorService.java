package com.ruoyi.cupid.service;

import java.util.Map;

/**
 * Cupid 业务专项监控服务
 */
public interface ICupidBusinessMonitorService
{
    /**
     * 获取只读业务运行快照
     *
     * @return 业务运行快照
     */
    Map<String, Object> getOverview();
}
