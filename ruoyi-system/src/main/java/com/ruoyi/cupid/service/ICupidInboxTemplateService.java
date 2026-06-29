package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

/** Cupid Match 通知模板服务。 */
public interface ICupidInboxTemplateService
{
    List<Map<String, Object>> selectTemplates(Map<String, Object> params);

    Map<String, Object> selectTemplate(String id);

    List<Map<String, Object>> selectEnabledTemplates();

    void createTemplate(Map<String, Object> body, String staffUserId);

    void updateTemplate(String id, Map<String, Object> body, String staffUserId);

    void updateStatus(String id, String status, String staffUserId);
}
