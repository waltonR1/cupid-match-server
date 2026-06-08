package com.ruoyi.cupid.mapper;

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
            @Param("preferredLocale") String preferredLocale);

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
}
