package com.ruoyi.cupid.service;

import com.ruoyi.cupid.domain.CupidAuthIdentity;
import com.ruoyi.cupid.domain.CupidUser;
import com.ruoyi.cupid.domain.CupidUserMembership;

/**
 * Cupid Match 前台用户服务
 */
public interface ICupidUserService
{
    /**
     * 根据认证方式和登录标识查询认证身份
     */
    CupidAuthIdentity selectIdentityByProviderAndIdentifier(String provider, String identifier);

    /**
     * 根据ID查询前台用户
     */
    CupidUser selectUserById(String userId);

    /**
     * 查询用户当前有效会员记录
     */
    CupidUserMembership selectActiveMembershipByUserId(String userId);

    /**
     * 重新启用已停用用户
     */
    void reactivateUser(String userId);

    /**
     * 创建用户及注册所需的默认账户数据
     */
    void createDefaultAccount(String userId, String identityId, String accountName, String preferredLocale,
            String provider, String identifier, String passwordHash);

    /**
     * 更新认证身份密码
     */
    void updatePassword(String identityId, String passwordHash);
}
