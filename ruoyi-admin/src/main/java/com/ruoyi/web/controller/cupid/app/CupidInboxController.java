package com.ruoyi.web.controller.cupid.app;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.model.CupidLoginUser;
import com.ruoyi.cupid.service.ICupidInboxService;

/**
 * Cupid Match 收件箱接口。
 */
@RestController
@RequestMapping("/api/inbox")
public class CupidInboxController
{
    @Autowired
    private ICupidInboxService inboxService;

    /**
     * 查询当前账户的消息线程。
     */
    @GetMapping("/threads")
    public AjaxResult threads(@AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(inboxService.getThreads(principal.getUserId()));
    }

    /**
     * 使用 before 游标查询线程消息。
     */
    @GetMapping("/threads/{id}/messages")
    public AjaxResult messages(@PathVariable String id,
            @AuthenticationPrincipal CupidLoginUser principal,
            @RequestParam(value = "before", required = false) String before,
            @RequestParam(value = "limit", defaultValue = "20") int limit)
    {
        return AjaxResult.success(inboxService.getMessages(
                principal.getUserId(), id, before, limit));
    }

    /**
     * 标记线程为已读。
     */
    @PostMapping("/threads/{id}/read")
    public AjaxResult markRead(@PathVariable String id,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(inboxService.markRead(principal.getUserId(), id));
    }

    /**
     * 向开放的聊天线程发送受控文本消息。
     */
    @PostMapping("/threads/{id}/messages")
    public AjaxResult sendMessage(@PathVariable String id,
            @RequestBody Map<String, Object> body,
            @AuthenticationPrincipal CupidLoginUser principal)
    {
        return AjaxResult.success(inboxService.sendMessage(
                principal.getUserId(), id, (String) body.get("body")));
    }
}
