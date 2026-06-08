package com.ruoyi.cupid.service;

import java.util.Map;

/**
 * Cupid Match 法务文档服务
 */
public interface ICupidLegalService
{
    /**
     * 查询指定类型和语言的有效法务文档
     *
     * @param type 文档类型
     * @param locale 语言
     * @return 法务文档内容
     */
    Map<String, Object> getDocument(String type, String locale);

    /**
     * 记录用户接受全部当前有效法务文档
     *
     * @param userId 用户ID
     */
    void acceptActiveDocuments(String userId);
}
