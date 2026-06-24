package com.ruoyi.web.controller.cupid.app;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Anonymous;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.cupid.service.ICupidProfileOptionService;

/**
 * Cupid Match 前台通用可选项接口
 */
@RestController
@RequestMapping("/api/common")
public class CupidCommonOptionsController
{
    @Autowired
    private ICupidProfileOptionService profileOptionService;

    /**
     * 查询通用可选项。
     */
    @Anonymous
    @GetMapping("/options")
    public AjaxResult options(@RequestParam Map<String, String> params)
    {
        String scope = params.getOrDefault("scope", "profile");
        if (!"profile".equals(scope))
        {
            return AjaxResult.error(400, "unsupported_options_scope");
        }

        return AjaxResult.success(profileOptionService.getProfileOptions(
                resolveLocale(params), params.get("version")));
    }

    private String resolveLocale(Map<String, String> params)
    {
        String lang = params.get("lang");
        if (lang != null && !lang.isBlank())
        {
            return lang;
        }
        return params.getOrDefault("locale", "zh");
    }
}
