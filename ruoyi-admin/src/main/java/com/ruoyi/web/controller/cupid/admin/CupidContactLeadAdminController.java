package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.cupid.service.ICupidAdminContactLeadService;

/**
 * Cupid Match admin contact lead controller.
 */
@RestController
@RequestMapping("/cupid/contact-lead")
public class CupidContactLeadAdminController extends BaseController
{
    @Autowired
    private ICupidAdminContactLeadService adminContactLeadService;

    @PreAuthorize("@ss.hasPermi('cupid:contactLead:list')")
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(adminContactLeadService.selectAdminContactLeads(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:contactLead:query')")
    @GetMapping("/{id}")
    public AjaxResult detail(@PathVariable String id)
    {
        return success(adminContactLeadService.selectAdminContactLeadById(id));
    }

    @Log(title = "Cupid contact lead", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:contactLead:handle')")
    @PostMapping("/{id}/handle")
    public AjaxResult handle(@PathVariable String id, @RequestBody Map<String, Object> body)
    {
        adminContactLeadService.handleAdminContactLead(id, body, String.valueOf(getUserId()));
        return success();
    }
}
