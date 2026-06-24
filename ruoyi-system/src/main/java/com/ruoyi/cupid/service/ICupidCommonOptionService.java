package com.ruoyi.cupid.service;

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
}
