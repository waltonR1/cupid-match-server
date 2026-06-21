package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.cupid.service.ICupidProfileManageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Cupid Match 后台资料运营管理接口
 */
@RestController
@RequestMapping("/cupid/profile-manage")
public class CupidProfileManageController extends BaseController
{
    @Autowired
    private ICupidProfileManageService profileManageService;

    @PreAuthorize("@ss.hasPermi('cupid:profileManage:list')")
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(profileManageService.selectProfileList(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:profileManage:query')")
    @GetMapping("/{id}")
    public AjaxResult detail(@PathVariable String id)
    {
        return AjaxResult.success(profileManageService.selectProfileDetail(id));
    }

    @PreAuthorize("@ss.hasPermi('cupid:profileManage:notes')")
    @GetMapping("/{id}/notes")
    public AjaxResult notes(@PathVariable String id)
    {
        return AjaxResult.success(profileManageService.selectProfileNotes(id));
    }

    @Log(title = "Cupid资料运营字段", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:profileManage:edit')")
    @PostMapping("/{id}/internal")
    public AjaxResult updateInternal(@PathVariable String id, @RequestBody Map<String, Object> body)
    {
        profileManageService.updateInternalFields(id, body, String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid资料内部备注", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:profileManage:editNotes')")
    @PostMapping("/{id}/notes")
    public AjaxResult updateNotes(@PathVariable String id, @RequestBody Map<String, Object> body)
    {
        profileManageService.updateNotes(id, body, String.valueOf(getUserId()));
        return success();
    }
}
