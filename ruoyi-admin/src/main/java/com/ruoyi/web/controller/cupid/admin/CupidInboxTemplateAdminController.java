package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
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
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.cupid.service.ICupidInboxTemplateService;

/** Cupid Match 后台通知模板接口。 */
@RestController
@RequestMapping("/cupid/inboxTemplate")
public class CupidInboxTemplateAdminController extends BaseController
{
    @Autowired
    private ICupidInboxTemplateService templateService;

    @PreAuthorize("@ss.hasPermi('cupid:inboxTemplate:list')")
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(templateService.selectTemplates(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:inboxTemplate:query')")
    @GetMapping("/{id}")
    public AjaxResult detail(@PathVariable String id)
    {
        return success(templateService.selectTemplate(id));
    }

    @Log(title = "Cupid通知模板新增", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('cupid:inboxTemplate:add')")
    @PostMapping
    public AjaxResult add(@RequestBody Map<String, Object> body)
    {
        templateService.createTemplate(body, String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid通知模板编辑", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:inboxTemplate:edit')")
    @PutMapping("/{id}")
    public AjaxResult edit(@PathVariable String id, @RequestBody Map<String, Object> body)
    {
        templateService.updateTemplate(id, body, String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid通知模板启停", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:inboxTemplate:changeStatus')")
    @PostMapping("/{id}/status")
    public AjaxResult status(@PathVariable String id, @RequestBody Map<String, String> body)
    {
        templateService.updateStatus(id, body.get("status"), String.valueOf(getUserId()));
        return success();
    }
}
