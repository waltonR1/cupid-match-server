package com.ruoyi.cupid.service.impl;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.ruoyi.cupid.service.ICupidCommonOptionService;

/**
 * Cupid Match 通用可选项服务实现。
 *
 * <p>8.2.4.1 阶段先使用后端代码常量维护 options；动态管理放到后续阶段。</p>
 */
@Service
public class CupidCommonOptionServiceImpl implements ICupidCommonOptionService
{
    private static final String VERSION = "2026-06-25-common-options-v7";
    private static final String PROFILE_GROUP_PREFIX = "profile.";

    private static final Map<String, List<Option>> GROUPS = new LinkedHashMap<>();

    static
    {
        put("city",
                option("FR:paris", "巴黎", "Paris", "Paris", false),
                option("FR:lyon", "里昂", "Lyon", "Lyon", false),
                option("FR:nice", "尼斯", "Nice", "Nice", false),
                option("FR:marseille", "马赛", "Marseille", "Marseille", false),
                option("CN:shanghai", "上海", "Shanghai", "Shanghai", false),
                option("CN:beijing", "北京", "Beijing", "Beijing", false),
                option("CH:geneva", "日内瓦", "Geneve", "Geneva", false),
                option("BE:brussels", "布鲁塞尔", "Bruxelles", "Brussels", false),
                option("NL:amsterdam", "阿姆斯特丹", "Amsterdam", "Amsterdam", false));
        put("country",
                option("FR", "法国", "France", "France", false),
                option("CN", "中国", "Chine", "China", false),
                option("US", "美国", "Etats-Unis", "United States", false),
                option("CH", "瑞士", "Suisse", "Switzerland", false),
                option("NL", "荷兰", "Pays-Bas", "Netherlands", false));
        put("nationality",
                option("FR", "法国", "France", "France", false),
                option("CN", "中国", "Chine", "China", false),
                option("US", "美国", "Etats-Unis", "United States", false),
                option("CH", "瑞士", "Suisse", "Switzerland", false),
                option("NL", "荷兰", "Pays-Bas", "Netherlands", false));
        put("languages",
                option("ZH", "中文", "Chinois", "Chinese", false),
                option("EN", "英语", "Anglais", "English", false),
                option("FR", "法语", "Francais", "French", false),
                option("ES", "西班牙语", "Espagnol", "Spanish", false),
                option("AR", "阿拉伯语", "Arabe", "Arabic", false),
                option("PT", "葡萄牙语", "Portugais", "Portuguese", false),
                option("RU", "俄语", "Russe", "Russian", false),
                option("DE", "德语", "Allemand", "German", false),
                option("JA", "日语", "Japonais", "Japanese", false),
                option("KO", "韩语", "Coreen", "Korean", false),
                option("HI", "印地语", "Hindi", "Hindi", false),
                option("IT", "意大利语", "Italien", "Italian", false),
                option("NL", "荷兰语", "Neerlandais", "Dutch", false),
                option("TR", "土耳其语", "Turc", "Turkish", false),
                option("VI", "越南语", "Vietnamien", "Vietnamese", false),
                option("TH", "泰语", "Thai", "Thai", false),
                option("PL", "波兰语", "Polonais", "Polish", false),
                option("SV", "瑞典语", "Suedois", "Swedish", false),
                option("EL", "希腊语", "Grec", "Greek", false),
                option("HE", "希伯来语", "Hebreu", "Hebrew", false),
                option("ID", "印尼语", "Indonesien", "Indonesian", false),
                option("MS", "马来语", "Malais", "Malay", false),
                option("BN", "孟加拉语", "Bengali", "Bengali", false),
                option("FA", "波斯语", "Persan", "Persian", false),
                option("UR", "乌尔都语", "Ourdou", "Urdu", false),
                option("YUE", "粤语", "Cantonais", "Cantonese", false),
                option("TA", "泰米尔语", "Tamoul", "Tamil", false),
                option("TE", "泰卢固语", "Telougou", "Telugu", false),
                option("MR", "马拉地语", "Marathi", "Marathi", false),
                option("GU", "古吉拉特语", "Gujarati", "Gujarati", false),
                option("PA", "旁遮普语", "Pendjabi", "Punjabi", false),
                option("TL", "他加禄语", "Tagalog", "Tagalog", false),
                option("KM", "高棉语", "Khmer", "Khmer", false),
                option("MY", "缅甸语", "Birman", "Burmese", false),
                option("LO", "老挝语", "Lao", "Lao", false),
                option("MN", "蒙古语", "Mongol", "Mongolian", false),
                option("NE", "尼泊尔语", "Nepalais", "Nepali", false),
                option("SI", "僧伽罗语", "Cinghalais", "Sinhala", false),
                option("AM", "阿姆哈拉语", "Amharique", "Amharic", false),
                option("SW", "斯瓦希里语", "Swahili", "Swahili", false),
                option("RO", "罗马尼亚语", "Roumain", "Romanian", false),
                option("HU", "匈牙利语", "Hongrois", "Hungarian", false),
                option("CS", "捷克语", "Tcheque", "Czech", false),
                option("SK", "斯洛伐克语", "Slovaque", "Slovak", false),
                option("BG", "保加利亚语", "Bulgare", "Bulgarian", false),
                option("SR", "塞尔维亚语", "Serbe", "Serbian", false),
                option("HR", "克罗地亚语", "Croate", "Croatian", false),
                option("UK", "乌克兰语", "Ukrainien", "Ukrainian", false),
                option("NO", "挪威语", "Norvegien", "Norwegian", false),
                option("DA", "丹麦语", "Danois", "Danish", false),
                option("FI", "芬兰语", "Finnois", "Finnish", false),
                option("LT", "立陶宛语", "Lituanien", "Lithuanian", false),
                option("LV", "拉脱维亚语", "Letton", "Latvian", false),
                option("ET", "爱沙尼亚语", "Estonien", "Estonian", false),
                option("SL", "斯洛文尼亚语", "Slovene", "Slovenian", false),
                option("IS", "冰岛语", "Islandais", "Icelandic", false),
                option("CA", "加泰罗尼亚语", "Catalan", "Catalan", false),
                option("HY", "亚美尼亚语", "Armenien", "Armenian", false),
                option("KA", "格鲁吉亚语", "Georgien", "Georgian", false),
                option("AZ", "阿塞拜疆语", "Azerbaidjanais", "Azerbaijani", false),
                option("KK", "哈萨克语", "Kazakh", "Kazakh", false),
                option("UZ", "乌兹别克语", "Ouzbek", "Uzbek", false),
                option("KY", "吉尔吉斯语", "Kirghize", "Kyrgyz", false),
                option("PS", "普什图语", "Pachto", "Pashto", false),
                option("KU", "库尔德语", "Kurde", "Kurdish", false),
                option("HT", "海地克里奥尔语", "Creole haitien", "Haitian Creole", false),
                option("MT", "马耳他语", "Maltais", "Maltese", false),
                option("GA", "爱尔兰语", "Irlandais", "Irish", false),
                option("CY", "威尔士语", "Gallois", "Welsh", false),
                option("ML", "马拉雅拉姆语", "Malayalam", "Malayalam", false),
                option("KN", "卡纳达语", "Kannada", "Kannada", false),
                option("OR", "奥里亚语", "Odia", "Odia", false),
                option("FIL", "菲律宾语", "Philippin", "Filipino", false),
                option("AF", "南非荷兰语", "Afrikaans", "Afrikaans", false),
                option("MI", "毛利语", "Maori", "Maori", false),
                option("MG", "马达加斯加语", "Malgache", "Malagasy", false),
                option("SO", "索马里语", "Somali", "Somali", false),
                option("SM", "萨摩亚语", "Samoan", "Samoan", false),
                option("SD", "信德语", "Sindhi", "Sindhi", false),
                option("TK", "土库曼语", "Turkmene", "Turkmen", false));
        put("education",
                option("bachelor_general", "本科背景", "Licence", "Bachelor background", false),
                option("master_general", "硕士及以上", "Master ou plus", "Master or above", false),
                option("other", "其他", "Autre", "Other", true));
        put("industry",
                option("finance", "金融", "Finance", "Finance", false),
                option("technology", "科技", "Technologie", "Technology", false),
                option("education", "教育", "Education", "Education", false),
                option("other", "其他", "Autre", "Other", true));
        put("relationshipGoal",
                option("long_term", "长期关系", "Relation durable", "Long-term relationship", false),
                option("marriage_oriented", "以婚姻为目标", "Projet de mariage", "Marriage oriented", false),
                option("other", "其他", "Autre", "Other", true));
        put("residencePlan",
                option("current_city", "留在当前城市", "Rester dans la ville actuelle", "Stay in current city", false),
                option("open_to_move", "愿意共同规划城市", "Ouvert a definir une ville commune", "Open to planning a shared city", false),
                option("other", "其他", "Autre", "Other", true));
        put("preferredEducation",
                option("bachelor_or_above", "本科及以上", "Licence ou plus", "Bachelor or above", false),
                option("master_or_above", "硕士及以上", "Master ou plus", "Master or above", false),
                option("other", "其他", "Autre", "Other", true));
        put("familyLife",
                option("open_to_discuss", "愿意沟通家庭规划", "Ouvert a discuter", "Open to discuss", false),
                option("clear_plan", "有明确家庭规划", "Projet familial clair", "Clear family plan", false),
                option("other", "其他", "Autre", "Other", true));
        put("exercise",
                option("regular", "规律运动", "Activite reguliere", "Regular exercise", false),
                option("occasional", "偶尔运动", "Activite occasionnelle", "Occasional exercise", false),
                option("other", "其他", "Autre", "Other", true));

        put("gender",
                option("male", "男", "Homme", "Male", false),
                option("female", "女", "Femme", "Female", false));
        put("degreeLevel",
                option("bachelor", "本科", "Licence", "Bachelor", false),
                option("master", "硕士", "Master", "Master", false),
                option("phd", "博士", "Doctorat", "PhD", false));
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
        put("maritalStatus",
                option("never_married", "未婚", "Jamais marie", "Never married", false),
                option("divorced", "离异", "Divorce", "Divorced", false),
                option("widowed", "丧偶", "Veuf/veuve", "Widowed", false));
        put("childrenPlan",
                option("wants", "希望有孩子", "Souhaite des enfants", "Wants children", false),
                option("open_to_discuss", "愿意沟通", "Ouvert a discuter", "Open to discuss", false),
                option("does_not_want", "不计划要孩子", "Ne souhaite pas d'enfants", "Does not want children", false));
        put("datingIntentionCode",
                option("serious", "认真交往", "Relation serieuse", "Serious relationship", false),
                option("marriage", "以婚姻为目标", "Projet de mariage", "Marriage minded", false),
                option("exclusive", "稳定专一关系", "Relation exclusive", "Exclusive relationship", false),
                option("cross_border", "接受跨境发展", "Ouvert a l'international", "Open to cross-border", false));
        put("relocation",
                option("willing", "愿意", "Oui", "Willing", false),
                option("unwilling", "不愿意", "Non", "Unwilling", false),
                option("open_to_discuss", "可以讨论", "A discuter", "Open to discuss", false));
        put("relationshipValues",
                option("honesty", "诚实", "Honnetete", "Honesty", false),
                option("trust", "信任", "Confiance", "Trust", false),
                option("communication", "沟通", "Communication", "Communication", false),
                option("respect", "尊重", "Respect", "Respect", false),
                option("loyalty", "忠诚", "Loyaute", "Loyalty", false),
                option("family", "家庭", "Famille", "Family", false),
                option("growth", "共同成长", "Croissance commune", "Growth", false),
                option("support", "相互支持", "Soutien mutuel", "Support", false),
                option("humor", "幽默", "Humour", "Humor", false),
                option("ambition", "事业心", "Ambition", "Ambition", false),
                option("kindness", "善良", "Bienveillance", "Kindness", false),
                option("independence", "独立", "Independance", "Independence", false),
                option("romance", "浪漫", "Romance", "Romance", false),
                option("stability", "稳定", "Stabilite", "Stability", false));
        put("preferredLocation",
                option("local", "同城", "Meme ville", "Local", false),
                option("regional", "同区域", "Region", "Regional", false),
                option("national", "全国", "National", "National", false),
                option("international", "不限", "International", "International", false));
        put("smoking",
                option("never", "从不", "Jamais", "Never", false),
                option("social", "社交场合", "Occasionnel", "Socially", false),
                option("often", "经常", "Souvent", "Often", false));
        put("drinking",
                option("never", "从不", "Jamais", "Never", false),
                option("social", "社交场合", "Occasionnel", "Socially", false),
                option("often", "经常", "Souvent", "Often", false));
        put("activityLevel",
                option("low", "低", "Faible", "Low", false),
                option("moderate", "中等", "Modere", "Moderate", false),
                option("high", "高", "Eleve", "High", false));
        put("weekendStyle",
                option("outdoors", "户外", "Exterieur", "Outdoors", false),
                option("indoors", "宅家", "Interieur", "Indoors", false),
                option("social", "社交聚会", "Social", "Social", false),
                option("flexible", "看心情", "Flexible", "Flexible", false));
        put("pets",
                option("has", "有宠物", "A des animaux", "Has pets", false),
                option("none", "不养", "Pas d'animaux", "No pets", false),
                option("likes", "喜欢但不养", "Aime sans en avoir", "Likes pets", false));
        put("communicationStyle",
                option("direct", "直接", "Direct", "Direct", false),
                option("indirect", "委婉", "Indirect", "Indirect", false),
                option("balanced", "看情况", "Equilibre", "Balanced", false));
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
        result.put("version", VERSION);
        if (VERSION.equals(clientVersion))
        {
            result.put("unchanged", true);
            return result;
        }

        String loc = normalizeLocale(locale);
        Map<String, Object> groups = new LinkedHashMap<>();
        for (Map.Entry<String, List<Option>> entry : GROUPS.entrySet())
        {
            List<Map<String, Object>> options = new ArrayList<>();
            for (Option option : entry.getValue())
            {
                options.add(option.toMap(loc));
            }
            String group = entry.getKey().contains(".") ? entry.getKey() : PROFILE_GROUP_PREFIX + entry.getKey();
            groups.put(group, options);
        }
        result.put("unchanged", false);
        result.put("groups", groups);
        return result;
    }

    @Override
    public String label(String group, String value, String locale)
    {
        if (!StringUtils.hasText(value))
        {
            return "";
        }
        List<Option> options = GROUPS.get(group);
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
