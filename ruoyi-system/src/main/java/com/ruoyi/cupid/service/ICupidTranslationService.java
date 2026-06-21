package com.ruoyi.cupid.service;

import java.util.List;

/**
 * Cupid Match 翻译服务
 */
public interface ICupidTranslationService
{
    /**
     * 为待机器翻译字段写入 pending 占位。
     * 已有 ready 译文不会被覆盖，pending/failed 可重新置为 pending。
     *
     * @param profileId    资料 ID
     * @param sourceLocale 本次编辑使用的语言
     * @param fieldNames   本次保存的字段名列表（snake_case）
     */
    void prepareTranslations(String profileId, String sourceLocale, List<String> fieldNames);

    /**
     * 为刚刚保存的本地化字段请求机器翻译。
     * 对 sourceLocale 以外的两种语言，若尚无 ready 值则更新 pending 状态。
     *
     * @param profileId   资料 ID
     * @param sourceLocale 本次编辑使用的语言
     * @param fieldNames  本次保存的字段名列表（snake_case）
     */
    void requestTranslations(String profileId, String sourceLocale, List<String> fieldNames);

    /**
     * 为后台内部多语言字段写入 pending 占位。
     * 已有非空译文不会被覆盖，空值、pending、failed 可重新置为 pending。
     *
     * @param internalRecordId 内部记录 ID
     * @param sourceLocale     本次编辑使用的语言
     * @param fieldNames       本次保存的字段名列表（snake_case）
     */
    void prepareInternalTranslations(String internalRecordId, String sourceLocale, List<String> fieldNames);

    /**
     * 为后台内部多语言字段请求机器翻译。
     *
     * @param internalRecordId 内部记录 ID
     * @param sourceLocale     本次编辑使用的语言
     * @param fieldNames       本次保存的字段名列表（snake_case）
     */
    void requestInternalTranslations(String internalRecordId, String sourceLocale, List<String> fieldNames);
}
