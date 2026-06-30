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
import com.ruoyi.cupid.service.ICupidAdminStaffTaskService;

@RestController
@RequestMapping("/cupid/staff-task")
public class CupidStaffTaskAdminController extends BaseController
{
    @Autowired
    private ICupidAdminStaffTaskService adminStaffTaskService;

    @PreAuthorize("@ss.hasPermi('cupid:staffTask:list')")
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(adminStaffTaskService.selectAdminStaffTasks(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:staffTask:query')")
    @GetMapping("/{id}")
    public AjaxResult detail(@PathVariable String id)
    {
        return success(adminStaffTaskService.selectAdminStaffTaskById(id));
    }

    @PreAuthorize("@ss.hasPermi('cupid:staffTask:query')")
    @GetMapping("/assignees")
    public AjaxResult assignees()
    {
        return success(adminStaffTaskService.selectAvailableAssignees());
    }

    @Log(title = "Cupid 跟进事项", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('cupid:staffTask:add')")
    @PostMapping
    public AjaxResult create(@RequestBody Map<String, Object> body)
    {
        adminStaffTaskService.createAdminStaffTask(body, String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid 跟进事项", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:staffTask:edit')")
    @PostMapping("/{id}/edit")
    public AjaxResult edit(@PathVariable String id, @RequestBody Map<String, Object> body)
    {
        adminStaffTaskService.updateAdminStaffTask(id, body, String.valueOf(getUserId()));
        return success();
    }
}
