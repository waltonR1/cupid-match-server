package com.ruoyi.cupid.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.cupid.domain.CupidAuthIdentity;
import com.ruoyi.cupid.domain.CupidUser;
import com.ruoyi.cupid.domain.CupidUserMembership;

/**
 * Cupid Match 用户认证数据层
 */
public interface CupidAuthMapper
{
    /**
     * 根据认证方式和登录标识查询认证身份
     */
    CupidAuthIdentity selectIdentityByProviderAndIdentifier(@Param("provider") String provider,
            @Param("identifier") String identifier);

    /**
     * 根据ID查询前台用户
     */
    CupidUser selectUserById(@Param("id") String id);

    /**
     * 查询用户当前有效会员记录
     */
    CupidUserMembership selectActiveMembershipByUserId(@Param("userId") String userId);

    /**
     * 重新启用已停用用户
     */
    int reactivateUser(@Param("id") String id);

    /**
     * 新增前台用户
     */
    int insertUser(@Param("id") String id, @Param("accountName") String accountName,
            @Param("preferredLocale") String preferredLocale,
            @Param("aliasWordCode") String aliasWordCode, @Param("aliasTag") String aliasTag);

    int countUserAlias(@Param("aliasWordCode") String aliasWordCode, @Param("aliasTag") String aliasTag);

    /**
     * 新增用户认证身份
     */
    int insertIdentity(@Param("id") String id, @Param("userId") String userId,
            @Param("provider") String provider, @Param("identifier") String identifier,
            @Param("passwordHash") String passwordHash);

    /**
     * 新增用户安全设置
     */
    int insertSecuritySettings(@Param("id") String id, @Param("userId") String userId);

    /**
     * 新增用户偏好设置
     */
    int insertPreferences(@Param("id") String id, @Param("userId") String userId,
            @Param("preferredContactChannel") String preferredContactChannel);

    /**
     * 为用户创建免费会员记录
     */
    int insertFreeMembership(@Param("id") String id, @Param("userId") String userId);

    /**
     * 更新认证身份密码
     */
    int updatePassword(@Param("id") String id, @Param("passwordHash") String passwordHash);

    /**
     * 更新用户基本信息
     */
    int updateUser(CupidUser user);

    /**
     * 停用用户
     */
    int deactivateUser(@Param("id") String id);

    /**
     * 查询用户全部认证身份
     */
    List<CupidAuthIdentity> selectIdentitiesByUserId(@Param("userId") String userId);

    /**
     * 删除认证身份
     */
    int deleteIdentity(@Param("id") String id);

    /**
     * 统计用户认证身份数量
     */
    int countIdentitiesByUserId(@Param("userId") String userId);

    /**
     * 查询用户安全设置
     */
    java.util.Map<String, Object> selectSecuritySettingsByUserId(@Param("userId") String userId);

    /**
     * 更新用户 MFA 设置
     */
    int updateMfaSettings(@Param("userId") String userId,
            @Param("mfaEnabled") boolean mfaEnabled,
            @Param("mfaMethod") String mfaMethod,
            @Param("mfaIdentityId") String mfaIdentityId);

    /**
     * 查询用户偏好设置
     */
    java.util.Map<String, Object> selectPreferencesByUserId(@Param("userId") String userId);

    /**
     * 新增或更新用户偏好设置
     */
    int upsertPreferences(@Param("id") String id, @Param("userId") String userId,
            @Param("preferredCity") String preferredCity,
            @Param("preferredContactChannel") String preferredContactChannel,
            @Param("staffContactEnabled") boolean staffContactEnabled,
            @Param("familyAssistEnabled") boolean familyAssistEnabled,
            @Param("introductionUpdatesEnabled") boolean introductionUpdatesEnabled,
            @Param("eventRemindersEnabled") boolean eventRemindersEnabled,
            @Param("serviceAnnouncementsEnabled") boolean serviceAnnouncementsEnabled,
            @Param("marketingEmailsEnabled") boolean marketingEmailsEnabled,
            @Param("analyticsConsentEnabled") boolean analyticsConsentEnabled);

    /**
     * 插入安全挑战记录
     */
    int insertSecurityChallenge(@Param("id") String id, @Param("userId") String userId,
            @Param("action") String action, @Param("method") String method,
            @Param("identityId") String identityId,
            @Param("expiresAt") java.util.Date expiresAt);

    /**
     * 查询最新待验证安全挑战
     */
    java.util.Map<String, Object> selectPendingSecurityChallenge(@Param("userId") String userId,
            @Param("action") String action, @Param("identityId") String identityId);

    /**
     * 标记安全挑战已验证并写入一次性令牌
     */
    int verifySecurityChallenge(@Param("id") String id,
            @Param("challengeToken") String challengeToken,
            @Param("expiresAt") java.util.Date expiresAt);

    /**
     * 根据 ID 查询认证身份
     */
    CupidAuthIdentity selectIdentityById(@Param("id") String id);

    /**
     * 消费安全挑战 token
     */
    int consumeSecurityChallenge(@Param("userId") String userId,
            @Param("action") String action,
            @Param("challengeToken") String challengeToken);

    /**
     * 标记过期安全挑战
     */
    int expireSecurityChallenge(@Param("userId") String userId,
            @Param("action") String action,
            @Param("challengeToken") String challengeToken);

    /**
     * 批量标记已超过有效期的安全挑战
     */
    int expireSecurityChallenges(@Param("batchSize") int batchSize);

    /**
     * 统计尚未过期的安全挑战令牌
     */
    int countActiveSecurityChallenges();
}
