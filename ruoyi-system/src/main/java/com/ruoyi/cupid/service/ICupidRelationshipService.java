package com.ruoyi.cupid.service;

import java.util.List;
import java.util.Map;

/**
 * Cupid Match 收藏与私人介绍服务。
 */
public interface ICupidRelationshipService
{
    Map<String, Object> addFavorite(String userId, String profileId);

    Map<String, Object> removeFavorite(String userId, String profileId);

    List<Map<String, Object>> getFavorites(String userId, String locale);

    Map<String, Object> requestIntroduction(
            String userId, String profileId, String expectedProfileType);

    List<Map<String, Object>> getIntroductions(String userId, String locale);

    Map<String, Object> getIntroductionContact(String userId, String requestId);

    int countFavorites(String userId);
}
