package com.ruoyi.cupid.service;

import java.util.Map;

/**
 * Cupid Match 资料可选项服务。
 */
public interface ICupidProfileOptionService
{
    /**
     * 获取资料表单可选项。
     *
     * @param locale 展示语言
     * @param clientVersion 前端缓存版本
     * @return 可选项分组，或未变更结果
     */
    Map<String, Object> getProfileOptions(String locale, String clientVersion);

    /**
     * 按分组和 code 解析展示文案。
     *
     * @param group 可选项分组
     * @param value code 值
     * @param locale 展示语言
     * @return 展示文案
     */
    String label(String group, String value, String locale);
}
