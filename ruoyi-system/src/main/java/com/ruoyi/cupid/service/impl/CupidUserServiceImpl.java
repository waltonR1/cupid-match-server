package com.ruoyi.cupid.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.constant.HttpStatus;
import com.ruoyi.common.exception.cupid.CupidApiException;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.cupid.domain.CupidAuthIdentity;
import com.ruoyi.cupid.domain.CupidUser;
import com.ruoyi.cupid.domain.CupidUserMembership;
import com.ruoyi.cupid.mapper.CupidAuthMapper;
import com.ruoyi.cupid.service.ICupidUserService;

/**
 * Cupid Match 前台用户服务实现
 */
@Service
public class CupidUserServiceImpl implements ICupidUserService
{
    @Autowired
    private CupidAuthMapper authMapper;

    @Override
    public CupidAuthIdentity selectIdentityByProviderAndIdentifier(String provider, String identifier)
    {
        return authMapper.selectIdentityByProviderAndIdentifier(provider, identifier);
    }

    @Override
    public CupidUser selectUserById(String userId)
    {
        return authMapper.selectUserById(userId);
    }

    @Override
    public CupidUserMembership selectActiveMembershipByUserId(String userId)
    {
        return authMapper.selectActiveMembershipByUserId(userId);
    }

    @Override
    public void reactivateUser(String userId)
    {
        authMapper.reactivateUser(userId);
    }

    @Override
    @Transactional
    public void createDefaultAccount(String userId, String identityId, String accountName, String preferredLocale,
            String provider, String identifier, String passwordHash)
    {
        authMapper.insertUser(userId, accountName, preferredLocale);
        authMapper.insertIdentity(identityId, userId, provider, identifier, passwordHash);
        authMapper.insertSecuritySettings(IdUtils.fastUUID(), userId);
        authMapper.insertPreferences(IdUtils.fastUUID(), userId, provider);
        if (authMapper.insertFreeMembership(IdUtils.fastUUID(), userId) != 1)
        {
            throw new CupidApiException(HttpStatus.ERROR, "free_membership_plan_not_found");
        }
    }

    @Override
    public void updatePassword(String identityId, String passwordHash)
    {
        authMapper.updatePassword(identityId, passwordHash);
    }
}
