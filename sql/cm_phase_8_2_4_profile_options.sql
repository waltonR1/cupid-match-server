-- Phase 8.2.4.1: 将 Profile 枚举字段从多语言文本表收回为稳定 code。
-- 执行前建议备份数据库；本脚本假设 cm_profiles / cm_profile_localized_fields 已存在。

alter table cm_profiles
  add column relationship_goal_code varchar(80) not null default '' comment '关系目标代码；可选值由资料选项接口维护' after industry_code,
  add column residence_plan_code varchar(80) not null default '' comment '居住计划代码；可选值由资料选项接口维护' after relationship_goal_code,
  add column preferred_education_code varchar(80) not null default '' comment '期望学历代码；可选值由资料选项接口维护' after residence_plan_code,
  add column family_life_code varchar(80) not null default '' comment '家庭生活代码；可选值由资料选项接口维护' after preferred_education_code,
  add column exercise_code varchar(80) not null default '' comment '运动习惯代码；可选值由资料选项接口维护' after family_life_code;

create table if not exists cm_profile_option_extra_texts (
  id                 varchar(36)   not null comment '资料枚举其他补充说明ID',
  profile_id         varchar(36)   not null comment '资料ID，关联 cm_profiles.id',
  field_name         varchar(60)   not null comment '字段名称；可选值：education, industry, relationship_goal, residence_plan, preferred_education, family_life, exercise',
  locale             varchar(8)    not null comment '语言；可选值：zh, fr, en',
  value              text          not null comment '补充说明',
  source             varchar(20)   not null default 'manual' comment '来源；可选值：manual, machine',
  provider           varchar(30)   default null comment '翻译提供方；可选值：human, translation_api',
  status             varchar(20)   not null default 'ready' comment '状态；可选值：ready, pending, failed, stale',
  created_at         datetime      not null default current_timestamp comment '创建时间',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_profile_option_extra_text (profile_id, field_name, locale),
  key idx_cm_profile_option_extra_lookup (field_name, locale, status)
) engine=innodb comment='资料枚举其他补充说明';

insert into cm_profile_option_extra_texts (
  id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at
)
select uuid(), profile_id, field_name, locale, value, source, provider, status, created_at, updated_at
from cm_profile_localized_fields
where field_name in ('relationship_goal', 'residence_plan', 'preferred_education', 'family_life', 'exercise')
  and trim(value) <> ''
on duplicate key update
  value = values(value),
  source = values(source),
  provider = values(provider),
  status = values(status),
  updated_at = values(updated_at);

update cm_profiles p
set relationship_goal_code = 'other'
where relationship_goal_code = ''
  and exists (
    select 1 from cm_profile_localized_fields lf
    where lf.profile_id = p.id and lf.field_name = 'relationship_goal' and trim(lf.value) <> ''
  );

update cm_profiles p
set residence_plan_code = 'other'
where residence_plan_code = ''
  and exists (
    select 1 from cm_profile_localized_fields lf
    where lf.profile_id = p.id and lf.field_name = 'residence_plan' and trim(lf.value) <> ''
  );

update cm_profiles p
set preferred_education_code = 'other'
where preferred_education_code = ''
  and exists (
    select 1 from cm_profile_localized_fields lf
    where lf.profile_id = p.id and lf.field_name = 'preferred_education' and trim(lf.value) <> ''
  );

update cm_profiles p
set family_life_code = 'other'
where family_life_code = ''
  and exists (
    select 1 from cm_profile_localized_fields lf
    where lf.profile_id = p.id and lf.field_name = 'family_life' and trim(lf.value) <> ''
  );

update cm_profiles p
set exercise_code = 'other'
where exercise_code = ''
  and exists (
    select 1 from cm_profile_localized_fields lf
    where lf.profile_id = p.id and lf.field_name = 'exercise' and trim(lf.value) <> ''
  );

insert into cm_profile_option_extra_texts (
  id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at
)
select uuid(), profile_id, field_name, locale, value, source, provider, status, created_at, updated_at
from cm_profile_localized_fields
where field_name in ('education', 'industry')
  and trim(value) <> ''
  and exists (
    select 1 from cm_profiles p
    where p.id = cm_profile_localized_fields.profile_id
      and (
        (cm_profile_localized_fields.field_name = 'education' and p.education_code = 'other')
        or (cm_profile_localized_fields.field_name = 'industry' and p.industry_code = 'other')
      )
  )
on duplicate key update
  value = values(value),
  source = values(source),
  provider = values(provider),
  status = values(status),
  updated_at = values(updated_at);

delete from cm_profile_localized_fields
where field_name in (
  'city', 'country', 'nationality', 'education', 'industry',
  'relationship_goal', 'residence_plan', 'preferred_education',
  'family_life', 'exercise'
);

alter table cm_profile_localized_fields
  modify column field_name varchar(60) not null comment '字段名称；可选值：profile_name, career_direction, summary';
