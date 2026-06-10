-- ----------------------------
-- Cupid Match business schema
-- ----------------------------
-- This script adds Cupid Match product-domain tables only.
-- RuoYi system tables such as sys_user, sys_role, sys_menu and Quartz tables stay unchanged.
--
-- Modeling rules:
-- PostgreSQL compatibility functions
-- ----------------------------

create or replace function find_in_set(str text, strlist text)
returns boolean as $$
declare
    pos integer;
begin
    select position(',' || str || ',' in ',' || strlist || ',') into pos;
    return pos > 0;
end;
$$ language plpgsql immutable;

-- ----------------------------

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
  id                 varchar(36)   not null,
  account_name       varchar(100)  not null,
  avatar_url         varchar(500)  default '',
  preferred_locale   varchar(8)    not null default 'zh',
  status             varchar(20)   not null default 'active',
  created_at         TIMESTAMP      not null default current_timestamp,
  updated_at         TIMESTAMP      not null default current_timestamp,
  primary key (id),
  key idx_cm_users_status (status)
);

create table cm_auth_identities (
  id                 varchar(36)   not null,
  user_id            varchar(36)   not null,
  provider           varchar(20)   not null,
  identifier         varchar(191)  not null,
  password_hash      varchar(255)  default null,
  verified_at        TIMESTAMP      default null,
  created_at         TIMESTAMP      not null default current_timestamp,
  updated_at         TIMESTAMP      not null default current_timestamp,
  primary key (id),
  unique key uk_cm_auth_provider_identifier (provider, identifier),
  key idx_cm_auth_user_id (user_id)
);

create table cm_user_security_settings (
  id                 varchar(36)   not null,
  user_id            varchar(36)   not null,
  mfa_enabled        BOOLEAN    not null default 0,
  mfa_method         varchar(20)   default null,
  mfa_identity_id    varchar(36)   default null,
  mfa_enabled_at     TIMESTAMP      default null,
  last_challenge_at  TIMESTAMP      default null,
  created_at         TIMESTAMP      not null default current_timestamp,
  updated_at         TIMESTAMP      not null default current_timestamp,
  primary key (id),
  unique key uk_cm_user_security_user (user_id),
  key idx_cm_user_security_identity (mfa_identity_id)
);

create table cm_user_security_challenges (
  id                 varchar(36)   not null,
  user_id            varchar(36)   not null,
  action             varchar(40)   not null,
  method             varchar(20)   not null,
  identity_id        varchar(36)   not null,
  status             varchar(20)   not null,
  challenge_token    varchar(191)  default null,
  expires_at         TIMESTAMP      not null,
  verified_at        TIMESTAMP      default null,
  consumed_at        TIMESTAMP      default null,
  created_at         TIMESTAMP      not null default current_timestamp,
  updated_at         TIMESTAMP      not null default current_timestamp,
  primary key (id),
  key idx_cm_security_challenge_user (user_id),
  key idx_cm_security_challenge_token (challenge_token),
  key idx_cm_security_challenge_expires (expires_at)
);

create table cm_user_preferences (
  id                               varchar(36)  not null,
  user_id                          varchar(36)  not null,
  preferred_city_code              varchar(80)  default null,
  preferred_contact_channel        varchar(20)  default null,
  staff_contact_enabled            BOOLEAN   not null default 1,
  family_assist_enabled            BOOLEAN   not null default 1,
  introduction_updates_enabled     BOOLEAN   not null default 1,
  event_reminders_enabled          BOOLEAN   not null default 1,
  service_announcements_enabled    BOOLEAN   not null default 1,
  marketing_emails_enabled         BOOLEAN   not null default 0,
  analytics_consent_enabled        BOOLEAN   not null default 0,
  created_at                       TIMESTAMP     not null default current_timestamp,
  updated_at                       TIMESTAMP     not null default current_timestamp,
  primary key (id),
  unique key uk_cm_user_preferences_user (user_id),
  key idx_cm_user_preferences_city (preferred_city_code)
);

create table cm_legal_documents (
  id                 varchar(36)   not null,
  type               varchar(20)   not null,
  version            varchar(40)   not null,
  status             varchar(20)   not null,
  active_type        varchar(20) generated always as (case when status = 'active' then type else null end) stored,
  effective_at       TIMESTAMP      not null,
  created_at         TIMESTAMP      not null default current_timestamp,
  updated_at         TIMESTAMP      not null default current_timestamp,
  primary key (id),
  unique key uk_cm_legal_type_version (type, version),
  unique key uk_cm_legal_active_type (active_type)
);

create table cm_legal_document_contents (
  id                 varchar(36)   not null,
  document_id        varchar(36)   not null,
  locale             varchar(8)    not null,
  title              varchar(255)  not null,
  sections           JSONB          not null,
  created_at         TIMESTAMP      not null default current_timestamp,
  updated_at         TIMESTAMP      not null default current_timestamp,
  primary key (id),
  unique key uk_cm_legal_content_document_locale (document_id, locale)
);

create table cm_user_agreement_acceptances (
  id                 varchar(36)   not null,
  user_id            varchar(36)   not null,
  document_type      varchar(20)   not null,
  document_version   varchar(40)   not null,
  accepted_at        TIMESTAMP      not null,
  created_at         TIMESTAMP      not null default current_timestamp,
  primary key (id),
  unique key uk_cm_user_agreement_user_type (user_id, document_type)
);

-- ----------------------------
-- Profiles
-- ----------------------------

create table cm_profiles (
  id                       varchar(36)  not null,
  profile_type             varchar(20)  not null,
  gender                   varchar(20)  not null,
  birth_year               int          not null,
  height                   int          not null,
  city_code                varchar(80)  not null,
  country_code             varchar(80)  not null,
  nationality_code         varchar(80)  not null,
  profile_status           varchar(20)  not null,
  last_active_at           TIMESTAMP     not null,
  family_visible           BOOLEAN   not null default 0,
  degree_level             varchar(20)  not null,
  education_code           varchar(80)  not null,
  industry_code            varchar(80)  not null,
  marital_status           varchar(30)  not null,
  has_children             BOOLEAN   not null default 0,
  children_plan            varchar(40)  not null,
  accepts_long_distance    BOOLEAN   not null default 0,
  dating_intention_code    varchar(30)  not null,
  relocation               varchar(30)  not null,
  preferred_age_min        int          not null,
  preferred_age_max        int          not null,
  preferred_location       varchar(30)  not null,
  smoking                  varchar(20)  not null,
  drinking                 varchar(20)  not null,
  activity_level           varchar(20)  not null,
  weekend_style            varchar(20)  not null,
  pets                     varchar(20)  not null,
  communication_style      varchar(20)  not null,
  archived_at              TIMESTAMP     default null,
  created_at               TIMESTAMP     not null default current_timestamp,
  updated_at               TIMESTAMP     not null default current_timestamp,
  primary key (id),
  key idx_cm_profiles_type_status (profile_type, profile_status),
  key idx_cm_profiles_city (city_code),
  key idx_cm_profiles_country (country_code),
  key idx_cm_profiles_industry (industry_code),
  key idx_cm_profiles_degree (degree_level),
  key idx_cm_profiles_last_active (last_active_at),
  key idx_cm_profiles_archived (archived_at)
);

create table cm_profile_languages (
  profile_id         varchar(36) not null,
  language_code      varchar(20) not null,
  primary key (profile_id, language_code),
  key idx_cm_profile_languages_language (language_code)
);

create table cm_profile_relationship_values (
  profile_id         varchar(36) not null,
  value_code         varchar(40) not null,
  primary key (profile_id, value_code),
  key idx_cm_profile_relationship_values_code (value_code)
);

create table cm_profile_localized_fields (
  id                 varchar(36)   not null,
  profile_id         varchar(36)   not null,
  field_name         varchar(60)   not null,
  locale             varchar(8)    not null,
  value              text          not null,
  source             varchar(20)   not null default 'manual',
  provider           varchar(30)   default null,
  status             varchar(20)   not null default 'ready',
  created_at         TIMESTAMP      not null default current_timestamp,
  updated_at         TIMESTAMP      not null default current_timestamp,
  primary key (id),
  unique key uk_cm_profile_localized_field (profile_id, field_name, locale),
  key idx_cm_profile_localized_lookup (field_name, locale, status)
);

create table cm_profile_localized_items (
  id                 varchar(36)   not null,
  profile_id         varchar(36)   not null,
  field_name         varchar(60)   not null,
  item_order         int           not null default 0,
  locale             varchar(8)    not null,
  value              text          not null,
  source             varchar(20)   not null default 'manual',
  provider           varchar(30)   default null,
  status             varchar(20)   not null default 'ready',
  created_at         TIMESTAMP      not null default current_timestamp,
  updated_at         TIMESTAMP      not null default current_timestamp,
  primary key (id),
  unique key uk_cm_profile_localized_item (profile_id, field_name, item_order, locale),
  key idx_cm_profile_localized_items_lookup (field_name, locale, status)
);

create table cm_profile_photos (
  id                 varchar(36)  not null,
  profile_id         varchar(36)  not null,
  url                varchar(500) not null,
  is_primary         BOOLEAN   not null default 0,
  sort_order         int          not null default 0,
  status             varchar(20)  not null,
  created_at         TIMESTAMP     not null default current_timestamp,
  updated_at         TIMESTAMP     not null default current_timestamp,
  primary key (id),
  key idx_cm_profile_photos_profile (profile_id),
  key idx_cm_profile_photos_status (status)
);

create table cm_profile_ownerships (
  id                       varchar(36) not null,
  user_id                  varchar(36) not null,
  profile_id               varchar(36) not null,
  relationship_to_profile  varchar(20) not null,
  permission               varchar(20) not null,
  status                   varchar(20) not null,
  invited_by_user_id       varchar(36) default null,
  accepted_at              TIMESTAMP    default null,
  revoked_at               TIMESTAMP    default null,
  created_at               TIMESTAMP    not null default current_timestamp,
  updated_at               TIMESTAMP    not null default current_timestamp,
  primary key (id),
  key idx_cm_profile_ownerships_user (user_id),
  key idx_cm_profile_ownerships_profile (profile_id)
);

create table cm_profile_internal_records (
  id                 varchar(36) not null,
  profile_id         varchar(36) not null,
  is_featured        BOOLEAN  not null default 0,
  source             varchar(30) default null,
  updated_by_user_id varchar(36) default null,
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_profile_internal_profile (profile_id),
  key idx_cm_profile_internal_featured (is_featured)
);

create table cm_profile_internal_localized_fields (
  id                 varchar(36) not null,
  internal_record_id varchar(36) not null,
  field_name         varchar(60) not null,
  locale             varchar(8)  not null,
  value              text        not null,
  source             varchar(20) not null default 'manual',
  provider           varchar(30) default null,
  status             varchar(20) not null default 'ready',
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_profile_internal_localized (internal_record_id, field_name, locale)
);

create table cm_profile_verifications (
  id                  varchar(36)  not null,
  profile_id          varchar(36)  not null,
  legal_name          varchar(100) default null,
  date_of_birth       date         default null,
  identity_status     varchar(20)  not null default 'unverified',
  education_status    varchar(20)  not null default 'unverified',
  income_status       varchar(20)  not null default 'unverified',
  marital_status      varchar(20)  not null default 'unverified',
  review_status       varchar(20)  not null default 'unreviewed',
  verified_at         TIMESTAMP     default null,
  verified_by_user_id varchar(36)  default null,
  created_at          TIMESTAMP     not null default current_timestamp,
  updated_at          TIMESTAMP     not null default current_timestamp,
  primary key (id),
  unique key uk_cm_profile_verifications_profile (profile_id)
);

create table cm_profile_contacts (
  id                 varchar(36)  not null,
  profile_id         varchar(36)  not null,
  phone              varchar(50)  default null,
  email              varchar(191) default null,
  wechat             varchar(100) default null,
  preferred_channel  varchar(20)  default null,
  visibility         varchar(30)  not null default 'after_introduction',
  created_at         TIMESTAMP     not null default current_timestamp,
  updated_at         TIMESTAMP     not null default current_timestamp,
  primary key (id),
  unique key uk_cm_profile_contacts_profile (profile_id)
);

create table cm_profile_privacy_preferences (
  id                         varchar(36) not null,
  profile_id                 varchar(36) not null,
  hide_marital_status        BOOLEAN  not null default 0,
  hide_has_children          BOOLEAN  not null default 0,
  hide_children_plan         BOOLEAN  not null default 0,
  hide_accepts_long_distance BOOLEAN  not null default 0,
  hide_smoking               BOOLEAN  not null default 0,
  hide_drinking              BOOLEAN  not null default 0,
  created_at                 TIMESTAMP    not null default current_timestamp,
  updated_at                 TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_profile_privacy_profile (profile_id)
);

-- ----------------------------
-- Membership
-- ----------------------------

create table cm_membership_plans (
  id                            varchar(36)  not null,
  tier                          varchar(20)  not null,
  price_cents                   int          not null,
  currency                      varchar(3)   not null default 'EUR',
  cny_price_cents               int          not null,
  billing_type                  varchar(20)  not null,
  billing_period                varchar(20)  default null,
  validity_months               int          default null,
  private_introduction_quota    int          not null default 0,
  private_introduction_period   varchar(20)  not null,
  event_quota                   int          not null default 0,
  event_priority_enabled        BOOLEAN   not null default 0,
  staff_review_enabled          BOOLEAN   not null default 0,
  profile_detail_access_level   varchar(20)  not null default 'registered',
  staff_support_level           varchar(20)  not null default 'none',
  concierge_priority            BOOLEAN   not null default 0,
  featured                      BOOLEAN   not null default 0,
  sort_order                    int          not null default 0,
  is_active                     BOOLEAN   not null default 1,
  created_at                    TIMESTAMP     not null default current_timestamp,
  updated_at                    TIMESTAMP     not null default current_timestamp,
  primary key (id),
  unique key uk_cm_membership_plans_tier (tier),
  key idx_cm_membership_plans_active_sort (is_active, sort_order)
);

create table cm_membership_plan_localized_fields (
  id                 varchar(36) not null,
  plan_id            varchar(36) not null,
  field_name         varchar(60) not null,
  locale             varchar(8)  not null,
  value              text        not null,
  source             varchar(20) not null default 'manual',
  provider           varchar(30) default null,
  status             varchar(20) not null default 'ready',
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_plan_localized_field (plan_id, field_name, locale)
);

create table cm_user_memberships (
  id                 varchar(36) not null,
  user_id            varchar(36) not null,
  plan_id            varchar(36) not null,
  tier               varchar(20) not null,
  status             varchar(20) not null,
  started_at         TIMESTAMP    not null,
  expires_at         TIMESTAMP    default null,
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  key idx_cm_user_memberships_user_status (user_id, status),
  key idx_cm_user_memberships_plan (plan_id)
);

create table cm_user_entitlement_balances (
  id                 varchar(36) not null,
  user_id            varchar(36) not null,
  membership_id      varchar(36) not null,
  entitlement_code   varchar(50) not null,
  period_started_at  TIMESTAMP    not null,
  period_ends_at     TIMESTAMP    not null,
  quota_total        int         not null default 0,
  quota_used         int         not null default 0,
  quota_remaining    int         not null default 0,
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_entitlement_user_code_period (user_id, entitlement_code, period_started_at, period_ends_at),
  key idx_cm_entitlement_membership (membership_id)
);

-- ----------------------------
-- Events
-- ----------------------------

create table cm_events (
  id                    varchar(36)  not null,
  slug                  varchar(120) not null,
  status                varchar(20)  not null,
  visibility            varchar(20)  not null,
  consumes_membership_quota BOOLEAN not null default 0,
  city_code             varchar(80)  not null,
  address_visibility    varchar(40)  not null,
  event_date            date         not null,
  start_time            time         not null,
  end_time              time         not null,
  capacity              int          not null,
  cover_image_url       varchar(500) not null,
  created_at            TIMESTAMP     not null default current_timestamp,
  updated_at            TIMESTAMP     not null default current_timestamp,
  primary key (id),
  unique key uk_cm_events_slug (slug),
  key idx_cm_events_status_date (status, event_date),
  key idx_cm_events_city (city_code),
  key idx_cm_events_visibility (visibility)
);

create table cm_event_localized_fields (
  id                 varchar(36) not null,
  event_id           varchar(36) not null,
  field_name         varchar(60) not null,
  locale             varchar(8)  not null,
  value              text        not null,
  source             varchar(20) not null default 'manual',
  provider           varchar(30) default null,
  status             varchar(20) not null default 'ready',
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_event_localized_field (event_id, field_name, locale)
);

create table cm_event_relationship_focuses (
  id                 varchar(36) not null,
  event_id           varchar(36) not null,
  focus_order        int         not null default 0,
  locale             varchar(8)  not null,
  value              text        not null,
  source             varchar(20) not null default 'manual',
  provider           varchar(30) default null,
  status             varchar(20) not null default 'ready',
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_event_focus_locale (event_id, focus_order, locale)
);

create table cm_event_language_codes (
  event_id           varchar(36) not null,
  language_code      varchar(20) not null,
  primary key (event_id, language_code),
  key idx_cm_event_language_codes_language (language_code)
);

create table cm_event_agenda_items (
  id                 varchar(36) not null,
  event_id           varchar(36) not null,
  agenda_time        varchar(20) not null,
  sort_order         int         not null default 0,
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  key idx_cm_event_agenda_event_sort (event_id, sort_order)
);

create table cm_event_agenda_item_localized_fields (
  id                 varchar(36) not null,
  agenda_item_id     varchar(36) not null,
  field_name         varchar(60) not null,
  locale             varchar(8)  not null,
  value              text        not null,
  source             varchar(20) not null default 'manual',
  provider           varchar(30) default null,
  status             varchar(20) not null default 'ready',
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_event_agenda_localized (agenda_item_id, field_name, locale)
);

create table cm_event_registrations (
  id                 varchar(36) not null,
  user_id            varchar(36) not null,
  event_id           varchar(36) not null,
  status             varchar(20) not null,
  requested_at       TIMESTAMP    not null,
  confirmed_at       TIMESTAMP    default null,
  declined_at        TIMESTAMP    default null,
  waitlisted_at      TIMESTAMP    default null,
  cancelled_at       TIMESTAMP    default null,
  attended_at        TIMESTAMP    default null,
  event_quota_consumed_at TIMESTAMP default null,
  event_quota_released_at TIMESTAMP default null,
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_event_registration_user_event (user_id, event_id),
  key idx_cm_event_registration_event_status (event_id, status)
);

-- ----------------------------
-- Relationship actions
-- ----------------------------

create table cm_favorite_profiles (
  id                 varchar(36) not null,
  user_id            varchar(36) not null,
  profile_id         varchar(36) not null,
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_favorite_user_profile (user_id, profile_id),
  key idx_cm_favorite_profile (profile_id)
);

create table cm_private_introduction_requests (
  id                       varchar(36)  not null,
  requester_user_id        varchar(36)  not null,
  requester_profile_id     varchar(36)  default null,
  target_profile_id        varchar(36)  not null,
  status                   varchar(20)  not null,
  active_target_id         varchar(36) generated always as (case when status in ('requested', 'accepted') then target_profile_id else null end) stored,
  message                  varchar(1000) default null,
  requested_at             TIMESTAMP     not null,
  expires_at               TIMESTAMP     default null,
  responded_at             TIMESTAMP     default null,
  cooldown_until           TIMESTAMP     default null,
  entitlement_balance_id   varchar(36)  default null,
  created_at               TIMESTAMP     not null default current_timestamp,
  updated_at               TIMESTAMP     not null default current_timestamp,
  primary key (id),
  unique key uk_cm_intro_active_pair (requester_user_id, active_target_id),
  key idx_cm_intro_requester_status (requester_user_id, status),
  key idx_cm_intro_target_status (target_profile_id, status),
  key idx_cm_intro_entitlement (entitlement_balance_id)
);

-- ----------------------------
-- Inbox
-- ----------------------------

create table cm_inbox_threads (
  id                 varchar(36) not null,
  user_id            varchar(36) not null,
  category           varchar(20) not null,
  subject_type       varchar(40) default null,
  subject_id         varchar(36) default null,
  status             varchar(20) not null,
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  key idx_cm_inbox_threads_user_status (user_id, status),
  key idx_cm_inbox_threads_subject (subject_type, subject_id)
);

create table cm_inbox_messages (
  id                 varchar(36)  not null,
  thread_id          varchar(36)  not null,
  sender_type        varchar(20)  not null,
  sender_user_id     varchar(36)  default null,
  message_type       varchar(30)  not null,
  body               text         not null,
  template_code      varchar(80)  default null,
  template_locale    varchar(8)   default null,
  action_type        varchar(80)  default null,
  action_payload     JSONB         default null,
  created_at         TIMESTAMP     not null default current_timestamp,
  updated_at         TIMESTAMP     not null default current_timestamp,
  primary key (id),
  key idx_cm_inbox_messages_thread_created (thread_id, created_at)
);

create table cm_inbox_reads (
  id                 varchar(36) not null,
  thread_id          varchar(36) not null,
  user_id            varchar(36) not null,
  last_read_at       TIMESTAMP    not null,
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_inbox_reads_thread_user (thread_id, user_id)
);

-- ----------------------------
-- Staff operations
-- ----------------------------
-- Staff users are RuoYi backend accounts. Bridge to sys_user instead of cm_users.

create table cm_staff_members (
  id                 varchar(36) not null,
  sys_user_id        BIGINT  not null,
  role               varchar(30) not null,
  status             varchar(20) not null,
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_staff_members_sys_user (sys_user_id)
);

create table cm_staff_tasks (
  id                    varchar(36) not null,
  assignee_sys_user_id  BIGINT  default null,
  subject_type          varchar(40) not null,
  subject_id            varchar(36) not null,
  status                varchar(20) not null,
  priority              varchar(20) not null,
  due_at                TIMESTAMP    default null,
  completed_at          TIMESTAMP    default null,
  created_at            TIMESTAMP    not null default current_timestamp,
  updated_at            TIMESTAMP    not null default current_timestamp,
  primary key (id),
  key idx_cm_staff_tasks_subject (subject_type, subject_id),
  key idx_cm_staff_tasks_assignee_status (assignee_sys_user_id, status)
);

create table cm_staff_task_localized_fields (
  id                 varchar(36) not null,
  staff_task_id      varchar(36) not null,
  field_name         varchar(60) not null,
  locale             varchar(8)  not null,
  value              text        not null,
  source             varchar(20) not null default 'manual',
  provider           varchar(30) default null,
  status             varchar(20) not null default 'ready',
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  unique key uk_cm_staff_task_localized (staff_task_id, field_name, locale)
);

-- ----------------------------
-- Audit and billing
-- ----------------------------

create table cm_audit_logs (
  id                 varchar(36)  not null,
  actor_type         varchar(20)  not null,
  actor_user_id      varchar(36)  default null,
  subject_type       varchar(50)  not null,
  subject_id         varchar(36)  not null,
  action             varchar(80)  not null,
  before_data        JSONB         default null,
  after_data         JSONB         default null,
  reason             varchar(500) default null,
  created_at         TIMESTAMP     not null default current_timestamp,
  primary key (id),
  key idx_cm_audit_subject (subject_type, subject_id),
  key idx_cm_audit_actor (actor_type, actor_user_id),
  key idx_cm_audit_created (created_at)
);

create table cm_orders (
  id                 varchar(36) not null,
  user_id            varchar(36) not null,
  plan_id            varchar(36) not null,
  status             varchar(20) not null,
  amount_cents       int         not null,
  currency           varchar(3)  not null,
  created_at         TIMESTAMP    not null default current_timestamp,
  updated_at         TIMESTAMP    not null default current_timestamp,
  primary key (id),
  key idx_cm_orders_user_status (user_id, status),
  key idx_cm_orders_plan (plan_id)
);

create table cm_payments (
  id                   varchar(36)  not null,
  order_id             varchar(36)  not null,
  provider             varchar(30)  not null,
  provider_payment_id  varchar(191) default null,
  status               varchar(20)  not null,
  amount_cents         int          not null,
  currency             varchar(3)   not null,
  paid_at              TIMESTAMP     default null,
  created_at           TIMESTAMP     not null default current_timestamp,
  updated_at           TIMESTAMP     not null default current_timestamp,
  primary key (id),
  key idx_cm_payments_order (order_id),
  key idx_cm_payments_provider_payment (provider, provider_payment_id)
);
