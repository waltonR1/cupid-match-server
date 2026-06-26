package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.domain.CupidCommonOptionValue;
import com.ruoyi.cupid.mapper.CupidCommonOptionMapper;
import com.ruoyi.cupid.service.ICupidCommonOptionService;

/**
 * Cupid Match 通用可选项服务实现。
 *
 * <p>动态 group 由 cm_option_groups/cm_option_values 维护；状态机和系统规则类 group 保留代码常量。</p>
 */
@Service
public class CupidCommonOptionServiceImpl implements ICupidCommonOptionService
{
    private static final String VERSION = "2026-06-26-common-options-v8";
    private static final String PROFILE_GROUP_PREFIX = "profile.";
    private static final Set<String> OPTION_STATUSES = Set.of("enabled", "disabled");

    private static final Map<String, List<Option>> GROUPS = new LinkedHashMap<>();

    @Autowired
    private CupidCommonOptionMapper commonOptionMapper;

    static
    {
        put("gender",
                option("male", "男", "Homme", "Male", false),
                option("female", "女", "Femme", "Female", false));
        put("profileStatus",
                option("draft", "草稿", "Brouillon", "Draft", false),
                option("review", "待审核", "En verification", "Under review", false),
                option("open", "已开放", "Ouvert", "Open", false),
                option("paused", "已暂停", "En pause", "Paused", false),
                option("hidden", "已隐藏", "Masque", "Hidden", false));
        put("profileType",
                option("self", "本人资料", "Profil personnel", "Self profile", false),
                option("family", "家庭代建", "Profil familial", "Family profile", false));
        put("photoStatus",
                option("review", "待审核", "En verification", "Under review", false),
                option("approved", "已通过", "Approuve", "Approved", false),
                option("rejected", "已拒绝", "Refuse", "Rejected", false),
                option("hidden", "已隐藏", "Masque", "Hidden", false));
        put("reviewStatus",
                option("unreviewed", "未审核", "Non verifie", "Unreviewed", false),
                option("pending", "待审核", "En attente", "Pending", false),
                option("approved", "已通过", "Approuve", "Approved", false),
                option("rejected", "已拒绝", "Refuse", "Rejected", false));
        put("verificationStatus",
                option("unverified", "未认证", "Non verifie", "Unverified", false),
                option("pending", "待审核", "En attente", "Pending", false),
                option("verified", "已认证", "Verifie", "Verified", false),
                option("rejected", "已拒绝", "Refuse", "Rejected", false));
        put("relationshipToProfile",
                option("self", "本人", "Moi", "Self", false),
                option("parent", "家长", "Parent", "Parent", false),
                option("father", "父亲", "Pere", "Father", false),
                option("mother", "母亲", "Mere", "Mother", false),
                option("relative", "亲属", "Proche", "Relative", false));
        put("preferredChannel",
                option("phone", "手机", "Telephone", "Phone", false),
                option("email", "邮箱", "Email", "Email", false),
                option("wechat", "微信", "WeChat", "WeChat", false));
        put("contactVisibility",
                option("after_introduction", "介绍成功后开放", "Apres introduction", "After introduction", false),
                option("owner_only", "仅管理员可见", "Gestionnaire uniquement", "Owner only", false),
                option("disabled", "暂不开放", "Desactive", "Disabled", false));
        put("account.status",
                option("active", "正常", "Actif", "Active", false),
                option("disabled", "已停用", "Desactive", "Disabled", false),
                option("pending", "待完善", "En attente", "Pending", false));
        put("account.locale",
                option("zh", "中文", "Chinois", "Chinese", false),
                option("fr", "Français", "Français", "French", false),
                option("en", "English", "Anglais", "English", false));
        put("account.identityProvider",
                option("email", "邮箱", "Email", "Email", false),
                option("phone", "手机", "Telephone", "Phone", false));
        put("account.preference",
                option("preferred_city", "偏好城市", "Ville preferee", "Preferred city", false),
                option("preferred_contact_channel", "首选联系方式", "Canal de contact prefere", "Preferred contact channel", false),
                option("staff_contact_enabled", "允许工作人员联系", "Contact conseiller autorise", "Staff contact enabled", false),
                option("family_assist_enabled", "家庭协助", "Assistance familiale", "Family assistance", false),
                option("introduction_updates_enabled", "介绍进展通知", "Notifications d'introduction", "Introduction updates", false),
                option("event_reminders_enabled", "活动提醒", "Rappels evenement", "Event reminders", false),
                option("service_announcements_enabled", "服务公告", "Annonces de service", "Service announcements", false),
                option("marketing_emails_enabled", "营销邮件", "Emails marketing", "Marketing emails", false),
                option("analytics_consent_enabled", "数据分析授权", "Consentement analytique", "Analytics consent", false));
        put("event.status",
                option("open", "报名中", "Ouvert", "Open", false),
                option("waitlist", "候补", "Attente", "Waitlist", false),
                option("closed", "已关闭", "Ferme", "Closed", false),
                option("completed", "已结束", "Termine", "Completed", false),
                option("member", "会员专属", "Membres", "Members only", false));
        put("event.registrationStatus",
                option("requested", "待确认", "En attente", "Pending", false),
                option("confirmed", "已确认", "Confirme", "Confirmed", false),
                option("waitlist", "候补中", "Liste d'attente", "Waitlist", false),
                option("declined", "未通过", "Refuse", "Declined", false),
                option("cancelled", "已取消", "Annule", "Cancelled", false),
                option("attended", "已参加", "Participe", "Attended", false));
        put("introduction.status",
                option("requested", "已申请", "Demande", "Requested", false),
                option("accepted", "已接受", "Accepte", "Accepted", false),
                option("declined", "已婉拒", "Refuse", "Declined", false),
                option("cancelled", "已取消", "Annule", "Cancelled", false),
                option("expired", "已过期", "Expire", "Expired", false),
                option("cooldown", "冷却中", "Attente", "Cooldown", false));
        put("membership.status",
                option("active", "生效中", "Actif", "Active", false),
                option("expired", "已到期", "Expire", "Expired", false),
                option("cancelled", "已取消", "Annule", "Cancelled", false),
                option("paused", "已暂停", "En pause", "Paused", false));
        put("membership.tier",
                option("free", "免费会员", "Gratuit", "Free", false),
                option("silver", "银卡会员", "Argent", "Silver", false),
                option("gold", "金卡会员", "Or", "Gold", false),
                option("diamond", "钻石会员", "Diamond", "Diamond", false));
        put("membership.entitlement",
                option("private_introduction", "私人介绍", "Introductions privees", "Private introductions", false),
                option("event_registration", "活动额度", "Quota evenement", "Event quota", false),
                option("event_priority", "活动优先权", "Priorite evenement", "Event priority", false),
                option("staff_review", "顾问审核", "Revue conseiller", "Advisor review", false),
                option("profile_detail_access", "资料详情访问", "Acces detail profil", "Profile detail access", false));
        put("message.subjectType",
                option("system", "系统通知", "Notification systeme", "System notice", false),
                option("profile", "资料", "Profil", "Profile", false),
                option("event", "活动", "Evenement", "Event", false),
                option("private_introduction_request", "私人介绍申请", "Demande d'introduction privee", "Private introduction request", false),
                option("membership", "会员", "Abonnement", "Membership", false),
                option("legal_document", "法律文档", "Document juridique", "Legal document", false));
        put("relationship.contactReason",
                option("not_found", "未找到该申请", "Demande introuvable", "Request not found", false),
                option("forbidden", "无权查看", "Acces refuse", "Access denied", false),
                option("not_accepted", "对方尚未接受申请", "Pas encore accepte", "Not yet accepted", false),
                option("contact_unavailable", "对方未填写联系方式", "Aucun contact enregistre", "No contact info on file", false),
                option("visibility_restricted", "对方设置了联系方式不可见", "Contact en prive", "Contact is set to private", false));
        put("event.addressLockReason",
                option("login_required", "登录后可查看具体地址", "Connectez-vous pour voir l'adresse exacte", "Log in to view the exact address", false),
                option("registration_required", "报名后可查看具体地址", "Inscrivez-vous pour voir l'adresse exacte", "Register for the event to view the exact address", false),
                option("confirmation_required", "报名确认后可查看具体地址", "Adresse visible apres confirmation", "Address is visible after confirmation", false));
        put("profile.ownershipPermission",
                option("owner", "所有者", "Proprietaire", "Owner", false),
                option("manager", "管理者", "Gestionnaire", "Manager", false));
        put("profile.ownershipStatus",
                option("pending", "待确认", "En attente", "Pending", false),
                option("active", "有效", "Actif", "Active", false),
                option("revoked", "已撤销", "Revoque", "Revoked", false));
        put("profile.internalRecordSource",
                option("self_submitted", "本人提交", "Soumis par soi-meme", "Self submitted", false),
                option("family_submitted", "家庭提交", "Soumis par la famille", "Family submitted", false),
                option("staff_collected", "员工采集", "Collecte par l'equipe", "Staff collected", false));
        put("localized.status",
                option("pending", "待处理", "En attente", "Pending", false),
                option("ready", "已完成", "Pret", "Ready", false),
                option("failed", "失败", "Echec", "Failed", false),
                option("stale", "待刷新", "A rafraichir", "Stale", false));
        put("localized.source",
                option("manual", "人工录入", "Saisie manuelle", "Manual", false),
                option("machine", "机器生成", "Genere par machine", "Machine generated", false),
                option("generated", "自动生成", "Genere automatiquement", "Generated", false),
                option("imported", "导入", "Importe", "Imported", false));
        put("localized.provider",
                option("human", "人工", "Humain", "Human", false),
                option("translation_api", "翻译接口", "API de traduction", "Translation API", false),
                option("libretranslate", "LibreTranslate", "LibreTranslate", "LibreTranslate", false),
                option("system", "系统", "Systeme", "System", false));
        put("verification.materialType",
                option("identity", "身份认证", "Identite", "Identity", false),
                option("education", "学历认证", "Education", "Education", false),
                option("income", "收入认证", "Revenu", "Income", false),
                option("marital", "婚姻认证", "Situation matrimoniale", "Marital", false));
        put("verification.materialStatus",
                option("pending", "待审核", "En attente", "Pending", false),
                option("approved", "已通过", "Approuve", "Approved", false),
                option("rejected", "已拒绝", "Refuse", "Rejected", false));

        put("verification.scanStatus",
                option("pending", "待检查", "En attente", "Pending", false),
                option("passed", "已通过", "Reussi", "Passed", false),
                option("failed", "未通过", "Echoue", "Failed", false));
    }

    @Override
    public Map<String, Object> getOptions(String locale, String clientVersion)
    {
        Map<String, Object> result = new LinkedHashMap<>();
        String version = currentVersion();
        result.put("version", version);
        if (version.equals(clientVersion))
        {
            result.put("unchanged", true);
            return result;
        }

        String loc = normalizeLocale(locale);
        result.put("unchanged", false);
        result.put("groups", responseGroups(visibleOptions(), loc));
        result.put("labelGroups", responseGroups(allLabelOptions(), loc));
        return result;
    }

    @Override
    public String label(String group, String value, String locale)
    {
        if (!StringUtils.hasText(value))
        {
            return "";
        }
        Map<String, List<Option>> groups = allLabelOptions();
        List<Option> options = groups.get(externalGroupKey(group));
        if (options != null)
        {
            String loc = normalizeLocale(locale);
            for (Option option : options)
            {
                if (option.value().equals(value))
                {
                    return option.label(loc);
                }
            }
        }
        return value;
    }

    @Override
    public List<Map<String, Object>> selectAdminOptionGroups()
    {
        return commonOptionMapper.selectAdminOptionGroups();
    }

    @Override
    public List<Map<String, Object>> selectAdminOptionValues(String groupKey)
    {
        return commonOptionMapper.selectAdminOptionValues(groupKey);
    }

    @Override
    public Map<String, Object> selectAdminOptionValue(String id)
    {
        return requireAdminOptionValue(id);
    }

    @Override
    public Map<String, Object> createAdminOptionValue(Map<String, Object> body, String staffUserId)
    {
        String groupKey = requireText(body, "groupKey", "选项分组不能为空");
        String optionValue = requireText(body, "optionValue", "选项 code 不能为空");
        if (!optionValue.matches("[A-Za-z0-9:_-]+"))
        {
            throw new ServiceException("选项 code 只能包含字母、数字、冒号、下划线和短横线");
        }

        Map<String, Object> group = commonOptionMapper.selectAdminOptionGroupByKey(groupKey);
        if (group == null)
        {
            throw new ServiceException("选项分组不存在或不可动态管理");
        }
        if (commonOptionMapper.selectAdminOptionValueByGroupAndValue(groupKey, optionValue) != null)
        {
            throw new ServiceException("选项 code 已存在");
        }

        Map<String, Object> params = new HashMap<>();
        String id = IdUtils.fastUUID();
        params.put("id", id);
        params.put("groupId", group.get("id"));
        params.put("optionValue", optionValue);
        params.put("labelZh", requireText(body, "labelZh", "中文文案不能为空"));
        params.put("labelFr", requireText(body, "labelFr", "法语文案不能为空"));
        params.put("labelEn", requireText(body, "labelEn", "英语文案不能为空"));
        params.put("sortOrder", integerValue(body.get("sortOrder"), 0, "排序不能为空"));
        params.put("requiresExtraText", booleanValue(body.get("requiresExtraText")));
        params.put("status", statusValue(body.get("status"), "enabled"));

        commonOptionMapper.insertAdminOptionValue(params);
        Map<String, Object> after = requireAdminOptionValue(id);
        insertAudit("option", id, "cupid.option.create", staffUserId, null, after, null);
        return after;
    }

    @Override
    public void updateAdminOptionValue(String id, Map<String, Object> body, String staffUserId)
    {
        Map<String, Object> before = requireAdminOptionValue(id);
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        copyText(body, params, "labelZh");
        copyText(body, params, "labelFr");
        copyText(body, params, "labelEn");
        copyInteger(body, params, "sortOrder");
        copyBoolean(body, params, "requiresExtraText");
        copyStatus(body, params);

        if (params.size() == 1)
        {
            throw new ServiceException("没有需要修改的选项字段");
        }

        commonOptionMapper.updateAdminOptionValue(params);
        Map<String, Object> after = requireAdminOptionValue(id);
        insertAudit("option", id, "cupid.option.update", staffUserId, before, after, null);
    }

    private Map<String, Object> requireAdminOptionValue(String id)
    {
        if (!StringUtils.hasText(id))
        {
            throw new ServiceException("选项不存在");
        }
        Map<String, Object> option = commonOptionMapper.selectAdminOptionValueById(id);
        if (option == null)
        {
            throw new ServiceException("选项不存在");
        }
        return option;
    }

    private String requireText(Map<String, Object> source, String key, String message)
    {
        Object value = source == null ? null : source.get(key);
        if (value == null || !StringUtils.hasText(String.valueOf(value)))
        {
            throw new ServiceException(message);
        }
        return String.valueOf(value).trim();
    }

    private void copyText(Map<String, Object> source, Map<String, Object> target, String key)
    {
        if (!source.containsKey(key))
        {
            return;
        }
        Object value = source.get(key);
        if (value == null || !StringUtils.hasText(String.valueOf(value)))
        {
            throw new ServiceException("选项标签不能为空");
        }
        target.put(key, String.valueOf(value).trim());
    }

    private void copyInteger(Map<String, Object> source, Map<String, Object> target, String key)
    {
        if (!source.containsKey(key))
        {
            return;
        }
        Object value = source.get(key);
        if (value == null)
        {
            throw new ServiceException("排序不能为空");
        }
        target.put(key, integerValue(value, null, "排序不能为空"));
    }

    private void copyBoolean(Map<String, Object> source, Map<String, Object> target, String key)
    {
        if (!source.containsKey(key))
        {
            return;
        }
        Object value = source.get(key);
        target.put(key, booleanValue(value));
    }

    private void copyStatus(Map<String, Object> source, Map<String, Object> target)
    {
        if (!source.containsKey("status"))
        {
            return;
        }
        target.put("status", statusValue(source.get("status"), null));
    }

    private Integer integerValue(Object value, Integer defaultValue, String message)
    {
        if (value == null || !StringUtils.hasText(String.valueOf(value)))
        {
            if (defaultValue != null)
            {
                return defaultValue;
            }
            throw new ServiceException(message);
        }
        return Integer.valueOf(String.valueOf(value));
    }

    private Integer booleanValue(Object value)
    {
        return Boolean.parseBoolean(String.valueOf(value)) ? 1 : 0;
    }

    private String statusValue(Object value, String defaultValue)
    {
        String status = value == null || !StringUtils.hasText(String.valueOf(value)) ? defaultValue : String.valueOf(value);
        if (!OPTION_STATUSES.contains(status))
        {
            throw new ServiceException("选项状态不合法");
        }
        return status;
    }

    private void insertAudit(String subjectType, String subjectId, String action, String staffUserId,
            Map<String, Object> before, Map<String, Object> after, String reason)
    {
        commonOptionMapper.insertAdminAuditLog(IdUtils.fastUUID(), "admin", staffUserId, subjectType, subjectId,
                action, JSON.toJSONString(before), JSON.toJSONString(after), reason);
    }

    private String currentVersion()
    {
        String dynamicVersion = commonOptionMapper.selectOptionsVersion();
        if (!StringUtils.hasText(dynamicVersion) || "empty".equals(dynamicVersion))
        {
            return VERSION;
        }
        return VERSION + "-" + dynamicVersion;
    }

    private Map<String, List<Option>> visibleOptions()
    {
        Map<String, List<Option>> options = staticOptionsByExternalGroup();
        mergeDynamicOptions(options, commonOptionMapper.selectAllOptions(), false);
        return options;
    }

    private Map<String, Object> responseGroups(Map<String, List<Option>> source, String locale)
    {
        Map<String, Object> groups = new LinkedHashMap<>();
        for (Map.Entry<String, List<Option>> entry : source.entrySet())
        {
            List<Map<String, Object>> options = new ArrayList<>();
            for (Option option : entry.getValue())
            {
                options.add(option.toMap(locale));
            }
            groups.put(entry.getKey(), options);
        }
        return groups;
    }

    private Map<String, List<Option>> allLabelOptions()
    {
        Map<String, List<Option>> options = staticOptionsByExternalGroup();
        mergeDynamicOptions(options, commonOptionMapper.selectAllOptions(), true);
        return options;
    }

    private Map<String, List<Option>> staticOptionsByExternalGroup()
    {
        Map<String, List<Option>> options = new LinkedHashMap<>();
        for (Map.Entry<String, List<Option>> entry : GROUPS.entrySet())
        {
            options.put(externalGroupKey(entry.getKey()), new ArrayList<>(entry.getValue()));
        }
        return options;
    }

    private void mergeDynamicOptions(Map<String, List<Option>> options, List<CupidCommonOptionValue> rows,
            boolean includeDisabled)
    {
        for (CupidCommonOptionValue row : rows)
        {
            String groupKey = row.getGroupKey();
            if (!includeDisabled && "disabled".equals(row.getGroupStatus()))
            {
                options.remove(groupKey);
                continue;
            }

            List<Option> groupOptions = options.computeIfAbsent(groupKey, key -> new ArrayList<>());
            removeOption(groupOptions, row.getOptionValue());
            if (includeDisabled || "enabled".equals(row.getStatus()))
            {
                groupOptions.add(option(
                        row.getOptionValue(),
                        row.getLabelZh(),
                        row.getLabelFr(),
                        row.getLabelEn(),
                        row.getRequiresExtraText() != null && row.getRequiresExtraText() == 1));
            }
        }
    }

    private void removeOption(List<Option> options, String value)
    {
        options.removeIf(option -> option.value().equals(value));
    }

    private static String externalGroupKey(String group)
    {
        if (!StringUtils.hasText(group) || group.contains("."))
        {
            return group;
        }
        return PROFILE_GROUP_PREFIX + group;
    }

    private static void put(String group, Option... options)
    {
        List<Option> list = new ArrayList<>();
        for (Option option : options)
        {
            list.add(option);
        }
        GROUPS.put(group, list);
    }

    private static Option option(String value, String zh, String fr, String en, boolean requiresExtraText)
    {
        return new Option(value, zh, fr, en, requiresExtraText);
    }

    private static String normalizeLocale(String locale)
    {
        if ("fr".equalsIgnoreCase(locale))
        {
            return "fr";
        }
        if ("en".equalsIgnoreCase(locale))
        {
            return "en";
        }
        return "zh";
    }

    private record Option(String value, String zh, String fr, String en, boolean requiresExtraText)
    {
        Map<String, Object> toMap(String locale)
        {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("value", value);
            map.put("label", label(locale));
            if (requiresExtraText)
            {
                map.put("requiresExtraText", true);
            }
            return map;
        }

        String label(String locale)
        {
            return switch (locale)
            {
                case "fr" -> fr;
                case "en" -> en;
                default -> zh;
            };
        }
    }
}
