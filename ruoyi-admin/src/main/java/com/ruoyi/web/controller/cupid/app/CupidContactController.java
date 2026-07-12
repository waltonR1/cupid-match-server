package com.ruoyi.web.controller.cupid.app;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.cupid.service.ICupidContactLeadService;

/**
 * Cupid Match app contact controller.
 */
@RestController
@RequestMapping("/api/contact")
public class CupidContactController
{
    @Autowired
    private ICupidContactLeadService contactLeadService;

    @PostMapping("/leads")
    public AjaxResult create(@RequestBody Map<String, Object> body)
    {
        return AjaxResult.success(contactLeadService.createContactLead(body));
    }
}
