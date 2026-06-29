package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Set;
import com.ruoyi.common.core.domain.model.CupidLoginUser;

public interface ICupidTokenService
{
    void deleteUserTokens(String userId);

    CupidLoginUser selectSession(String sessionId);

    List<CupidLoginUser> selectUserSessions(String userId);

    int countUserSessions(String userId);

    Set<String> selectOnlineUserIds();

    boolean deleteUserSession(String userId, String sessionId);
}
