package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
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

    @PreAuthorize("@ss.hasPermi('cupid:payment:list')")
    @GetMapping("/orders/{id}")
    public AjaxResult orderDetail(@PathVariable String id)
    {
        return success(adminPaymentService.selectAdminOrderDetail(id));
    }

    @PreAuthorize("@ss.hasPermi('cupid:payment:subscription:cancel')")
    @PostMapping("/orders/{id}/cancel-renewal")
    public AjaxResult cancelOrderRenewal(@PathVariable String id)
    {
        return success(adminPaymentService.cancelAdminOrderRenewal(id));
    }

    @PreAuthorize("@ss.hasPermi('cupid:payment:refund')")
    @PostMapping("/orders/{id}/refund")
    public AjaxResult refundOrder(@PathVariable String id)
    {
        return success(adminPaymentService.refundAdminOrder(id));
    }

    @PreAuthorize("@ss.hasPermi('cupid:payment:webhook:list')")
    @GetMapping("/webhooks/list")
    public TableDataInfo webhooks(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(adminPaymentService.selectAdminWebhookEvents(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:payment:webhook:list')")
    @GetMapping("/webhooks/{id}")
    public AjaxResult webhookDetail(@PathVariable String id)
    {
        return success(adminPaymentService.selectAdminWebhookEventDetail(id));
    }
}
