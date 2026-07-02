package com.ruoyi.web.controller.cupid.admin;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.cupid.service.ICupidBusinessMonitorService;

/**
 * Cupid 业务专项监控
 */
@RestController
@RequestMapping("/cupid/monitor")
public class CupidBusinessMonitorAdminController extends BaseController
{
    @Autowired
    private ICupidBusinessMonitorService businessMonitorService;

    /**
     * 获取只读业务运行快照
     */
    @PreAuthorize("@ss.hasPermi('cupid:monitor:list')")
    @GetMapping("/overview")
    public AjaxResult overview()
    {
        return success(businessMonitorService.getOverview());
    }
}
