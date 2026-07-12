package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Date;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.cupid.domain.CupidLegalDocument;
import com.ruoyi.cupid.domain.CupidLegalDocumentContent;

/**
 * Cupid Match 法务文档数据层
 */
public interface CupidLegalMapper
{
    /**
     * 根据类型查询当前有效文档
     */
    CupidLegalDocument selectActiveDocumentByType(@Param("type") String type);

    /**
     * 查询全部当前有效文档
     */
    List<CupidLegalDocument> selectActiveDocuments();

    /**
     * 查询后台法律文档列表。
     */
    List<CupidLegalDocument> selectAdminDocuments(@Param("type") String type);

    /**
     * 根据 ID 查询法律文档。
     */
    CupidLegalDocument selectDocumentById(@Param("id") String id);

    /**
     * 查询指定类型的草稿文档。
     */
    CupidLegalDocument selectDraftDocumentByType(@Param("type") String type);

    /**
     * 查询文档指定语言的内容
     */
    CupidLegalDocumentContent selectContentByLocale(@Param("documentId") String documentId, @Param("locale") String locale);

    /**
     * 查询文档的回退语言内容
     */
    CupidLegalDocumentContent selectFallbackContent(@Param("documentId") String documentId);

    /**
     * 更新法律文档基础信息。
     */
    int updateDocument(CupidLegalDocument document);

    /**
     * 新增法律文档。
     */
    int insertDocument(CupidLegalDocument document);

    /**
     * 归档指定类型当前生效文档。
     */
    int archiveActiveDocumentByType(@Param("type") String type);

    /**
     * 新增或更新法律文档本地化内容。
     */
    int upsertContent(CupidLegalDocumentContent content);

    /**
     * 新增或更新用户文档接受记录
     */
    int upsertAcceptance(@Param("id") String id, @Param("userId") String userId,
            @Param("documentType") String documentType, @Param("documentVersion") String documentVersion,
            @Param("acceptedAt") Date acceptedAt);
}
