package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.cupid.service.ICupidSecurityEventService;

@RestController
@RequestMapping("/cupid/security-event")
public class CupidSecurityEventAdminController extends BaseController
{
    @Autowired
    private ICupidSecurityEventService securityEventService;

    @PreAuthorize("@ss.hasPermi('cupid:security:event:list')")
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(securityEventService.selectAdminSecurityEvents(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:security:event:query')")
    @GetMapping("/{id}")
    public AjaxResult detail(@PathVariable String id)
    {
        return success(securityEventService.selectAdminSecurityEventById(id));
    }
}
