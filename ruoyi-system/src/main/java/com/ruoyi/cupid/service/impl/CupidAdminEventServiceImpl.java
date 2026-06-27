package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.domain.CupidEvent;
import com.ruoyi.cupid.domain.CupidEventRegistration;
import com.ruoyi.cupid.domain.CupidUserMembership;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.mapper.CupidEventMapper;
import com.ruoyi.cupid.mapper.CupidProfileMapper;
import com.ruoyi.cupid.service.ICupidAdminEventService;

/**
 * Cupid Match 后台活动与报名服务实现。
 */
@Service
public class CupidAdminEventServiceImpl implements ICupidAdminEventService
{
    private static final Set<String> EVENT_STATUSES =
            Set.of("draft", "open", "waitlist", "closed", "completed");

    private static final Set<String> WRITABLE_EVENT_STATUSES = Set.of("draft", "open");

    private static final Set<String> EVENT_VISIBILITIES = Set.of("public", "registered", "member");

    private static final Set<String> ADDRESS_VISIBILITIES =
            Set.of("registered_only", "confirmed_attendee_only");

    private static final Set<String> REGISTRATION_STATUSES =
            Set.of("requested", "confirmed", "declined", "waitlist", "cancelled", "attended");

    @Autowired
    private CupidEventMapper eventMapper;

    @Autowired
    private CupidAuthMapper authMapper;

    @Autowired
    private CupidProfileMapper profileMapper;

    @Override
    public List<Map<String, Object>> selectAdminEvents(Map<String, Object> params)
    {
        return eventMapper.selectAdminEvents(params);
    }

    @Override
    public Map<String, Object> selectAdminEventDetail(String id)
    {
        Map<String, Object> detail =
                require(eventMapper.selectAdminEventDetail(id), "活动不存在");
        int occupied = eventMapper.countEventOccupied(id);
        detail.put("occupiedCount", occupied);
        Map<String, Object> registrationCounts =
                eventMapper.selectAdminEventRegistrationCounts(id);
        if (registrationCounts != null)
        {
            detail.putAll(registrationCounts);
        }
        Map<String, Object> localized =
                eventMapper.selectAdminEventLocalizedFields(id, "zh");
        if (localized != null)
        {
            detail.putAll(localized);
        }
        detail.put("languageCodes", eventMapper.selectAdminEventLanguageCodes(id));
        detail.put("relationshipFocus", eventMapper.selectAdminEventRelationshipFocuses(id, "zh"));
        detail.put("noteItems", eventMapper.selectEventNoteItems(id, "zh"));
        detail.put("agendaItems", eventMapper.selectAdminEventAgendaItems(id, "zh"));
        return detail;
    }

    @Override
    @Transactional
    public void createEvent(Map<String, Object> data, String operatorUserId)
    {
        String title = requiredString(data, "title", "活动标题不能为空");
        String status = stringOrDefault(data, "status", "draft");
        String visibility = stringOrDefault(data, "visibility", "registered");
        String cityCode = requiredString(data, "cityCode", "城市不能为空");
        String addressVisibility = stringOrDefault(data, "addressVisibility", "registered_only");
        String eventDate = requiredString(data, "eventDate", "活动日期不能为空");
        String startTime = requiredString(data, "startTime", "开始时间不能为空");
        String endTime = requiredString(data, "endTime", "结束时间不能为空");
        int capacity = positiveInt(data.get("capacity"), "容量必须大于 0");
        String coverImageUrl = stringValue(data.get("coverImageUrl"));
        boolean consumesMembershipQuota = booleanValue(data.get("consumesMembershipQuota"));

        validateWritableEventStatus(status);
        if (!EVENT_VISIBILITIES.contains(visibility))
        {
            throw new ServiceException("不支持的活动可见范围");
        }
        if (!ADDRESS_VISIBILITIES.contains(addressVisibility))
        {
            throw new ServiceException("不支持的地址可见性");
        }
        validatePublishFields(status, data, title, coverImageUrl);

        String eventId = IdUtils.simpleUUID();
        eventMapper.insertAdminEvent(eventId, status, visibility,
                consumesMembershipQuota, cityCode, addressVisibility,
                eventDate, startTime, endTime, capacity, coverImageUrl);
        upsertEventLocalizedFields(eventId, data, title);
        replaceLanguageCodes(eventId, data);
        replaceRelationshipFocuses(eventId, data);
        replaceNoteItems(eventId, data);
        replaceAgendaItems(eventId, data);

        Map<String, Object> after = selectAdminEventDetail(eventId);
        insertAudit("event", eventId, "cupid.event.create",
                operatorUserId, Map.of(), after, null);
    }

    @Override
    @Transactional
    public void updateEvent(String id, Map<String, Object> data, String operatorUserId)
    {
        Map<String, Object> before = selectAdminEventDetail(id);
        if (!"draft".equals(String.valueOf(before.get("status"))))
        {
            throw new ServiceException("只有草稿活动可以编辑字段");
        }

        String title = requiredString(data, "title", "活动标题不能为空");
        String status = stringOrDefault(data, "status", "draft");
        String visibility = stringOrDefault(data, "visibility", "registered");
        String cityCode = requiredString(data, "cityCode", "城市不能为空");
        String addressVisibility = stringOrDefault(data, "addressVisibility", "registered_only");
        String eventDate = requiredString(data, "eventDate", "活动日期不能为空");
        String startTime = requiredString(data, "startTime", "开始时间不能为空");
        String endTime = requiredString(data, "endTime", "结束时间不能为空");
        int capacity = positiveInt(data.get("capacity"), "活动名额必须大于 0");
        String coverImageUrl = stringValue(data.get("coverImageUrl"));
        boolean consumesMembershipQuota = booleanValue(data.get("consumesMembershipQuota"));

        validateWritableEventStatus(status);
        if (!EVENT_VISIBILITIES.contains(visibility))
        {
            throw new ServiceException("不支持的活动可见范围");
        }
        if (!ADDRESS_VISIBILITIES.contains(addressVisibility))
        {
            throw new ServiceException("不支持的地址可见性");
        }

        validatePublishFields(status, data, title, coverImageUrl);

        int updated = eventMapper.updateAdminEvent(id, status, visibility,
                consumesMembershipQuota, cityCode, addressVisibility,
                eventDate, startTime, endTime, capacity, coverImageUrl);
        if (updated != 1)
        {
            throw new ServiceException("活动已不是草稿，无法编辑字段");
        }
        upsertEventLocalizedFields(id, data, title);
        replaceLanguageCodes(id, data);
        replaceRelationshipFocuses(id, data);
        replaceNoteItems(id, data);
        replaceAgendaItems(id, data);

        Map<String, Object> after = selectAdminEventDetail(id);
        insertAudit("event", id, "cupid.event.edit",
                operatorUserId, before, after, null);
    }

    @Override
    @Transactional
    public void updateEventStatus(String id, String status, String reason, String reviewerUserId)
    {
        if (!EVENT_STATUSES.contains(status))
        {
            throw new ServiceException("不支持的活动状态");
        }

        Map<String, Object> before = selectAdminEventDetail(id);
        if (!EVENT_STATUSES.contains(String.valueOf(before.get("status"))))
        {
            throw new ServiceException("活动不存在");
        }
        if (reason == null || reason.isBlank())
        {
            throw new ServiceException("状态变更原因不能为空");
        }

        String currentStatus = String.valueOf(before.get("status"));
        if (currentStatus.equals(status))
        {
            throw new ServiceException("目标状态不能与当前状态相同");
        }
        if (!canTransitEventStatus(currentStatus, status))
        {
            throw new ServiceException("不支持的活动状态流转");
        }
        validatePublishFields(status, before, stringValue(before.get("title")),
                stringValue(before.get("coverImageUrl")));

        if (eventMapper.updateAdminEventStatus(id, status) != 1)
        {
            throw new ServiceException("活动状态变更失败");
        }
        Map<String, Object> after = selectAdminEventDetail(id);
        insertAudit("event", id, "cupid.event.changeStatus", reviewerUserId, before, after, reason);
    }

    @Override
    public List<Map<String, Object>> selectAdminRegistrations(Map<String, Object> params)
    {
        // Registration list returns CupidEventRegistration objects;
        // wrap into maps for controller compatibility
        List<CupidEventRegistration> list = eventMapper.selectAdminRegistrations(params);
        return list.stream().map(this::registrationToMap).toList();
    }

    @Override
    public Map<String, Object> selectAdminRegistrationDetail(String id)
    {
        return require(eventMapper.selectAdminRegistrationById(id), "报名记录不存在");
    }

    @Override
    @Transactional
    public void reviewRegistration(String id, String targetStatus, String reason, String reviewerUserId)
    {
        if (!REGISTRATION_STATUSES.contains(targetStatus))
        {
            throw new ServiceException("不支持的报名状态");
        }
        if (reason == null || reason.isBlank())
        {
            throw new ServiceException("状态纠正原因不能为空");
        }

        Map<String, Object> detail =
                require(eventMapper.selectAdminRegistrationById(id), "报名记录不存在");
        String eventId = String.valueOf(detail.get("eventId"));

        // 与 C 端保持相同的加锁顺序：先活动，再报名记录。
        CupidEvent event = eventMapper.selectEventByIdForUpdate(eventId);
        if (event == null)
        {
            throw new ServiceException("活动不存在");
        }

        CupidEventRegistration registration =
                require(eventMapper.selectAdminRegistrationByIdForUpdate(id), "报名记录不存在");
        String currentStatus = registration.getStatus();
        if (targetStatus.equals(currentStatus))
        {
            throw new ServiceException("目标状态不能与当前状态相同");
        }

        boolean currentOccupiesSeat = occupiesSeat(currentStatus);
        boolean targetOccupiesSeat = occupiesSeat(targetStatus);
        if (targetOccupiesSeat && !currentOccupiesSeat
                && eventMapper.countEventOccupied(eventId) >= event.getCapacity())
        {
            throw new ServiceException("活动名额已满");
        }

        boolean quotaActive = registration.getEventQuotaConsumedAt() != null
                && registration.getEventQuotaReleasedAt() == null;
        boolean consumeQuota = event.isConsumesMembershipQuota()
                && targetOccupiesSeat && !quotaActive;
        boolean releaseQuota = event.isConsumesMembershipQuota()
                && !targetOccupiesSeat && quotaActive;
        String entitlementBalanceId = registration.getEntitlementBalanceId();

        if (consumeQuota)
        {
            CupidUserMembership membership =
                    authMapper.selectActiveMembershipByUserId(registration.getUserId());
            if (membership == null)
            {
                throw new ServiceException("用户没有有效会员，无法扣减活动额度");
            }
            entitlementBalanceId =
                    eventMapper.selectAvailableEventEntitlementBalanceForUpdate(
                            registration.getUserId(), membership.getId());
            if (entitlementBalanceId == null
                    || eventMapper.consumeEventEntitlementById(entitlementBalanceId) != 1)
            {
                throw new ServiceException("活动额度不足");
            }
        }
        if (releaseQuota)
        {
            if (entitlementBalanceId == null
                    || eventMapper.releaseEventEntitlementById(entitlementBalanceId) != 1)
            {
                throw new ServiceException("活动额度返还失败");
            }
        }

        if (eventMapper.updateAdminRegistrationStatus(id, targetStatus,
                entitlementBalanceId, consumeQuota, releaseQuota) != 1)
        {
            throw new ServiceException("报名状态纠正失败");
        }
        Map<String, Object> after = eventMapper.selectAdminRegistrationById(id);
        insertAudit("event_registration", id,
                "cupid.eventRegistration.changeStatus", reviewerUserId,
                registrationToMap(registration), after, reason);
    }

    private boolean occupiesSeat(String status)
    {
        return "confirmed".equals(status) || "attended".equals(status);
    }

    private boolean canTransitEventStatus(String currentStatus, String targetStatus)
    {
        if ("draft".equals(currentStatus))
        {
            return Set.of("open").contains(targetStatus);
        }
        if ("open".equals(currentStatus))
        {
            return Set.of("waitlist", "closed", "completed").contains(targetStatus);
        }
        if ("waitlist".equals(currentStatus))
        {
            return Set.of("closed", "completed").contains(targetStatus);
        }
        if ("closed".equals(currentStatus))
        {
            return Set.of("open", "completed").contains(targetStatus);
        }
        return false;
    }

    private String requiredString(Map<String, Object> data, String key, String message)
    {
        String value = stringValue(data.get(key));
        if (value == null || value.isBlank())
        {
            throw new ServiceException(message);
        }
        return value;
    }

    private String stringOrDefault(Map<String, Object> data, String key, String defaultValue)
    {
        String value = stringValue(data.get(key));
        return value == null || value.isBlank() ? defaultValue : value;
    }

    private String stringValue(Object value)
    {
        return value == null ? null : String.valueOf(value).trim();
    }

    private boolean booleanValue(Object value)
    {
        if (value instanceof Boolean)
        {
            return (Boolean) value;
        }
        return "true".equalsIgnoreCase(String.valueOf(value))
                || "1".equals(String.valueOf(value));
    }

    private int positiveInt(Object value, String message)
    {
        try
        {
            int result = Integer.parseInt(String.valueOf(value));
            if (result > 0)
            {
                return result;
            }
        }
        catch (NumberFormatException ignored)
        {
        }
        throw new ServiceException(message);
    }

    private void validateWritableEventStatus(String status)
    {
        if (!WRITABLE_EVENT_STATUSES.contains(status))
        {
            throw new ServiceException("新建或编辑活动只支持草稿、报名中");
        }
    }

    private void validatePublishFields(String status, Map<String, Object> data,
            String title, String coverImageUrl)
    {
        if (!"open".equals(status))
        {
            return;
        }

        requireNonBlank(title, "报名中活动必须填写活动标题");
        requireNonBlank(coverImageUrl, "报名中活动必须上传活动封面");
        requiredString(data, "summary", "报名中活动必须填写活动说明");
        requiredString(data, "venue", "报名中活动必须填写场地");
        requiredString(data, "address", "报名中活动必须填写地址");
        requiredString(data, "format", "报名中活动必须填写活动形式");
        requiredString(data, "audience", "报名中活动必须填写适合人群");
        if (extractLanguageCodes(data).isEmpty())
        {
            throw new ServiceException("报名中活动必须选择活动语言");
        }
        if (extractRelationshipFocuses(data).isEmpty())
        {
            throw new ServiceException("报名中活动必须填写关系主题");
        }
        if (!hasOnlyCompleteItems(data, "agendaItems", true))
        {
            throw new ServiceException("报名中活动的每条活动流程都必须完整");
        }
        if (!hasOnlyCompleteItems(data, "noteItems", false))
        {
            throw new ServiceException("报名中活动的每条活动说明都必须完整");
        }
    }

    private void requireNonBlank(String value, String message)
    {
        if (value == null || value.isBlank())
        {
            throw new ServiceException(message);
        }
    }

    private boolean hasOnlyCompleteItems(Map<String, Object> data, String key, boolean requireTime)
    {
        Object rawItems = data.get(key);
        if (!(rawItems instanceof List<?>) || ((List<?>) rawItems).isEmpty())
        {
            return false;
        }
        for (Object rawItem : (List<?>) rawItems)
        {
            if (!(rawItem instanceof Map<?, ?>))
            {
                return false;
            }
            Map<?, ?> item = (Map<?, ?>) rawItem;
            String time = stringValue(item.get("time"));
            String title = stringValue(item.get("title"));
            String description = stringValue(item.get("description"));
            boolean timeComplete = !requireTime || (time != null && !time.isBlank());
            if (!timeComplete || title == null || title.isBlank()
                    || description == null || description.isBlank())
            {
                return false;
            }
        }
        return true;
    }

    private List<String> extractLanguageCodes(Map<String, Object> data)
    {
        List<String> codes = new ArrayList<>();
        Object rawCodes = data.get("languageCodes");
        if (!(rawCodes instanceof List<?>))
        {
            return codes;
        }
        for (Object rawCode : (List<?>) rawCodes)
        {
            String code = stringValue(rawCode);
            if (code != null && !code.isBlank() && !codes.contains(code))
            {
                codes.add(code);
            }
        }
        return codes;
    }

    private List<String> extractRelationshipFocuses(Map<String, Object> data)
    {
        List<String> values = new ArrayList<>();
        Object rawValues = data.get("relationshipFocus");
        if (!(rawValues instanceof List<?>))
        {
            return values;
        }
        for (Object rawValue : (List<?>) rawValues)
        {
            String value = stringValue(rawValue);
            if (value != null && !value.isBlank())
            {
                values.add(value);
            }
        }
        return values;
    }

    private void upsertEventLocalizedFields(String eventId, Map<String, Object> data, String title)
    {
        Map<String, String> fields = new LinkedHashMap<>();
        fields.put("title", title);
        fields.put("summary", stringOrDefault(data, "summary", ""));
        fields.put("venue", stringOrDefault(data, "venue", ""));
        fields.put("address", stringOrDefault(data, "address", ""));
        fields.put("format", stringOrDefault(data, "format", ""));
        fields.put("audience", stringOrDefault(data, "audience", ""));
        for (Map.Entry<String, String> entry : fields.entrySet())
        {
            eventMapper.upsertAdminEventLocalizedField(IdUtils.simpleUUID(),
                    eventId, entry.getKey(), "zh", entry.getValue());
        }
    }

    private void replaceLanguageCodes(String eventId, Map<String, Object> data)
    {
        eventMapper.deleteAdminEventLanguageCodes(eventId);
        for (String languageCode : extractLanguageCodes(data))
        {
            eventMapper.insertAdminEventLanguageCode(eventId, languageCode);
        }
    }

    private void replaceRelationshipFocuses(String eventId, Map<String, Object> data)
    {
        eventMapper.deleteAdminEventRelationshipFocuses(eventId);
        int index = 0;
        for (String value : extractRelationshipFocuses(data))
        {
            eventMapper.insertAdminEventRelationshipFocus(IdUtils.simpleUUID(),
                    eventId, ++index, "zh", value);
        }
    }

    private void replaceAgendaItems(String eventId, Map<String, Object> data)
    {
        eventMapper.deleteAdminEventAgendaLocalizedFields(eventId);
        eventMapper.deleteAdminEventAgendaItems(eventId);

        Object rawItems = data.get("agendaItems");
        if (!(rawItems instanceof List<?>))
        {
            return;
        }

        int index = 0;
        for (Object rawItem : (List<?>) rawItems)
        {
            if (!(rawItem instanceof Map<?, ?>))
            {
                continue;
            }
            Map<?, ?> item = (Map<?, ?>) rawItem;
            String time = stringValue(item.get("time"));
            String title = stringValue(item.get("title"));
            String description = stringValue(item.get("description"));
            if ((time == null || time.isBlank())
                    && (title == null || title.isBlank())
                    && (description == null || description.isBlank()))
            {
                continue;
            }

            String agendaItemId = IdUtils.simpleUUID();
            eventMapper.insertAdminEventAgendaItem(agendaItemId, eventId,
                    time == null ? "" : time, index + 1);
            eventMapper.insertAdminEventAgendaLocalizedField(IdUtils.simpleUUID(),
                    agendaItemId, "title", "zh", title == null ? "" : title);
            eventMapper.insertAdminEventAgendaLocalizedField(IdUtils.simpleUUID(),
                    agendaItemId, "description", "zh", description == null ? "" : description);
            index++;
        }
    }

    private void replaceNoteItems(String eventId, Map<String, Object> data)
    {
        eventMapper.deleteAdminEventNoteLocalizedFields(eventId);
        eventMapper.deleteAdminEventNoteItems(eventId);

        Object rawItems = data.get("noteItems");
        if (!(rawItems instanceof List<?>))
        {
            return;
        }

        int index = 0;
        for (Object rawItem : (List<?>) rawItems)
        {
            if (!(rawItem instanceof Map<?, ?>))
            {
                continue;
            }
            Map<?, ?> item = (Map<?, ?>) rawItem;
            String title = stringValue(item.get("title"));
            String description = stringValue(item.get("description"));
            if ((title == null || title.isBlank())
                    && (description == null || description.isBlank()))
            {
                continue;
            }

            String noteItemId = IdUtils.simpleUUID();
            eventMapper.insertAdminEventNoteItem(noteItemId, eventId, ++index);
            eventMapper.insertAdminEventNoteLocalizedField(IdUtils.simpleUUID(),
                    noteItemId, "title", "zh", title == null ? "" : title);
            eventMapper.insertAdminEventNoteLocalizedField(IdUtils.simpleUUID(),
                    noteItemId, "description", "zh",
                    description == null ? "" : description);
        }
    }

    private Map<String, Object> registrationToMap(CupidEventRegistration reg)
    {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", reg.getId());
        map.put("userId", reg.getUserId());
        map.put("eventId", reg.getEventId());
        map.put("entitlementBalanceId", reg.getEntitlementBalanceId());
        map.put("status", reg.getStatus());
        map.put("requestedAt", reg.getRequestedAt());
        map.put("confirmedAt", reg.getConfirmedAt());
        map.put("declinedAt", reg.getDeclinedAt());
        map.put("waitlistedAt", reg.getWaitlistedAt());
        map.put("cancelledAt", reg.getCancelledAt());
        map.put("attendedAt", reg.getAttendedAt());
        map.put("eventQuotaConsumedAt", reg.getEventQuotaConsumedAt());
        map.put("eventQuotaReleasedAt", reg.getEventQuotaReleasedAt());
        map.put("createdAt", reg.getCreatedAt());
        map.put("updatedAt", reg.getUpdatedAt());
        map.put("userAccountName", reg.getUserAccountName());
        map.put("eventTitle", reg.getEventTitle());
        map.put("eventDate", reg.getEventDate());
        return map;
    }

    private void insertAudit(String subjectType, String subjectId, String action,
            String reviewerUserId, Map<String, Object> before, Map<String, Object> after, String reason)
    {
        profileMapper.insertAdminAuditLog(IdUtils.fastUUID(), "staff", reviewerUserId,
                subjectType, subjectId, action,
                JSON.toJSONString(before), JSON.toJSONString(after), reason);
    }

    private static <T> T require(T value, String message)
    {
        if (value == null)
        {
            throw new ServiceException(message);
        }
        return value;
    }
}
