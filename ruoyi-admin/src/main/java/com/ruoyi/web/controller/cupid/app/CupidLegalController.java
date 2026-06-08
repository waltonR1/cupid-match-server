package com.ruoyi.web.controller.cupid.app;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.cupid.service.ICupidLegalService;

/**
 * Cupid Match 法务文档接口
 */
@RestController
@RequestMapping("/api/legal")
public class CupidLegalController
{
    @Autowired
    private ICupidLegalService legalService;

    /**
     * 查询指定类型的有效法务文档
     */
    @GetMapping("/documents/{type}")
    public AjaxResult document(@PathVariable String type,
            @RequestParam(value = "lang", required = false, defaultValue = "zh") String lang)
    {
        return AjaxResult.success(legalService.getDocument(type, lang));
    }
}
