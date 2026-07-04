package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.cupid.domain.CupidEvent;
import com.ruoyi.cupid.domain.CupidEventRegistration;

/**
 * Cupid Match 活动数据层
 */
public interface CupidEventMapper
{
    /**
     * 分页查询活动列表
     */
    List<CupidEvent> selectEvents(@Param("offset") int offset, @Param("limit") int limit,
            @Param("city") String city, @Param("status") String status,
            @Param("visibility") String visibility, @Param("month") String month);

    /**
     * 统计活动总数
     */
    int countEvents(@Param("city") String city, @Param("status") String status,
            @Param("visibility") String visibility, @Param("month") String month);

    /**
     * 根据 ID 查询活动
     */
    CupidEvent selectEventById(@Param("id") String id);

    /**
     * 锁定活动记录，串行化报名状态变更
     */
    CupidEvent selectEventByIdForUpdate(@Param("id") String id);

    /**
     * 查询活动本地化字段
     */
    List<Map<String, Object>> selectEventLocalizedFields(@Param("eventIds") List<String> eventIds,
            @Param("locale") String locale);

    /**
     * 查询活动语言
     */
    List<Map<String, Object>> selectEventLanguages(@Param("eventIds") List<String> eventIds);

    /**
     * 查询活动议程
     */
    List<Map<String, Object>> selectEventAgendaItems(@Param("eventId") String eventId,
            @Param("locale") String locale);

    /**
     * 查询用户对活动的报名
     */
    Map<String, Object> selectRegistration(@Param("userId") String userId,
            @Param("eventId") String eventId);

    /**
     * 锁定用户报名记录
     */
    Map<String, Object> selectRegistrationForUpdate(@Param("userId") String userId,
            @Param("eventId") String eventId);

    /**
     * 查询活动关系主题
     */
    List<Map<String, Object>> selectRelationshipFocuses(
            @Param("eventIds") List<String> eventIds,
            @Param("locale") String locale);

    /**
     * 按状态统计活动报名人数
     */
    List<Map<String, Object>> countRegistrationsByStatus(@Param("eventIds") List<String> eventIds);

    /**
     * 新增报名
     */
    int insertRegistration(@Param("id") String id, @Param("userId") String userId,
            @Param("eventId") String eventId, @Param("status") String status,
            @Param("entitlementBalanceId") String entitlementBalanceId,
            @Param("consumeQuota") boolean consumeQuota);

    /**
     * 将已取消或拒绝的报名重新提交
     */
    int resubmitRegistration(@Param("id") String id, @Param("status") String status,
            @Param("entitlementBalanceId") String entitlementBalanceId,
            @Param("consumeQuota") boolean consumeQuota);

    /**
     * 标记报名取消
     */
    int cancelRegistration(@Param("id") String id);

    /**
     * 标记活动额度已经返还
     */
    int markQuotaReleased(@Param("id") String id);

    /**
     * 查询用户报名列表
     */
    List<CupidEvent> selectUserRegistrations(@Param("userId") String userId,
            @Param("locale") String locale);

    // ---- Admin ----

    List<Map<String, Object>> selectAdminEvents(@Param("params") Map<String, Object> params);

    Map<String, Object> selectAdminEventDetail(@Param("id") String id);

    Map<String, Object> selectAdminEventLocalizedFields(
            @Param("eventId") String eventId, @Param("locale") String locale);

    List<Map<String, Object>> selectAdminEventAgendaItems(
            @Param("eventId") String eventId, @Param("locale") String locale);

    List<Map<String, Object>> selectEventNoteItems(
            @Param("eventId") String eventId, @Param("locale") String locale);

    List<String> selectAdminEventLanguageCodes(@Param("eventId") String eventId);

    List<String> selectAdminEventRelationshipFocuses(
            @Param("eventId") String eventId, @Param("locale") String locale);

    int insertAdminEvent(@Param("id") String id,
            @Param("status") String status, @Param("visibility") String visibility,
            @Param("consumesMembershipQuota") boolean consumesMembershipQuota,
            @Param("cityCode") String cityCode,
            @Param("addressVisibility") String addressVisibility,
            @Param("eventDate") String eventDate, @Param("startTime") String startTime,
            @Param("endTime") String endTime, @Param("capacity") int capacity,
            @Param("coverImageUrl") String coverImageUrl);

    int insertAdminEventLocalizedField(@Param("id") String id,
            @Param("eventId") String eventId, @Param("fieldName") String fieldName,
            @Param("locale") String locale, @Param("value") String value);

    int upsertAdminEventLocalizedField(@Param("id") String id,
            @Param("eventId") String eventId, @Param("fieldName") String fieldName,
            @Param("locale") String locale, @Param("value") String value);

    int updateAdminEvent(@Param("id") String id, @Param("status") String status,
            @Param("visibility") String visibility,
            @Param("consumesMembershipQuota") boolean consumesMembershipQuota,
            @Param("cityCode") String cityCode,
            @Param("addressVisibility") String addressVisibility,
            @Param("eventDate") String eventDate, @Param("startTime") String startTime,
            @Param("endTime") String endTime, @Param("capacity") int capacity,
            @Param("coverImageUrl") String coverImageUrl);

    int deleteAdminEventLanguageCodes(@Param("eventId") String eventId);

    int insertAdminEventLanguageCode(@Param("eventId") String eventId,
            @Param("languageCode") String languageCode);

    int deleteAdminEventRelationshipFocuses(@Param("eventId") String eventId);

    int insertAdminEventRelationshipFocus(@Param("id") String id,
            @Param("eventId") String eventId, @Param("focusOrder") int focusOrder,
            @Param("locale") String locale, @Param("value") String value);

    int deleteAdminEventAgendaLocalizedFields(@Param("eventId") String eventId);

    int deleteAdminEventAgendaItems(@Param("eventId") String eventId);

    int insertAdminEventAgendaItem(@Param("id") String id,
            @Param("eventId") String eventId, @Param("agendaTime") String agendaTime,
            @Param("sortOrder") int sortOrder);

    int insertAdminEventAgendaLocalizedField(@Param("id") String id,
            @Param("agendaItemId") String agendaItemId,
            @Param("fieldName") String fieldName,
            @Param("locale") String locale, @Param("value") String value);

    int deleteAdminEventNoteLocalizedFields(@Param("eventId") String eventId);

    int deleteAdminEventNoteItems(@Param("eventId") String eventId);

    int insertAdminEventNoteItem(@Param("id") String id,
            @Param("eventId") String eventId, @Param("sortOrder") int sortOrder);

    int insertAdminEventNoteLocalizedField(@Param("id") String id,
            @Param("noteItemId") String noteItemId,
            @Param("fieldName") String fieldName,
            @Param("locale") String locale, @Param("value") String value);

    int updateAdminEventStatus(@Param("id") String id, @Param("status") String status);

    int countEventOccupied(@Param("eventId") String eventId);

    Map<String, Object> selectAdminEventRegistrationCounts(@Param("eventId") String eventId);

    List<CupidEventRegistration> selectAdminRegistrations(
            @Param("params") Map<String, Object> params);

    Map<String, Object> selectAdminRegistrationById(@Param("id") String id);

    CupidEventRegistration selectAdminRegistrationByIdForUpdate(@Param("id") String id);

    String selectAvailableEventEntitlementBalanceForUpdate(
            @Param("userId") String userId, @Param("membershipId") String membershipId);

    int consumeEventEntitlementById(@Param("balanceId") String balanceId);

    int releaseEventEntitlementById(@Param("balanceId") String balanceId);

    int updateAdminRegistrationStatus(@Param("id") String id,
            @Param("status") String status,
            @Param("entitlementBalanceId") String entitlementBalanceId,
            @Param("consumeQuota") boolean consumeQuota,
            @Param("releaseQuota") boolean releaseQuota);

    List<Map<String, Object>> selectUpcomingEventReminderTargets(
            @Param("batchSize") int batchSize);

    List<String> selectEventLifecycleCandidates(@Param("batchSize") int batchSize);

    CupidEventRegistration selectNextPendingRegistrationForUpdate(
            @Param("eventId") String eventId);

    int markConfirmedRegistrationsAttended(@Param("eventId") String eventId);

    int markEventCompleted(@Param("eventId") String eventId);
}
