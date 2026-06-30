package com.ruoyi.cupid.service.impl;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.mapper.CupidAdminStaffTaskMapper;
import com.ruoyi.cupid.mapper.CupidCommonOptionMapper;
import com.ruoyi.cupid.service.ICupidAdminStaffTaskService;
import com.ruoyi.system.mapper.SysUserMapper;

@Service
public class CupidAdminStaffTaskServiceImpl implements ICupidAdminStaffTaskService
{
    private static final String MANAGE_PERMISSION = "cupid:staffTask:add";
    private static final Set<String> ALLOWED_SUBJECT_TYPES = Set.of(
            "user", "profile", "private_introduction_request", "event");
    private static final Set<String> ALLOWED_STATUSES = Set.of("open", "done", "snoozed");
    private static final Set<String> ALLOWED_PRIORITIES = Set.of("low", "normal", "high");

    @Autowired
    private CupidAdminStaffTaskMapper adminStaffTaskMapper;

    @Autowired
    private CupidCommonOptionMapper commonOptionMapper;

    @Autowired
    private SysUserMapper sysUserMapper;

    @Override
    public List<Map<String, Object>> selectAdminStaffTasks(Map<String, Object> params)
    {
        Map<String, Object> query = new HashMap<>();
        query.put("keyword", trim(params.get("keyword")));
        query.put("subjectType", trim(params.get("subjectType")));
        query.put("status", trim(params.get("status")));
        query.put("priority", trim(params.get("priority")));
        if (isManagerOperator())
        {
            query.put("assigneeSysUserId", trim(params.get("assigneeSysUserId")));
        }
        else
        {
            query.put("assigneeSysUserId", String.valueOf(SecurityUtils.getUserId()));
        }
        return adminStaffTaskMapper.selectAdminStaffTasks(query);
    }

    @Override
    public Map<String, Object> selectAdminStaffTaskById(String id)
    {
        Map<String, Object> detail = adminStaffTaskMapper.selectAdminStaffTaskById(id);
        if (detail == null)
        {
            throw new ServiceException("跟进事项不存在");
        }
        if (!isManagerOperator() && !isOwnedByCurrentUser(detail))
        {
            throw new ServiceException("无权查看他人负责的跟进事项");
        }
        return detail;
    }

    @Override
    public List<Map<String, Object>> selectAvailableAssignees()
    {
        if (!isManagerOperator())
        {
            LoginUser loginUser = SecurityUtils.getLoginUser();
            Map<String, Object> self = new LinkedHashMap<>();
            self.put("userId", loginUser.getUserId());
            self.put("userName", loginUser.getUsername());
            self.put("nickName", loginUser.getUser().getNickName());
            return List.of(self);
        }
        return adminStaffTaskMapper.selectAvailableAssignees();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createAdminStaffTask(Map<String, Object> body, String operatorUserId)
    {
        if (!isManagerOperator())
        {
            throw new ServiceException("无权创建跟进事项");
        }
        String id = IdUtils.fastUUID();
        Long assigneeSysUserId = parseAssignee(body.get("assigneeSysUserId"));
        String subjectType = requireAllowed(body.get("subjectType"), "业务对象类型", ALLOWED_SUBJECT_TYPES);
        String subjectId = requireText(body.get("subjectId"), "业务对象ID");
        String status = requireAllowedWithDefault(body.get("status"), "open", "状态", ALLOWED_STATUSES);
        String priority = requireAllowedWithDefault(body.get("priority"), "normal", "优先级", ALLOWED_PRIORITIES);
        Date dueAt = parseOptionalDateTime(body.get("dueAt"), "截止时间");
        Date completedAt = "done".equals(status) ? new Date() : null;
        String noteZh = trim(body.get("noteZh"));
        String noteFr = trim(body.get("noteFr"));
        String noteEn = trim(body.get("noteEn"));
        validateNote(noteZh, noteFr, noteEn);
        validateStatusNote(status, noteZh, noteFr, noteEn);
        validateAssignee(assigneeSysUserId);
        adminStaffTaskMapper.insertAdminStaffTask(id, assigneeSysUserId, subjectType, subjectId, status, priority, dueAt,
                completedAt);
        upsertNotes(id, noteZh, noteFr, noteEn);

        Map<String, Object> after = new LinkedHashMap<>();
        after.put("assigneeSysUserId", assigneeSysUserId);
        after.put("subjectType", subjectType);
        after.put("subjectId", subjectId);
        after.put("status", status);
        after.put("priority", priority);
        after.put("dueAt", dueAt);
        after.put("noteZh", noteZh);
        after.put("noteFr", noteFr);
        after.put("noteEn", noteEn);
        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", operatorUserId,
                "staff_task", id, "cupid.staffTask.create", null, JSON.toJSONString(after), null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateAdminStaffTask(String id, Map<String, Object> body, String operatorUserId)
    {
        Map<String, Object> before = selectAdminStaffTaskById(id);
        boolean managerOperator = isManagerOperator();
        if (!managerOperator && !isOwnedByCurrentUser(before))
        {
            throw new ServiceException("无权处理他人负责的跟进事项");
        }
        if (!managerOperator && (body.containsKey("assigneeSysUserId") || body.containsKey("priority") || body.containsKey("dueAt")))
        {
            throw new ServiceException("仅管理员可修改负责人、优先级和截止时间");
        }

        Long assigneeSysUserId = managerOperator
                ? parseAssignee(body.get("assigneeSysUserId"))
                : parseExistingAssignee(before.get("assigneeSysUserId"));
        String status = requireAllowedWithDefault(body.get("status"), String.valueOf(before.get("status")), "状态",
                ALLOWED_STATUSES);
        String priority = managerOperator
                ? requireAllowedWithDefault(body.get("priority"), String.valueOf(before.get("priority")), "优先级",
                        ALLOWED_PRIORITIES)
                : String.valueOf(before.get("priority"));
        Date dueAt = managerOperator
                ? parseOptionalDateTime(body.get("dueAt"), "截止时间")
                : parseExistingDate(before.get("dueAt"));
        Date completedAt = "done".equals(status) ? new Date() : null;
        String noteZh = trim(body.get("noteZh"));
        String noteFr = trim(body.get("noteFr"));
        String noteEn = trim(body.get("noteEn"));
        validateNote(noteZh, noteFr, noteEn);
        validateStatusNote(status, noteZh, noteFr, noteEn);
        validateAssignee(assigneeSysUserId);
        adminStaffTaskMapper.updateAdminStaffTask(id, assigneeSysUserId, status, priority, dueAt, completedAt);
        upsertNotes(id, noteZh, noteFr, noteEn);

        Map<String, Object> beforeAudit = new LinkedHashMap<>();
        beforeAudit.put("assigneeSysUserId", before.get("assigneeSysUserId"));
        beforeAudit.put("status", before.get("status"));
        beforeAudit.put("priority", before.get("priority"));
        beforeAudit.put("dueAt", before.get("dueAt"));
        beforeAudit.put("noteZh", before.get("noteZh"));
        beforeAudit.put("noteFr", before.get("noteFr"));
        beforeAudit.put("noteEn", before.get("noteEn"));
        Map<String, Object> afterAudit = new LinkedHashMap<>();
        afterAudit.put("assigneeSysUserId", assigneeSysUserId);
        afterAudit.put("status", status);
        afterAudit.put("priority", priority);
        afterAudit.put("dueAt", dueAt);
        afterAudit.put("noteZh", noteZh);
        afterAudit.put("noteFr", noteFr);
        afterAudit.put("noteEn", noteEn);
        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", operatorUserId,
                "staff_task", id, "cupid.staffTask.edit",
                JSON.toJSONString(beforeAudit), JSON.toJSONString(afterAudit), null);
    }

    private void validateNote(String noteZh, String noteFr, String noteEn)
    {
        if (!StringUtils.hasText(noteZh) && !StringUtils.hasText(noteFr) && !StringUtils.hasText(noteEn))
        {
            throw new ServiceException("请至少填写一种语言的跟进说明");
        }
    }

    private void validateStatusNote(String status, String noteZh, String noteFr, String noteEn)
    {
        if (("done".equals(status) || "snoozed".equals(status))
                && !StringUtils.hasText(noteZh) && !StringUtils.hasText(noteFr) && !StringUtils.hasText(noteEn))
        {
            throw new ServiceException("完成或暂缓时必须填写跟进说明");
        }
    }

    private void upsertNotes(String taskId, String noteZh, String noteFr, String noteEn)
    {
        upsertNote(taskId, "zh", noteZh);
        upsertNote(taskId, "fr", noteFr);
        upsertNote(taskId, "en", noteEn);
    }

    private void upsertNote(String taskId, String locale, String value)
    {
        if (!StringUtils.hasText(value))
        {
            return;
        }
        adminStaffTaskMapper.upsertTaskLocalizedField(IdUtils.fastUUID(), taskId, locale, value.trim());
    }

    private void validateAssignee(Long assigneeSysUserId)
    {
        if (assigneeSysUserId == null)
        {
            return;
        }
        SysUser assignee = sysUserMapper.selectUserById(assigneeSysUserId);
        if (assignee == null || !"0".equals(assignee.getStatus()))
        {
            throw new ServiceException("负责人无效或已停用");
        }
    }

    private boolean isManagerOperator()
    {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        return loginUser != null && loginUser.getPermissions() != null
                && loginUser.getPermissions().contains(MANAGE_PERMISSION);
    }

    private boolean isOwnedByCurrentUser(Map<String, Object> task)
    {
        Long currentUserId = SecurityUtils.getUserId();
        Long assigneeUserId = parseExistingAssignee(task.get("assigneeSysUserId"));
        return assigneeUserId != null && assigneeUserId.equals(currentUserId);
    }

    private String requireText(Object value, String fieldName)
    {
        String text = trim(value);
        if (!StringUtils.hasText(text))
        {
            throw new ServiceException(fieldName + "不能为空");
        }
        return text;
    }

    private String requireAllowed(Object value, String fieldName, Set<String> allowedValues)
    {
        String text = requireText(value, fieldName);
        if (!allowedValues.contains(text))
        {
            throw new ServiceException(fieldName + "无效");
        }
        return text;
    }

    private String requireAllowedWithDefault(Object value, String defaultValue, String fieldName, Set<String> allowedValues)
    {
        String text = trim(value);
        if (!StringUtils.hasText(text))
        {
            text = defaultValue;
        }
        if (!allowedValues.contains(text))
        {
            throw new ServiceException(fieldName + "无效");
        }
        return text;
    }

    private Long parseAssignee(Object value)
    {
        String text = trim(value);
        if (!StringUtils.hasText(text))
        {
            return null;
        }
        try
        {
            return Long.valueOf(text);
        }
        catch (NumberFormatException ex)
        {
            throw new ServiceException("负责人无效");
        }
    }

    private Long parseExistingAssignee(Object value)
    {
        if (value == null)
        {
            return null;
        }
        if (value instanceof Number)
        {
            return ((Number) value).longValue();
        }
        return parseAssignee(value);
    }

    private String trim(Object value)
    {
        if (value == null)
        {
            return null;
        }
        String text = String.valueOf(value).trim();
        return StringUtils.hasText(text) ? text : null;
    }

    private Date parseOptionalDateTime(Object value, String fieldName)
    {
        String text = trim(value);
        return StringUtils.hasText(text) ? parseDateTime(text, fieldName) : null;
    }

    private Date parseExistingDate(Object value)
    {
        return value instanceof Date ? (Date) value : null;
    }

    private Date parseDateTime(String value, String fieldName)
    {
        try
        {
            if (value.endsWith("Z"))
            {
                return Date.from(Instant.parse(value));
            }
            DateTimeFormatter formatter = value.length() == 16
                    ? DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")
                    : DateTimeFormatter.ISO_LOCAL_DATE_TIME;
            LocalDateTime localDateTime = LocalDateTime.parse(value, formatter);
            return Date.from(localDateTime.atZone(ZoneId.systemDefault()).toInstant());
        }
        catch (DateTimeParseException ex)
        {
            throw new ServiceException(fieldName + "格式无效");
        }
    }
}
