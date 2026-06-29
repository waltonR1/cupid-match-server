package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.cupid.service.ICupidAdminInboxService;

/** Cupid Match 后台通知发布接口，不提供 C 端历史消息查询。 */
@RestController
@RequestMapping("/cupid/inbox")
public class CupidInboxAdminController extends BaseController
{
    @Autowired
    private ICupidAdminInboxService inboxService;

    @PreAuthorize("@ss.hasAnyPermi('cupid:inbox:preview,cupid:inbox:send')")
    @GetMapping("/users")
    public AjaxResult users(@RequestParam(required = false) String keyword)
    {
        return success(inboxService.searchUsers(keyword));
    }

    @PreAuthorize("@ss.hasAnyPermi('cupid:inbox:preview,cupid:inbox:send')")
    @GetMapping("/subjects")
    public AjaxResult subjects(@RequestParam String userId, @RequestParam String subjectType,
            @RequestParam(required = false) String keyword)
    {
        return success(inboxService.searchSubjects(userId, subjectType, keyword));
    }

    @PreAuthorize("@ss.hasPermi('cupid:inbox:preview')")
    @GetMapping("/templates")
    public AjaxResult templates()
    {
        return success(inboxService.enabledTemplates());
    }

    @PreAuthorize("@ss.hasPermi('cupid:inbox:preview')")
    @PostMapping("/preview")
    public AjaxResult preview(@RequestBody Map<String, Object> body)
    {
        return success(inboxService.preview(body));
    }

    @Log(title = "Cupid单用户通知", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('cupid:inbox:send')")
    @PostMapping("/notify")
    public AjaxResult notify(@RequestBody Map<String, Object> body)
    {
        inboxService.send(body, String.valueOf(getUserId()));
        return success();
    }

    @PreAuthorize("@ss.hasPermi('cupid:inbox:broadcast')")
    @PostMapping("/broadcast/preview")
    public AjaxResult broadcastPreview(@RequestBody Map<String, Object> body)
    {
        return success(inboxService.previewBroadcast(body));
    }

    @Log(title = "Cupid群发通知", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('cupid:inbox:broadcast')")
    @PostMapping("/broadcast")
    public AjaxResult broadcast(@RequestBody Map<String, Object> body)
    {
        return success(inboxService.broadcast(body, String.valueOf(getUserId())));
    }
}
