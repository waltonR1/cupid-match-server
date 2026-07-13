package com.ruoyi.web.controller.cupid.admin;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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
import com.ruoyi.web.controller.cupid.support.CupidVerificationMaterialStorage.StoredMaterial;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

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

    @Log(title = "Cupid认证材料补录", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('cupid:verification:material:create')")
    @PostMapping("/verification/material/create")
    public AjaxResult createVerificationMaterial(@RequestParam Map<String, Object> payload,
            @RequestParam("file") MultipartFile file)
    {
        try
        {
            StoredMaterial material = materialStorage.upload(String.valueOf(payload.get("profileId")), file);
            if (payload.get("materialName") == null || String.valueOf(payload.get("materialName")).trim().isEmpty())
            {
                payload.put("materialName", material.originalFilename());
            }
            reviewService.createVerificationMaterial(payload, material.materialUrl(),
                    material.scanStatus(), material.scanMessage(), String.valueOf(getUserId()));
            return success();
        }
        catch (IllegalArgumentException e)
        {
            return AjaxResult.error(400, e.getMessage());
        }
        catch (Exception e)
        {
            return AjaxResult.error(400, "upload_failed");
        }
    }

    @Log(title = "Cupid认证重置", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:verification:reset')")
    @PostMapping("/verification/reset")
    public AjaxResult resetVerification(@RequestBody Map<String, String> body)
    {
        reviewService.resetVerification(body.get("profileId"), body.get("materialType"),
                body.get("reason"), String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid认证审核", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:verification:review')")
    @PostMapping("/verification/{materialId}/review")
    public AjaxResult reviewVerification(@PathVariable String materialId, @RequestBody Map<String, String> body)
    {
        reviewService.reviewVerification(materialId, body.get("status"), body.get("reason"), String.valueOf(getUserId()));
        return success();
    }

    @PreAuthorize("@ss.hasPermi('cupid:introduction:list')")
    @GetMapping("/introduction/list")
    public TableDataInfo introductionList(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(reviewService.selectIntroductionList(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:introduction:query')")
    @GetMapping("/introduction/{requestId}")
    public AjaxResult introductionDetail(@PathVariable String requestId)
    {
        return AjaxResult.success(reviewService.selectIntroductionDetail(requestId));
    }

    @Log(title = "Cupid私人介绍受理", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:introduction:accept')")
    @PostMapping("/introduction/{requestId}/accept")
    public AjaxResult acceptIntroduction(@PathVariable String requestId, @RequestBody Map<String, String> body)
    {
        reviewService.acceptIntroduction(requestId, body.get("reason"), String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid私人介绍暂不受理", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:introduction:decline')")
    @PostMapping("/introduction/{requestId}/decline")
    public AjaxResult declineIntroduction(@PathVariable String requestId, @RequestBody Map<String, String> body)
    {
        reviewService.declineIntroduction(requestId, body.get("reason"), String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid私人介绍备注", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('cupid:introduction:note')")
    @PostMapping("/introduction/{requestId}/note")
    public AjaxResult noteIntroduction(@PathVariable String requestId, @RequestBody Map<String, String> body)
    {
        reviewService.noteIntroduction(requestId, body.get("note"), String.valueOf(getUserId()));
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
            try (MaterialFile file = materialStorage.resolve(String.valueOf(detail.get("materialUrl"))))
            {
                response.setContentType(file.contentType());
                if (file.contentLength() >= 0)
                {
                    response.setContentLengthLong(file.contentLength());
                }
                response.setHeader("Content-Disposition",
                        (attachment ? "attachment" : "inline") + "; filename*=UTF-8''" + encodeFilename(file.filename()));
                response.setHeader("Cache-Control", "no-store");
                file.inputStream().transferTo(response.getOutputStream());
            }
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
