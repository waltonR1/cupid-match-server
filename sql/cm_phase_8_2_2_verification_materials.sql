-- Cupid Match Phase 8.2.2 认证材料增量迁移
-- 用途：在不重建数据库的情况下创建认证材料表，并把旧汇总认证状态回填成可查看的材料记录。

create table if not exists cm_profile_verification_materials (
  id                    varchar(36)  not null comment '认证材料ID',
  profile_id            varchar(36)  not null comment '资料ID，关联 cm_profiles.id',
  material_type         varchar(20)  not null comment '材料类型；可选值：identity, education, income, marital',
  status                varchar(20)  not null default 'pending' comment '材料审核状态；可选值：pending, approved, rejected',
  legal_name            varchar(100) default null comment '法定姓名，仅身份认证使用',
  date_of_birth         date         default null comment '出生日期，仅身份认证使用',
  material_name         varchar(191) default null comment '材料名称',
  material_url          varchar(500) default null comment '材料私有地址或对象Key',
  review_note           varchar(500) default null comment '提交说明',
  submitted_by_user_id  varchar(36)  not null comment '提交人用户ID，关联 cm_users.id',
  submitted_at          datetime     not null default current_timestamp comment '提交时间',
  reviewed_by_user_id   varchar(36)  default null comment '审核人用户ID（后台操作人保存 sys_user.user_id 字符串）',
  reviewed_at           datetime     default null comment '审核时间',
  rejection_reason      varchar(500) default null comment '拒绝原因',
  created_at            datetime     not null default current_timestamp comment '创建时间',
  updated_at            datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_profile_verification_materials_profile (profile_id),
  key idx_cm_profile_verification_materials_status (status, submitted_at),
  key idx_cm_profile_verification_materials_type (material_type, status)
) engine=innodb comment='资料认证材料';

insert into cm_profile_verification_materials (
  id, profile_id, material_type, status, legal_name, date_of_birth,
  material_name, material_url, review_note, submitted_by_user_id,
  submitted_at, reviewed_by_user_id, reviewed_at, rejection_reason,
  created_at, updated_at
)
select uuid(), source.profile_id, source.material_type, source.material_status,
       source.legal_name, source.date_of_birth, source.material_name, null,
       '由旧认证汇总状态回填生成。', coalesce(o.user_id, source.verified_by_user_id, 'system'),
       source.updated_at, source.verified_by_user_id,
       case when source.material_status in ('approved', 'rejected') then source.verified_at else null end,
       null, now(), now()
from (
  select profile_id, 'identity' as material_type,
         case identity_status when 'verified' then 'approved' when 'rejected' then 'rejected' else identity_status end as material_status,
         legal_name, date_of_birth, '历史身份认证记录' as material_name,
         verified_by_user_id, verified_at, updated_at
  from cm_profile_verifications
  where identity_status in ('pending', 'verified', 'rejected')
  union all
  select profile_id, 'education',
         case education_status when 'verified' then 'approved' when 'rejected' then 'rejected' else education_status end,
         null, null, '历史学历认证记录', verified_by_user_id, verified_at, updated_at
  from cm_profile_verifications
  where education_status in ('pending', 'verified', 'rejected')
  union all
  select profile_id, 'income',
         case income_status when 'verified' then 'approved' when 'rejected' then 'rejected' else income_status end,
         null, null, '历史收入认证记录', verified_by_user_id, verified_at, updated_at
  from cm_profile_verifications
  where income_status in ('pending', 'verified', 'rejected')
  union all
  select profile_id, 'marital',
         case marital_status when 'verified' then 'approved' when 'rejected' then 'rejected' else marital_status end,
         null, null, '历史婚姻认证记录', verified_by_user_id, verified_at, updated_at
  from cm_profile_verifications
  where marital_status in ('pending', 'verified', 'rejected')
) source
left join cm_profile_ownerships o on o.profile_id = source.profile_id and o.status = 'active'
where not exists (
  select 1
  from cm_profile_verification_materials existing
  where existing.profile_id = source.profile_id
    and existing.material_type = source.material_type
);
