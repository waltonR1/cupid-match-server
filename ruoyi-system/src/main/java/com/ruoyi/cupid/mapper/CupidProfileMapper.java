package com.ruoyi.cupid.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.cupid.domain.CupidProfile;
import com.ruoyi.cupid.domain.CupidProfileLanguage;
import com.ruoyi.cupid.domain.CupidProfileLocalizedField;
import com.ruoyi.cupid.domain.CupidProfileLocalizedItem;
import com.ruoyi.cupid.domain.CupidProfileOwnership;
import com.ruoyi.cupid.domain.CupidProfilePhoto;
import com.ruoyi.cupid.domain.CupidProfilePrivacyPreference;
import com.ruoyi.cupid.domain.CupidProfileRelationshipValue;
import com.ruoyi.cupid.domain.CupidProfileVerification;
import com.ruoyi.cupid.domain.CupidFavoriteProfile;
import com.ruoyi.cupid.domain.CupidPrivateIntroductionRequest;
import com.ruoyi.cupid.domain.CupidUserEntitlementBalance;

/**
 * Cupid Match 用户资料数据层
 */
public interface CupidProfileMapper
{
    /**
     * 分页查询自助征婚资料目录
     */
    List<CupidProfile> selectSelfDirectoryProfiles(CupidProfile profile);

    /**
     * 统计自助征婚资料目录总数
     */
    int countSelfDirectoryProfiles(CupidProfile profile);

    /**
     * 分页查询家庭征婚资料目录
     */
    List<CupidProfile> selectFamilyDirectoryProfiles(CupidProfile profile);

    /**
     * 统计家庭征婚资料目录总数
     */
    int countFamilyDirectoryProfiles(CupidProfile profile);

    /**
     * 分页查询首页精选资料
     */
    List<CupidProfile> selectFeaturedDirectoryProfiles(CupidProfile profile);

    /**
     * 批量查询指定资料的已审核照片
     */
    List<CupidProfilePhoto> selectApprovedPhotosByProfileIds(@Param("profileIds") List<String> profileIds);

    /**
     * 批量查询指定资料的语言列表
     */
    List<CupidProfileLanguage> selectLanguagesByProfileIds(@Param("profileIds") List<String> profileIds);

    /**
     * 批量查询指定资料的本地化字段
     */
    List<CupidProfileLocalizedField> selectLocalizedFieldsByProfileIds(
            @Param("profileIds") List<String> profileIds,
            @Param("fieldNames") List<String> fieldNames,
            @Param("locale") String locale);

    /**
     * 批量查询指定资料的本地化列表项
     */
    List<CupidProfileLocalizedItem> selectLocalizedItemsByProfileIds(
            @Param("profileIds") List<String> profileIds,
            @Param("fieldNames") List<String> fieldNames,
            @Param("locale") String locale);

    /**
     * 根据ID查询资料
     */
    CupidProfile selectProfileById(@Param("id") String id);

    /**
     * 查询指定资料的已审核照片
     */
    List<CupidProfilePhoto> selectApprovedPhotosByProfileId(@Param("profileId") String profileId);

    /**
     * 查询指定资料的语言列表
     */
    List<CupidProfileLanguage> selectLanguagesByProfileId(@Param("profileId") String profileId);

    /**
     * 查询指定资料的全部本地化字段
     */
    List<CupidProfileLocalizedField> selectAllLocalizedFieldsByProfileId(
            @Param("profileId") String profileId, @Param("locale") String locale);

    /**
     * 查询指定资料的全部本地化列表项
     */
    List<CupidProfileLocalizedItem> selectAllLocalizedItemsByProfileId(
            @Param("profileId") String profileId, @Param("locale") String locale);

    /**
     * 查询指定资料的关系价值观
     */
    List<CupidProfileRelationshipValue> selectRelationshipValuesByProfileId(@Param("profileId") String profileId);

    /**
     * 查询指定资料的认证信息
     */
    CupidProfileVerification selectVerificationByProfileId(@Param("profileId") String profileId);

    /**
     * 查询指定资料的隐私偏好设置
     */
    CupidProfilePrivacyPreference selectPrivacyPreferenceByProfileId(@Param("profileId") String profileId);

    /**
     * 查询用户对指定资料的归属关系
     */
    CupidProfileOwnership selectOwnershipByUserAndProfile(@Param("userId") String userId, @Param("profileId") String profileId);

    /**
     * 自助征婚目录性别筛选面
     */
    List<CupidProfile> selectSelfFacetGender(CupidProfile profile);

    /**
     * 自助征婚目录城市筛选面
     */
    List<CupidProfile> selectSelfFacetCity(CupidProfile profile);

    /**
     * 自助征婚目录学历筛选面
     */
    List<CupidProfile> selectSelfFacetEducation(CupidProfile profile);

    /**
     * 自助征婚目录行业筛选面
     */
    List<CupidProfile> selectSelfFacetIndustry(CupidProfile profile);

    /**
     * 家庭征婚目录性别筛选面
     */
    List<CupidProfile> selectFamilyFacetGender(CupidProfile profile);

    /**
     * 家庭征婚目录城市筛选面
     */
    List<CupidProfile> selectFamilyFacetCity(CupidProfile profile);

    /**
     * 家庭征婚目录学历筛选面
     */
    List<CupidProfile> selectFamilyFacetEducation(CupidProfile profile);

    /**
     * 家庭征婚目录行业筛选面
     */
    List<CupidProfile> selectFamilyFacetIndustry(CupidProfile profile);

    /**
     * 自助征婚目录交友意向筛选面
     */
    List<String> selectSelfDistinctIntentions(CupidProfile profile);

    /**
     * 家庭征婚目录交友意向筛选面
     */
    List<String> selectFamilyDistinctIntentions(CupidProfile profile);

    /**
     * 自助征婚目录语种筛选面
     */
    List<String> selectSelfDistinctLanguages(CupidProfile profile);

    /**
     * 查询用户是否已收藏指定资料
     */
    CupidFavoriteProfile selectFavoriteByUserAndProfile(
            @Param("userId") String userId, @Param("profileId") String profileId);

    /**
     * 查询用户当前权益余额
     */
    CupidUserEntitlementBalance selectCurrentEntitlementBalance(
            @Param("userId") String userId, @Param("entitlementCode") String entitlementCode);

    /**
     * 查询用户对指定资料最近一次私人介绍请求
     */
    CupidPrivateIntroductionRequest selectLatestIntroductionRequest(
            @Param("userId") String userId, @Param("profileId") String profileId);
}
