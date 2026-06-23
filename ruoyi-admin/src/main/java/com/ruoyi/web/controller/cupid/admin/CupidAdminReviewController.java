package com.ruoyi.web.controller.cupid.admin;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.Map;
import jakarta.servlet.http.HttpServletResponse;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.cupid.service.ICupidAdminReviewService;
import com.ruoyi.web.controller.cupid.support.CupidVerificationMaterialStorage;
import com.ruoyi.web.controller.cupid.support.CupidVerificationMaterialStorage.MaterialFile;
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

    @Autowired
    private CupidVerificationMaterialStorage materialStorage;

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

    @PreAuthorize("@ss.hasPermi('cupid:verification:material:preview')")
    @GetMapping("/verification/{materialId}/material/preview")
    public void previewVerificationMaterial(@PathVariable String materialId, HttpServletResponse response)
            throws IOException
    {
        writeVerificationMaterial(materialId, response, false);
    }

    @PreAuthorize("@ss.hasPermi('cupid:verification:material:download')")
    @GetMapping("/verification/{materialId}/material/download")
    public void downloadVerificationMaterial(@PathVariable String materialId, HttpServletResponse response)
            throws IOException
    {
        writeVerificationMaterial(materialId, response, true);
    }

    @Log(title = "Cupid认证审核", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:verification:review')")
    @PostMapping("/verification/{materialId}/review")
    public AjaxResult reviewVerification(@PathVariable String materialId, @RequestBody Map<String, String> body)
    {
        reviewService.reviewVerification(materialId, body.get("status"), body.get("reason"), String.valueOf(getUserId()));
        return success();
    }

    private void writeVerificationMaterial(String materialId, HttpServletResponse response, boolean attachment)
            throws IOException
    {
        Map<String, Object> detail = reviewService.selectVerificationDetail(materialId);
        if (detail == null || detail.get("materialUrl") == null)
        {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        try
        {
            MaterialFile file = materialStorage.resolve(String.valueOf(detail.get("materialUrl")));
            response.setContentType(file.contentType());
            response.setHeader("Content-Disposition",
                    (attachment ? "attachment" : "inline") + "; filename*=UTF-8''" + encodeFilename(file.filename()));
            response.setHeader("Cache-Control", "no-store");
            Files.copy(file.path(), response.getOutputStream());
        }
        catch (IllegalArgumentException e)
        {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private String encodeFilename(String filename)
    {
        return URLEncoder.encode(filename, StandardCharsets.UTF_8).replace("+", "%20");
    }
}
