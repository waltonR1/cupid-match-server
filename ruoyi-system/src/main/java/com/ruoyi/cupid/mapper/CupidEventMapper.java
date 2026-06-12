package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.cupid.domain.CupidEvent;

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
            @Param("eventId") String eventId, @Param("status") String status);

    /**
     * 将已取消或拒绝的报名重新提交
     */
    int resubmitRegistration(@Param("id") String id);

    /**
     * 标记报名取消
     */
    int cancelRegistration(@Param("id") String id);

    /**
     * 标记活动额度已经返还
     */
    int markQuotaReleased(@Param("id") String id);

    /**
     * 原子返还当前周期活动额度
     */
    int releaseEventEntitlement(@Param("userId") String userId,
            @Param("membershipId") String membershipId);

    /**
     * 查询用户报名列表
     */
    List<CupidEvent> selectUserRegistrations(@Param("userId") String userId,
            @Param("locale") String locale);
}
