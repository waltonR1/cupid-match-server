package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.cupid.service.ICupidAdminReviewService;
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
 * Cupid Match 后台审核接口
 */
@RestController
@RequestMapping("/cupid")
public class CupidAdminReviewController extends BaseController
{
    @Autowired
    private ICupidAdminReviewService reviewService;

    @PreAuthorize("@ss.hasPermi('cupid:profile:list')")
    @GetMapping("/profile/list")
    public TableDataInfo profileList(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(reviewService.selectProfileList(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:profile:query')")
    @GetMapping("/profile/{id}")
    public AjaxResult profileDetail(@PathVariable String id)
    {
        return AjaxResult.success(reviewService.selectProfileDetail(id));
    }

    @Log(title = "Cupid资料审核", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:profile:review')")
    @PostMapping("/profile/{id}/review")
    public AjaxResult reviewProfile(@PathVariable String id, @RequestBody Map<String, String> body)
    {
        reviewService.reviewProfile(id, body.get("status"), body.get("reason"), String.valueOf(getUserId()));
        return success();
    }

    @PreAuthorize("@ss.hasPermi('cupid:photo:list')")
    @GetMapping("/photo/list")
    public TableDataInfo photoList(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(reviewService.selectPhotoList(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:photo:query')")
    @GetMapping("/photo/{id}")
    public AjaxResult photoDetail(@PathVariable String id)
    {
        return AjaxResult.success(reviewService.selectPhotoDetail(id));
    }

    @Log(title = "Cupid照片审核", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:photo:review')")
    @PostMapping("/photo/{id}/review")
    public AjaxResult reviewPhoto(@PathVariable String id, @RequestBody Map<String, String> body)
    {
        reviewService.reviewPhoto(id, body.get("status"), body.get("reason"), String.valueOf(getUserId()));
        return success();
    }

    @PreAuthorize("@ss.hasPermi('cupid:verification:list')")
    @GetMapping("/verification/list")
    public TableDataInfo verificationList(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(reviewService.selectVerificationList(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:verification:query')")
    @GetMapping("/verification/{materialId}")
    public AjaxResult verificationDetail(@PathVariable String materialId)
    {
        return AjaxResult.success(reviewService.selectVerificationDetail(materialId));
    }

    @Log(title = "Cupid认证审核", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:verification:review')")
    @PostMapping("/verification/{materialId}/review")
    public AjaxResult reviewVerification(@PathVariable String materialId, @RequestBody Map<String, String> body)
    {
        reviewService.reviewVerification(materialId, body.get("status"), body.get("reason"), String.valueOf(getUserId()));
        return success();
    }
}
