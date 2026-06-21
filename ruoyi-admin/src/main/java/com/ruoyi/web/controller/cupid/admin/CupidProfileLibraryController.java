package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.cupid.service.ICupidProfileLibraryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Cupid Match 后台资料库只读接口
 */
@RestController
@RequestMapping("/cupid/profile-library")
public class CupidProfileLibraryController extends BaseController
{
    @Autowired
    private ICupidProfileLibraryService profileLibraryService;

    @PreAuthorize("@ss.hasPermi('cupid:profileLibrary:list')")
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(profileLibraryService.selectProfileList(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:profileLibrary:query')")
    @GetMapping("/{id}")
    public AjaxResult detail(@PathVariable String id)
    {
        return AjaxResult.success(profileLibraryService.selectProfileDetail(id));
    }
}
