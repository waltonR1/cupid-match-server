package com.ruoyi.cupid.support;

import java.security.SecureRandom;
import java.util.Map;
import com.ruoyi.common.utils.StringUtils;

/**
 * C端用户假名工具。
 */
public final class CupidProfileDisplayNameHelper
{
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final char[] LETTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ".toCharArray();

    private static final AliasWord[] WORDS = {
            word("gentle_starlight", "温柔星光", "Gentle Starlight", "Douce lumière"),
            word("quiet_breeze", "静谧微风", "Quiet Breeze", "Brise paisible"),
            word("warm_sunrise", "暖色晨曦", "Warm Sunrise", "Aube douce"),
            word("clear_moonlight", "清澈月光", "Clear Moonlight", "Clair de lune"),
            word("blue_horizon", "蓝色远方", "Blue Horizon", "Horizon bleu"),
            word("soft_rain", "轻柔细雨", "Soft Rain", "Pluie légère"),
            word("forest_echo", "森林回声", "Forest Echo", "Écho forestier"),
            word("ocean_dream", "海洋之梦", "Ocean Dream", "Rêve océanique"),
            word("silver_cloud", "银色云朵", "Silver Cloud", "Nuage argenté"),
            word("spring_path", "春日小径", "Spring Path", "Sentier printanier"),
            word("amber_glow", "琥珀微光", "Amber Glow", "Lueur ambrée"),
            word("calm_river", "安静河流", "Calm River", "Rivière calme")
    };

    private static final Map<String, AliasWord> WORD_INDEX = Map.ofEntries(
            Map.entry("gentle_starlight", WORDS[0]),
            Map.entry("quiet_breeze", WORDS[1]),
            Map.entry("warm_sunrise", WORDS[2]),
            Map.entry("clear_moonlight", WORDS[3]),
            Map.entry("blue_horizon", WORDS[4]),
            Map.entry("soft_rain", WORDS[5]),
            Map.entry("forest_echo", WORDS[6]),
            Map.entry("ocean_dream", WORDS[7]),
            Map.entry("silver_cloud", WORDS[8]),
            Map.entry("spring_path", WORDS[9]),
            Map.entry("amber_glow", WORDS[10]),
            Map.entry("calm_river", WORDS[11])
    );

    private CupidProfileDisplayNameHelper()
    {
    }

    public static String randomWordCode()
    {
        return WORDS[RANDOM.nextInt(WORDS.length)].code();
    }

    public static String randomTag()
    {
        char first = LETTERS[RANDOM.nextInt(LETTERS.length)];
        int number = RANDOM.nextInt(100);
        char last = LETTERS[RANDOM.nextInt(LETTERS.length)];
        return String.format("%c%02d%c", first, number, last);
    }

    public static String displayName(String wordCode, String tag, String locale)
    {
        if (!StringUtils.hasText(wordCode) || !StringUtils.hasText(tag))
        {
            return "";
        }
        AliasWord word = WORD_INDEX.get(wordCode);
        if (word == null)
        {
            return "";
        }
        return word.text(locale) + "·" + tag;
    }

    private static AliasWord word(String code, String zh, String en, String fr)
    {
        return new AliasWord(code, zh, en, fr);
    }

    private record AliasWord(String code, String zh, String en, String fr)
    {
        String text(String locale)
        {
            if ("en".equals(locale))
            {
                return en;
            }
            if ("fr".equals(locale))
            {
                return fr;
            }
            return zh;
        }
    }
}
