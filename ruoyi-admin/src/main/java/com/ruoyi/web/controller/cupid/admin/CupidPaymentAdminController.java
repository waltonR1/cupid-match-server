package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.cupid.service.ICupidAdminPaymentService;

@RestController
@RequestMapping("/cupid/payment")
public class CupidPaymentAdminController extends BaseController
{
    @Autowired
    private ICupidAdminPaymentService adminPaymentService;

    @PreAuthorize("@ss.hasPermi('cupid:payment:list')")
    @GetMapping("/orders/list")
    public TableDataInfo orders(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(adminPaymentService.selectAdminOrders(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:payment:webhook:list')")
    @GetMapping("/webhooks/list")
    public TableDataInfo webhooks(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(adminPaymentService.selectAdminWebhookEvents(params));
    }
}
