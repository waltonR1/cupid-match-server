package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.cupid.domain.CupidCommonOptionValue;

/**
 * Cupid Match 通用选项数据层。
 */
public interface CupidCommonOptionMapper
{
    /**
     * 查询前台可见的启用选项。
     *
     * @return 启用选项
     */
    List<CupidCommonOptionValue> selectEnabledOptions();

    /**
     * 查询所有可回显选项，包含停用项。
     *
     * @return 所有选项
     */
    List<CupidCommonOptionValue> selectAllOptions();

    /**
     * 查询动态选项版本。
     *
     * @return 版本时间戳
     */
    String selectOptionsVersion();

    List<Map<String, Object>> selectAdminOptionGroups();

    List<Map<String, Object>> selectAdminOptionValues(@Param("groupKey") String groupKey);

    Map<String, Object> selectAdminOptionValueById(@Param("id") String id);

    Map<String, Object> selectAdminOptionGroupByKey(@Param("groupKey") String groupKey);

    Map<String, Object> selectAdminOptionValueByGroupAndValue(@Param("groupKey") String groupKey,
            @Param("optionValue") String optionValue);

    int insertAdminOptionValue(Map<String, Object> params);

    int updateAdminOptionValue(Map<String, Object> params);

    int insertAdminAuditLog(@Param("id") String id,
            @Param("actorType") String actorType,
            @Param("actorUserId") String actorUserId,
            @Param("subjectType") String subjectType,
            @Param("subjectId") String subjectId,
            @Param("action") String action,
            @Param("beforeData") String beforeData,
            @Param("afterData") String afterData,
            @Param("reason") String reason);
}
