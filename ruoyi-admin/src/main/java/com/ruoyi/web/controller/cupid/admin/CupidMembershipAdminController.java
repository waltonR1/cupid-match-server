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
import com.ruoyi.cupid.service.ICupidAdminMembershipService;

@RestController
@RequestMapping("/cupid/membership")
public class CupidMembershipAdminController extends BaseController
{
    @Autowired
    private ICupidAdminMembershipService adminMembershipService;

    @PreAuthorize("@ss.hasPermi('cupid:membership:list')")
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(adminMembershipService.selectAdminMemberships(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:membership:query')")
    @GetMapping("/{id}")
    public AjaxResult detail(@PathVariable String id)
    {
        return success(adminMembershipService.selectAdminMembershipDetail(id));
    }

    @Log(title = "Cupid 会员状态变更", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:membership:status')")
    @PostMapping("/{id}/status")
    public AjaxResult updateStatus(@PathVariable String id, @RequestBody Map<String, String> body)
    {
        adminMembershipService.updateMembershipStatus(id, body.get("status"), body.get("reason"),
                String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid 会员资料编辑", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:membership:edit')")
    @PostMapping("/{id}/edit")
    public AjaxResult updateFields(@PathVariable String id, @RequestBody Map<String, String> body)
    {
        adminMembershipService.updateMembershipFields(id, body.get("tier"), body.get("startedAt"),
                body.get("expiresAt"), body.get("reason"), String.valueOf(getUserId()));
        return success();
    }
}
