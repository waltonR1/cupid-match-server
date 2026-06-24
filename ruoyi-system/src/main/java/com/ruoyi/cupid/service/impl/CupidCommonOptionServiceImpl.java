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
    private static final String VERSION = "2026-06-24-common-options-v1";
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
            groups.put(PROFILE_GROUP_PREFIX + entry.getKey(), options);
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
