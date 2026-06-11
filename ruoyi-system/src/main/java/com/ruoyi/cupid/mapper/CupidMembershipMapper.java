package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.cupid.domain.CupidMembershipPlan;
import com.ruoyi.cupid.domain.CupidUserEntitlementBalance;
import com.ruoyi.cupid.domain.CupidUserMembership;

/**
 * Cupid Match 会员套餐数据层
 */
public interface CupidMembershipMapper
{
    /**
     * 查询全部启用套餐（按 sort_order 排序）
     */
    List<CupidMembershipPlan> selectActivePlans();

    /**
     * 根据 ID 查询套餐，包括已停用套餐
     */
    CupidMembershipPlan selectPlanById(@Param("planId") String planId);

    /**
     * 查询用户最近一条会员记录，用于展示已过期会员
     */
    CupidUserMembership selectLatestMembershipByUserId(@Param("userId") String userId);

    /**
     * 查询当前会员、当前周期的全部权益余额
     */
    List<CupidUserEntitlementBalance> selectCurrentEntitlementBalances(
            @Param("userId") String userId, @Param("membershipId") String membershipId);

    /**
     * 查询套餐本地化名称和描述（按 locale 回退）
     */
    List<Map<String, Object>> selectPlanLocalizedNames(@Param("locale") String locale);

}
