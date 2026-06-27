package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.cupid.service.ICupidAdminEventService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Cupid Match 后台活动与报名管理接口。
 */
@RestController
@RequestMapping("/cupid")
public class CupidEventAdminController extends BaseController
{
    @Autowired
    private ICupidAdminEventService adminEventService;

    // -- Event --

    @PreAuthorize("@ss.hasPermi('cupid:event:list')")
    @GetMapping("/event/list")
    public TableDataInfo eventList(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(adminEventService.selectAdminEvents(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:event:query')")
    @GetMapping("/event/{id}")
    public AjaxResult eventDetail(@PathVariable String id)
    {
        return AjaxResult.success(adminEventService.selectAdminEventDetail(id));
    }

    @Log(title = "Cupid活动新建", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('cupid:event:add')")
    @PostMapping("/event")
    public AjaxResult addEvent(@RequestBody Map<String, Object> body)
    {
        adminEventService.createEvent(body, String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid活动编辑", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:event:edit')")
    @PutMapping("/event/{id}")
    public AjaxResult editEvent(@PathVariable String id, @RequestBody Map<String, Object> body)
    {
        adminEventService.updateEvent(id, body, String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid活动状态变更", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:event:changeStatus')")
    @PostMapping("/event/{id}/status")
    public AjaxResult changeEventStatus(@PathVariable String id, @RequestBody Map<String, String> body)
    {
        adminEventService.updateEventStatus(id,
                body.get("status"), body.get("reason"), String.valueOf(getUserId()));
        return success();
    }

    // -- Registration --

    @PreAuthorize("@ss.hasPermi('cupid:eventRegistration:list')")
    @GetMapping("/eventRegistration/list")
    public TableDataInfo registrationList(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(adminEventService.selectAdminRegistrations(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:eventRegistration:query')")
    @GetMapping("/eventRegistration/{id}")
    public AjaxResult registrationDetail(@PathVariable String id)
    {
        return AjaxResult.success(adminEventService.selectAdminRegistrationDetail(id));
    }

    @Log(title = "Cupid报名处理", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:eventRegistration:review')")
    @PostMapping("/eventRegistration/{id}/review")
    public AjaxResult reviewRegistration(@PathVariable String id, @RequestBody Map<String, String> body)
    {
        adminEventService.reviewRegistration(id,
                body.get("status"), body.get("reason"), String.valueOf(getUserId()));
        return success();
    }
}
