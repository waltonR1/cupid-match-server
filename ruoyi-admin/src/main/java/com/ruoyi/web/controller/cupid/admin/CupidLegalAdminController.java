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
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.cupid.service.ICupidLegalService;

/**
 * Cupid Match legal document admin controller.
 */
@RestController
@RequestMapping("/cupid/legal")
public class CupidLegalAdminController extends BaseController
{
    @Autowired
    private ICupidLegalService legalService;

    @PreAuthorize("@ss.hasPermi('cupid:legal:list')")
    @GetMapping("/list")
    public AjaxResult list(@RequestParam Map<String, Object> params)
    {
        return success(legalService.selectAdminDocuments(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:legal:query')")
    @GetMapping("/{id}")
    public AjaxResult detail(@PathVariable String id)
    {
        return success(legalService.selectAdminDocumentById(id));
    }

    @Log(title = "Cupid legal document", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:legal:edit')")
    @PostMapping("/{id}")
    public AjaxResult update(@PathVariable String id, @RequestBody Map<String, Object> body)
    {
        legalService.updateAdminDocument(id, body);
        return success();
    }

    @Log(title = "Cupid legal document", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('cupid:legal:edit')")
    @PostMapping("/{type}/draft")
    public AjaxResult createDraft(@PathVariable String type)
    {
        return success(legalService.createAdminDraft(type));
    }

    @Log(title = "Cupid legal document", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:legal:edit')")
    @PostMapping("/{id}/publish")
    public AjaxResult publish(@PathVariable String id, @RequestBody(required = false) Map<String, Object> body)
    {
        legalService.publishAdminDraft(id, body);
        return success();
    }
}
