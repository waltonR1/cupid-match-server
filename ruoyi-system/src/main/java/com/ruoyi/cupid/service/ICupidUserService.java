package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;
import com.ruoyi.cupid.domain.CupidAuthIdentity;
import com.ruoyi.cupid.domain.CupidUser;
import com.ruoyi.cupid.domain.CupidUserMembership;

/**
 * Cupid Match 前台用户服务
 */
public interface ICupidUserService
{
    CupidAuthIdentity selectIdentityByProviderAndIdentifier(String provider, String identifier);
    CupidUser selectUserById(String userId);
    CupidUserMembership selectActiveMembershipByUserId(String userId);
    void reactivateUser(String userId);
    void createDefaultAccount(String userId, String identityId, String accountName, String preferredLocale,
            String provider, String identifier, String passwordHash);
    void updatePassword(String identityId, String passwordHash);

    /**
     * 更新用户基本信息（accountName、avatarUrl、preferredLocale）
     */
    void updateUser(CupidUser user);

    /**
     * 停用用户
     */
    void deactivateUser(String userId);

    /**
     * 查询用户全部认证身份
     */
    List<CupidAuthIdentity> getIdentities(String userId);

    /**
     * 校验身份绑定请求并返回规范化后的 identifier。
     */
    String validateIdentityBinding(String userId, String provider, String identifier);

    /**
     * 绑定新认证身份
     */
    CupidAuthIdentity bindIdentity(String userId, String provider, String identifier, String code);

    /**
     * 解绑认证身份
     */
    void unbindIdentity(String userId, String identityId);

    /**
     * 查询用户偏好设置
     */
    Map<String, Object> getPreferences(String userId);

    /**
     * 更新用户偏好设置
     */
    void updatePreferences(String userId, Map<String, Object> prefs);

    /**
     * 查询 MFA 状态
     */
    Map<String, Object> getMfaStatus(String userId);

    /**
     * 校验 MFA 启用请求并返回对应认证身份
     */
    CupidAuthIdentity validateMfaEnable(String userId, String method, String identityId);

    /**
     * 启用 MFA
     */
    void enableMfa(String userId, String method, String identityId, String code);

    /**
     * 校验 MFA 禁用请求并返回当前 MFA 认证身份
     */
    CupidAuthIdentity validateMfaDisable(String userId);

    /**
     * 禁用 MFA
     */
    void disableMfa(String userId, String code);

    /**
     * 根据 ID 查询认证身份
     */
    CupidAuthIdentity selectIdentityById(String identityId);
}
