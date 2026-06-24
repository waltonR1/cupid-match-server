-- ----------------------------
-- Cupid Match 业务表结构
-- ----------------------------
-- 本脚本只创建 Cupid Match 产品领域表。
-- RuoYi 的 sys_user、sys_role、sys_menu 等系统表及 Quartz 表保持不变。
--
-- 建模规则：
-- 1. 可查询的事实、状态、时间、归属关系和金额使用普通字段。
-- 2. 多值筛选字段使用关系表。
-- 3. 多语言展示内容使用对应领域的多语言表。
-- 4. JSON 仅用于法律文档章节、消息操作参数和审计快照。
-- 5. Cupid Match 实体主键及其引用统一使用 36 字符 UUID。
-- 6. 业务含义放在 tier、slug、type 和 code 等字段中，不写入 ID 前缀。

drop table if exists cm_payments;
drop table if exists cm_orders;
drop table if exists cm_audit_logs;
drop table if exists cm_staff_task_localized_fields;
drop table if exists cm_staff_tasks;
-- 清理旧版冗余员工映射表，当前结构不再创建该表。
drop table if exists cm_staff_members;
drop table if exists cm_inbox_reads;
drop table if exists cm_inbox_messages;
drop table if exists cm_inbox_threads;
drop table if exists cm_private_introduction_requests;
drop table if exists cm_favorite_profiles;
drop table if exists cm_event_registrations;
drop table if exists cm_event_language_codes;
drop table if exists cm_event_relationship_focuses;
drop table if exists cm_event_agenda_item_localized_fields;
drop table if exists cm_event_agenda_items;
drop table if exists cm_event_localized_fields;
drop table if exists cm_events;
drop table if exists cm_user_entitlement_balances;
drop table if exists cm_user_memberships;
drop table if exists cm_membership_plan_localized_fields;
drop table if exists cm_membership_plans;
drop table if exists cm_profile_privacy_preferences;
drop table if exists cm_profile_contacts;
drop table if exists cm_profile_verifications;
drop table if exists cm_profile_verification_materials;
drop table if exists cm_profile_internal_localized_fields;
drop table if exists cm_profile_internal_records;
drop table if exists cm_profile_ownerships;
drop table if exists cm_profile_photos;
drop table if exists cm_profile_localized_items;
drop table if exists cm_profile_option_extra_texts;
drop table if exists cm_profile_localized_fields;
drop table if exists cm_profile_relationship_values;
drop table if exists cm_profile_languages;
drop table if exists cm_profiles;
drop table if exists cm_user_agreement_acceptances;
drop table if exists cm_legal_document_contents;
drop table if exists cm_legal_documents;
drop table if exists cm_user_preferences;
drop table if exists cm_user_security_challenges;
drop table if exists cm_user_security_settings;
drop table if exists cm_auth_identities;
drop table if exists cm_users;

-- ----------------------------
-- 账户与认证
-- ----------------------------

create table cm_users (
  id                 varchar(36)   not null comment 'Cupid Match 用户ID',
  account_name       varchar(100)  not null comment '账户显示名称（非唯一）',
  avatar_url         varchar(500)  default '' comment '头像地址',
  preferred_locale   varchar(8)    not null default 'zh' comment '偏好语言；可选值：zh, fr, en',
  status             varchar(20)   not null default 'active' comment 'Cupid Match 用户状态；可选值：active, deactivated, suspended',
  created_at         datetime      not null default current_timestamp comment '创建时间',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_users_status (status)
) engine=innodb comment='Cupid Match 用户';

create table cm_auth_identities (
  id                 varchar(36)   not null comment '认证身份ID',
  user_id            varchar(36)   not null comment '用户ID，关联 cm_users.id',
  provider           varchar(20)   not null comment '身份提供方；可选值：email, phone, wechat, google',
  identifier         varchar(191)  not null comment '登录标识',
  password_hash      varchar(255)  default null comment '基于密码登录的密码哈希',
  verified_at        datetime      default null comment '认证时间',
  created_at         datetime      not null default current_timestamp comment '创建时间',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_auth_provider_identifier (provider, identifier),
  key idx_cm_auth_user_id (user_id)
) engine=innodb comment='认证身份';

create table cm_user_security_settings (
  id                 varchar(36)   not null comment '用户安全设置ID',
  user_id            varchar(36)   not null comment '用户ID，关联 cm_users.id',
  mfa_enabled        tinyint(1)    not null default 0 comment '是否启用多因素认证',
  mfa_method         varchar(20)   default null comment '多因素认证方式；可选值：email, phone',
  mfa_identity_id    varchar(36)   default null comment '多因素认证身份ID，关联 cm_auth_identities.id',
  mfa_enabled_at     datetime      default null comment '多因素认证启用时间',
  last_challenge_at  datetime      default null comment '最后安全挑战时间',
  created_at         datetime      not null default current_timestamp comment '创建时间',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_user_security_user (user_id),
  key idx_cm_user_security_identity (mfa_identity_id)
) engine=innodb comment='用户安全设置';

create table cm_user_security_challenges (
  id                 varchar(36)   not null comment '用户安全挑战ID',
  user_id            varchar(36)   not null comment '用户ID，关联 cm_users.id',
  action             varchar(40)   not null comment '敏感操作类型；可选值：change_password, deactivate_account, export_data, unbind_identity',
  method             varchar(20)   not null comment '验证方式；可选值：email, phone',
  identity_id        varchar(36)   not null comment '认证身份ID，关联 cm_auth_identities.id',
  status             varchar(20)   not null comment '用户安全挑战状态；可选值：pending, verified, expired, consumed',
  challenge_token    varchar(191)  default null comment '敏感操作临时令牌',
  expires_at         datetime      not null comment '过期时间',
  verified_at        datetime      default null comment '认证时间',
  consumed_at        datetime      default null comment '挑战凭证使用时间',
  created_at         datetime      not null default current_timestamp comment '创建时间',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_security_challenge_user (user_id),
  key idx_cm_security_challenge_token (challenge_token),
  key idx_cm_security_challenge_expires (expires_at)
) engine=innodb comment='用户安全挑战';

create table cm_user_preferences (
  id                               varchar(36)  not null comment '用户偏好ID',
  user_id                          varchar(36)  not null comment '用户ID，关联 cm_users.id',
  preferred_city_code              varchar(80)  default null comment '偏好城市代码',
  preferred_contact_channel        varchar(20)  default null comment '偏好联系渠道；可选值：email, phone, wechat',
  staff_contact_enabled            tinyint(1)   not null default 1 comment '是否允许员工联系',
  family_assist_enabled            tinyint(1)   not null default 1 comment '家庭协助功能是否启用',
  introduction_updates_enabled     tinyint(1)   not null default 1 comment '是否接收私人介绍更新',
  event_reminders_enabled          tinyint(1)   not null default 1 comment '是否接收活动提醒',
  service_announcements_enabled    tinyint(1)   not null default 1 comment '是否接收服务公告',
  marketing_emails_enabled         tinyint(1)   not null default 0 comment '是否接收营销邮件',
  analytics_consent_enabled        tinyint(1)   not null default 0 comment '分析数据授权',
  created_at                       datetime     not null default current_timestamp comment '创建时间',
  updated_at                       datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_user_preferences_user (user_id),
  key idx_cm_user_preferences_city (preferred_city_code)
) engine=innodb comment='用户偏好';

create table cm_legal_documents (
  id                 varchar(36)   not null comment '法律文档ID',
  type               varchar(20)   not null comment '法律文档类型；可选值：terms, privacy',
  version            varchar(40)   not null comment '版本',
  status             varchar(20)   not null comment '法律文档状态；可选值：draft, active, archived',
  active_type        varchar(20) generated always as (case when status = 'active' then type else null end) stored comment '生效文档类型',
  effective_at       datetime      not null comment '生效时间',
  created_at         datetime      not null default current_timestamp comment '创建时间',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_legal_type_version (type, version),
  unique key uk_cm_legal_active_type (active_type)
) engine=innodb comment='法律文档';

create table cm_legal_document_contents (
  id                 varchar(36)   not null comment '法律文档内容ID',
  document_id        varchar(36)   not null comment '法律文档ID，关联 cm_legal_documents.id',
  locale             varchar(8)    not null comment '语言；可选值：zh, fr, en',
  title              varchar(255)  not null comment '标题',
  sections           json          not null comment '本地化章节结构',
  created_at         datetime      not null default current_timestamp comment '创建时间',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_legal_content_document_locale (document_id, locale)
) engine=innodb comment='法律文档内容';

create table cm_user_agreement_acceptances (
  id                 varchar(36)   not null comment '用户协议接受记录ID',
  user_id            varchar(36)   not null comment '用户ID，关联 cm_users.id',
  document_type      varchar(20)   not null comment '文档类型；可选值：terms, privacy',
  document_version   varchar(40)   not null comment '文档版本',
  accepted_at        datetime      not null comment '接受时间',
  created_at         datetime      not null default current_timestamp comment '创建时间',
  primary key (id),
  unique key uk_cm_user_agreement_user_type (user_id, document_type)
) engine=innodb comment='用户协议接受记录';

-- ----------------------------
-- 婚恋资料
-- ----------------------------

create table cm_profiles (
  id                       varchar(36)  not null comment '婚恋资料ID',
  profile_type             varchar(20)  not null comment '资料类型；可选值：self, family',
  gender                   varchar(20)  not null comment '性别；可选值：male, female',
  birth_year               int          not null comment '出生年份',
  height                   int          not null comment '身高',
  city_code                varchar(80)  not null comment '城市代码',
  country_code             varchar(80)  not null comment '国家代码',
  nationality_code         varchar(80)  not null comment '国籍代码',
  profile_status           varchar(20)  not null comment '资料状态；可选值：draft, review, open, paused, hidden',
  last_active_at           datetime     not null comment '最后活跃时间',
  family_visible           tinyint(1)   not null default 0 comment '家庭端是否可见',
  degree_level             varchar(20)  not null comment '学历层级；可选值：bachelor, master, phd',
  education_code           varchar(80)  not null comment '教育代码',
  industry_code            varchar(80)  not null comment '行业代码',
  relationship_goal_code   varchar(80)  not null default '' comment '关系目标代码；可选值由资料选项接口维护',
  residence_plan_code      varchar(80)  not null default '' comment '居住计划代码；可选值由资料选项接口维护',
  preferred_education_code varchar(80)  not null default '' comment '期望学历代码；可选值由资料选项接口维护',
  family_life_code         varchar(80)  not null default '' comment '家庭生活代码；可选值由资料选项接口维护',
  exercise_code            varchar(80)  not null default '' comment '运动习惯代码；可选值由资料选项接口维护',
  marital_status           varchar(30)  not null comment '婚姻状态；可选值：never_married, divorced, widowed',
  has_children             tinyint(1)   not null default 0 comment '是否有子女',
  children_plan            varchar(40)  not null comment '子女计划；可选值：wants, open_to_discuss, does_not_want',
  accepts_long_distance    tinyint(1)   not null default 0 comment '是否接受异地关系',
  dating_intention_code    varchar(30)  not null comment '婚恋意向代码；可选值：serious, marriage, exclusive, cross_border',
  relocation               varchar(30)  not null comment '异地迁居意愿；可选值：willing, unwilling, open_to_discuss',
  preferred_age_min        int          not null comment '偏好最小年龄',
  preferred_age_max        int          not null comment '偏好最大年龄',
  preferred_location       varchar(30)  not null comment '偏好地点；可选值：local, regional, national, international',
  smoking                  varchar(20)  not null comment '吸烟；可选值：never, social, often',
  drinking                 varchar(20)  not null comment '饮酒；可选值：never, social, often',
  activity_level           varchar(20)  not null comment '日常活跃程度；可选值：low, moderate, high',
  weekend_style            varchar(20)  not null comment '周末生活方式；可选值：outdoors, indoors, social, flexible',
  pets                     varchar(20)  not null comment '宠物偏好；可选值：has, none, likes',
  communication_style      varchar(20)  not null comment '沟通方式；可选值：direct, indirect, balanced',
  archived_at              datetime     default null comment '归档时间',
  created_at               datetime     not null default current_timestamp comment '创建时间',
  updated_at               datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_profiles_type_status (profile_type, profile_status),
  key idx_cm_profiles_city (city_code),
  key idx_cm_profiles_country (country_code),
  key idx_cm_profiles_industry (industry_code),
  key idx_cm_profiles_degree (degree_level),
  key idx_cm_profiles_last_active (last_active_at),
  key idx_cm_profiles_archived (archived_at)
) engine=innodb comment='婚恋资料';

create table cm_profile_languages (
  profile_id         varchar(36) not null comment '资料ID，关联 cm_profiles.id',
  language_code      varchar(20) not null comment '语言代码',
  primary key (profile_id, language_code),
  key idx_cm_profile_languages_language (language_code)
) engine=innodb comment='资料语言';

create table cm_profile_relationship_values (
  profile_id         varchar(36) not null comment '资料ID，关联 cm_profiles.id',
  value_code         varchar(40) not null comment '值代码',
  primary key (profile_id, value_code),
  key idx_cm_profile_relationship_values_code (value_code)
) engine=innodb comment='资料关系价值观';

create table cm_profile_localized_fields (
  id                 varchar(36)   not null comment '资料多语言字段ID',
  profile_id         varchar(36)   not null comment '资料ID，关联 cm_profiles.id',
  field_name         varchar(60)   not null comment '字段名称；可选值：profile_name, career_direction, summary',
  locale             varchar(8)    not null comment '语言；可选值：zh, fr, en',
  value              text          not null comment '值',
  source             varchar(20)   not null default 'manual' comment '来源；可选值：manual, machine',
  provider           varchar(30)   default null comment '翻译提供方；可选值：human, translation_api',
  status             varchar(20)   not null default 'ready' comment '资料多语言字段状态；可选值：ready, pending, failed, stale',
  created_at         datetime      not null default current_timestamp comment '创建时间',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_profile_localized_field (profile_id, field_name, locale),
  key idx_cm_profile_localized_lookup (field_name, locale, status)
) engine=innodb comment='资料多语言字段';

create table cm_profile_option_extra_texts (
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

create table cm_profile_localized_items (
  id                 varchar(36)   not null comment '资料多语言列表项ID',
  profile_id         varchar(36)   not null comment '资料ID，关联 cm_profiles.id',
  field_name         varchar(60)   not null comment '字段名称；可选值：deal_breakers, personality_traits, interests, tags',
  item_order         int           not null default 0 comment '项目顺序',
  locale             varchar(8)    not null comment '语言；可选值：zh, fr, en',
  value              text          not null comment '值',
  source             varchar(20)   not null default 'manual' comment '来源；可选值：manual, machine',
  provider           varchar(30)   default null comment '翻译提供方；可选值：human, translation_api',
  status             varchar(20)   not null default 'ready' comment '资料多语言列表项状态；可选值：ready, pending, failed, stale',
  created_at         datetime      not null default current_timestamp comment '创建时间',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_profile_localized_item (profile_id, field_name, item_order, locale),
  key idx_cm_profile_localized_items_lookup (field_name, locale, status)
) engine=innodb comment='资料多语言列表项';

create table cm_profile_photos (
  id                 varchar(36)  not null comment '资料照片ID',
  profile_id         varchar(36)  not null comment '资料ID，关联 cm_profiles.id',
  url                varchar(500) not null comment '地址',
  is_primary         tinyint(1)   not null default 0 comment '是否主照片',
  sort_order         int          not null default 0 comment '排序顺序',
  status             varchar(20)  not null comment '资料照片状态；可选值：review, approved, rejected, hidden',
  created_at         datetime     not null default current_timestamp comment '创建时间',
  updated_at         datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_profile_photos_profile (profile_id),
  key idx_cm_profile_photos_status (status)
) engine=innodb comment='资料照片';

create table cm_profile_ownerships (
  id                       varchar(36) not null comment '资料归属关系ID',
  user_id                  varchar(36) not null comment '用户ID，关联 cm_users.id',
  profile_id               varchar(36) not null comment '资料ID，关联 cm_profiles.id',
  relationship_to_profile  varchar(20) not null comment '与资料主体的关系；可选值：self, father, mother, relative',
  permission               varchar(20) not null comment '权限；可选值：owner, manager',
  status                   varchar(20) not null comment '资料归属关系状态；可选值：pending, active, revoked',
  invited_by_user_id       varchar(36) default null comment '邀请人用户ID，关联 cm_users.id',
  accepted_at              datetime    default null comment '接受时间',
  revoked_at               datetime    default null comment '撤销时间',
  created_at               datetime    not null default current_timestamp comment '创建时间',
  updated_at               datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_profile_ownerships_user (user_id),
  key idx_cm_profile_ownerships_profile (profile_id)
) engine=innodb comment='资料归属关系';

create table cm_profile_internal_records (
  id                 varchar(36) not null comment '资料内部记录ID',
  profile_id         varchar(36) not null comment '资料ID，关联 cm_profiles.id',
  is_featured        tinyint(1)  not null default 0 comment '是否精选',
  source             varchar(30) default null comment '内部记录来源，预留给资料采集或自动精选流程；可选值：self_submitted, family_submitted, staff_collected',
  updated_by_user_id varchar(36) default null comment '更新人用户ID（用户操作人保存 cm_users.id，后台操作人保存 sys_user.user_id 字符串）',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_profile_internal_profile (profile_id),
  key idx_cm_profile_internal_featured (is_featured)
) engine=innodb comment='资料内部记录';

create table cm_profile_internal_localized_fields (
  id                 varchar(36) not null comment '资料内部多语言字段ID',
  internal_record_id varchar(36) not null comment '内部记录ID，关联 cm_profile_internal_records.id',
  field_name         varchar(60) not null comment '字段名称；可选值：employer, income_range, staff_notes',
  locale             varchar(8)  not null comment '语言；可选值：zh, fr, en',
  value              text        not null comment '值',
  source             varchar(20) not null default 'manual' comment '来源；可选值：manual, machine',
  provider           varchar(30) default null comment '翻译提供方；可选值：human, translation_api',
  status             varchar(20) not null default 'ready' comment '资料内部多语言字段状态；可选值：ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_profile_internal_localized (internal_record_id, field_name, locale)
) engine=innodb comment='资料内部多语言字段';

create table cm_profile_verifications (
  id                  varchar(36)  not null comment '资料认证ID',
  profile_id          varchar(36)  not null comment '资料ID，关联 cm_profiles.id',
  legal_name          varchar(100) default null comment '法定姓名',
  date_of_birth       date         default null comment '出生日期',
  identity_status     varchar(20)  not null default 'unverified' comment '身份状态；可选值：unverified, pending, verified, rejected',
  education_status    varchar(20)  not null default 'unverified' comment '学历认证状态；可选值：unverified, pending, verified, rejected',
  income_status       varchar(20)  not null default 'unverified' comment '收入状态；可选值：unverified, pending, verified, rejected',
  marital_status      varchar(20)  not null default 'unverified' comment '婚姻状态认证结果；可选值：unverified, pending, verified, rejected',
  review_status       varchar(20)  not null default 'unreviewed' comment '审核状态；可选值：unreviewed, pending, approved, rejected',
  verified_at         datetime     default null comment '认证时间',
  verified_by_user_id varchar(36)  default null comment '认证人用户ID（用户操作人保存 cm_users.id，后台操作人保存 sys_user.user_id 字符串）',
  created_at          datetime     not null default current_timestamp comment '创建时间',
  updated_at          datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_profile_verifications_profile (profile_id)
) engine=innodb comment='资料认证';

create table cm_profile_verification_materials (
  id                  varchar(36)  not null comment '认证材料ID',
  profile_id          varchar(36)  not null comment '资料ID，关联 cm_profiles.id',
  material_type       varchar(20)  not null comment '材料类型；可选值：identity, education, income, marital',
  status              varchar(20)  not null default 'pending' comment '材料审核状态；可选值：pending, approved, rejected',
  legal_name          varchar(100) default null comment '法定姓名，仅身份认证使用',
  date_of_birth       date         default null comment '出生日期，仅身份认证使用',
  material_name       varchar(191) default null comment '材料名称',
  material_url        varchar(500) default null comment '材料私有地址或对象Key',
  scan_status         varchar(20)  not null default 'passed' comment '安全检查状态',
  scan_message        varchar(255) default null comment '安全检查说明',
  scanned_at          datetime     default null comment '安全检查时间',
  review_note         varchar(500) default null comment '提交说明',
  submitted_by_user_id varchar(36) not null comment '提交人用户ID，关联 cm_users.id',
  submitted_at        datetime     not null default current_timestamp comment '提交时间',
  reviewed_by_user_id varchar(36)  default null comment '审核人用户ID（后台操作人保存 sys_user.user_id 字符串）',
  reviewed_at         datetime     default null comment '审核时间',
  rejection_reason    varchar(500) default null comment '拒绝原因',
  created_at          datetime     not null default current_timestamp comment '创建时间',
  updated_at          datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_profile_verification_materials_profile (profile_id),
  key idx_cm_profile_verification_materials_status (status, submitted_at),
  key idx_cm_profile_verification_materials_type (material_type, status),
  key idx_cm_profile_verification_materials_scan (scan_status, scanned_at)
) engine=innodb comment='资料认证材料';

create table cm_profile_contacts (
  id                 varchar(36)  not null comment '资料联系方式ID',
  profile_id         varchar(36)  not null comment '资料ID，关联 cm_profiles.id',
  phone              varchar(50)  default null comment '手机号',
  email              varchar(191) default null comment '邮箱',
  wechat             varchar(100) default null comment '微信',
  preferred_channel  varchar(20)  default null comment '偏好联系渠道；可选值：phone, email, wechat',
  visibility         varchar(30)  not null default 'after_introduction' comment '可见范围；可选值：after_introduction, owner_only, disabled',
  created_at         datetime     not null default current_timestamp comment '创建时间',
  updated_at         datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_profile_contacts_profile (profile_id)
) engine=innodb comment='资料联系方式';

create table cm_profile_privacy_preferences (
  id                         varchar(36) not null comment '资料隐私偏好ID',
  profile_id                 varchar(36) not null comment '资料ID，关联 cm_profiles.id',
  hide_marital_status        tinyint(1)  not null default 0 comment '是否隐藏婚姻状态',
  hide_has_children          tinyint(1)  not null default 0 comment '是否隐藏子女情况',
  hide_children_plan         tinyint(1)  not null default 0 comment '是否隐藏子女计划',
  hide_accepts_long_distance tinyint(1)  not null default 0 comment '是否隐藏异地接受意愿',
  hide_smoking               tinyint(1)  not null default 0 comment '是否隐藏吸烟习惯',
  hide_drinking              tinyint(1)  not null default 0 comment '是否隐藏饮酒习惯',
  created_at                 datetime    not null default current_timestamp comment '创建时间',
  updated_at                 datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_profile_privacy_profile (profile_id)
) engine=innodb comment='资料隐私偏好';

-- ----------------------------
-- 会员与权益
-- ----------------------------

create table cm_membership_plans (
  id                            varchar(36)  not null comment '会员套餐ID',
  tier                          varchar(20)  not null comment '等级；可选值：free, silver, gold, diamond',
  price_cents                   int          not null comment '欧元价格（分）',
  currency                      varchar(3)   not null default 'EUR' comment '币种',
  cny_price_cents               int          not null comment '人民币价格（分）',
  billing_type                  varchar(20)  not null comment '计费类型；可选值：free, one_time, recurring',
  billing_period                varchar(20)  default null comment '计费周期；可选值：monthly, quarterly, yearly',
  validity_months               int          default null comment '有效期月数',
  private_introduction_quota    int          not null default 0 comment '私人介绍配额',
  private_introduction_period   varchar(20)  not null comment '私人介绍配额周期；可选值：monthly, quarterly, yearly',
  event_quota                   int          not null default 0 comment '活动报名权益次数',
  event_priority_enabled        tinyint(1)   not null default 0 comment '是否启用活动优先权益',
  staff_review_enabled          tinyint(1)   not null default 0 comment '是否启用人工审核',
  profile_detail_access_level   varchar(20)  not null default 'registered' comment '资料详情访问级别；可选值：registered, premium',
  staff_support_level           varchar(20)  not null default 'none' comment '员工支持级别；可选值：none, standard, priority, concierge',
  concierge_priority            tinyint(1)   not null default 0 comment '是否启用礼宾优先服务',
  featured                      tinyint(1)   not null default 0 comment '是否为推荐套餐',
  sort_order                    int          not null default 0 comment '排序顺序',
  is_active                     tinyint(1)   not null default 1 comment '是否启用',
  created_at                    datetime     not null default current_timestamp comment '创建时间',
  updated_at                    datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_membership_plans_tier (tier),
  key idx_cm_membership_plans_active_sort (is_active, sort_order)
) engine=innodb comment='会员套餐';

create table cm_membership_plan_localized_fields (
  id                 varchar(36) not null comment '会员套餐多语言字段ID',
  plan_id            varchar(36) not null comment '会员套餐ID，关联 cm_membership_plans.id',
  field_name         varchar(60) not null comment '字段名称；可选值：name, description',
  locale             varchar(8)  not null comment '语言；可选值：zh, fr, en',
  value              text        not null comment '值',
  source             varchar(20) not null default 'manual' comment '来源；可选值：manual, machine',
  provider           varchar(30) default null comment '翻译提供方；可选值：human, translation_api',
  status             varchar(20) not null default 'ready' comment '会员套餐多语言字段状态；可选值：ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_plan_localized_field (plan_id, field_name, locale)
) engine=innodb comment='会员套餐多语言字段';

create table cm_user_memberships (
  id                 varchar(36) not null comment '用户会员ID',
  user_id            varchar(36) not null comment '用户ID，关联 cm_users.id',
  plan_id            varchar(36) not null comment '会员套餐ID，关联 cm_membership_plans.id',
  tier               varchar(20) not null comment '等级；可选值：free, silver, gold, diamond',
  status             varchar(20) not null comment '用户会员状态；可选值：active, expired, cancelled, paused',
  started_at         datetime    not null comment '开始时间',
  expires_at         datetime    default null comment '过期时间',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_user_memberships_user_status (user_id, status),
  key idx_cm_user_memberships_plan (plan_id)
) engine=innodb comment='用户会员';

create table cm_user_entitlement_balances (
  id                 varchar(36) not null comment '用户权益余额ID',
  user_id            varchar(36) not null comment '用户ID，关联 cm_users.id',
  membership_id      varchar(36) not null comment '用户会员ID，关联 cm_user_memberships.id',
  entitlement_code   varchar(50) not null comment '权益代码；可选值：private_introduction, event_registration, event_priority, staff_review, profile_detail_access',
  period_started_at  datetime    not null comment '权益周期开始时间',
  period_ends_at     datetime    not null comment '权益周期结束时间',
  quota_total        int         not null default 0 comment '总配额',
  quota_used         int         not null default 0 comment '已用配额',
  quota_remaining    int         not null default 0 comment '剩余配额',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_entitlement_user_code_period (user_id, entitlement_code, period_started_at, period_ends_at),
  key idx_cm_entitlement_membership (membership_id)
) engine=innodb comment='用户权益余额';

-- ----------------------------
-- 活动
-- ----------------------------

create table cm_events (
  id                    varchar(36)  not null comment '活动ID',
  slug                  varchar(120) not null comment '标识',
  status                varchar(20)  not null comment '活动状态；可选值：draft, open, waitlist, closed, completed',
  visibility            varchar(20)  not null comment '可见范围；可选值：public, registered, member',
  consumes_membership_quota tinyint(1) not null default 0 comment '是否消耗会员活动权益',
  city_code             varchar(80)  not null comment '城市代码',
  address_visibility    varchar(40)  not null comment '地址可见范围；可选值：registered_only, confirmed_attendee_only',
  event_date            date         not null comment '活动日期',
  start_time            time         not null comment '开始时间',
  end_time              time         not null comment '结束时间',
  capacity              int          not null comment '容量',
  cover_image_url       varchar(500) not null comment '封面图片地址',
  created_at            datetime     not null default current_timestamp comment '创建时间',
  updated_at            datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_events_slug (slug),
  key idx_cm_events_status_date (status, event_date),
  key idx_cm_events_city (city_code),
  key idx_cm_events_visibility (visibility)
) engine=innodb comment='活动';

create table cm_event_localized_fields (
  id                 varchar(36) not null comment '活动多语言字段ID',
  event_id           varchar(36) not null comment '活动ID，关联 cm_events.id',
  field_name         varchar(60) not null comment '字段名称；可选值：title, summary, city, venue, address, format, audience, curator_note',
  locale             varchar(8)  not null comment '语言；可选值：zh, fr, en',
  value              text        not null comment '值',
  source             varchar(20) not null default 'manual' comment '来源；可选值：manual, machine',
  provider           varchar(30) default null comment '翻译提供方；可选值：human, translation_api',
  status             varchar(20) not null default 'ready' comment '活动多语言字段状态；可选值：ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_event_localized_field (event_id, field_name, locale)
) engine=innodb comment='活动多语言字段';

create table cm_event_relationship_focuses (
  id                 varchar(36) not null comment '活动关系主题ID',
  event_id           varchar(36) not null comment '活动ID，关联 cm_events.id',
  focus_order        int         not null default 0 comment '主题顺序',
  locale             varchar(8)  not null comment '语言；可选值：zh, fr, en',
  value              text        not null comment '值',
  source             varchar(20) not null default 'manual' comment '来源；可选值：manual, machine',
  provider           varchar(30) default null comment '翻译提供方；可选值：human, translation_api',
  status             varchar(20) not null default 'ready' comment '活动关系主题状态；可选值：ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_event_focus_locale (event_id, focus_order, locale)
) engine=innodb comment='活动关系主题';

create table cm_event_language_codes (
  event_id           varchar(36) not null comment '活动ID，关联 cm_events.id',
  language_code      varchar(20) not null comment '语言代码',
  primary key (event_id, language_code),
  key idx_cm_event_language_codes_language (language_code)
) engine=innodb comment='活动语言';

create table cm_event_agenda_items (
  id                 varchar(36) not null comment '活动议程项ID',
  event_id           varchar(36) not null comment '活动ID，关联 cm_events.id',
  agenda_time        varchar(20) not null comment '议程时间标签',
  sort_order         int         not null default 0 comment '排序顺序',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_event_agenda_event_sort (event_id, sort_order)
) engine=innodb comment='活动议程项';

create table cm_event_agenda_item_localized_fields (
  id                 varchar(36) not null comment '活动议程项多语言字段ID',
  agenda_item_id     varchar(36) not null comment '议程项ID，关联 cm_event_agenda_items.id',
  field_name         varchar(60) not null comment '字段名称；可选值：title, description',
  locale             varchar(8)  not null comment '语言；可选值：zh, fr, en',
  value              text        not null comment '值',
  source             varchar(20) not null default 'manual' comment '来源；可选值：manual, machine',
  provider           varchar(30) default null comment '翻译提供方；可选值：human, translation_api',
  status             varchar(20) not null default 'ready' comment '活动议程项多语言字段状态；可选值：ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_event_agenda_localized (agenda_item_id, field_name, locale)
) engine=innodb comment='活动议程项多语言字段';

create table cm_event_registrations (
  id                 varchar(36) not null comment '活动报名ID',
  user_id            varchar(36) not null comment '用户ID，关联 cm_users.id',
  event_id           varchar(36) not null comment '活动ID，关联 cm_events.id',
  status             varchar(20) not null comment '活动报名状态；可选值：requested, confirmed, declined, waitlist, cancelled, attended',
  requested_at       datetime    not null comment '申请时间',
  confirmed_at       datetime    default null comment '确认时间',
  declined_at        datetime    default null comment '拒绝时间',
  waitlisted_at      datetime    default null comment '候补时间',
  cancelled_at       datetime    default null comment '取消时间',
  attended_at        datetime    default null comment '出席时间',
  event_quota_consumed_at datetime default null comment '活动权益消耗时间',
  event_quota_released_at datetime default null comment '活动权益返还时间',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_event_registration_user_event (user_id, event_id),
  key idx_cm_event_registration_event_status (event_id, status)
) engine=innodb comment='活动报名';

-- ----------------------------
-- 收藏与私人介绍
-- ----------------------------

create table cm_favorite_profiles (
  id                 varchar(36) not null comment '资料收藏ID',
  user_id            varchar(36) not null comment '用户ID，关联 cm_users.id',
  profile_id         varchar(36) not null comment '资料ID，关联 cm_profiles.id',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_favorite_user_profile (user_id, profile_id),
  key idx_cm_favorite_profile (profile_id)
) engine=innodb comment='资料收藏';

create table cm_private_introduction_requests (
  id                       varchar(36)  not null comment '私人介绍申请ID',
  requester_user_id        varchar(36)  not null comment '申请人用户ID，关联 cm_users.id',
  requester_profile_id     varchar(36)  default null comment '申请人资料ID，关联 cm_profiles.id',
  target_profile_id        varchar(36)  not null comment '目标资料ID，关联 cm_profiles.id',
  status                   varchar(20)  not null comment '私人介绍申请状态；可选值：requested, accepted, declined, cancelled',
  active_target_id         varchar(36) generated always as (case when status in ('requested', 'accepted') then target_profile_id else null end) stored comment '有效目标资料ID，用于限制进行中的重复申请',
  message                  varchar(1000) default null comment '申请留言',
  requested_at             datetime     not null comment '申请时间',
  expires_at               datetime     default null comment '过期时间',
  responded_at             datetime     default null comment '响应时间',
  cooldown_until           datetime     default null comment '冷却截止时间',
  entitlement_balance_id   varchar(36)  default null comment '权益余额ID，关联 cm_user_entitlement_balances.id',
  created_at               datetime     not null default current_timestamp comment '创建时间',
  updated_at               datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_intro_active_pair (requester_user_id, active_target_id),
  key idx_cm_intro_requester_status (requester_user_id, status),
  key idx_cm_intro_target_status (target_profile_id, status),
  key idx_cm_intro_entitlement (entitlement_balance_id)
) engine=innodb comment='私人介绍申请';

-- ----------------------------
-- 收件箱
-- ----------------------------

create table cm_inbox_threads (
  id                 varchar(36) not null comment '收件箱会话ID',
  user_id            varchar(36) not null comment '用户ID，关联 cm_users.id',
  category           varchar(20) not null comment '会话分类；可选值：system, chat',
  subject_type       varchar(40) default null comment '业务对象类型；可选值：profile, event, private_introduction_request, membership, legal_document',
  subject_id         varchar(36) default null comment '业务对象ID',
  status             varchar(20) not null comment '收件箱会话状态；可选值：open, closed, archived',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_inbox_threads_user_status (user_id, status),
  key idx_cm_inbox_threads_subject (subject_type, subject_id)
) engine=innodb comment='收件箱会话';

create table cm_inbox_messages (
  id                 varchar(36)  not null comment '收件箱消息ID',
  thread_id          varchar(36)  not null comment '会话ID，关联 cm_inbox_threads.id',
  sender_type        varchar(20)  not null comment '发送者类型；可选值：system, staff, user',
  sender_user_id     varchar(36)  default null comment '发送者用户ID（用户发送者保存 cm_users.id，后台发送者保存 sys_user.user_id 字符串）',
  message_type       varchar(30)  not null comment '消息类型；可选值：text, system_notice, status_update, action_prompt',
  body               text         not null comment '正文',
  template_code      varchar(80)  default null comment '模板代码',
  template_locale    varchar(8)   default null comment '模板语言；可选值：zh, fr, en',
  action_type        varchar(80)  default null comment '操作类型',
  action_payload     json         default null comment '消息操作参数',
  created_at         datetime     not null default current_timestamp comment '创建时间',
  updated_at         datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_inbox_messages_thread_created (thread_id, created_at)
) engine=innodb comment='收件箱消息';

create table cm_inbox_reads (
  id                 varchar(36) not null comment '收件箱已读记录ID',
  thread_id          varchar(36) not null comment '会话ID，关联 cm_inbox_threads.id',
  user_id            varchar(36) not null comment '用户ID，关联 cm_users.id',
  last_read_at       datetime    not null comment '最后阅读时间',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_inbox_reads_thread_user (thread_id, user_id)
) engine=innodb comment='收件箱已读记录';

-- ----------------------------
-- 后台运营
-- ----------------------------
-- 后台员工直接使用 RuoYi 的 sys_user、角色和权限体系，不进入 cm_users。

create table cm_staff_tasks (
  id                    varchar(36) not null comment '后台任务ID',
  assignee_sys_user_id  bigint(20)  default null comment '负责人若依用户ID，关联 sys_user.user_id',
  subject_type          varchar(40) not null comment '业务对象类型；可选值：user, profile, private_introduction_request, event',
  subject_id            varchar(36) not null comment '业务对象ID',
  status                varchar(20) not null comment '后台任务状态；可选值：open, done, snoozed',
  priority              varchar(20) not null comment '优先级；可选值：low, normal, high',
  due_at                datetime    default null comment '截止时间',
  completed_at          datetime    default null comment '完成时间',
  created_at            datetime    not null default current_timestamp comment '创建时间',
  updated_at            datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_staff_tasks_subject (subject_type, subject_id),
  key idx_cm_staff_tasks_assignee_status (assignee_sys_user_id, status)
) engine=innodb comment='后台任务';

create table cm_staff_task_localized_fields (
  id                 varchar(36) not null comment '后台任务多语言字段ID',
  staff_task_id      varchar(36) not null comment '后台任务ID，关联 cm_staff_tasks.id',
  field_name         varchar(60) not null comment '字段名称；固定值：note',
  locale             varchar(8)  not null comment '语言；可选值：zh, fr, en',
  value              text        not null comment '值',
  source             varchar(20) not null default 'manual' comment '来源；可选值：manual, machine',
  provider           varchar(30) default null comment '翻译提供方；可选值：human, translation_api',
  status             varchar(20) not null default 'ready' comment '后台任务多语言字段状态；可选值：ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  unique key uk_cm_staff_task_localized (staff_task_id, field_name, locale)
) engine=innodb comment='后台任务多语言字段';

-- ----------------------------
-- 审计与支付
-- ----------------------------

create table cm_audit_logs (
  id                 varchar(36)  not null comment '业务审计日志ID',
  actor_type         varchar(20)  not null comment '操作人类型；可选值：user, staff, system',
  actor_user_id      varchar(36)  default null comment '操作人用户ID（用户操作人保存 cm_users.id，后台操作人保存 sys_user.user_id 字符串）',
  subject_type       varchar(50)  not null comment '业务对象类型',
  subject_id         varchar(36)  not null comment '业务对象ID',
  action             varchar(80)  not null comment '操作代码',
  before_data        json         default null comment '变更前快照',
  after_data         json         default null comment '变更后快照',
  reason             varchar(500) default null comment '原因',
  created_at         datetime     not null default current_timestamp comment '创建时间',
  primary key (id),
  key idx_cm_audit_subject (subject_type, subject_id),
  key idx_cm_audit_actor (actor_type, actor_user_id),
  key idx_cm_audit_created (created_at)
) engine=innodb comment='业务审计日志';

create table cm_orders (
  id                 varchar(36) not null comment '订单ID',
  user_id            varchar(36) not null comment '用户ID，关联 cm_users.id',
  plan_id            varchar(36) not null comment '会员套餐ID，关联 cm_membership_plans.id',
  status             varchar(20) not null comment '订单状态；可选值：pending, paid, cancelled, refunded, failed',
  amount_cents       int         not null comment '金额（分）',
  currency           varchar(3)  not null comment '币种；可选值：EUR, USD, CNY',
  created_at         datetime    not null default current_timestamp comment '创建时间',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_orders_user_status (user_id, status),
  key idx_cm_orders_plan (plan_id)
) engine=innodb comment='订单';

create table cm_payments (
  id                   varchar(36)  not null comment '支付记录ID',
  order_id             varchar(36)  not null comment '订单ID，关联 cm_orders.id',
  provider             varchar(30)  not null comment '支付提供方；可选值：stripe, manual',
  provider_payment_id  varchar(191) default null comment '支付服务商交易ID',
  status               varchar(20)  not null comment '支付记录状态；可选值：pending, succeeded, failed, refunded',
  amount_cents         int          not null comment '金额（分）',
  currency             varchar(3)   not null comment '币种；可选值：EUR, USD, CNY',
  paid_at              datetime     default null comment '支付时间',
  created_at           datetime     not null default current_timestamp comment '创建时间',
  updated_at           datetime     not null default current_timestamp on update current_timestamp comment '更新时间',
  primary key (id),
  key idx_cm_payments_order (order_id),
  key idx_cm_payments_provider_payment (provider, provider_payment_id)
) engine=innodb comment='支付记录';
