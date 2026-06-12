package com.ruoyi.web.controller.cupid.app;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.cupid.service.ICupidEventService;

/**
 * Cupid Match 活动接口
 */
@RestController
@RequestMapping("/api")
public class CupidEventController
{
    @Autowired
    private ICupidEventService eventService;

    /**
     * 活动目录（公开）
     */
    @GetMapping("/events")
    public AjaxResult directory(@RequestParam Map<String, String> params,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        String userId = principal != null ? principal.getUserId() : null;
        return AjaxResult.success(eventService.getEvents(params, userId));
    }

    /**
     * 活动详情（公开）
     */
    @GetMapping("/events/{id}")
    public AjaxResult detail(@PathVariable String id,
            @AuthenticationPrincipal CupidLoginUser principal,
            @RequestParam(value = "lang", defaultValue = "zh") String locale)
    {
        String userId = principal != null ? principal.getUserId() : null;
        Map<String, Object> detail = eventService.getEventDetail(id, userId, locale);
        if (detail == null)
        {
            return AjaxResult.error(404, "event_not_found");
        }
        return AjaxResult.success(detail);
    }

    /**
     * 报名活动
     */
    @PostMapping("/events/{id}/register")
    public AjaxResult register(@PathVariable String id,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(eventService.register(principal.getUserId(), id));
    }

    /**
     * 取消报名
     */
    @PostMapping("/events/{id}/cancel")
    public AjaxResult cancel(@PathVariable String id,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(eventService.cancel(principal.getUserId(), id));
    }

    /**
     * 当前用户的报名记录
     */
    @GetMapping("/account/events")
    public AjaxResult myEvents(@AuthenticationPrincipal CupidLoginUser principal,
            @RequestParam(value = "lang", defaultValue = "zh") String locale)
    {
        return AjaxResult.success(eventService.getMyEvents(principal.getUserId(), locale));
    }
}
