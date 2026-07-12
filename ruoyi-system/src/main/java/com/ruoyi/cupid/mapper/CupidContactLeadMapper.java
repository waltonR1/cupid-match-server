package com.ruoyi.cupid.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

/**
 * Cupid Match contact lead mapper.
 */
public interface CupidContactLeadMapper
{
    int insertContactLead(@Param("id") String id,
            @Param("source") String source,
            @Param("inquiryType") String inquiryType,
            @Param("name") String name,
            @Param("contactChannel") String contactChannel,
            @Param("contactValue") String contactValue,
            @Param("message") String message);

    List<Map<String, Object>> selectAdminContactLeads(Map<String, Object> params);

    Map<String, Object> selectAdminContactLeadById(@Param("id") String id);

    int updateAdminContactLead(@Param("id") String id,
            @Param("status") String status,
            @Param("handlerSysUserId") String handlerSysUserId,
            @Param("handlerNote") String handlerNote);
}
