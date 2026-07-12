package com.ruoyi.cupid.service;

import java.util.Map;
import java.util.List;

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
     * 查询后台法律文档列表。
     */
    List<Map<String, Object>> selectAdminDocuments(Map<String, Object> params);

    /**
     * 查询后台法律文档详情。
     */
    Map<String, Object> selectAdminDocumentById(String id);

    /**
     * 更新后台法律文档内容。
     */
    void updateAdminDocument(String id, Map<String, Object> body);

    /**
     * 基于当前文档创建新版草稿。
     */
    Map<String, Object> createAdminDraft(String type);

    /**
     * 发布草稿为生效版本，并自动归档旧生效版本。
     */
    void publishAdminDraft(String id, Map<String, Object> body);

    /**
     * 记录用户接受全部当前有效法务文档
     *
     * @param userId 用户ID
     */
    void acceptActiveDocuments(String userId);
}
