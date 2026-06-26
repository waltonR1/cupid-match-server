package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

/**
 * Cupid Match 通用可选项服务。
 */
public interface ICupidCommonOptionService
{
    /**
     * 获取通用可选项。
     *
     * @param locale 展示语言
     * @param clientVersion 前端缓存版本
     * @return 可选项分组，或未变更结果
     */
    Map<String, Object> getOptions(String locale, String clientVersion);

    /**
     * 按分组和 code 解析展示文案。
     *
     * @param group 可选项分组
     * @param value code 值
     * @param locale 展示语言
     * @return 展示文案
     */
    String label(String group, String value, String locale);

    List<Map<String, Object>> selectAdminOptionGroups();

    List<Map<String, Object>> selectAdminOptionValues(String groupKey);

    Map<String, Object> selectAdminOptionValue(String id);

    Map<String, Object> createAdminOptionValue(Map<String, Object> body, String staffUserId);

    void updateAdminOptionValue(String id, Map<String, Object> body, String staffUserId);
}
