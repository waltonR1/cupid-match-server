package com.ruoyi.cupid.service.impl;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.domain.CupidEvent;
import com.ruoyi.cupid.domain.CupidMembershipPlan;
import com.ruoyi.cupid.domain.CupidUserEntitlementBalance;
import com.ruoyi.cupid.domain.CupidUserMembership;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.mapper.CupidEventMapper;
import com.ruoyi.cupid.mapper.CupidMembershipMapper;
import com.ruoyi.cupid.service.ICupidCommonOptionService;
import com.ruoyi.cupid.service.ICupidEventService;

/**
 * Cupid Match 活动服务实现
 */
@Service
public class CupidEventServiceImpl implements ICupidEventService
{
    private static final String EVENT_ENTITLEMENT = "event_registration";
    private static final int DEFAULT_PAGE_SIZE = 12;
    private static final int MAX_PAGE_SIZE = 100;

    @Autowired
    private CupidEventMapper eventMapper;

    @Autowired
    private CupidAuthMapper authMapper;

    @Autowired
    private CupidMembershipMapper membershipMapper;

    @Autowired
    private ICupidCommonOptionService commonOptionService;

    @Override
    public Map<String, Object> getEvents(Map<String, String> params, String userId)
    {
        int page = positiveInt(params.get("page"), 1);
        int pageSize = Math.min(positiveInt(params.get("pageSize"), DEFAULT_PAGE_SIZE), MAX_PAGE_SIZE);
        int offset = (page - 1) * pageSize;
        String locale = normalizeLocale(params.get("lang"));
        String city = trimToNull(params.get("city"));
        String status = trimToNull(params.get("status"));
        String visibility = normalizeVisibility(params.get("visibility"));
        String month = normalizeMonth(params.get("month"));

        List<CupidEvent> events = eventMapper.selectEvents(
                offset, pageSize, city, status, visibility, month);
        enrichEvents(events, locale);
        int total = eventMapper.countEvents(city, status, visibility, month);

        List<Map<String, Object>> items = new ArrayList<>();
        for (CupidEvent event : events)
        {
            items.add(buildDirectoryItem(event));
        }

        List<CupidEvent> facetEvents = eventMapper.selectEvents(
                0, 10000, null, null, null, null);
        enrichEvents(facetEvents, locale);

        Map<String, Object> pagination = new LinkedHashMap<>();
        pagination.put("page", page);
        pagination.put("pageSize", pageSize);
        pagination.put("total", total);
        pagination.put("totalPages", total == 0 ? 0 : (int) Math.ceil((double) total / pageSize));

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("items", items);
        result.put("pagination", pagination);
        result.put("facets", buildFacets(facetEvents));
        return result;
    }

    @Override
    public Map<String, Object> getEventDetail(String eventId, String userId, String locale)
    {
        CupidEvent event = eventMapper.selectEventById(eventId);
        if (event == null || "draft".equals(event.getStatus()))
        {
            return null;
        }

        enrichEvents(List.of(event), normalizeLocale(locale));
        Map<String, Object> registration = eventMapper.selectRegistration(userId, eventId);

        Map<String, Object> detail = buildDirectoryItem(event);
        detail.putAll(resolveAddress(event, userId, registration));
        detail.put("languageCodes", loadLanguageCodes(eventId));
        detail.put("noteItems", loadNoteItems(eventId, normalizeLocale(locale)));
        detail.put("agendaItems", loadAgendaItems(eventId, normalizeLocale(locale)));
        detail.put("registration", resolveRegistrationState(event, userId, registration));
        detail.put("eventEntitlement", buildEventEntitlement(userId));
        return detail;
    }

    @Override
    @Transactional
    public Map<String, Object> register(String userId, String eventId)
    {
        CupidEvent event = eventMapper.selectEventByIdForUpdate(eventId);
        if (event == null || "draft".equals(event.getStatus()))
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "event_not_found");
        }

        enrichEvents(List.of(event), "zh");
        Map<String, Object> existing =
                eventMapper.selectRegistrationForUpdate(userId, eventId);
        String registrationId = null;
        if (existing != null)
        {
            registrationId = (String) existing.get("id");
            String currentStatus = (String) existing.get("status");
            if ("cancelled".equals(currentStatus)
                    && wasConfirmedRegistration(existing))
            {
                return buildRegistrationResponse(
                        event, registrationState("cancelled", registrationId), userId);
            }
            if (!"cancelled".equals(currentStatus) && !"declined".equals(currentStatus))
            {
                return buildRegistrationResponse(
                        event, registrationState(currentStatus, registrationId), userId);
            }
        }

        String effectiveStatus = resolveEventStatus(event);
        if ("closed".equals(effectiveStatus) || "completed".equals(effectiveStatus))
        {
            return buildRegistrationResponse(event, registrationState("closed", null), userId);
        }
        if ("member".equals(event.getVisibility()) && !hasActivePaidMembership(userId))
        {
            return buildRegistrationResponse(event, registrationState("member_required", null), userId);
        }

        CupidUserEntitlementBalance balance = currentEventEntitlement(userId);
        if (event.isConsumesMembershipQuota()
                && (balance == null || balance.getQuotaRemaining() <= 0))
        {
            return buildRegistrationResponse(event,
                    registrationState("event_quota_exhausted", null), userId);
        }

        String registrationStatus = shouldWaitlist(event) ? "waitlist" : "confirmed";
        String entitlementBalanceId = null;
        boolean consumeQuota = false;
        if ("confirmed".equals(registrationStatus) && event.isConsumesMembershipQuota())
        {
            entitlementBalanceId = balance.getId();
            consumeQuota = true;
            if (eventMapper.consumeEventEntitlementById(entitlementBalanceId) != 1)
            {
                throw new CupidApiException(
                        HttpStatus.CONFLICT, "event_quota_exhausted");
            }
        }
        if (existing == null)
        {
            registrationId = IdUtils.fastUUID();
            eventMapper.insertRegistration(registrationId, userId, eventId,
                    registrationStatus, entitlementBalanceId, consumeQuota);
        }
        else
        {
            eventMapper.resubmitRegistration(registrationId, registrationStatus,
                    entitlementBalanceId, consumeQuota);
        }

        loadCounts(event);
        return buildRegistrationResponse(
                event, registrationState(registrationStatus, registrationId), userId);
    }

    @Override
    @Transactional
    public Map<String, Object> cancel(String userId, String eventId)
    {
        CupidEvent event = eventMapper.selectEventByIdForUpdate(eventId);
        if (event == null || "draft".equals(event.getStatus()))
        {
            throw new CupidApiException(HttpStatus.NOT_FOUND, "event_not_found");
        }
        enrichEvents(List.of(event), "zh");

        Map<String, Object> registration =
                eventMapper.selectRegistrationForUpdate(userId, eventId);
        if (registration == null)
        {
            loadCounts(event);
            return buildRegistrationResponse(
                    event, resolveRegistrationState(event, userId, null), userId);
        }

        String registrationId = (String) registration.get("id");
        String status = (String) registration.get("status");
        if ("attended".equals(status))
        {
            loadCounts(event);
            return buildRegistrationResponse(
                    event, registrationState("attended", registrationId), userId);
        }
        if ("cancelled".equals(status))
        {
            loadCounts(event);
            return buildRegistrationResponse(
                    event, registrationState("cancelled", registrationId), userId);
        }

        if (registration.get("eventQuotaConsumedAt") != null
                && registration.get("eventQuotaReleasedAt") == null)
        {
            String entitlementBalanceId =
                    (String) registration.get("entitlementBalanceId");
            if (entitlementBalanceId == null
                    || eventMapper.releaseEventEntitlementById(entitlementBalanceId) != 1
                    || eventMapper.markQuotaReleased(registrationId) != 1)
            {
                throw new CupidApiException(
                        HttpStatus.CONFLICT, "event_entitlement_release_failed");
            }
        }

        eventMapper.cancelRegistration(registrationId);
        loadCounts(event);
        return buildRegistrationResponse(
                event, registrationState("cancelled", registrationId), userId);
    }

    @Override
    public List<Map<String, Object>> getMyEvents(String userId, String locale)
    {
        List<CupidEvent> events =
                eventMapper.selectUserRegistrations(userId, normalizeLocale(locale));
        enrichEvents(events, normalizeLocale(locale));

        List<Map<String, Object>> items = new ArrayList<>();
        for (CupidEvent event : events)
        {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("registrationId", event.getRegistrationId());
            item.put("eventId", event.getId());
            item.put("title", valueOrEmpty(event.getTitle()));
            item.put("coverImageUrl", event.getCoverImageUrl());
            item.put("city", valueOrEmpty(event.getCity()));
            item.put("venue", valueOrEmpty(event.getVenue()));
            item.put("date", formatDate(event.getEventDate()));
            item.put("startTime", event.getStartTime());
            item.put("endTime", event.getEndTime());
            item.put("status", event.getRegistrationStatus());
            items.add(item);
        }

        return items;
    }

    private void enrichEvents(List<CupidEvent> events, String locale)
    {
        if (events.isEmpty())
        {
            return;
        }

        List<String> eventIds = new ArrayList<>();
        for (CupidEvent event : events)
        {
            eventIds.add(event.getId());
        }

        Map<String, Map<String, String>> localized =
                loadLocalizedFields(eventIds, locale);
        Map<String, Map<String, Integer>> counts = loadRegistrationCounts(eventIds);
        Map<String, List<String>> focuses = loadRelationshipFocuses(eventIds, locale);

        for (CupidEvent event : events)
        {
            applyLocalizedFields(event,
                    localized.getOrDefault(event.getId(), Map.of()));
            event.setCity(commonOptionService.label("city", event.getCityCode(), locale));
            applyCounts(event, counts.getOrDefault(event.getId(), Map.of()));
            event.setRelationshipFocus(
                    focuses.getOrDefault(event.getId(), List.of()));
        }
    }

    private Map<String, Map<String, String>> loadLocalizedFields(
            List<String> eventIds, String locale)
    {
        Map<String, Map<String, String>> grouped = new LinkedHashMap<>();
        for (Map<String, Object> row :
                eventMapper.selectEventLocalizedFields(eventIds, locale))
        {
            String eventId = (String) row.get("eventId");
            String fieldName = (String) row.get("fieldName");
            String value = (String) row.get("value");
            grouped.computeIfAbsent(eventId, key -> new LinkedHashMap<>())
                    .putIfAbsent(fieldName, value);
        }
        return grouped;
    }

    private Map<String, List<String>> loadRelationshipFocuses(
            List<String> eventIds, String locale)
    {
        Map<String, Map<Integer, String>> grouped = new LinkedHashMap<>();
        for (Map<String, Object> row :
                eventMapper.selectRelationshipFocuses(eventIds, locale))
        {
            String eventId = (String) row.get("eventId");
            int sortOrder = ((Number) row.get("sortOrder")).intValue();
            grouped.computeIfAbsent(eventId, key -> new LinkedHashMap<>())
                    .putIfAbsent(sortOrder, (String) row.get("value"));
        }

        Map<String, List<String>> result = new LinkedHashMap<>();
        for (Map.Entry<String, Map<Integer, String>> entry : grouped.entrySet())
        {
            result.put(entry.getKey(), new ArrayList<>(entry.getValue().values()));
        }
        return result;
    }

    private Map<String, Map<String, Integer>> loadRegistrationCounts(
            List<String> eventIds)
    {
        Map<String, Map<String, Integer>> grouped = new LinkedHashMap<>();
        for (Map<String, Object> row :
                eventMapper.countRegistrationsByStatus(eventIds))
        {
            grouped.computeIfAbsent(
                    (String) row.get("eventId"), key -> new LinkedHashMap<>())
                    .put((String) row.get("status"),
                            ((Number) row.get("cnt")).intValue());
        }
        return grouped;
    }

    private void applyLocalizedFields(CupidEvent event, Map<String, String> fields)
    {
        event.setTitle(valueOrEmpty(fields.get("title")));
        event.setSummary(valueOrEmpty(fields.get("summary")));
        event.setVenue(valueOrEmpty(fields.get("venue")));
        event.setAddress(valueOrEmpty(fields.get("address")));
        event.setFormat(valueOrEmpty(fields.get("format")));
        event.setAudience(valueOrEmpty(fields.get("audience")));
    }

    private void applyCounts(CupidEvent event, Map<String, Integer> counts)
    {
        int registered = counts.getOrDefault("confirmed", 0);
        event.setRegisteredCount(registered);
        event.setWaitlistCount(counts.getOrDefault("waitlist", 0));
        event.setRemainingSeats(Math.max(event.getCapacity() - registered, 0));
    }

    private void loadCounts(CupidEvent event)
    {
        Map<String, Map<String, Integer>> counts =
                loadRegistrationCounts(List.of(event.getId()));
        applyCounts(event, counts.getOrDefault(event.getId(), Map.of()));
    }

    private List<String> loadLanguageCodes(String eventId)
    {
        List<String> values = new ArrayList<>();
        for (Map<String, Object> row :
                eventMapper.selectEventLanguages(List.of(eventId)))
        {
            values.add((String) row.get("languageCode"));
        }
        return values;
    }

    private List<Map<String, Object>> loadAgendaItems(String eventId, String locale)
    {
        Map<String, Map<String, Object>> grouped = new LinkedHashMap<>();
        for (Map<String, Object> row :
                eventMapper.selectEventAgendaItems(eventId, locale))
        {
            String id = (String) row.get("id");
            Map<String, Object> item =
                    grouped.computeIfAbsent(id, key -> {
                        Map<String, Object> value = new LinkedHashMap<>();
                        value.put("id", id);
                        value.put("time", row.get("time"));
                        value.put("title", "");
                        value.put("description", "");
                        value.put("sortOrder",
                                ((Number) row.get("sortOrder")).intValue());
                        return value;
                    });
            String fieldName = (String) row.get("fieldName");
            if (fieldName != null && "".equals(item.get(fieldName)))
            {
                item.put(fieldName, row.get("value"));
            }
        }
        return new ArrayList<>(grouped.values());
    }

    private List<Map<String, Object>> loadNoteItems(String eventId, String locale)
    {
        return eventMapper.selectEventNoteItems(eventId, locale);
    }

    private Map<String, Object> buildDirectoryItem(CupidEvent event)
    {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("id", event.getId());
        item.put("status", resolveEventStatus(event));
        item.put("title", valueOrEmpty(event.getTitle()));
        item.put("summary", valueOrEmpty(event.getSummary()));
        item.put("city", valueOrEmpty(event.getCity()));
        item.put("venue", valueOrEmpty(event.getVenue()));
        item.put("date", formatDate(event.getEventDate()));
        item.put("startTime", event.getStartTime());
        item.put("endTime", event.getEndTime());
        item.put("format", valueOrEmpty(event.getFormat()));
        item.put("audience", valueOrEmpty(event.getAudience()));
        item.put("relationshipFocus",
                event.getRelationshipFocus() == null
                        ? List.of() : event.getRelationshipFocus());
        item.put("capacity", event.getCapacity());
        item.put("registeredCount", event.getRegisteredCount());
        item.put("waitlistCount", event.getWaitlistCount());
        item.put("remainingSeats", event.getRemainingSeats());
        item.put("memberOnly", "member".equals(event.getVisibility()));
        item.put("consumesMembershipQuota", event.isConsumesMembershipQuota());
        item.put("coverImageUrl", event.getCoverImageUrl());
        return item;
    }

    private Map<String, Object> buildFacets(List<CupidEvent> events)
    {
        Map<String, Object> facets = new LinkedHashMap<>();
        facets.put("city", buildCityFacet(events));
        facets.put("status", buildFacet(events, "status"));
        facets.put("visibility", buildFacet(events, "visibility"));
        facets.put("month", buildFacet(events, "month"));
        return facets;
    }

    private List<Map<String, Object>> buildCityFacet(List<CupidEvent> events)
    {
        Map<String, Map<String, Object>> options = new LinkedHashMap<>();
        for (CupidEvent event : events)
        {
            Map<String, Object> option = options.computeIfAbsent(
                    event.getCityCode(), key -> {
                        Map<String, Object> value = new LinkedHashMap<>();
                        value.put("value", key);
                        value.put("label", valueOrDefault(
                                event.getCity(), event.getCityCode()));
                        value.put("count", 0);
                        return value;
                    });
            option.put("count", ((Number) option.get("count")).intValue() + 1);
        }
        return new ArrayList<>(options.values());
    }

    private List<Map<String, Object>> buildFacet(
            List<CupidEvent> events, String type)
    {
        Map<String, Integer> counts = new LinkedHashMap<>();
        for (CupidEvent event : events)
        {
            String value;
            if ("status".equals(type))
            {
                value = resolveEventStatus(event);
            }
            else if ("visibility".equals(type))
            {
                value = event.getVisibility();
            }
            else
            {
                value = new SimpleDateFormat("yyyy-MM").format(event.getEventDate());
            }
            counts.merge(value, 1, Integer::sum);
        }

        List<Map<String, Object>> options = new ArrayList<>();
        for (Map.Entry<String, Integer> entry : counts.entrySet())
        {
            Map<String, Object> option = new LinkedHashMap<>();
            option.put("value", entry.getKey());
            option.put("label", entry.getKey());
            option.put("count", entry.getValue());
            options.add(option);
        }
        return options;
    }

    private Map<String, Object> resolveAddress(CupidEvent event, String userId,
            Map<String, Object> registration)
    {
        Map<String, Object> result = new LinkedHashMap<>();
        if (event.getAddress() == null || event.getAddress().isEmpty())
        {
            result.put("addressVisible", false);
            return result;
        }
        if (userId == null)
        {
            result.put("addressVisible", false);
            result.put("addressLockReason", "login_required");
            return result;
        }
        if ("confirmed_attendee_only".equals(event.getAddressVisibility())
                && !isConfirmedOrAttended(registration))
        {
            result.put("addressVisible", false);
            result.put("addressLockReason", "confirmation_required");
            return result;
        }
        result.put("address", event.getAddress());
        result.put("addressVisible", true);
        return result;
    }

    private Map<String, Object> resolveRegistrationState(CupidEvent event,
            String userId, Map<String, Object> registration)
    {
        if (userId == null)
        {
            return registrationState("guest", null);
        }
        if (registration != null)
        {
            String status = (String) registration.get("status");
            if ("cancelled".equals(status)
                    && wasConfirmedRegistration(registration))
            {
                return registrationState(
                        "cancelled", (String) registration.get("id"));
            }
            if (!"cancelled".equals(status) && !"declined".equals(status))
            {
                return registrationState(
                        status, (String) registration.get("id"));
            }
        }
        if ("member".equals(event.getVisibility())
                && !hasActivePaidMembership(userId))
        {
            return registrationState("member_required", null);
        }
        if (event.isConsumesMembershipQuota())
        {
            CupidUserEntitlementBalance balance = currentEventEntitlement(userId);
            if (balance == null || balance.getQuotaRemaining() <= 0)
            {
                return registrationState("event_quota_exhausted", null);
            }
        }
        String status = resolveEventStatus(event);
        if ("closed".equals(status) || "completed".equals(status))
        {
            return registrationState("closed", null);
        }
        return registrationState("available", null);
    }

    private Map<String, Object> buildRegistrationResponse(CupidEvent event,
            Map<String, Object> registration, String userId)
    {
        loadCounts(event);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("registration", registration);
        result.put("registeredCount", event.getRegisteredCount());
        result.put("waitlistCount", event.getWaitlistCount());
        result.put("remainingSeats", event.getRemainingSeats());
        result.put("eventEntitlement", buildEventEntitlement(userId));
        return result;
    }

    private Map<String, Object> registrationState(String status, String id)
    {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", status);
        if (id != null)
        {
            result.put("registrationId", id);
        }
        return result;
    }

    private Map<String, Object> buildEventEntitlement(String userId)
    {
        CupidUserEntitlementBalance balance = currentEventEntitlement(userId);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("code", EVENT_ENTITLEMENT);
        result.put("quotaTotal", balance == null ? 0 : balance.getQuotaTotal());
        result.put("quotaUsed", balance == null ? 0 : balance.getQuotaUsed());
        result.put("quotaRemaining",
                balance == null ? 0 : balance.getQuotaRemaining());
        if (balance != null)
        {
            result.put("periodStartedAt", balance.getPeriodStartedAt());
            result.put("periodEndsAt", balance.getPeriodEndsAt());
        }
        return result;
    }

    private CupidUserEntitlementBalance currentEventEntitlement(String userId)
    {
        if (userId == null)
        {
            return null;
        }
        CupidUserMembership membership =
                authMapper.selectActiveMembershipByUserId(userId);
        if (membership == null)
        {
            return null;
        }
        for (CupidUserEntitlementBalance balance :
                membershipMapper.selectCurrentEntitlementBalances(
                        userId, membership.getId()))
        {
            if (EVENT_ENTITLEMENT.equals(balance.getEntitlementCode()))
            {
                return balance;
            }
        }
        return null;
    }

    private boolean hasActivePaidMembership(String userId)
    {
        if (userId == null)
        {
            return false;
        }
        CupidUserMembership membership =
                authMapper.selectActiveMembershipByUserId(userId);
        if (membership == null)
        {
            return false;
        }
        CupidMembershipPlan plan =
                membershipMapper.selectPlanById(membership.getPlanId());
        return plan != null && plan.getIsActive() && !"free".equals(plan.getTier());
    }

    private boolean isConfirmedOrAttended(Map<String, Object> registration)
    {
        if (registration == null)
        {
            return false;
        }
        String status = (String) registration.get("status");
        return "confirmed".equals(status) || "attended".equals(status);
    }

    private boolean wasConfirmedRegistration(Map<String, Object> registration)
    {
        return registration.get("confirmedAt") != null
                || registration.get("attendedAt") != null;
    }

    private String resolveEventStatus(CupidEvent event)
    {
        if ("hidden".equals(event.getStatus()))
        {
            return "hidden";
        }
        LocalDate eventDate = event.getEventDate().toInstant()
                .atZone(ZoneId.systemDefault()).toLocalDate();
        if (eventDate.isBefore(LocalDate.now()))
        {
            return "completed";
        }
        return event.getStatus();
    }

    private boolean shouldWaitlist(CupidEvent event)
    {
        return "waitlist".equals(event.getStatus()) || event.getRemainingSeats() <= 0;
    }

    private String normalizeLocale(String locale)
    {
        return "fr".equals(locale) || "en".equals(locale) ? locale : "zh";
    }

    private String normalizeVisibility(String visibility)
    {
        return "public".equals(visibility)
                || "registered".equals(visibility)
                || "member".equals(visibility) ? visibility : null;
    }

    private String normalizeMonth(String month)
    {
        return month != null && month.matches("\\d{4}-(0[1-9]|1[0-2])")
                ? month : null;
    }

    private int positiveInt(String value, int defaultValue)
    {
        try
        {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : defaultValue;
        }
        catch (RuntimeException ex)
        {
            return defaultValue;
        }
    }

    private String trimToNull(String value)
    {
        if (value == null || value.trim().isEmpty())
        {
            return null;
        }
        return value.trim();
    }

    private String valueOrEmpty(String value)
    {
        return value == null ? "" : value;
    }

    private String valueOrDefault(String value, String defaultValue)
    {
        return value == null || value.isEmpty() ? defaultValue : value;
    }

    private String formatDate(Date value)
    {
        return new SimpleDateFormat("yyyy-MM-dd").format(value);
    }
}
