package com.ruoyi.cupid.event;

import java.util.Map;

/** 核心业务提交后生成的结构化站内通知事件。 */
public class CupidInboxNotificationEvent
{
    private final String userId;
    private final String templateCode;
    private final Map<String, Object> variables;
    private final String subjectId;
    private final String dedupeKey;

    public CupidInboxNotificationEvent(String userId, String templateCode,
            Map<String, Object> variables, String subjectId, String dedupeKey)
    {
        this.userId = userId;
        this.templateCode = templateCode;
        this.variables = variables;
        this.subjectId = subjectId;
        this.dedupeKey = dedupeKey;
    }

    public String getUserId() { return userId; }
    public String getTemplateCode() { return templateCode; }
    public Map<String, Object> getVariables() { return variables; }
    public String getSubjectId() { return subjectId; }
    public String getDedupeKey() { return dedupeKey; }
}
