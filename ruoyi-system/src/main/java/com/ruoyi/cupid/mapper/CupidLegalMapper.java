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
     * 查询文档指定语言的内容
     */
    CupidLegalDocumentContent selectContentByLocale(@Param("documentId") String documentId, @Param("locale") String locale);

    /**
     * 查询文档的回退语言内容
     */
    CupidLegalDocumentContent selectFallbackContent(@Param("documentId") String documentId);

    /**
     * 新增或更新用户文档接受记录
     */
    int upsertAcceptance(@Param("id") String id, @Param("userId") String userId,
            @Param("documentType") String documentType, @Param("documentVersion") String documentVersion,
            @Param("acceptedAt") Date acceptedAt);
}
