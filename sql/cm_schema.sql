-- ----------------------------
-- Cupid Match business schema
-- ----------------------------
-- This script adds Cupid Match product-domain tables only.
-- RuoYi system tables such as sys_user, sys_role, sys_menu and Quartz tables stay unchanged.
--
-- Modeling rules:
-- 1. Queryable facts, statuses, timestamps, ownership and money are normal columns.
-- 2. Multi-value filter fields use relation tables.
-- 3. Localized display text uses domain-specific localized tables.
-- 4. JSON is reserved for legal document sections, inbox action payloads and audit snapshots.
-- 5. Cupid Match entity primary keys and references use canonical 36-character UUID strings.
-- 6. Business meaning belongs in tier, slug, type and code columns, never in ID prefixes.

drop table if exists cm_payments;
drop table if exists cm_orders;
drop table if exists cm_audit_logs;
drop table if exists cm_staff_task_localized_fields;
drop table if exists cm_staff_tasks;
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
drop table if exists cm_profile_internal_localized_fields;
drop table if exists cm_profile_internal_records;
drop table if exists cm_profile_ownerships;
drop table if exists cm_profile_photos;
drop table if exists cm_profile_localized_items;
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
-- Account and auth
-- ----------------------------

create table cm_users (
  id                 varchar(36)   not null comment 'Business user ID',
  account_name       varchar(100)  not null comment 'Account display name; not unique',
  avatar_url         varchar(500)  default '' comment 'Account avatar URL',
  preferred_locale   varchar(8)    not null default 'zh' comment 'zh, fr, en',
  status             varchar(20)   not null default 'active' comment 'active, deactivated, suspended',
  created_at         datetime      not null default current_timestamp comment 'Create time',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_users_status (status)
) engine=innodb default charset=utf8mb4 comment='Cupid Match users';

create table cm_auth_identities (
  id                 varchar(36)   not null comment 'Identity ID',
  user_id            varchar(36)   not null comment 'cm_users.id',
  provider           varchar(20)   not null comment 'email, phone, wechat, google',
  identifier         varchar(191)  not null comment 'Provider identifier',
  password_hash      varchar(255)  default null comment 'Password hash for password-based identities',
  verified_at        datetime      default null comment 'Verification time',
  created_at         datetime      not null default current_timestamp comment 'Create time',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_auth_provider_identifier (provider, identifier),
  key idx_cm_auth_user_id (user_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match auth identities';

create table cm_user_security_settings (
  id                 varchar(36)   not null comment 'Security setting ID',
  user_id            varchar(36)   not null comment 'cm_users.id',
  mfa_enabled        tinyint(1)    not null default 0 comment 'Whether MFA is enabled',
  mfa_method         varchar(20)   default null comment 'email, phone',
  mfa_identity_id    varchar(36)   default null comment 'cm_auth_identities.id',
  mfa_enabled_at     datetime      default null comment 'MFA enabled time',
  last_challenge_at  datetime      default null comment 'Last challenge time',
  created_at         datetime      not null default current_timestamp comment 'Create time',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_user_security_user (user_id),
  key idx_cm_user_security_identity (mfa_identity_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match user security settings';

create table cm_user_security_challenges (
  id                 varchar(36)   not null comment 'Security challenge ID',
  user_id            varchar(36)   not null comment 'cm_users.id',
  action             varchar(40)   not null comment 'change_password, deactivate_account, export_data, unbind_identity',
  method             varchar(20)   not null comment 'email, phone',
  identity_id        varchar(36)   not null comment 'cm_auth_identities.id',
  status             varchar(20)   not null comment 'pending, verified, expired, consumed',
  challenge_token    varchar(191)  default null comment 'Short-lived sensitive-action token',
  expires_at         datetime      not null comment 'Expiration time',
  verified_at        datetime      default null comment 'Verified time',
  consumed_at        datetime      default null comment 'Consumed time',
  created_at         datetime      not null default current_timestamp comment 'Create time',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_security_challenge_user (user_id),
  key idx_cm_security_challenge_token (challenge_token),
  key idx_cm_security_challenge_expires (expires_at)
) engine=innodb default charset=utf8mb4 comment='Cupid Match sensitive action challenges';

create table cm_user_preferences (
  id                               varchar(36)  not null comment 'Preference ID',
  user_id                          varchar(36)  not null comment 'cm_users.id',
  preferred_city_code              varchar(80)  default null comment 'Preferred city code',
  preferred_contact_channel        varchar(20)  default null comment 'email, phone, wechat',
  staff_contact_enabled            tinyint(1)   not null default 1 comment 'Allow staff contact',
  family_assist_enabled            tinyint(1)   not null default 1 comment 'Enable family assistance',
  introduction_updates_enabled     tinyint(1)   not null default 1 comment 'Receive introduction updates',
  event_reminders_enabled          tinyint(1)   not null default 1 comment 'Receive event reminders',
  service_announcements_enabled    tinyint(1)   not null default 1 comment 'Receive service announcements',
  marketing_emails_enabled         tinyint(1)   not null default 0 comment 'Receive marketing emails',
  analytics_consent_enabled        tinyint(1)   not null default 0 comment 'Analytics consent',
  created_at                       datetime     not null default current_timestamp comment 'Create time',
  updated_at                       datetime     not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_user_preferences_user (user_id),
  key idx_cm_user_preferences_city (preferred_city_code)
) engine=innodb default charset=utf8mb4 comment='Cupid Match user preferences';

create table cm_legal_documents (
  id                 varchar(36)   not null comment 'Legal document ID',
  type               varchar(20)   not null comment 'terms, privacy',
  version            varchar(40)   not null comment 'Global legal version',
  status             varchar(20)   not null comment 'draft, active, archived',
  active_type        varchar(20) generated always as (case when status = 'active' then type else null end) stored comment 'Generated active document uniqueness key',
  effective_at       datetime      not null comment 'Effective time',
  created_at         datetime      not null default current_timestamp comment 'Create time',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_legal_type_version (type, version),
  unique key uk_cm_legal_active_type (active_type)
) engine=innodb default charset=utf8mb4 comment='Cupid Match legal documents';

create table cm_legal_document_contents (
  id                 varchar(36)   not null comment 'Legal content ID',
  document_id        varchar(36)   not null comment 'cm_legal_documents.id',
  locale             varchar(8)    not null comment 'zh, fr, en',
  title              varchar(255)  not null comment 'Localized title',
  sections           json          not null comment 'Localized section structure',
  created_at         datetime      not null default current_timestamp comment 'Create time',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_legal_content_document_locale (document_id, locale)
) engine=innodb default charset=utf8mb4 comment='Cupid Match localized legal document contents';

create table cm_user_agreement_acceptances (
  id                 varchar(36)   not null comment 'Agreement acceptance ID',
  user_id            varchar(36)   not null comment 'cm_users.id',
  document_type      varchar(20)   not null comment 'terms, privacy',
  document_version   varchar(40)   not null comment 'Accepted global legal version',
  accepted_at        datetime      not null comment 'Acceptance time',
  created_at         datetime      not null default current_timestamp comment 'Create time',
  primary key (id),
  unique key uk_cm_user_agreement_user_type (user_id, document_type)
) engine=innodb default charset=utf8mb4 comment='Cupid Match user agreement acceptances';

-- ----------------------------
-- Profiles
-- ----------------------------

create table cm_profiles (
  id                       varchar(36)  not null comment 'Profile ID',
  profile_type             varchar(20)  not null comment 'self, family',
  gender                   varchar(20)  not null comment 'male, female',
  birth_year               int          not null comment 'Birth year',
  height                   int          not null comment 'Height in centimeters',
  city_code                varchar(80)  not null comment 'City code for filtering',
  country_code             varchar(80)  not null comment 'Country code for filtering',
  nationality_code         varchar(80)  not null comment 'Nationality code for filtering',
  profile_status           varchar(20)  not null comment 'draft, review, open, paused, hidden',
  last_active_at           datetime     not null comment 'Last active time',
  family_visible           tinyint(1)   not null default 0 comment 'Visible in family path',
  degree_level             varchar(20)  not null comment 'bachelor, master, phd',
  education_code           varchar(80)  not null comment 'Education code for filtering',
  industry_code            varchar(80)  not null comment 'Industry code for filtering',
  marital_status           varchar(30)  not null comment 'never_married, divorced, widowed',
  has_children             tinyint(1)   not null default 0 comment 'Whether has children',
  children_plan            varchar(40)  not null comment 'wants, open_to_discuss, does_not_want',
  accepts_long_distance    tinyint(1)   not null default 0 comment 'Accepts long distance',
  dating_intention_code    varchar(30)  not null comment 'serious, marriage, exclusive, cross_border',
  relocation               varchar(30)  not null comment 'willing, unwilling, open_to_discuss',
  preferred_age_min        int          not null comment 'Preferred minimum age',
  preferred_age_max        int          not null comment 'Preferred maximum age',
  preferred_location       varchar(30)  not null comment 'local, regional, national, international',
  smoking                  varchar(20)  not null comment 'never, social, often',
  drinking                 varchar(20)  not null comment 'never, social, often',
  activity_level           varchar(20)  not null comment 'low, moderate, high',
  weekend_style            varchar(20)  not null comment 'outdoors, indoors, social, flexible',
  pets                     varchar(20)  not null comment 'has, none, likes',
  communication_style      varchar(20)  not null comment 'direct, indirect, balanced',
  archived_at              datetime     default null comment 'Archive time',
  created_at               datetime     not null default current_timestamp comment 'Create time',
  updated_at               datetime     not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_profiles_type_status (profile_type, profile_status),
  key idx_cm_profiles_city (city_code),
  key idx_cm_profiles_country (country_code),
  key idx_cm_profiles_industry (industry_code),
  key idx_cm_profiles_degree (degree_level),
  key idx_cm_profiles_last_active (last_active_at),
  key idx_cm_profiles_archived (archived_at)
) engine=innodb default charset=utf8mb4 comment='Cupid Match profiles';

create table cm_profile_languages (
  profile_id         varchar(36) not null comment 'cm_profiles.id',
  language_code      varchar(20) not null comment 'Language code',
  primary key (profile_id, language_code),
  key idx_cm_profile_languages_language (language_code)
) engine=innodb default charset=utf8mb4 comment='Cupid Match profile languages';

create table cm_profile_relationship_values (
  profile_id         varchar(36) not null comment 'cm_profiles.id',
  value_code         varchar(40) not null comment 'Relationship value code',
  primary key (profile_id, value_code),
  key idx_cm_profile_relationship_values_code (value_code)
) engine=innodb default charset=utf8mb4 comment='Cupid Match profile relationship values';

create table cm_profile_localized_fields (
  id                 varchar(36)   not null comment 'Localized profile field ID',
  profile_id         varchar(36)   not null comment 'cm_profiles.id',
  field_name         varchar(60)   not null comment 'profile_name, city, country, nationality, education, industry, career_direction, relationship_goal, residence_plan, preferred_education, family_life, exercise, summary',
  locale             varchar(8)    not null comment 'zh, fr, en',
  value              text          not null comment 'Localized value',
  source             varchar(20)   not null default 'manual' comment 'manual, machine',
  provider           varchar(30)   default null comment 'human, translation_api',
  status             varchar(20)   not null default 'ready' comment 'ready, pending, failed, stale',
  created_at         datetime      not null default current_timestamp comment 'Create time',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_profile_localized_field (profile_id, field_name, locale),
  key idx_cm_profile_localized_lookup (field_name, locale, status)
) engine=innodb default charset=utf8mb4 comment='Cupid Match localized profile fields';

create table cm_profile_localized_items (
  id                 varchar(36)   not null comment 'Localized profile list item ID',
  profile_id         varchar(36)   not null comment 'cm_profiles.id',
  field_name         varchar(60)   not null comment 'deal_breakers, personality_traits, interests, tags',
  item_order         int           not null default 0 comment 'Item order',
  locale             varchar(8)    not null comment 'zh, fr, en',
  value              text          not null comment 'Localized item value',
  source             varchar(20)   not null default 'manual' comment 'manual, machine',
  provider           varchar(30)   default null comment 'human, translation_api',
  status             varchar(20)   not null default 'ready' comment 'ready, pending, failed, stale',
  created_at         datetime      not null default current_timestamp comment 'Create time',
  updated_at         datetime      not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_profile_localized_item (profile_id, field_name, item_order, locale),
  key idx_cm_profile_localized_items_lookup (field_name, locale, status)
) engine=innodb default charset=utf8mb4 comment='Cupid Match localized profile list items';

create table cm_profile_photos (
  id                 varchar(36)  not null comment 'Profile photo ID',
  profile_id         varchar(36)  not null comment 'cm_profiles.id',
  url                varchar(500) not null comment 'Photo URL',
  is_primary         tinyint(1)   not null default 0 comment 'Whether primary photo',
  sort_order         int          not null default 0 comment 'Sort order',
  status             varchar(20)  not null comment 'review, approved, hidden',
  created_at         datetime     not null default current_timestamp comment 'Create time',
  updated_at         datetime     not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_profile_photos_profile (profile_id),
  key idx_cm_profile_photos_status (status)
) engine=innodb default charset=utf8mb4 comment='Cupid Match profile photos';

create table cm_profile_ownerships (
  id                       varchar(36) not null comment 'Profile ownership ID',
  user_id                  varchar(36) not null comment 'cm_users.id',
  profile_id               varchar(36) not null comment 'cm_profiles.id',
  relationship_to_profile  varchar(20) not null comment 'self, father, mother, relative',
  permission               varchar(20) not null comment 'owner, manager',
  status                   varchar(20) not null comment 'pending, active, revoked',
  invited_by_user_id       varchar(36) default null comment 'Inviter cm_users.id',
  accepted_at              datetime    default null comment 'Acceptance time',
  revoked_at               datetime    default null comment 'Revocation time',
  created_at               datetime    not null default current_timestamp comment 'Create time',
  updated_at               datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_profile_ownerships_user (user_id),
  key idx_cm_profile_ownerships_profile (profile_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match profile ownerships';

create table cm_profile_internal_records (
  id                 varchar(36) not null comment 'Internal profile record ID',
  profile_id         varchar(36) not null comment 'cm_profiles.id',
  is_featured        tinyint(1)  not null default 0 comment 'Whether featured',
  source             varchar(30) default null comment 'self_submitted, family_submitted, staff_collected',
  updated_by_user_id varchar(36) default null comment 'cm_users.id or staff actor ID',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_profile_internal_profile (profile_id),
  key idx_cm_profile_internal_featured (is_featured)
) engine=innodb default charset=utf8mb4 comment='Cupid Match profile internal records';

create table cm_profile_internal_localized_fields (
  id                 varchar(36) not null comment 'Localized internal profile field ID',
  internal_record_id varchar(36) not null comment 'cm_profile_internal_records.id',
  field_name         varchar(60) not null comment 'employer, income_range, staff_notes',
  locale             varchar(8)  not null comment 'zh, fr, en',
  value              text        not null comment 'Localized value',
  source             varchar(20) not null default 'manual' comment 'manual, machine',
  provider           varchar(30) default null comment 'human, translation_api',
  status             varchar(20) not null default 'ready' comment 'ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_profile_internal_localized (internal_record_id, field_name, locale)
) engine=innodb default charset=utf8mb4 comment='Cupid Match localized internal profile fields';

create table cm_profile_verifications (
  id                  varchar(36)  not null comment 'Profile verification ID',
  profile_id          varchar(36)  not null comment 'cm_profiles.id',
  legal_name          varchar(100) default null comment 'Legal name',
  date_of_birth       date         default null comment 'Verified date of birth',
  identity_status     varchar(20)  not null default 'unverified' comment 'unverified, pending, verified, rejected',
  education_status    varchar(20)  not null default 'unverified' comment 'unverified, pending, verified, rejected',
  income_status       varchar(20)  not null default 'unverified' comment 'unverified, pending, verified, rejected',
  marital_status      varchar(20)  not null default 'unverified' comment 'unverified, pending, verified, rejected',
  review_status       varchar(20)  not null default 'unreviewed' comment 'unreviewed, pending, approved, rejected',
  verified_at         datetime     default null comment 'Verification time',
  verified_by_user_id varchar(36)  default null comment 'Verifier cm_users.id or staff actor ID',
  created_at          datetime     not null default current_timestamp comment 'Create time',
  updated_at          datetime     not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_profile_verifications_profile (profile_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match profile verifications';

create table cm_profile_contacts (
  id                 varchar(36)  not null comment 'Profile contact ID',
  profile_id         varchar(36)  not null comment 'cm_profiles.id',
  phone              varchar(50)  default null comment 'Phone number',
  email              varchar(191) default null comment 'Email',
  wechat             varchar(100) default null comment 'WeChat ID',
  preferred_channel  varchar(20)  default null comment 'phone, email, wechat',
  visibility         varchar(30)  not null default 'after_introduction' comment 'after_introduction, owner_only, disabled',
  created_at         datetime     not null default current_timestamp comment 'Create time',
  updated_at         datetime     not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_profile_contacts_profile (profile_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match profile contacts';

create table cm_profile_privacy_preferences (
  id                         varchar(36) not null comment 'Profile privacy preference ID',
  profile_id                 varchar(36) not null comment 'cm_profiles.id',
  hide_marital_status        tinyint(1)  not null default 0 comment 'Hide marital status',
  hide_has_children          tinyint(1)  not null default 0 comment 'Hide has-children value',
  hide_children_plan         tinyint(1)  not null default 0 comment 'Hide children plan',
  hide_accepts_long_distance tinyint(1)  not null default 0 comment 'Hide long-distance preference',
  hide_smoking               tinyint(1)  not null default 0 comment 'Hide smoking habit',
  hide_drinking              tinyint(1)  not null default 0 comment 'Hide drinking habit',
  created_at                 datetime    not null default current_timestamp comment 'Create time',
  updated_at                 datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_profile_privacy_profile (profile_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match profile privacy preferences';

-- ----------------------------
-- Membership
-- ----------------------------

create table cm_membership_plans (
  id                            varchar(36)  not null comment 'Membership plan UUID',
  tier                          varchar(20)  not null comment 'free, silver, gold, diamond',
  price_cents                   int          default null comment 'Price in cents',
  currency                      varchar(3)   default null comment 'EUR, USD, CNY',
  billing_period                varchar(20)  default null comment 'monthly, quarterly, yearly',
  private_introduction_quota    int          not null default 0 comment 'Private introduction quota',
  private_introduction_period   varchar(20)  not null comment 'monthly, quarterly, yearly',
  event_priority_enabled        tinyint(1)   not null default 0 comment 'Enable event priority',
  staff_review_enabled          tinyint(1)   not null default 0 comment 'Enable staff review',
  profile_detail_access_level   varchar(20)  not null default 'registered' comment 'registered, premium',
  staff_support_level           varchar(20)  not null default 'none' comment 'none, standard, priority, concierge',
  concierge_priority            tinyint(1)   not null default 0 comment 'Enable concierge priority',
  featured                      tinyint(1)   not null default 0 comment 'Featured plan',
  sort_order                    int          not null default 0 comment 'Sort order',
  is_active                     tinyint(1)   not null default 1 comment 'Whether active',
  created_at                    datetime     not null default current_timestamp comment 'Create time',
  updated_at                    datetime     not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_membership_plans_tier (tier),
  key idx_cm_membership_plans_active_sort (is_active, sort_order)
) engine=innodb default charset=utf8mb4 comment='Cupid Match membership plans';

create table cm_membership_plan_localized_fields (
  id                 varchar(36) not null comment 'Localized membership plan field ID',
  plan_id            varchar(36) not null comment 'cm_membership_plans.id',
  field_name         varchar(60) not null comment 'name, description',
  locale             varchar(8)  not null comment 'zh, fr, en',
  value              text        not null comment 'Localized value',
  source             varchar(20) not null default 'manual' comment 'manual, machine',
  provider           varchar(30) default null comment 'human, translation_api',
  status             varchar(20) not null default 'ready' comment 'ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_plan_localized_field (plan_id, field_name, locale)
) engine=innodb default charset=utf8mb4 comment='Cupid Match localized membership plan fields';

create table cm_user_memberships (
  id                 varchar(36) not null comment 'User membership ID',
  user_id            varchar(36) not null comment 'cm_users.id',
  plan_id            varchar(36) not null comment 'cm_membership_plans.id',
  tier               varchar(20) not null comment 'free, silver, gold, diamond',
  status             varchar(20) not null comment 'active, expired, cancelled, paused',
  started_at         datetime    not null comment 'Start time',
  expires_at         datetime    default null comment 'Expiration time',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_user_memberships_user_status (user_id, status),
  key idx_cm_user_memberships_plan (plan_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match user memberships';

create table cm_user_entitlement_balances (
  id                 varchar(36) not null comment 'Entitlement balance ID',
  user_id            varchar(36) not null comment 'cm_users.id',
  membership_id      varchar(36) not null comment 'cm_user_memberships.id',
  entitlement_code   varchar(50) not null comment 'private_introduction, event_priority, staff_review, profile_detail_access',
  period_started_at  datetime    not null comment 'Period start time',
  period_ends_at     datetime    not null comment 'Period end time',
  quota_total        int         not null default 0 comment 'Total quota',
  quota_used         int         not null default 0 comment 'Used quota',
  quota_remaining    int         not null default 0 comment 'Remaining quota',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_entitlement_user_code_period (user_id, entitlement_code, period_started_at, period_ends_at),
  key idx_cm_entitlement_membership (membership_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match user entitlement balances';

-- ----------------------------
-- Events
-- ----------------------------

create table cm_events (
  id                    varchar(36)  not null comment 'Event ID',
  slug                  varchar(120) not null comment 'Event slug',
  status                varchar(20)  not null comment 'draft, open, waitlist, closed, completed',
  visibility            varchar(20)  not null comment 'public, registered, member',
  city_code             varchar(80)  not null comment 'City code for filtering',
  address_visibility    varchar(40)  not null comment 'registered_only, confirmed_attendee_only',
  event_date            date         not null comment 'Event date',
  start_time            time         not null comment 'Start time',
  end_time              time         not null comment 'End time',
  capacity              int          not null comment 'Capacity',
  cover_image_url       varchar(500) not null comment 'Cover image URL',
  created_at            datetime     not null default current_timestamp comment 'Create time',
  updated_at            datetime     not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_events_slug (slug),
  key idx_cm_events_status_date (status, event_date),
  key idx_cm_events_city (city_code),
  key idx_cm_events_visibility (visibility)
) engine=innodb default charset=utf8mb4 comment='Cupid Match events';

create table cm_event_localized_fields (
  id                 varchar(36) not null comment 'Localized event field ID',
  event_id           varchar(36) not null comment 'cm_events.id',
  field_name         varchar(60) not null comment 'title, summary, city, venue, address, format, audience, curator_note',
  locale             varchar(8)  not null comment 'zh, fr, en',
  value              text        not null comment 'Localized value',
  source             varchar(20) not null default 'manual' comment 'manual, machine',
  provider           varchar(30) default null comment 'human, translation_api',
  status             varchar(20) not null default 'ready' comment 'ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_event_localized_field (event_id, field_name, locale)
) engine=innodb default charset=utf8mb4 comment='Cupid Match localized event fields';

create table cm_event_relationship_focuses (
  id                 varchar(36) not null comment 'Event relationship focus ID',
  event_id           varchar(36) not null comment 'cm_events.id',
  focus_order        int         not null default 0 comment 'Focus order',
  locale             varchar(8)  not null comment 'zh, fr, en',
  value              text        not null comment 'Localized focus value',
  source             varchar(20) not null default 'manual' comment 'manual, machine',
  provider           varchar(30) default null comment 'human, translation_api',
  status             varchar(20) not null default 'ready' comment 'ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_event_focus_locale (event_id, focus_order, locale)
) engine=innodb default charset=utf8mb4 comment='Cupid Match localized event relationship focuses';

create table cm_event_language_codes (
  event_id           varchar(36) not null comment 'cm_events.id',
  language_code      varchar(20) not null comment 'Language code',
  primary key (event_id, language_code),
  key idx_cm_event_language_codes_language (language_code)
) engine=innodb default charset=utf8mb4 comment='Cupid Match event language codes';

create table cm_event_agenda_items (
  id                 varchar(36) not null comment 'Event agenda item ID',
  event_id           varchar(36) not null comment 'cm_events.id',
  agenda_time        varchar(20) not null comment 'Agenda time label',
  sort_order         int         not null default 0 comment 'Sort order',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_event_agenda_event_sort (event_id, sort_order)
) engine=innodb default charset=utf8mb4 comment='Cupid Match event agenda items';

create table cm_event_agenda_item_localized_fields (
  id                 varchar(36) not null comment 'Localized agenda item field ID',
  agenda_item_id     varchar(36) not null comment 'cm_event_agenda_items.id',
  field_name         varchar(60) not null comment 'title, description',
  locale             varchar(8)  not null comment 'zh, fr, en',
  value              text        not null comment 'Localized value',
  source             varchar(20) not null default 'manual' comment 'manual, machine',
  provider           varchar(30) default null comment 'human, translation_api',
  status             varchar(20) not null default 'ready' comment 'ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_event_agenda_localized (agenda_item_id, field_name, locale)
) engine=innodb default charset=utf8mb4 comment='Cupid Match localized event agenda item fields';

create table cm_event_registrations (
  id                 varchar(36) not null comment 'Event registration ID',
  user_id            varchar(36) not null comment 'cm_users.id',
  event_id           varchar(36) not null comment 'cm_events.id',
  status             varchar(20) not null comment 'requested, confirmed, declined, waitlist, cancelled, attended',
  requested_at       datetime    not null comment 'Request time',
  confirmed_at       datetime    default null comment 'Confirmation time',
  declined_at        datetime    default null comment 'Decline time',
  waitlisted_at      datetime    default null comment 'Waitlist time',
  cancelled_at       datetime    default null comment 'Cancellation time',
  attended_at        datetime    default null comment 'Attendance time',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_event_registration_user_event (user_id, event_id),
  key idx_cm_event_registration_event_status (event_id, status)
) engine=innodb default charset=utf8mb4 comment='Cupid Match event registrations';

-- ----------------------------
-- Relationship actions
-- ----------------------------

create table cm_favorite_profiles (
  id                 varchar(36) not null comment 'Favorite profile ID',
  user_id            varchar(36) not null comment 'cm_users.id',
  profile_id         varchar(36) not null comment 'cm_profiles.id',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_favorite_user_profile (user_id, profile_id),
  key idx_cm_favorite_profile (profile_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match favorite profiles';

create table cm_private_introduction_requests (
  id                       varchar(36)  not null comment 'Private introduction request ID',
  requester_user_id        varchar(36)  not null comment 'Requester cm_users.id',
  requester_profile_id     varchar(36)  default null comment 'Requester cm_profiles.id',
  target_profile_id        varchar(36)  not null comment 'Target cm_profiles.id',
  status                   varchar(20)  not null comment 'requested, accepted, declined, cancelled',
  active_target_id         varchar(36) generated always as (case when status in ('requested', 'accepted') then target_profile_id else null end) stored comment 'Generated active pair uniqueness key',
  message                  varchar(1000) default null comment 'Requester message',
  requested_at             datetime     not null comment 'Request time',
  expires_at               datetime     default null comment 'Expiration time',
  responded_at             datetime     default null comment 'Response time',
  cooldown_until           datetime     default null comment 'Cooldown time',
  entitlement_balance_id   varchar(36)  default null comment 'cm_user_entitlement_balances.id',
  created_at               datetime     not null default current_timestamp comment 'Create time',
  updated_at               datetime     not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_intro_active_pair (requester_user_id, active_target_id),
  key idx_cm_intro_requester_status (requester_user_id, status),
  key idx_cm_intro_target_status (target_profile_id, status),
  key idx_cm_intro_entitlement (entitlement_balance_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match private introduction requests';

-- ----------------------------
-- Inbox
-- ----------------------------

create table cm_inbox_threads (
  id                 varchar(36) not null comment 'Inbox thread ID',
  user_id            varchar(36) not null comment 'cm_users.id',
  category           varchar(20) not null comment 'system, chat',
  subject_type       varchar(40) default null comment 'profile, event, private_introduction_request, membership, legal_document',
  subject_id         varchar(36) default null comment 'Subject ID',
  status             varchar(20) not null comment 'open, closed, archived',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_inbox_threads_user_status (user_id, status),
  key idx_cm_inbox_threads_subject (subject_type, subject_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match inbox threads';

create table cm_inbox_messages (
  id                 varchar(36)  not null comment 'Inbox message ID',
  thread_id          varchar(36)  not null comment 'cm_inbox_threads.id',
  sender_type        varchar(20)  not null comment 'system, staff, user',
  sender_user_id     varchar(36)  default null comment 'cm_users.id for user senders; sys_user.user_id string for staff senders',
  message_type       varchar(30)  not null comment 'text, system_notice, status_update, action_prompt',
  body               text         not null comment 'Message body',
  template_code      varchar(80)  default null comment 'Template code',
  template_locale    varchar(8)   default null comment 'zh, fr, en',
  action_type        varchar(80)  default null comment 'Action type',
  action_payload     json         default null comment 'Action payload',
  created_at         datetime     not null default current_timestamp comment 'Create time',
  updated_at         datetime     not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_inbox_messages_thread_created (thread_id, created_at)
) engine=innodb default charset=utf8mb4 comment='Cupid Match inbox messages';

create table cm_inbox_reads (
  id                 varchar(36) not null comment 'Inbox read ID',
  thread_id          varchar(36) not null comment 'cm_inbox_threads.id',
  user_id            varchar(36) not null comment 'cm_users.id',
  last_read_at       datetime    not null comment 'Last read time',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_inbox_reads_thread_user (thread_id, user_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match inbox reads';

-- ----------------------------
-- Staff operations
-- ----------------------------
-- Staff users are RuoYi backend accounts. Bridge to sys_user instead of cm_users.

create table cm_staff_members (
  id                 varchar(36) not null comment 'Staff member ID',
  sys_user_id        bigint(20)  not null comment 'RuoYi sys_user.user_id',
  role               varchar(30) not null comment 'admin, operator, reviewer, event_manager, support',
  status             varchar(20) not null comment 'active, paused, revoked',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_staff_members_sys_user (sys_user_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match staff members';

create table cm_staff_tasks (
  id                    varchar(36) not null comment 'Staff task ID',
  assignee_sys_user_id  bigint(20)  default null comment 'Assigned RuoYi sys_user.user_id',
  subject_type          varchar(40) not null comment 'user, profile, private_introduction_request, event',
  subject_id            varchar(36) not null comment 'Subject ID',
  status                varchar(20) not null comment 'open, done, snoozed',
  priority              varchar(20) not null comment 'low, normal, high',
  due_at                datetime    default null comment 'Due time',
  completed_at          datetime    default null comment 'Completed time',
  created_at            datetime    not null default current_timestamp comment 'Create time',
  updated_at            datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_staff_tasks_subject (subject_type, subject_id),
  key idx_cm_staff_tasks_assignee_status (assignee_sys_user_id, status)
) engine=innodb default charset=utf8mb4 comment='Cupid Match staff tasks';

create table cm_staff_task_localized_fields (
  id                 varchar(36) not null comment 'Localized staff task field ID',
  staff_task_id      varchar(36) not null comment 'cm_staff_tasks.id',
  field_name         varchar(60) not null comment 'note',
  locale             varchar(8)  not null comment 'zh, fr, en',
  value              text        not null comment 'Localized value',
  source             varchar(20) not null default 'manual' comment 'manual, machine',
  provider           varchar(30) default null comment 'human, translation_api',
  status             varchar(20) not null default 'ready' comment 'ready, pending, failed, stale',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  unique key uk_cm_staff_task_localized (staff_task_id, field_name, locale)
) engine=innodb default charset=utf8mb4 comment='Cupid Match localized staff task fields';

-- ----------------------------
-- Audit and billing
-- ----------------------------

create table cm_audit_logs (
  id                 varchar(36)  not null comment 'Audit log ID',
  actor_type         varchar(20)  not null comment 'user, staff, system',
  actor_user_id      varchar(36)  default null comment 'cm_users.id for user actor; sys_user.user_id string for staff actor',
  subject_type       varchar(50)  not null comment 'Audited subject type',
  subject_id         varchar(36)  not null comment 'Audited subject ID',
  action             varchar(80)  not null comment 'Action code',
  before_data        json         default null comment 'Before snapshot',
  after_data         json         default null comment 'After snapshot',
  reason             varchar(500) default null comment 'Reason',
  created_at         datetime     not null default current_timestamp comment 'Create time',
  primary key (id),
  key idx_cm_audit_subject (subject_type, subject_id),
  key idx_cm_audit_actor (actor_type, actor_user_id),
  key idx_cm_audit_created (created_at)
) engine=innodb default charset=utf8mb4 comment='Cupid Match audit logs';

create table cm_orders (
  id                 varchar(36) not null comment 'Order ID',
  user_id            varchar(36) not null comment 'cm_users.id',
  plan_id            varchar(36) not null comment 'cm_membership_plans.id',
  status             varchar(20) not null comment 'pending, paid, cancelled, refunded, failed',
  amount_cents       int         not null comment 'Amount in cents',
  currency           varchar(3)  not null comment 'EUR, USD, CNY',
  created_at         datetime    not null default current_timestamp comment 'Create time',
  updated_at         datetime    not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_orders_user_status (user_id, status),
  key idx_cm_orders_plan (plan_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match orders';

create table cm_payments (
  id                   varchar(36)  not null comment 'Payment ID',
  order_id             varchar(36)  not null comment 'cm_orders.id',
  provider             varchar(30)  not null comment 'stripe, manual',
  provider_payment_id  varchar(191) default null comment 'Provider payment ID',
  status               varchar(20)  not null comment 'pending, succeeded, failed, refunded',
  amount_cents         int          not null comment 'Amount in cents',
  currency             varchar(3)   not null comment 'EUR, USD, CNY',
  paid_at              datetime     default null comment 'Paid time',
  created_at           datetime     not null default current_timestamp comment 'Create time',
  updated_at           datetime     not null default current_timestamp on update current_timestamp comment 'Update time',
  primary key (id),
  key idx_cm_payments_order (order_id),
  key idx_cm_payments_provider_payment (provider, provider_payment_id)
) engine=innodb default charset=utf8mb4 comment='Cupid Match payments';
