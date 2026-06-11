package com.ruoyi.cupid.service;

import java.util.Map;

/**
 * Cupid Match 会员服务
 */
public interface ICupidMembershipService
{
    /**
     * 查询公共会员套餐目录（无需登录）
     */
    Map<String, Object> getCatalog(String locale);

    /**
     * 查询当前用户会员信息（含可升级套餐）
     */
    Map<String, Object> getAccountMembership(String userId, String locale);

    /**
     * 请求升级会员（不创建订单，不修改会员）
     */
    Map<String, Object> requestUpgrade(String userId, String tier);
}
