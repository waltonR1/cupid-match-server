package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.cupid.domain.CupidProfile;
import com.ruoyi.cupid.domain.CupidProfileLanguage;
import com.ruoyi.cupid.domain.CupidProfileLocalizedField;
import com.ruoyi.cupid.domain.CupidProfileLocalizedItem;
import com.ruoyi.cupid.domain.CupidProfileOwnership;
import com.ruoyi.cupid.domain.CupidProfilePhoto;
import com.ruoyi.cupid.domain.CupidProfilePrivacyPreference;
import com.ruoyi.cupid.domain.CupidProfileRelationshipValue;
import com.ruoyi.cupid.domain.CupidProfileContact;
import com.ruoyi.cupid.domain.CupidProfileVerification;
import com.ruoyi.cupid.domain.CupidProfileVerificationMaterial;
import com.ruoyi.cupid.domain.CupidFavoriteProfile;
import com.ruoyi.cupid.domain.CupidPrivateIntroductionRequest;
import com.ruoyi.cupid.domain.CupidUserEntitlementBalance;

/**
 * Cupid Match 用户资料数据层
 */
public interface CupidProfileMapper
{
    List<Map<String, Object>> selectAdminProfileList(Map<String, Object> params);

    Map<String, Object> selectAdminProfileDetail(@Param("profileId") String profileId);

    List<Map<String, Object>> selectAdminLocalizedFieldsByProfileId(@Param("profileId") String profileId);

    List<Map<String, Object>> selectAdminLocalizedItemsByProfileId(@Param("profileId") String profileId);

    List<Map<String, Object>> selectAdminPhotosByProfileId(@Param("profileId") String profileId);

    int updateAdminProfileReviewStatus(@Param("profileId") String profileId, @Param("status") String status);

    List<Map<String, Object>> selectAdminPhotoList(Map<String, Object> params);

    Map<String, Object> selectAdminPhotoDetail(@Param("photoId") String photoId);

    int updateAdminPhotoReviewStatus(@Param("photoId") String photoId, @Param("status") String status);

    List<Map<String, Object>> selectAdminVerificationList(Map<String, Object> params);

    Map<String, Object> selectAdminVerificationDetail(@Param("materialId") String materialId);

    int updateAdminVerificationMaterialStatus(@Param("materialId") String materialId,
            @Param("status") String status,
            @Param("reviewerUserId") String reviewerUserId,
            @Param("rejectionReason") String rejectionReason);

    int updateVerificationStatusByMaterial(@Param("profileId") String profileId,
            @Param("materialType") String materialType,
            @Param("materialStatus") String materialStatus,
            @Param("reviewerUserId") String reviewerUserId);

    int resetVerificationStatusByMaterial(@Param("profileId") String profileId,
            @Param("materialType") String materialType,
            @Param("reviewerUserId") String reviewerUserId);

    int refreshVerificationReviewStatus(@Param("profileId") String profileId);

    int insertAdminAuditLog(@Param("id") String id,
            @Param("actorType") String actorType,
            @Param("actorUserId") String actorUserId,
            @Param("subjectType") String subjectType,
            @Param("subjectId") String subjectId,
            @Param("action") String action,
            @Param("beforeData") String beforeData,
            @Param("afterData") String afterData,
            @Param("reason") String reason);

    List<Map<String, Object>> selectAdminProfileManageList(Map<String, Object> params);

    Map<String, Object> selectAdminProfileManageDetail(@Param("profileId") String profileId);

    Map<String, Object> selectAdminInternalRecordByProfileId(@Param("profileId") String profileId);

    List<Map<String, Object>> selectAdminInternalLocalizedFieldsByProfileId(@Param("profileId") String profileId);

    List<Map<String, Object>> selectAdminInternalLocalizedFieldsByRecordId(@Param("internalRecordId") String internalRecordId);

    int upsertAdminInternalRecord(@Param("id") String id,
            @Param("profileId") String profileId,
            @Param("isFeatured") Integer isFeatured,
            @Param("source") String source,
            @Param("updatedByUserId") String updatedByUserId);

    int upsertAdminInternalLocalizedField(@Param("id") String id,
            @Param("internalRecordId") String internalRecordId,
            @Param("fieldName") String fieldName,
            @Param("locale") String locale,
            @Param("value") String value);

    int upsertAdminInternalLocalizedFieldWithMeta(@Param("id") String id,
            @Param("internalRecordId") String internalRecordId,
            @Param("fieldName") String fieldName,
            @Param("locale") String locale,
            @Param("value") String value,
            @Param("source") String source,
            @Param("provider") String provider,
            @Param("status") String status);

    int upsertPendingAdminInternalLocalizedField(@Param("id") String id,
            @Param("internalRecordId") String internalRecordId,
            @Param("fieldName") String fieldName,
            @Param("locale") String locale);

    int updatePendingAdminInternalLocalizedFieldStatus(
            @Param("internalRecordId") String internalRecordId,
            @Param("fieldName") String fieldName,
            @Param("locale") String locale,
            @Param("status") String status);

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
     * 按资料 ID 集合批量查询资料
     */
    List<CupidProfile> selectProfilesByIds(@Param("profileIds") List<String> profileIds);

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
     * 查询指定资料的认证材料记录
     */
    List<CupidProfileVerificationMaterial> selectVerificationMaterialsByProfileId(@Param("profileId") String profileId);

    /**
     * 新增认证材料
     */
    int insertVerificationMaterial(CupidProfileVerificationMaterial material);

    /**
     * 将指定认证项标记为待审核
     */
    int markVerificationMaterialPending(@Param("profileId") String profileId,
            @Param("materialType") String materialType,
            @Param("legalName") String legalName,
            @Param("dateOfBirth") java.util.Date dateOfBirth,
            @Param("userId") String userId);

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

    int insertFavorite(@Param("id") String id, @Param("userId") String userId, @Param("profileId") String profileId);

    int deleteFavorite(@Param("userId") String userId, @Param("profileId") String profileId);

    List<CupidFavoriteProfile> selectFavoritesByUserId(@Param("userId") String userId);

    int countFavoritesByUserId(@Param("userId") String userId);

    /**
     * 查询用户当前权益余额
     */
    CupidUserEntitlementBalance selectCurrentEntitlementBalance(
            @Param("userId") String userId,
            @Param("membershipId") String membershipId,
            @Param("entitlementCode") String entitlementCode);

    /**
     * 查询用户对指定资料最近一次私人介绍请求
     */
    CupidPrivateIntroductionRequest selectLatestIntroductionRequest(
            @Param("userId") String userId, @Param("profileId") String profileId);

    CupidPrivateIntroductionRequest selectLatestIntroductionRequestForUpdate(
            @Param("userId") String userId, @Param("profileId") String profileId);

    /**
     * 新增私人介绍申请
     */
    int insertIntroductionRequest(@Param("id") String id,
            @Param("requesterUserId") String requesterUserId,
            @Param("targetProfileId") String targetProfileId,
            @Param("status") String status,
            @Param("expiresAt") java.util.Date expiresAt,
            @Param("entitlementBalanceId") String entitlementBalanceId);

    int expireIntroductionRequest(@Param("id") String id);

    int consumeIntroductionEntitlement(@Param("balanceId") String balanceId);

    /**
     * 查询用户发出的全部私人介绍申请
     */
    List<CupidPrivateIntroductionRequest> selectIntroductionsByUserId(
            @Param("userId") String userId);

    /**
     * 根据 ID 查询私人介绍申请
     */
    CupidPrivateIntroductionRequest selectIntroductionRequestById(@Param("id") String id);

    /**
     * 查询用户管理的全部资料归属关系
     */
    List<CupidProfileOwnership> selectOwnershipsByUserId(@Param("userId") String userId);

    /**
     * 按资料 ID 集合查询全部照片（含待审核与隐藏）
     */
    List<CupidProfilePhoto> selectAllPhotosByProfileIds(@Param("profileIds") List<String> profileIds);

    /**
     * 查询指定资料的联系方式
     */
    CupidProfileContact selectContactByProfileId(@Param("profileId") String profileId);
    /**
     * 归档资料（设置 archived_at）
     */
    int archiveProfile(@Param("id") String id);

    /**
     * 统计指定资料的有效私人介绍请求数
     */
    int countActiveIntroductionsByProfileId(@Param("profileId") String profileId);

    /**
     * 新增或更新隐私偏好设置
     */
    int upsertPrivacyPreference(CupidProfilePrivacyPreference pref);

    /**
     * 新增或更新资料联系方式
     */
    int upsertContact(CupidProfileContact contact);

    /**
     * 更新资料主表
     */
    int updateProfile(CupidProfile profile);

    /**
     * 新增资料
     */
    int insertProfile(CupidProfile profile);

    /**
     * 新增资料归属关系
     */
    /**
     * 新增内部记录
     */
    int insertInternalRecord(@Param("id") String id, @Param("profileId") String profileId);

    int insertOwnership(CupidProfileOwnership ownership);

    /**
     * 按资料 ID 删除全部照片
     */
    int deletePhotosByProfileId(@Param("profileId") String profileId);

    /**
     * 按资料 ID 和照片 ID 删除单张照片
     */
    int deletePhotoByProfileAndId(@Param("profileId") String profileId, @Param("id") String id);

    /**
     * 新增照片
     */
    int insertPhoto(CupidProfilePhoto photo);

    /**
     * 更新已有照片
     */
    int upsertPhoto(CupidProfilePhoto photo);

    /**
     * 新增或更新本地化字段
     */
    int upsertLocalizedField(CupidProfileLocalizedField field);

    /**
     * 新增或刷新待机器翻译的本地化字段占位
     */
    int upsertPendingLocalizedField(CupidProfileLocalizedField field);

    /**
     * 更新待机器翻译字段的处理状态
     */
    int updatePendingLocalizedFieldStatus(
            @Param("profileId") String profileId,
            @Param("fieldName") String fieldName,
            @Param("locale") String locale,
            @Param("status") String status);

    /**
     * 新增或更新认证草稿（legalName / dateOfBirth）
     */
    int upsertVerificationDraft(CupidProfileVerification verification);

    /**
     * 按资料 ID 和字段名删除本地化字段
     */
    int deleteLocalizedFieldsByProfileAndField(
            @Param("profileId") String profileId, @Param("fieldName") String fieldName,
            @Param("locale") String locale);

    /**
     * 按资料 ID 和字段名删除本地化列表项
     */
    int deleteLocalizedItemsByProfileAndField(
            @Param("profileId") String profileId, @Param("fieldName") String fieldName,
            @Param("locale") String locale);

    /**
     * 新增本地化列表项
     */
    int insertLocalizedItem(CupidProfileLocalizedItem item);

    /**
     * 按资料 ID 删除全部语言记录
     */
    int deleteLanguagesByProfileId(@Param("profileId") String profileId);

    /**
     * 新增语言记录
     */
    int insertLanguage(@Param("profileId") String profileId, @Param("languageCode") String languageCode);

    /**
     * 按资料 ID 删除全部关系价值观
     */
    int deleteRelationshipValuesByProfileId(@Param("profileId") String profileId);

    /**
     * 新增关系价值观
     */
    int insertRelationshipValue(@Param("profileId") String profileId, @Param("valueCode") String valueCode);

    /**
     * 新增或更新认证信息
     */
    int upsertVerification(CupidProfileVerification verification);

}
