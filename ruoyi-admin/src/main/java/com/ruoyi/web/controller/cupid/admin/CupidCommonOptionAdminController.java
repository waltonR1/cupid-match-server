package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.cupid.service.ICupidCommonOptionService;
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
 * Cupid Match 后台通用选项管理接口。
 */
@RestController
@RequestMapping("/cupid/options")
public class CupidCommonOptionAdminController extends BaseController
{
    @Autowired
    private ICupidCommonOptionService commonOptionService;

    @PreAuthorize("@ss.hasPermi('cupid:options:list')")
    @GetMapping("/groups")
    public AjaxResult groups()
    {
        return AjaxResult.success(commonOptionService.selectAdminOptionGroups());
    }

    @PreAuthorize("@ss.hasPermi('cupid:options:list')")
    @GetMapping("/values")
    public AjaxResult values(@RequestParam(required = false) String groupKey)
    {
        return AjaxResult.success(commonOptionService.selectAdminOptionValues(groupKey));
    }

    @PreAuthorize("@ss.hasPermi('cupid:options:query')")
    @GetMapping("/values/{id}")
    public AjaxResult detail(@PathVariable String id)
    {
        return AjaxResult.success(commonOptionService.selectAdminOptionValue(id));
    }

    @Log(title = "Cupid通用选项", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('cupid:options:edit')")
    @PostMapping("/values")
    public AjaxResult create(@RequestBody Map<String, Object> body)
    {
        return AjaxResult.success(commonOptionService.createAdminOptionValue(body, String.valueOf(getUserId())));
    }

    @Log(title = "Cupid通用选项", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:options:edit')")
    @PostMapping("/values/{id}")
    public AjaxResult update(@PathVariable String id, @RequestBody Map<String, Object> body)
    {
        commonOptionService.updateAdminOptionValue(id, body, String.valueOf(getUserId()));
        return success();
    }
}
