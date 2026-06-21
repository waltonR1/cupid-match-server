package com.ruoyi.cupid.service.impl;

import java.util.List;
import java.util.Map;
import com.ruoyi.cupid.mapper.CupidProfileMapper;
import com.ruoyi.cupid.service.ICupidProfileLibraryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * Cupid Match 后台资料库只读服务实现
 */
@Service
public class CupidProfileLibraryServiceImpl implements ICupidProfileLibraryService
{
    @Autowired
    private CupidProfileMapper profileMapper;

    @Override
    public List<Map<String, Object>> selectProfileList(Map<String, Object> params)
    {
        return profileMapper.selectAdminProfileList(params);
    }

    @Override
    public Map<String, Object> selectProfileDetail(String profileId)
    {
        Map<String, Object> profile = profileMapper.selectAdminProfileDetail(profileId);
        if (profile != null)
        {
            profile.put("photos", profileMapper.selectApprovedPhotosByProfileId(profileId));
            profile.put("localizedFields", profileMapper.selectAdminLocalizedFieldsByProfileId(profileId));
            profile.put("localizedItems", profileMapper.selectAdminLocalizedItemsByProfileId(profileId));
            profile.put("languages", profileMapper.selectLanguagesByProfileId(profileId));
            profile.put("relationshipValues", profileMapper.selectRelationshipValuesByProfileId(profileId));
            profile.put("privacyPreferences", profileMapper.selectPrivacyPreferenceByProfileId(profileId));
            profile.put("contact", profileMapper.selectContactByProfileId(profileId));
            profile.put("internalRecord", profileMapper.selectAdminInternalRecordByProfileId(profileId));
            profile.put("internalFields", profileMapper.selectAdminInternalLocalizedFieldsByProfileId(profileId));
        }
        return profile;
    }
}
