package com.ruoyi.web.controller.cupid.app;

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.web.controller.cupid.support.CupidPublicImageStorage;

/**
 * Cupid Match 上传接口
 */
@RestController
@RequestMapping("/api")
public class CupidUploadController
{
    private final CupidPublicImageStorage storage;

    public CupidUploadController(CupidPublicImageStorage storage)
    {
        this.storage = storage;
    }

    /**
     * 上传图片
     */
    @PostMapping("/upload")
    public AjaxResult upload(@RequestParam("file") MultipartFile file)
    {
        if (file.isEmpty())
        {
            return AjaxResult.error(400, "empty_file");
        }
        try
        {
            String path = storage.upload(file);
            Map<String, Object> result = new LinkedHashMap<>();
            result.put("url", path);
            return AjaxResult.success(result);
        }
        catch (IllegalArgumentException e)
        {
            return AjaxResult.error(400, e.getMessage());
        }
        catch (Exception e)
        {
            return AjaxResult.error(400, e.getMessage());
        }
    }
}
