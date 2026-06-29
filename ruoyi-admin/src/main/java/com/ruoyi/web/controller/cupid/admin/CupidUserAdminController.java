package com.ruoyi.web.controller.cupid.admin;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.cupid.service.ICupidAdminUserService;

@RestController
@RequestMapping("/cupid/user")
public class CupidUserAdminController extends BaseController
{
    @Autowired
    private ICupidAdminUserService adminUserService;

    @PreAuthorize("@ss.hasPermi('cupid:user:list')")
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam Map<String, Object> params)
    {
        startPage();
        return getDataTable(adminUserService.selectAdminUsers(params));
    }

    @PreAuthorize("@ss.hasPermi('cupid:user:query')")
    @GetMapping("/{id}")
    public AjaxResult detail(@PathVariable String id)
    {
        return success(adminUserService.selectAdminUserDetail(id));
    }

    @PreAuthorize("@ss.hasPermi('cupid:user:session:list')")
    @GetMapping("/{id}/sessions")
    public AjaxResult sessions(@PathVariable String id)
    {
        return success(adminUserService.selectUserSessions(id));
    }

    @Log(title = "Cupid 用户状态变更", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('cupid:user:status')")
    @PostMapping("/{id}/status")
    public AjaxResult status(@PathVariable String id, @RequestBody Map<String, String> body)
    {
        adminUserService.updateUserStatus(id, body.get("status"), body.get("reason"), String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid 用户单会话强退", businessType = BusinessType.FORCE)
    @PreAuthorize("@ss.hasPermi('cupid:user:session:kick')")
    @DeleteMapping("/{id}/sessions/{sessionId}")
    public AjaxResult deleteSession(@PathVariable String id, @PathVariable String sessionId,
            @RequestBody(required = false) Map<String, String> body)
    {
        adminUserService.deleteUserSession(id, sessionId, body == null ? null : body.get("reason"),
                String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid 用户全部会话强退", businessType = BusinessType.FORCE)
    @PreAuthorize("@ss.hasPermi('cupid:user:session:kick')")
    @DeleteMapping("/{id}/sessions")
    public AjaxResult deleteAllSessions(@PathVariable String id, @RequestBody(required = false) Map<String, String> body)
    {
        adminUserService.deleteAllUserSessions(id, body == null ? null : body.get("reason"),
                String.valueOf(getUserId()));
        return success();
    }

    @Log(title = "Cupid 查看用户敏感信息", businessType = BusinessType.OTHER)
    @PreAuthorize("@ss.hasPermi('cupid:user:sensitive')")
    @PostMapping("/{id}/sensitive/view")
    public AjaxResult sensitive(@PathVariable String id, @RequestBody Map<String, String> body)
    {
        return success(adminUserService.viewSensitive(id, body.get("reason"), String.valueOf(getUserId())));
    }
}
