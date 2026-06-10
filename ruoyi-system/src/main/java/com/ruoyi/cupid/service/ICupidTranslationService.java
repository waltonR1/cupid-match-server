package com.ruoyi.cupid.service;

import java.util.List;

/**
 * Cupid Match 翻译服务
 */
public interface ICupidTranslationService
{
    /**
     * 为刚刚保存的本地化字段请求机器翻译。
     * 对 sourceLocale 以外的两种语言，若尚无 ready 值则插入 pending 占位。
     *
     * @param profileId   资料 ID
     * @param sourceLocale 本次编辑使用的语言
     * @param fieldNames  本次保存的字段名列表（snake_case）
     */
    void requestTranslations(String profileId, String sourceLocale, List<String> fieldNames);
}
