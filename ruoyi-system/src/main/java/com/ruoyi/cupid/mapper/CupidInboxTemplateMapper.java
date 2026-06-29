package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

/** Cupid Match 通知模板数据层。 */
public interface CupidInboxTemplateMapper
{
    List<Map<String, Object>> selectTemplates(Map<String, Object> params);

    Map<String, Object> selectTemplateById(@Param("id") String id);

    Map<String, Object> selectTemplateByCode(@Param("templateCode") String templateCode);

    List<Map<String, Object>> selectLocalizedFields(@Param("templateId") String templateId);

    Map<String, Object> selectLocalizedField(@Param("templateId") String templateId,
            @Param("locale") String locale);

    int insertTemplate(Map<String, Object> params);

    int updateTemplate(Map<String, Object> params);

    int updateTemplateStatus(@Param("id") String id, @Param("status") String status);

    int upsertLocalizedField(Map<String, Object> params);
}
