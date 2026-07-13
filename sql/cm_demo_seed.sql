-- Cupid Match demo seed data (DML only)
-- Run after sql/cm_schema.sql and sql/cm_required_seed.sql.
-- Contains C-end demo users, profiles, events, memberships, messages, contact leads, payments and audit records.

start transaction;

-- Clean optional demo business rows managed by this file.
-- Do not run this file against production data.
delete from cm_payment_webhook_events;
delete from cm_payments;
delete from cm_subscriptions;
delete from cm_orders;
delete from cm_payment_customers;
delete from cm_audit_logs;
delete from cm_contact_leads;
delete from cm_translation_retries;
delete from cm_staff_task_localized_fields;
delete from cm_staff_tasks;
delete from cm_inbox_reads;
delete from cm_inbox_messages;
delete from cm_inbox_threads;
delete from cm_inbox_single_dispatches;
delete from cm_inbox_broadcast_targets;
delete from cm_inbox_broadcasts;
delete from cm_inbox_system_failures;
delete from cm_private_introduction_requests;
delete from cm_favorite_profiles;
delete from cm_event_registrations;
delete from cm_event_agenda_item_localized_fields;
delete from cm_event_agenda_items;
delete from cm_event_note_item_localized_fields;
delete from cm_event_note_items;
delete from cm_event_language_codes;
delete from cm_event_relationship_focuses;
delete from cm_event_localized_fields;
delete from cm_events;
delete from cm_user_entitlement_balances;
delete from cm_user_memberships;
delete from cm_profile_privacy_preferences;
delete from cm_profile_contacts;
delete from cm_profile_verification_materials;
delete from cm_profile_verifications;
delete from cm_profile_internal_localized_fields;
delete from cm_profile_internal_records;
delete from cm_profile_ownerships;
delete from cm_profile_photos;
delete from cm_profile_localized_items;
delete from cm_profile_option_extra_texts;
delete from cm_profile_localized_fields;
delete from cm_profile_relationship_values;
delete from cm_profile_languages;
delete from cm_profiles;
delete from cm_user_agreement_acceptances;
delete from cm_user_preferences;
delete from cm_security_events;
delete from cm_user_security_challenges;
delete from cm_user_security_settings;
delete from cm_auth_identities;
delete from cm_users;

insert into cm_users (id, account_name, avatar_url, preferred_locale, alias_word_code, alias_tag, status, created_at, updated_at) values
  ('efdca298-c977-5502-ad2e-8ba480ca1ea3', '林远航', '', 'zh', 'gentle_starlight', 'K27R', 'active', '2026-01-18 00:00:00', '2026-05-27 18:33:11'),
  ('b0000000-0000-4000-8000-000000000001', 'Aline Moreau', '', 'fr', 'quiet_breeze', 'M18Q', 'active', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('b0000000-0000-4000-8000-000000000002', 'Sophie Laurent', '', 'fr', 'warm_sunrise', 'V63B', 'active', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('b0000000-0000-4000-8000-000000000003', 'Martin Keller', '', 'en', 'ocean_dream', 'L52S', 'active', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('b0000000-0000-4000-8000-000000000004', 'Iris Van Dijk', '', 'en', 'silver_cloud', 'T74W', 'active', '2026-02-14 00:00:00', '2026-04-21 10:45:00');

-- 3A.2 Auth identities
insert into cm_auth_identities (id, user_id, provider, identifier, password_hash, verified_at, created_at, updated_at) values
  ('866d5279-f964-5513-92af-3e3c3005e0af', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'email', 'lin.yuanhang@rencontreaparis.test', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', '2026-01-18 00:00:00', '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('dab49d53-34f1-552a-b3fb-a90847e7adae', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'phone', '13333333333', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', '2026-06-01 12:16:53', '2026-06-01 12:16:53', '2026-06-01 12:16:53'),
  ('a1000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'email', 'aline.moreau@rencontreaparis.test', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', '2026-01-12 00:00:00', '2026-01-12 00:00:00', '2026-01-12 00:00:00'),
  ('a1000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'email', 'sophie.laurent@rencontreaparis.test', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', '2026-03-01 00:00:00', '2026-03-01 00:00:00', '2026-03-01 00:00:00'),
  ('a1000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000003', 'email', 'martin.keller@rencontreaparis.test', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', '2026-02-02 00:00:00', '2026-02-02 00:00:00', '2026-02-02 00:00:00'),
  ('a1000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000004', 'email', 'iris.vandijk@rencontreaparis.test', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', '2026-02-14 00:00:00', '2026-02-14 00:00:00', '2026-02-14 00:00:00');

-- 3A.3 Security settings
insert into cm_user_security_settings (id, user_id, mfa_enabled, mfa_method, mfa_identity_id, mfa_enabled_at, last_challenge_at, created_at, updated_at) values
  ('c12c12d6-7cf2-580c-afa8-86439bbe71a3', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 1, 'email', '866d5279-f964-5513-92af-3e3c3005e0af', '2026-05-31 14:39:34', '2026-06-01 12:50:47', '2026-05-31 14:39:34', '2026-06-01 12:50:47');

-- 3A.4 Security challenges
insert into cm_user_security_challenges (id, user_id, action, method, identity_id, status, challenge_token, expires_at, verified_at, consumed_at, created_at, updated_at) values
  ('fc53472e-6584-5b40-906e-b4f5b222e183', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'export_data', 'email', '866d5279-f964-5513-92af-3e3c3005e0af', 'consumed', 'challenge-security-token-001-1780238394772', '2026-05-31 14:44:54', '2026-05-31 14:39:54', '2026-05-31 14:39:54', '2026-05-31 14:39:39', '2026-05-31 14:39:54'),
  ('04d4e928-0644-5dcf-865e-6426d8069384', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'export_data', 'email', '866d5279-f964-5513-92af-3e3c3005e0af', 'pending', null, '2026-05-31 14:45:04', null, null, '2026-05-31 14:40:04', '2026-05-31 14:40:04'),
  ('aed0ae4f-b415-585c-9b9e-0d03817240ae', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'export_data', 'email', '866d5279-f964-5513-92af-3e3c3005e0af', 'pending', null, '2026-05-31 14:46:05', null, null, '2026-05-31 14:41:05', '2026-05-31 14:41:05'),
  ('0d6ece63-908e-53ff-941b-ef0c2a5cced2', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'export_data', 'email', '866d5279-f964-5513-92af-3e3c3005e0af', 'pending', null, '2026-06-01 12:55:47', null, null, '2026-06-01 12:50:47', '2026-06-01 12:50:47');

-- 3A.4B Security events
insert into cm_security_events (id, user_id, identity_id, event_type, event_result, risk_level, ip, user_agent, device_id, detail_json, created_at) values
  ('a3500000-0000-4000-8000-000000000001', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '866d5279-f964-5513-92af-3e3c3005e0af', 'login_success', 'success', null, '127.0.0.1', 'Cupid Match H5 Local Browser', 'device-lin-yuanhang-h5-paris', '{"provider":"email","identifier":"lin.yuanhang@rencontreaparis.test"}', '2026-06-01 12:16:53'),
  ('a3500000-0000-4000-8000-000000000002', null, null, 'login_failed', 'failed', null, '127.0.0.1', 'Cupid Match H5 Local Browser', 'device-suspicious-paris-office', '{"provider":"email","identifier":"blocked.login@rencontreaparis.test","reason":"bad_credentials"}', '2026-06-01 12:17:10'),
  ('a3500000-0000-4000-8000-000000000003', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '866d5279-f964-5513-92af-3e3c3005e0af', 'risk_detected', 'detected', 'high', '127.0.0.1', 'Cupid Match H5 Local Browser', 'device-suspicious-paris-office', '{"reason":"too_many_failed_login_attempts","windowMinutes":10,"failedAttempts":6}', '2026-06-01 12:18:00');

-- 3A.5 User preferences
insert into cm_user_preferences (id, user_id, preferred_city_code, preferred_contact_channel, staff_contact_enabled, family_assist_enabled, introduction_updates_enabled, event_reminders_enabled, service_announcements_enabled, marketing_emails_enabled, analytics_consent_enabled, created_at, updated_at) values
  ('0ddabb82-4c33-5f95-8cea-4ee08f4fdd2e', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'FR:paris', 'email', 1, 1, 1, 1, 1, 0, 0, '2026-01-01 00:00:00', '2026-05-27 18:36:02'),
  ('a2000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'FR:paris', 'email', 1, 0, 1, 1, 1, 0, 0, '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('a2000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'FR:paris', 'email', 1, 1, 1, 1, 1, 0, 0, '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('a2000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000003', 'CH:geneva', 'email', 1, 0, 1, 1, 1, 0, 0, '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('a2000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000004', 'NL:amsterdam', 'email', 1, 0, 1, 1, 1, 0, 0, '2026-02-14 00:00:00', '2026-04-21 10:45:00');

-- 3A.6 User agreement acceptances
insert into cm_user_agreement_acceptances (id, user_id, document_type, document_version, accepted_at, created_at) values
  ('4757b4e9-0b69-5c9e-ba64-0cee9c6ac4f5', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'terms', '1.0', '2026-05-15 22:13:49', '2026-05-15 22:13:49'),
  ('46464343-a0da-5394-afcd-870960046e79', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'privacy', '1.0', '2026-05-15 22:13:49', '2026-05-15 22:13:49'),
  ('a3000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'terms', '1.0', '2026-01-12 00:00:00', '2026-01-12 00:00:00'),
  ('a3000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000001', 'privacy', '1.0', '2026-01-12 00:00:00', '2026-01-12 00:00:00'),
  ('a3000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000002', 'terms', '1.0', '2026-03-01 00:00:00', '2026-03-01 00:00:00'),
  ('a3000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000002', 'privacy', '1.0', '2026-03-01 00:00:00', '2026-03-01 00:00:00'),
  ('a3000000-0000-4000-8000-000000000005', 'b0000000-0000-4000-8000-000000000003', 'terms', '1.0', '2026-02-02 00:00:00', '2026-02-02 00:00:00'),
  ('a3000000-0000-4000-8000-000000000006', 'b0000000-0000-4000-8000-000000000003', 'privacy', '1.0', '2026-02-02 00:00:00', '2026-02-02 00:00:00'),
  ('a3000000-0000-4000-8000-000000000007', 'b0000000-0000-4000-8000-000000000004', 'terms', '1.0', '2026-02-14 00:00:00', '2026-02-14 00:00:00'),
  ('a3000000-0000-4000-8000-000000000008', 'b0000000-0000-4000-8000-000000000004', 'privacy', '1.0', '2026-02-14 00:00:00', '2026-02-14 00:00:00');

-- 3A.6 Profiles
insert into cm_profiles (id, profile_type, gender, birth_year, height, city_code, country_code, nationality_code, profile_status, last_active_at, family_visible, degree_level, education_code, industry_code, relationship_goal_code, residence_plan_code, preferred_education_code, family_life_code, exercise_code, marital_status, has_children, children_plan, accepts_long_distance, dating_intention_code, relocation, preferred_age_min, preferred_age_max, preferred_location, smoking, drinking, activity_level, weekend_style, pets, communication_style, archived_at, created_at, updated_at) values
  ('506ce3c7-b236-5b44-b8d0-459c4250ea03', 'self', 'female', 1995, 168, 'FR:paris', 'FR', 'FR', 'open', '2026-04-20 18:30:00', 0, 'master', 'master_business', 'other', 'other', 'other', 'other', 'other', 'other', 'never_married', 0, 'wants', 1, 'serious', 'willing', 28, 40, 'regional', 'never', 'social', 'high', 'flexible', 'likes', 'direct', null, '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'self', 'male', 1992, 178, 'FR:paris', 'FR', 'CN', 'open', '2026-04-22 09:00:00', 1, 'master', 'master_engineering', 'technology', 'other', 'other', 'other', 'other', 'other', 'never_married', 0, 'wants', 1, 'marriage', 'willing', 28, 40, 'regional', 'never', 'social', 'high', 'flexible', 'likes', 'direct', null, '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('d7a4c336-b6f4-5079-a4ad-c47b4044a740', 'self', 'female', 1990, 170, 'FR:paris', 'FR', 'FR', 'review', '2026-04-21 20:30:00', 1, 'phd', 'phd', 'other', 'other', 'other', 'other', 'other', 'other', 'divorced', 1, 'does_not_want', 1, 'exclusive', 'willing', 28, 40, 'regional', 'never', 'social', 'low', 'flexible', 'likes', 'direct', null, '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'self', 'male', 1991, 174, 'CH:geneva', 'CH', 'CH', 'open', '2026-04-25 07:50:00', 1, 'master', 'master_finance', 'finance', 'other', 'other', 'other', 'other', 'other', 'never_married', 0, 'wants', 1, 'cross_border', 'willing', 28, 40, 'regional', 'never', 'social', 'high', 'flexible', 'likes', 'direct', null, '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'self', 'female', 1993, 171, 'NL:amsterdam', 'NL', 'NL', 'open', '2026-04-21 10:45:00', 1, 'master', 'master_science', 'other', 'other', 'other', 'other', 'other', 'other', 'divorced', 0, 'wants', 1, 'serious', 'willing', 28, 40, 'regional', 'never', 'social', 'moderate', 'flexible', 'likes', 'direct', null, '2026-02-14 00:00:00', '2026-04-21 10:45:00');

-- 3B.2 cm_profile_languages
insert into cm_profile_languages (profile_id, language_code) values
  ('506ce3c7-b236-5b44-b8d0-459c4250ea03', 'FR'),
  ('506ce3c7-b236-5b44-b8d0-459c4250ea03', 'EN'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'ZH'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'FR'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'EN'),
  ('d7a4c336-b6f4-5079-a4ad-c47b4044a740', 'FR'),
  ('d7a4c336-b6f4-5079-a4ad-c47b4044a740', 'EN'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'FR'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'EN'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'DE'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'EN'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'NL'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'FR');

-- 3B.3 cm_profile_relationship_values
insert into cm_profile_relationship_values (profile_id, value_code) values
  ('506ce3c7-b236-5b44-b8d0-459c4250ea03', 'honesty'),
  ('506ce3c7-b236-5b44-b8d0-459c4250ea03', 'growth'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'loyalty'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'support'),
  ('d7a4c336-b6f4-5079-a4ad-c47b4044a740', 'respect'),
  ('d7a4c336-b6f4-5079-a4ad-c47b4044a740', 'communication'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'family'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'trust'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'respect'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'communication');

-- 3C.1 cm_profile_localized_fields
insert into cm_profile_localized_fields (id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('13b171ee-b159-5b8d-9664-e1e233dfc855', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'profile_name', 'zh', '巴黎品牌策略师', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-24 00:00:00'),
  ('2d90a2e8-6303-567a-babf-43e580480a61', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'profile_name', 'fr', 'Strategiste de marque a Paris', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-24 00:00:00'),
  ('9009f810-bb96-5004-8616-b233aaa18c11', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'profile_name', 'en', 'Paris brand strategist', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-24 00:00:00'),
  ('58024103-1dc2-5d47-8fb7-364cc7cf3845', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'career_direction', 'zh', '品牌策略', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4452c68b-c089-5d77-abc4-3427ea22e431', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'career_direction', 'fr', 'Strategie de marque', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('9a9d75ee-6172-5b75-be64-5a047844f6ab', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'career_direction', 'en', 'Brand strategist', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('8a3f876a-6225-55a1-bea6-be0176dc202f', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'summary', 'zh', '重视表达、节奏和跨文化理解。', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('a1410e30-c32b-5f70-9774-25b5c78217cb', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'summary', 'fr', 'Attentive a la communication, au rythme et a la comprehension interculturelle.', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('20fe4256-d922-55eb-b03a-abc1b8aea433', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'summary', 'en', 'Values communication, pacing, and intercultural understanding.', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('52b18e22-9af2-5933-a11d-78c4fa3bff1b', '503a9c99-2842-54db-8858-24fbd3108e3b', 'profile_name', 'zh', '巴黎产品负责人', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('25ab232d-05c5-5739-aa6c-32ccf63a7497', '503a9c99-2842-54db-8858-24fbd3108e3b', 'profile_name', 'fr', 'Responsable produit a Paris', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-24 00:00:00'),
  ('313cae33-f67f-5890-b8dd-d15d800b4514', '503a9c99-2842-54db-8858-24fbd3108e3b', 'profile_name', 'en', 'Paris product lead', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-24 00:00:00'),
  ('27e96d3a-b2f2-562f-8430-06467d6f604e', '503a9c99-2842-54db-8858-24fbd3108e3b', 'career_direction', 'zh', '产品负责人', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('e00833d9-3d70-5561-9148-fba2207ad9a4', '503a9c99-2842-54db-8858-24fbd3108e3b', 'career_direction', 'fr', 'Responsable produit', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('49b14928-323b-5478-bcf4-fd508c9e7ddb', '503a9c99-2842-54db-8858-24fbd3108e3b', 'career_direction', 'en', 'Product lead', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('9c98ea72-5578-5804-8dca-0dea16aac841', '503a9c99-2842-54db-8858-24fbd3108e3b', 'summary', 'zh', '重视长期关系中的稳定、透明和行动力。', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('25ee86d8-56dc-5a01-b292-d489264eda40', '503a9c99-2842-54db-8858-24fbd3108e3b', 'summary', 'fr', 'Cherche de la stabilite, de la clarte et de l action dans une relation durable.', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('fc4455ae-ebc8-5339-8bb8-c654075414c3', '503a9c99-2842-54db-8858-24fbd3108e3b', 'summary', 'en', 'Values stability, clarity, and follow-through in a long-term relationship.', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('ede9cdb0-337d-5c5f-ad59-fe11c00e5c12', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'profile_name', 'zh', '公共政策研究员', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-24 00:00:00'),
  ('c344497f-e98f-5ad9-b6d1-88bfbaf01044', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'profile_name', 'fr', 'Chercheuse en politiques publiques', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-24 00:00:00'),
  ('7e261815-231b-5a03-9836-a84100c16217', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'profile_name', 'en', 'Public policy researcher', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-24 00:00:00'),
  ('3b3189ef-c0f1-5155-a97a-2c815f2118a8', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'career_direction', 'zh', '公共政策研究员', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('fcffc6bc-7436-5bf8-b025-d24cf0afc20a', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'career_direction', 'fr', 'Chercheuse en politiques publiques', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('dec8ec20-e926-52bf-a9ec-1fefe90c78b8', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'career_direction', 'en', 'Public policy researcher', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('55ef25db-a4b2-52d1-9b41-6b1ecdc27879', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'summary', 'zh', '希望在成熟、清晰和尊重边界的前提下推进关系。', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0816d7c1-01c1-5d2f-aea4-fa235de5782f', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'summary', 'fr', 'Souhaite avancer dans un cadre mature, clair et respectueux des limites.', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('e256a23b-0f72-5501-b6c1-ccb72f8c1a3a', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'summary', 'en', 'Wants to move forward in a mature, clear, and boundary-respecting way.', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('d878c23a-d44d-510d-bb86-e94a76576cdb', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'profile_name', 'zh', '跨城投融资经理', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-24 00:00:00'),
  ('4d5de3f8-4c52-53ab-bbdd-58a064a6f995', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'profile_name', 'fr', 'Manager financement transfrontalier', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-24 00:00:00'),
  ('503bb249-d469-53ac-aad5-d0d1af413a2a', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'profile_name', 'en', 'Cross-border finance manager', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-24 00:00:00'),
  ('0e930ce3-44b5-58fb-9f0b-19401039a08f', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'career_direction', 'zh', '投融资经理', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('cd762bf5-bddd-5ecd-a8ae-8900fc76c2e8', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'career_direction', 'fr', 'Manager financement', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('f21d02e9-40c9-5f47-a62d-096919507932', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'career_direction', 'en', 'Finance manager', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('daeab0d8-8d71-5f9a-9d30-613486c575f1', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'summary', 'zh', '重视跨城市协同能力和长期执行力。', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('157d0ee0-3316-5d48-8c55-63db29de661d', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'summary', 'fr', 'Valorise la coordination entre villes et la capacite d execution.', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('1c5b61a6-09e8-5a2b-bbe3-39183809d05b', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'summary', 'en', 'Values cross-city coordination and long-term execution.', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('78b9ae00-772c-5154-b6b8-64ead275423c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'profile_name', 'zh', '阿姆斯特丹用户研究员', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-24 00:00:00'),
  ('283cd4b8-e803-506d-9298-d52427f0ccf0', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'profile_name', 'fr', 'Chercheuse UX a Amsterdam', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-24 00:00:00'),
  ('8d58ae14-4ca7-5060-b0c9-f7f976b0c5b4', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'profile_name', 'en', 'Amsterdam UX researcher', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-24 00:00:00'),
  ('86ed4159-d277-5fe3-9427-56ab8f60a304', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'career_direction', 'zh', '用户研究员', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('44f988a9-cb65-5445-9cdf-204d34653188', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'career_direction', 'fr', 'Chercheuse UX', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('4af68b24-506c-580f-b55c-09a4d4bad50c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'career_direction', 'en', 'UX researcher', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('5f612d53-753a-5374-a3a2-f9b771cf7f26', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'summary', 'zh', '重视生活一致性与沟通质量。', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('65959282-d45c-5fe6-85d8-413873eb8291', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'summary', 'fr', 'Attachee a la coherence de vie et a la qualite de communication.', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('dbe28286-d590-5427-90dc-57b3975fc5d6', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'summary', 'en', 'Values lifestyle consistency and communication quality.', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20');

-- 3D.1 cm_profile_option_extra_texts
insert into cm_profile_option_extra_texts (id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('4e70e287-f162-5299-a03f-eeb5390dfee0', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('c65deaec-a398-53e0-b2e8-ed79bc24c7c3', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('b3a86c83-af16-5b7c-b962-330977e2f430', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('0e0be4ec-1257-5d7a-b4d0-c501414f3ecf', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'industry', 'zh', '奢侈品', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('75d2bb45-d18f-57be-bec9-a7a219a83c20', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'industry', 'fr', 'Luxe', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('81b60cfe-a34e-53bb-afeb-468062d7adab', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'industry', 'en', 'Luxury', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('8e20a47d-65c6-5c03-b6ce-0c315c07748c', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'relationship_goal', 'zh', '一年内确认节奏', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('94d638c7-8a25-5081-aef3-d8c59cd2575a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'relationship_goal', 'fr', 'Clarifier le rythme sous un an', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('ba4bf557-ff69-5e46-b663-e196a4b6be40', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'relationship_goal', 'en', 'Clarify long-term pace within a year', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4b6531f3-9ab5-5d59-b5e4-ad850df89cd6', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'residence_plan', 'zh', '优先巴黎，也接受欧洲双城', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2f51835d-0714-5191-bfa7-bd4f0372246a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'residence_plan', 'fr', 'Paris en priorite, ouverte a une double ville en Europe', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('1e7d3b37-6e03-52b2-ae14-b4403448c047', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'residence_plan', 'en', 'Prefers Paris, open to a two-city setup in Europe', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('03e1f2bb-a584-55bc-b741-c8df5a978f8a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('b1bac649-581d-5327-ba3b-aa5bea7c97e7', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4f406ecf-c201-5516-b054-757eef5b4101', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('60cfd810-e44c-5f2d-8b60-510591607338', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('40c926c6-6ae6-5084-b428-c3fbc8c12a56', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4cef23f0-cc0e-5aa1-8144-38fddd73e518', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('8093a9d3-25ad-5ca6-9beb-61f212ad0fc9', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'exercise', 'zh', '每周瑜伽和步行', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2681fe86-aa0f-51b1-92c9-e4b285a450e5', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'exercise', 'fr', 'Yoga et marche chaque semaine', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('e8d1f95d-2832-5d54-8ebb-f47726f22619', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'exercise', 'en', 'Weekly yoga and walking', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('cfb798df-d5d8-561b-9436-ecdf9ad75da8', '503a9c99-2842-54db-8858-24fbd3108e3b', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('6673c574-99a5-5af3-a6f5-76d6b11c5840', '503a9c99-2842-54db-8858-24fbd3108e3b', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('48de2e20-662d-5af2-8d60-8354f558c83c', '503a9c99-2842-54db-8858-24fbd3108e3b', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('5c01edf1-45b3-5253-b90a-cdd96701d4cc', '503a9c99-2842-54db-8858-24fbd3108e3b', 'industry', 'zh', '科技', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('2ad075e6-808c-5110-b42c-0bd872aac784', '503a9c99-2842-54db-8858-24fbd3108e3b', 'industry', 'fr', 'Tech', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('22fac3e8-d831-57cb-ae8e-b0d5541d203e', '503a9c99-2842-54db-8858-24fbd3108e3b', 'industry', 'en', 'Technology', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('c0e81e04-6ff8-5352-a3c6-6bab2cae7904', '503a9c99-2842-54db-8858-24fbd3108e3b', 'relationship_goal', 'zh', '明确方向后稳步推进', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('84b09491-2f4d-5738-a815-73198214388b', '503a9c99-2842-54db-8858-24fbd3108e3b', 'relationship_goal', 'fr', 'Avancer de facon stable une fois l orientation clarifiee', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('39516afa-c5c9-54b5-a2d8-a479127fb30c', '503a9c99-2842-54db-8858-24fbd3108e3b', 'relationship_goal', 'en', 'Move steadily once long-term direction is clear', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('246e9e32-2a2a-5fb0-8c55-bf6e50106f9f', '503a9c99-2842-54db-8858-24fbd3108e3b', 'residence_plan', 'zh', '巴黎长期发展', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('37836562-fd88-5a70-8b8b-f5a652f33388', '503a9c99-2842-54db-8858-24fbd3108e3b', 'residence_plan', 'fr', 'Projet long terme a Paris', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('aecbaef9-0087-5464-b57f-1b03db382f9d', '503a9c99-2842-54db-8858-24fbd3108e3b', 'residence_plan', 'en', 'Long-term plan in Paris', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('4b732c26-2681-5215-8aa6-b33347e3aa45', '503a9c99-2842-54db-8858-24fbd3108e3b', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('1e0ff0bb-6fee-58da-96fe-f9c909e1be19', '503a9c99-2842-54db-8858-24fbd3108e3b', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('9da63b95-838f-5525-b0e1-bb6242578c83', '503a9c99-2842-54db-8858-24fbd3108e3b', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('53958c78-a60d-511d-80e0-9ac4e6bde4f1', '503a9c99-2842-54db-8858-24fbd3108e3b', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('8691cd21-dceb-50cf-bcbb-b11153cef4f8', '503a9c99-2842-54db-8858-24fbd3108e3b', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('02f06a86-4ce8-56e4-b5b5-8e1c38d40ffe', '503a9c99-2842-54db-8858-24fbd3108e3b', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('7c493dc6-6069-5e1c-ba33-43d0809f88cc', '503a9c99-2842-54db-8858-24fbd3108e3b', 'exercise', 'zh', '跑步和力量训练', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('bba70d5a-8c71-5186-89ff-7088b0ea65b1', '503a9c99-2842-54db-8858-24fbd3108e3b', 'exercise', 'fr', 'Course et renforcement', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('4c584a5e-a5fa-5e3d-bf76-61844c3f5612', '503a9c99-2842-54db-8858-24fbd3108e3b', 'exercise', 'en', 'Running and strength training', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('b0fea0a9-7ff6-5e3e-ad52-9fe8c184ec47', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'education', 'zh', '博士', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('1b33ee72-91c2-57ca-97d0-b8779776d3cd', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'education', 'fr', 'Doctorat', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0faaf556-8542-55cc-ac8c-d6205716c01a', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'education', 'en', 'PhD', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('e76cecc7-cd23-521f-9c57-45228f00085f', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'industry', 'zh', '公共事务', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0d9b2ecb-64f1-5ae1-bc73-5790225f0918', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'industry', 'fr', 'Affaires publiques', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('527f8239-f786-52a3-8f86-6dad50382b6d', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'industry', 'en', 'Public affairs', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('ac3dd044-42f7-5cf8-9adb-8bc9ba3c55c8', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'relationship_goal', 'zh', '先确认家庭节奏与城市安排', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('1289fbf8-2e32-540d-93af-d23c287b96c8', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'relationship_goal', 'fr', 'Verifier d abord le rythme familial et la logistique des villes', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('7e9bbc0d-5001-559f-addf-dd9d3c9092cb', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'relationship_goal', 'en', 'First confirm family rhythm and city logistics', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('3c38b18f-a801-5c75-82f4-cdcf272836c6', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'residence_plan', 'zh', '巴黎为主，也可双城', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('695ab81e-2ac6-5738-be4f-78d090e0c12d', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'residence_plan', 'fr', 'Paris prioritaire, possible double ville', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('55c14f7a-1095-5cd6-a08f-599735658373', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'residence_plan', 'en', 'Paris first, open to a two-city setup', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('26406b90-3705-5d98-b4d6-98145d4d793b', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('f194a1c2-83b5-5779-a40f-d7ad32bc87f5', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('15a80999-44cd-5388-b94e-676705824ba2', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('a5c35c39-d23e-5398-866d-a3c8c0696d2c', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('c49458d9-3b9f-564d-a24e-d61bd20e5bee', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('6e85e6b7-d50c-53c6-8379-49b4da48d9e6', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('7635cfe1-ea59-5c15-9c78-c0c0e068f498', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'exercise', 'zh', '步行和网球', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('7dea2da5-5d8f-53f6-9a18-d35b5c91c39b', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'exercise', 'fr', 'Marche et tennis', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('82866ad4-3421-595e-b2c2-c8fe239e3a91', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'exercise', 'en', 'Walking and tennis', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0cca6e29-e534-5d5e-a1b3-edcb02c9e907', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('efb2f04f-5b5b-54e1-b165-7177dde52b02', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('29ac3832-8304-53d4-bc0e-0ce05b935d47', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('0eb26d16-0ec4-5d19-becd-72911e4c0bae', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'industry', 'zh', '金融', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('8838a5df-fdd0-55c5-94a1-531721dcb72c', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'industry', 'fr', 'Finance', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('321e2e48-9b26-5270-afd5-64277956c5f9', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'industry', 'en', 'Finance', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('cdbb1e44-c636-5894-9dad-b5a43e491c08', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'relationship_goal', 'zh', '接受跨境安排，优先确定共同城市策略', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('9275ab86-88db-51a0-9727-adac6f70f7b7', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'relationship_goal', 'fr', 'Ouvert au transfrontalier avec strategie de ville commune', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('f1886399-7b6e-5c0b-b417-aa2e54a4f32d', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'relationship_goal', 'en', 'Open to cross-border setup with a shared city strategy', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('69d7f902-90ba-59ef-b12d-5e2425c46f87', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'residence_plan', 'zh', '日内瓦为主，接受巴黎双城', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('1007ac50-4280-5324-a4a6-26159eb93aef', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'residence_plan', 'fr', 'Geneve en base, possible schema Geneve-Paris', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('76226226-43c5-5812-8723-03aaaf927f64', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'residence_plan', 'en', 'Geneva-based, open to Geneva-Paris setup', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('5df6c783-8c5e-53b4-9903-82a6a88627a3', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('f9eb7077-02da-5489-bc9c-ea561dae3b78', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('0686cb87-a0fd-5317-a488-796034a3fbfa', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('c2dd5995-84c2-52ea-8804-83de8e6f2174', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('9b87080c-d7da-5916-91af-19d197335233', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('182f54bc-06ef-5c03-8b1c-897b09e7917b', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('3c505de4-b273-5845-bbe1-5ac643535845', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'exercise', 'zh', '滑雪和徒步', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('195534b1-b535-5ff4-9596-07287dac5719', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'exercise', 'fr', 'Ski et randonnee', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('84224217-0d89-550e-8e1a-ea2abed8d24f', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'exercise', 'en', 'Skiing and hiking', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('4496617a-f643-51cd-a376-69cc50e1186f', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('9b4f73c7-e199-5764-a65e-3dc38e36aed0', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('c18b1c79-2ffb-50b0-8e08-7c0e3b776e62', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('7a9048ed-26a0-52ce-85c3-4efb9b7966e7', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'industry', 'zh', '数字产品', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('64efcb6a-9332-51eb-8e0c-767e0cb4707c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'industry', 'fr', 'Produit numerique', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('d22f53bd-e01a-5416-b237-e6105a1e69e0', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'industry', 'en', 'Digital product', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('b9268581-70f9-5098-a378-31800fec1f50', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'relationship_goal', 'zh', '先建立共同生活节奏，再推进长期关系', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('29ca8eb7-060e-578b-af81-a1f2330a898f', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'relationship_goal', 'fr', 'Installer un rythme de vie commun avant de projeter le long terme', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('c7a747ff-1731-5292-af91-f981758308b7', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'relationship_goal', 'en', 'Build daily-life rhythm first, then advance long-term plans', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('720b9871-bba5-52ad-962f-f9254e36395f', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'residence_plan', 'zh', '阿姆斯特丹为主，接受巴黎/布鲁塞尔协同', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('4bb8cdc8-8094-5f6a-846b-955a225f9678', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'residence_plan', 'fr', 'Base Amsterdam, ouverte a Paris ou Bruxelles', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('82c76128-4ecf-52ca-b866-524179da172c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'residence_plan', 'en', 'Amsterdam-based, open to Paris/Brussels coordination', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('e3631400-f153-5354-94de-fe56eaa8081c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('395506b6-3dcb-5803-9d6a-91280987a9d0', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('a8d76440-cf2b-5bbb-8078-72cf73fb1d5e', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('b2a48efe-0b1e-5358-8761-0bd7e07a9cf6', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('c96d41c2-da26-53d0-be7d-503d5692cf18', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('4187449e-9017-5f06-ac1d-3e88e2a06052', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('a85f9ce1-5f82-5a36-9402-95982715c22c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'exercise', 'zh', '划船和慢跑', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('7b981b34-b0b0-5321-a421-a49f9d3f6ae9', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'exercise', 'fr', 'Rameur et jogging', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('88f28cb8-67d1-5b6d-ac0f-726ab261442c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'exercise', 'en', 'Rowing and jogging', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20');

-- 3A.9 cm_profile_localized_items
insert into cm_profile_localized_items (id, profile_id, field_name, item_order, locale, value, source, provider, status, created_at, updated_at) values
  ('9707592f-595f-5bc1-9bca-484fa48e1fe5', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4d0f0f82-90b8-5d98-bc6c-836263977537', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('d5062173-7224-5f8b-9aaf-c618236f6317', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('d90b9fec-c0f5-50f0-b083-cb0b308d2353', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('f0aa0038-596e-5322-8c5b-8026e1e45ec9', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('12043a25-1fbe-583f-acc9-9f946c01e5ad', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('edc80f35-1b91-5b57-9b22-9af70e859aaf', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 0, 'zh', '表达清晰', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('ef3976dd-b41d-5214-9e49-a6cccb7f0022', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 0, 'fr', 'Communication claire', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('1cd98d81-baa6-5f2d-bc0d-552fcf4c94f3', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 0, 'en', 'Clear communicator', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('c6a791b6-babe-5ab7-bad7-9c7166762b05', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 1, 'zh', '审美稳定', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('c43508f3-7eac-549c-9723-3651d9291da1', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 1, 'fr', 'Sens esthetique stable', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2f57e21e-cc2a-5d53-b350-6696c3d7bd7b', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 1, 'en', 'Consistent taste', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('8d8a0030-ab0b-5167-a515-81c27152c50f', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 2, 'zh', '重视边界', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('8ddfa90c-ccfd-55e4-9b86-18cb86aa2e4f', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 2, 'fr', 'Respecte les limites', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('b313dde0-dd57-56ba-bee3-1cab4eeb31a6', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 2, 'en', 'Values boundaries', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('a351f601-65ae-5b6c-b771-2ac68a5ccc83', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 0, 'zh', '展览', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('615ff39f-f38a-5d05-b27c-a34c97e37f60', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 0, 'fr', 'Expositions', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('aa79d3e0-2403-54b1-b5a4-c7d2cb5d5f2d', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 0, 'en', 'Exhibitions', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2a409dbe-d1c5-5da7-b932-cbf4c5291597', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 1, 'zh', '城市散步', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('9b643cc8-3398-5659-ac4b-0c377caf6150', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 1, 'fr', 'Balades urbaines', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('e77e2a71-8ce3-5117-a2a6-e30f9c00f0d2', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 1, 'en', 'City walks', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('18ad84bd-4801-59f2-922e-6e6ced928c8a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 2, 'zh', '法式烹饪', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4ef0bcca-32f4-5d77-b496-78936e2b6fe2', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 2, 'fr', 'Cuisine francaise', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('c60275ef-6ea6-524e-b197-8fbba0145888', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 2, 'en', 'French cooking', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2d0754e2-f742-5b9f-bcc7-6568fc5f36c1', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 0, 'zh', '文化活动', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('9a65d176-5879-5629-a6e2-523e36ac8c3a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 0, 'fr', 'Activites culturelles', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('808414b9-fb65-56db-8af2-e2042244b4c3', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 0, 'en', 'Cultural activities', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('cd2bf547-9c31-5fe0-b2a8-5e0159c24641', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 1, 'zh', '城市生活', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('71006629-e0bc-5d25-af5e-e7354560cabb', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 1, 'fr', 'Vie urbaine', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('50cdc4a1-954c-52d8-8445-cb86ee7d538a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 1, 'en', 'City life', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('c6aa9913-84b6-578e-b8a6-e86a422de74d', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 2, 'zh', '稳定节奏', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('df4bedd0-ce1d-50a6-8db1-0ca1177dc2f0', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 2, 'fr', 'Rythme stable', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('1839f64f-2a4b-5146-8186-b02f5dc82ab9', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 2, 'en', 'Steady pace', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2072fbb9-fb26-5a2b-bdc1-73758f4b4eec', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('1ae26191-2668-55c9-bc31-a650a57b4c55', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('659920ec-34da-5074-be7a-1cb842cbb2ca', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('e978c89f-3d92-5a07-8e66-a133b416323a', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('e47997b1-afd9-5108-9c24-7af15bbecdad', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('9fd9564c-767a-5a1c-bf88-18f8adaec470', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('2c4fc79a-8190-5fd0-9c07-2feaf9df0fae', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 0, 'zh', '目标清晰', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('d504a106-e085-5db4-9d4b-7a1d6bf9da9f', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 0, 'fr', 'Objectifs clairs', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('fa676115-e197-5472-adf2-6d2fef873fbd', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 0, 'en', 'Clear goals', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('72955b27-e856-5825-8177-b8e64eefd839', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 1, 'zh', '执行力强', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('97d068dc-dd7e-529e-a978-cdc2c9dee8fd', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 1, 'fr', 'Fort sens de l execution', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('ee3ed886-d8bf-51fd-9c19-fb58027be331', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 1, 'en', 'Strong follow-through', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('d57e83b3-f0a7-577e-b539-2911f58222fc', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 2, 'zh', '情绪稳定', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('27c49f83-9483-557e-88c4-855217d5288f', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 2, 'fr', 'Stable emotionnellement', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('1597f4d4-5785-5bf0-9767-b2b0509ecdb0', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 2, 'en', 'Emotionally steady', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('c2a8ba36-2e20-56de-bb05-7ce2e76ef84f', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 0, 'zh', '骑行', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('5aec2d5c-40e6-58ff-b267-f9b9ed64c9fc', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 0, 'fr', 'Velo', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('01a17b44-18be-56cf-8679-cf39809f7789', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 0, 'en', 'Cycling', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('bc9d5943-283a-5df2-86fb-b1ca59bfedd1', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 1, 'zh', '产品播客', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('1e669f1d-dcba-5250-a8de-07f43e7ce9c1', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 1, 'fr', 'Podcasts produit', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('e1cdef4f-5f26-54f9-818a-d9e745cba4db', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 1, 'en', 'Product podcasts', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('1123282e-f8d0-50a3-a050-38fe0f08f39b', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 2, 'zh', '周末做饭', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('580fe557-1d97-5d11-89d5-80820cdf24bb', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 2, 'fr', 'Cuisine le week-end', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('c7725346-068b-5b25-90d7-008620e86483', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 2, 'en', 'Weekend cooking', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('c70e4e37-41a7-5105-a153-72584415bf09', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 0, 'zh', '长期关系', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('be674512-162f-5536-8a91-1855039e6a98', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 0, 'fr', 'Long terme', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('97aa5303-fed6-5972-9d8c-91590b23ce90', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 0, 'en', 'Long-term', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('b6fe3495-f4cc-52a5-9be5-7034d982d49c', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 1, 'zh', '顾问协同', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('45566ebc-1144-5a5e-8caa-f0fbd9a1a7d2', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 1, 'fr', 'Coordination conseiller', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('247f34e2-1bb2-539d-b0b1-1f8e7ce314dc', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 1, 'en', 'Advisor-supported', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('caa8915e-2fcd-5012-b1aa-aea6c0bf720c', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 2, 'zh', '跨文化', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('f770e12d-1b4d-567a-a5ac-9840ffb90caa', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 2, 'fr', 'Interculturel', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('5715ac23-1d62-56f4-aae6-4bfcfe115bad', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 2, 'en', 'Cross-cultural', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('2cbcda5e-7773-578f-8f05-5a2500536992', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('6ff1583a-e441-5ff6-aa06-1528bf037146', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('efbdc9dc-d72b-5667-b94e-b694780b5091', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('11e32e22-6d52-5d00-acf1-e1bf21bf8a69', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('581f67ed-5e14-5482-bec7-1353302427ea', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('498d62e3-a54b-5167-bc42-920b87c8fe39', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0d869475-466e-5221-bdfb-b00140e9ac44', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 0, 'zh', '温和直接', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('ff7ea61f-41d1-5215-a2ea-208f68efef8f', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 0, 'fr', 'Douce et directe', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('7e3ca8ce-6e78-5193-b7c2-1aa1c79ebd28', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 0, 'en', 'Warm and direct', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('285e1c14-fee2-5c43-93d9-7556f009e711', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 1, 'zh', '生活有秩序', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('2015df2e-5429-5467-9b5f-26a634d1d7b9', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 1, 'fr', 'Vie bien organisee', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('4183dd85-97df-5f0a-8345-dedd6d5030fc', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 1, 'en', 'Well organized', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('e60a4a79-d80a-5e41-a152-4db6219263c0', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 2, 'zh', '重视真实相处', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0ee31112-45f7-5081-a8a7-972ec84eb8ad', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 2, 'fr', 'Valorise l authenticite', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('5a2af7ae-935b-5edb-a4db-789450f8b119', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 2, 'en', 'Values authenticity', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('84dc370d-a0c4-5efd-ac01-102502136935', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 0, 'zh', '阅读', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('105b5d3a-76da-5c32-a363-d6107c2eb683', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 0, 'fr', 'Lecture', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('61826833-34f7-577b-8f88-673e50ba1195', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 0, 'en', 'Reading', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('b8c746ff-b530-5600-8a8d-9fbac126ce5e', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 1, 'zh', '散步', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('3726a9f1-cfce-5d85-ab83-3ef58f2e5e54', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 1, 'fr', 'Balades', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('438e3430-de9e-516f-9f93-666d94f45f07', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 1, 'en', 'Walks', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('adb26e97-d833-5ac8-bcc1-b93c4f07d2b6', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 2, 'zh', '周末探店', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('6aa40ee1-3135-51dc-841e-feee7d938382', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 2, 'fr', 'Decouvertes le week-end', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('3bb14fb5-ed7d-5d26-bc9e-5c095d373837', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 2, 'en', 'Weekend discoveries', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('a7e000fa-7449-5548-b3dd-437b26115701', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 0, 'zh', '家庭节奏', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('2ec1da8d-b6d1-5cca-9414-4e5b1dffee7c', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 0, 'fr', 'Rythme familial', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('1d6df03b-7d00-5909-8c04-238f123686d8', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 0, 'en', 'Family rhythm', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('89e29a58-86bf-5c2b-b0a3-40c78925db7a', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 1, 'zh', '双城安排', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('19530580-d97d-50d6-a2b2-09ab5c164adc', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 1, 'fr', 'Deux villes', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('527e4755-1c7a-56c6-bdec-6503460d2571', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 1, 'en', 'Two-city setup', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('fe2209a8-10cd-5fbd-b7ee-2b0af1d3202a', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 2, 'zh', '成熟沟通', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('d07e5182-5d85-5055-8e2f-d2f3e6df5315', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 2, 'fr', 'Communication mature', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('42e9a311-04c3-57b0-a8bd-b1cfa14fa619', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 2, 'en', 'Mature communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('4d3442b2-56a2-5500-a2ba-2522e49e1d45', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('1523e661-34a8-57cb-887a-5cdf8e51e147', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('9f4ad05f-5dec-5e19-8f1a-f6e2008c88f0', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('7fd31078-1bed-5f33-8c55-da1a09d61a39', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('fe0591cb-980f-5fb5-b85b-4b87923a76b3', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('03fb47ce-5787-52fe-8930-8947aef2c895', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('03e9da58-0c81-5db0-84c1-45bb6c15d2b7', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 0, 'zh', '时间观念强', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('35411f5f-6439-55ce-b095-44dd61aba0e4', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 0, 'fr', 'Tres ponctuel', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('5c18d106-f055-5189-8d17-a37ac9abfea3', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 0, 'en', 'Very punctual', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('9e66e827-95ff-59a8-8c41-8a513256706b', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 1, 'zh', '跨文化适应力好', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('ce55cd68-b276-598c-a57f-786a204fc102', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 1, 'fr', 'Aisance interculturelle', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('ff5b6a22-d952-5873-923a-6f7ed418dcaa', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 1, 'en', 'Cross-cultural ease', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('a1c37419-638e-5569-a448-55fe98056f06', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 2, 'zh', '重视承诺', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('aa744d94-7708-5956-96f3-0435bb0b87ff', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 2, 'fr', 'Attache aux engagements', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('a076534a-4c25-52b6-99b5-b327e5c89ff6', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 2, 'en', 'Commitment-minded', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('db8f13cd-2e6e-5469-9074-567c09a47dbc', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 0, 'zh', '滑雪', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('413e2161-88e7-5e55-968b-9581de39d367', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 0, 'fr', 'Ski', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('0847e129-0afb-54c0-b40d-cb9c8c9136f6', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 0, 'en', 'Skiing', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('acb2026a-e336-5c01-bc5b-1e3eb8ea27dc', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 1, 'zh', '徒步', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('9e6a71cb-b690-5935-b0e2-6186c76280f0', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 1, 'fr', 'Randonnee', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('ac1f3c57-9f04-5977-ae71-17f671100adc', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 1, 'en', 'Hiking', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('ea8147eb-3532-52b1-8a64-c0a0980abd33', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 2, 'zh', '城市短途旅行', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('d1ad23b8-9e98-56fb-b7f9-89abcb39254c', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 2, 'fr', 'Escapades urbaines', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('c9171629-d936-5276-8331-3595fcb58a33', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 2, 'en', 'City breaks', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('697d6338-ea7b-5b34-b866-e922d1cd1bec', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 0, 'zh', '跨境节奏', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('fd300753-ff9b-5aff-b737-04ba616b1794', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 0, 'fr', 'Transfrontalier', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('96ae347c-51b7-5af3-b69f-6a3ce215b02e', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 0, 'en', 'Cross-border', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('c61093c3-1a1f-579d-a90f-0fd63273ee07', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 1, 'zh', '高匹配意愿', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('238cabe4-466e-579c-a5b3-204497b1e07c', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 1, 'fr', 'Intention elevee', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('75377ff4-96c5-5f57-80c7-a44b6d711349', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 1, 'en', 'High matching intent', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('59fcc817-3668-53c9-ae6c-06697f7259bf', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 2, 'zh', '执行力', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('6e4ad6de-18fb-5716-b995-2fb2ac7cc388', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 2, 'fr', 'Execution', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('3b25d7bd-2917-5b67-be4a-629355a85925', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 2, 'en', 'Execution', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('3f60c249-e3d8-548b-a4d5-de6799de0be2', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('a08d00ac-fcaa-5d0d-8064-669c4536a44a', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('31d7d94a-6d0b-51c1-a4dd-46f7cca3f4d8', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('c69982f5-9e13-52c8-ace0-4113f485ac1f', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('d18b0231-f413-5c8c-bb76-2e72efae24be', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('82cffe0c-86b1-5f3a-acc2-a5dc2fe78469', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('5611722a-57a9-5844-9ed1-be813ed96876', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 0, 'zh', '温和直接', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('3312d1be-3b0c-59e1-b59f-427a8179e134', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 0, 'fr', 'Douce et directe', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('e25a8901-ec00-599f-ad54-aa97d58cd45f', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 0, 'en', 'Warm and direct', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('fc4c8089-9be1-5f96-8ff6-6edeeefc5d55', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 1, 'zh', '生活有秩序', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('cbd75c21-ca1f-5439-ae2c-514c06dc96b1', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 1, 'fr', 'Vie bien organisee', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('8ce54e37-853b-5416-932b-77156428df7b', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 1, 'en', 'Well organized', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('e5a1861e-b646-542e-a514-bfb24598d50d', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 2, 'zh', '重视真实相处', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('7cfe1d80-0a32-589a-b267-ad9387b4c3c1', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 2, 'fr', 'Valorise l authenticite', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('de46be3f-2be2-5ff0-a7f9-99e1f30a8a0b', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 2, 'en', 'Values authenticity', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('03257880-4953-545b-a765-ca761830c08e', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 0, 'zh', '阅读', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('7c49194d-0235-55cc-8aae-a2ab45415365', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 0, 'fr', 'Lecture', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('8835dd84-816e-59b3-97ab-72178705cb03', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 0, 'en', 'Reading', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('32198e77-c406-568a-9161-9cddf0302d56', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 1, 'zh', '散步', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('9e0c2acb-3f1d-52dd-83af-c07964f69cf6', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 1, 'fr', 'Balades', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('734928e8-fe9e-5562-90cc-47866e3e02ed', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 1, 'en', 'Walks', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('96bdaed5-d0a9-5dd4-8093-b2a5d3d63fcc', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 2, 'zh', '周末探店', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('deddecf2-caf6-5eb1-b729-9fe2fe752b99', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 2, 'fr', 'Decouvertes le week-end', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('3b25a046-eb87-5add-ac4a-05a1e3dc3a7c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 2, 'en', 'Weekend discoveries', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('ca415402-1f2f-5eed-8eb7-95009ab534f0', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 0, 'zh', '跨文化', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('adb162d7-b172-5949-b19e-e2ddda037224', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 0, 'fr', 'Interculturel', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('0952ea1c-6c13-5188-b53b-da371f638733', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 0, 'en', 'Cross-cultural', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('faffdceb-2e27-5ce1-957f-3e606a8128ae', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 1, 'zh', '沟通质量', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('100e0b4a-8981-576d-a922-5b58528c46d9', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 1, 'fr', 'Qualite echange', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('11a00f3a-bdc9-5ece-8a6f-906989158fed', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 1, 'en', 'Communication quality', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('7229ac57-ae91-57d3-a317-7bc5dff989d4', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 2, 'zh', '生活一致', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('b0359cd9-4d8b-5771-9d42-e11ecd1f30a9', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 2, 'fr', 'Coherence de vie', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('602542cb-4db1-5237-8f6e-053e9382b2f4', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 2, 'en', 'Lifestyle alignment', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20');

-- 3A.10 cm_profile_photos
insert into cm_profile_photos (id, profile_id, url, is_primary, sort_order, status, created_at, updated_at) values
  ('f4391fce-c307-5754-83ab-efd016d9aada', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'https://picsum.photos/seed/p-001-1/900/1200', 1, 1, 'approved', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('b1485a44-d50c-5529-b41e-b61d87902a7b', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'https://picsum.photos/seed/p-001-2/900/1200', 0, 2, 'approved', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('d1286d2d-c0bb-51de-b1b4-c343ffda3e9c', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'https://picsum.photos/seed/p-001-3/900/1200', 0, 3, 'approved', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('9189edae-6db1-566d-abbc-ebf8ce71b63a', '503a9c99-2842-54db-8858-24fbd3108e3b', 'https://picsum.photos/seed/p-002-1/900/1200', 1, 1, 'approved', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('27367cf8-7d47-55d1-b745-376e53d8ab80', '503a9c99-2842-54db-8858-24fbd3108e3b', 'https://picsum.photos/seed/p-002-2/900/1200', 0, 2, 'approved', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('ce6bd69f-1a5d-567c-a881-3e83aca50550', '503a9c99-2842-54db-8858-24fbd3108e3b', 'https://picsum.photos/seed/p-002-3/900/1200', 0, 3, 'approved', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('e9675246-2d82-594a-adf1-bb4ace1c384b', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'https://picsum.photos/seed/p-006-1/900/1200', 1, 1, 'approved', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('e7050e2b-8592-5b6a-aa22-859e20d3c9fa', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'https://picsum.photos/seed/p-006-2/900/1200', 0, 2, 'approved', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('cc38e10c-0461-5ecc-9518-a67811f5c7b4', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'https://picsum.photos/seed/p-006-3/900/1200', 0, 3, 'approved', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('ac0f143b-13c9-548f-a15b-3d6763bc1576', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'https://picsum.photos/seed/p-009-1/900/1200', 1, 1, 'approved', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('31f97d57-ccd0-51c1-8b94-05d8f36c5288', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'https://picsum.photos/seed/p-009-2/900/1200', 0, 2, 'approved', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('393d2339-10b6-5dd9-bafc-4befd3a800fc', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'https://picsum.photos/seed/p-009-3/900/1200', 0, 3, 'approved', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('d1113beb-ce6f-5cf1-996b-f0834252e153', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'https://picsum.photos/seed/p-010-1/900/1200', 1, 1, 'approved', '2026-02-14 00:00:00', '2026-04-21 10:45:00'),
  ('cd6ee5a1-7302-56fd-a8bc-4cfb747a53ed', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'https://picsum.photos/seed/p-010-2/900/1200', 0, 2, 'approved', '2026-02-14 00:00:00', '2026-04-21 10:45:00'),
  ('d732ca77-9605-5651-9437-1f8b45e87f25', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'https://picsum.photos/seed/p-010-3/900/1200', 0, 3, 'approved', '2026-02-14 00:00:00', '2026-04-21 10:45:00');

-- 3A.11 cm_profile_ownerships
insert into cm_profile_ownerships (id, user_id, profile_id, relationship_to_profile, permission, status, invited_by_user_id, accepted_at, revoked_at, created_at, updated_at) values
  ('ce1facca-cc05-5f3c-8c31-58deda8629ac', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '503a9c99-2842-54db-8858-24fbd3108e3b', 'self', 'owner', 'active', null, null, null, '2026-01-01 00:00:00', '2026-05-25 21:07:58'),
  ('b1111111-1111-4111-8111-000000000001', 'b0000000-0000-4000-8000-000000000001', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'self', 'owner', 'active', null, null, null, '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('b1111111-1111-4111-8111-000000000002', 'b0000000-0000-4000-8000-000000000002', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'self', 'owner', 'active', null, null, null, '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('b1111111-1111-4111-8111-000000000003', 'b0000000-0000-4000-8000-000000000003', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'self', 'owner', 'active', null, null, null, '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('b1111111-1111-4111-8111-000000000004', 'b0000000-0000-4000-8000-000000000004', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'self', 'owner', 'active', null, null, null, '2026-02-14 00:00:00', '2026-04-21 10:45:00');

-- 3A.12 cm_profile_internal_records
insert into cm_profile_internal_records (id, profile_id, is_featured, source, updated_by_user_id, created_at, updated_at) values
  ('7ab713a0-49ec-50ce-8249-8b9a76897f96', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 0, null, null, '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('478efbe6-fca6-5281-979b-54083466ab54', '503a9c99-2842-54db-8858-24fbd3108e3b', 1, null, null, '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('c0194fe5-c673-522e-8e8e-7a70c1756be7', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 0, null, null, '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('ab6bf2a4-8581-52c6-b12f-89f53d5f31e1', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 1, null, null, '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('8890d441-fb8d-5a09-97b5-7a5f6a0a1e92', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 0, null, null, '2026-02-14 00:00:00', '2026-04-21 10:45:00');

-- 3A.12B cm_profile_internal_localized_fields
insert into cm_profile_internal_localized_fields (id, internal_record_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('a4200000-0000-4000-8000-000000000001', '478efbe6-fca6-5281-979b-54083466ab54', 'staff_notes', 'zh', '巴黎本地长期活跃用户，资料完整度高，适合作为推荐样例。', 'manual', 'human', 'ready', '2026-05-25 21:07:58', '2026-05-25 21:07:58'),
  ('a4200000-0000-4000-8000-000000000002', 'ab6bf2a4-8581-52c6-b12f-89f53d5f31e1', 'employer', 'zh', '跨境科技公司', 'manual', 'human', 'ready', '2026-04-25 07:50:00', '2026-04-25 07:50:00'),
  ('a4200000-0000-4000-8000-000000000003', 'ab6bf2a4-8581-52c6-b12f-89f53d5f31e1', 'income_range', 'zh', '高收入稳定区间', 'manual', 'human', 'ready', '2026-04-25 07:50:00', '2026-04-25 07:50:00');

-- 3A.13 cm_profile_verifications
insert into cm_profile_verifications (id, profile_id, legal_name, date_of_birth, identity_status, education_status, income_status, marital_status, review_status, verified_at, verified_by_user_id, created_at, updated_at) values
  ('512e1727-7810-5a09-8ce6-750f72a633ff', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'Aline Moreau', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('b8b2aece-5ed3-5e5c-906a-4f770c0b951f', '503a9c99-2842-54db-8858-24fbd3108e3b', '林远航', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('1fe5ee5f-2e5e-5f8b-8251-2fd5ab8ddce5', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'Sophie Laurent', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('9894e977-083c-5d2c-8a4e-4b7d3b539930', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'Martin Keller', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('c25eb929-8172-5434-96d1-db4a93a4c2f8', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'Iris Van Dijk', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-02-14 00:00:00', '2026-04-21 10:45:00');

-- 3A.14 cm_profile_contacts
insert into cm_profile_contacts (id, profile_id, phone, email, wechat, preferred_channel, visibility, created_at, updated_at) values
  ('e076859b-73d2-55bd-bf3e-7bbea0853691', '506ce3c7-b236-5b44-b8d0-459c4250ea03', '+33 6 12 34 56 78', 'aline.moreau@rencontreaparis.test', null, 'phone', 'after_introduction', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('27544d96-4bd3-5b0a-8b2c-3227e57fdc23', '503a9c99-2842-54db-8858-24fbd3108e3b', '+33 6 98 76 54 32', 'lin.yuanhang@rencontreaparis.test', 'lin_yuanhang_paris', 'phone', 'after_introduction', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('e1445318-683e-557c-bcc5-8a9599b4d74f', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', '+33 6 11 22 33 44', 'sophie.laurent@rencontreaparis.test', 'sophie_laurent_paris', 'email', 'after_introduction', '2026-02-14 00:00:00', '2026-05-28 10:00:00');

-- 3A.15 cm_profile_privacy_preferences
insert into cm_profile_privacy_preferences (id, profile_id, hide_marital_status, hide_has_children, hide_children_plan, hide_accepts_long_distance, hide_smoking, hide_drinking, created_at, updated_at) values
  ('1caff97d-06d9-53cb-a771-e169c484b90f', '503a9c99-2842-54db-8858-24fbd3108e3b', 0, 0, 0, 0, 0, 0, '2026-05-23 11:02:04', '2026-05-23 11:02:33');

-- 3A.18 cm_user_memberships
insert into cm_user_memberships (id, user_id, plan_id, tier, status, started_at, expires_at, created_at, updated_at) values
  ('d052548f-34dc-54f9-aab7-6dca95709306', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'gold', 'active', '2026-01-18 00:00:00', '2026-07-18 00:00:00', '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('a4000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'free', 'active', '2026-01-12 00:00:00', null, '2026-01-12 00:00:00', '2026-01-12 00:00:00'),
  ('a4000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'silver', 'active', '2026-03-01 00:00:00', '2026-08-01 00:00:00', '2026-03-01 00:00:00', '2026-03-01 00:00:00'),
  ('a4000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000003', '9fb53b84-a341-5b63-b6e8-35a474540a4c', 'diamond', 'active', '2026-02-02 00:00:00', '2026-08-02 00:00:00', '2026-02-02 00:00:00', '2026-02-02 00:00:00'),
  ('a4000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000004', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'free', 'active', '2026-02-14 00:00:00', null, '2026-02-14 00:00:00', '2026-02-14 00:00:00');

-- 3A.19 cm_user_entitlement_balances
insert into cm_user_entitlement_balances (id, user_id, membership_id, entitlement_code, period_started_at, period_ends_at, quota_total, quota_used, quota_remaining, created_at, updated_at) values
  ('202f036e-42b5-506e-9509-1cfb4960555f', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'd052548f-34dc-54f9-aab7-6dca95709306', 'private_introduction', '2026-06-01 00:00:00', '2026-06-30 00:00:00', 15, 1, 14, '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('6f796142-1339-5002-980e-8a2c61382c4b', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'd052548f-34dc-54f9-aab7-6dca95709306', 'event_registration', '2026-01-18 00:00:00', '2026-07-18 00:00:00', 20, 0, 20, '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('a4100000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000002', 'a4000000-0000-4000-8000-000000000002', 'private_introduction', '2026-07-01 00:00:00', '2026-07-31 23:59:59', 5, 0, 5, '2026-03-01 00:00:00', '2026-07-01 00:00:00'),
  ('a4100000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'a4000000-0000-4000-8000-000000000002', 'event_registration', '2026-03-01 00:00:00', '2026-08-01 00:00:00', 12, 2, 10, '2026-03-01 00:00:00', '2026-07-01 00:00:00'),
  ('a4100000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000003', 'a4000000-0000-4000-8000-000000000003', 'private_introduction', '2026-07-01 00:00:00', '2026-07-31 23:59:59', 30, 2, 28, '2026-02-02 00:00:00', '2026-07-01 00:00:00'),
  ('a4100000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000003', 'a4000000-0000-4000-8000-000000000003', 'event_registration', '2026-02-02 00:00:00', '2026-08-02 00:00:00', 24, 1, 23, '2026-02-02 00:00:00', '2026-07-01 00:00:00');

-- 3A.20 cm_events
insert into cm_events (id, status, visibility, consumes_membership_quota, city_code, address_visibility, event_date, start_time, end_time, capacity, cover_image_url, created_at, updated_at) values
  ('0ed043fe-531a-511d-940b-5daa55de963e', 'open', 'registered', 0, 'FR:paris', 'registered_only', '2026-05-12', '18:30', '21:00', 12, 'https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=1200&q=80', '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('38f69abd-73b4-5464-8b07-a95a9bb58547', 'waitlist', 'member', 1, 'FR:paris', 'confirmed_attendee_only', '2026-05-20', '19:00', '22:00', 8, 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=80', '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('1bcb995a-540c-5c66-9b92-52471c43e587', 'open', 'registered', 1, 'BE:brussels', 'registered_only', '2026-05-28', '14:30', '17:00', 16, 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80', '2026-04-01 00:00:00', '2026-05-01 00:00:00');

-- 3A.21 cm_event_localized_fields
insert into cm_event_localized_fields (id, event_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('098259d0-1a0c-5c74-a27f-f1f9a9868317', '0ed043fe-531a-511d-940b-5daa55de963e', 'title', 'zh', '春季双语沙龙', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('6be3fb00-fa24-5763-97d7-105cdfc82cf6', '0ed043fe-531a-511d-940b-5daa55de963e', 'title', 'fr', 'Salon bilingue du printemps', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('730263d9-f33f-52de-940c-70681b10446e', '0ed043fe-531a-511d-940b-5daa55de963e', 'title', 'en', 'Spring bilingual salon', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('eb44aded-1de3-545f-a6b4-78dbc4ae514c', '0ed043fe-531a-511d-940b-5daa55de963e', 'summary', 'zh', '围绕跨文化关系、工作节奏和城市生活展开小组交流。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('4c2cf0b0-3b2b-5d5d-b3fd-bc4fe74100fb', '0ed043fe-531a-511d-940b-5daa55de963e', 'summary', 'fr', 'Echanges en petits groupes autour des relations interculturelles et du rythme de vie.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('608010d4-f61a-59cb-ad15-fb1adaeb16b1', '0ed043fe-531a-511d-940b-5daa55de963e', 'summary', 'en', 'Small-group conversations around intercultural dating and lifestyle pace.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f12a23ae-ad4d-5c98-8fd1-46c42a71cae9', '0ed043fe-531a-511d-940b-5daa55de963e', 'venue', 'zh', '左岸私享沙龙', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('48416a3f-4bd1-5e14-bc13-4f12990f3321', '0ed043fe-531a-511d-940b-5daa55de963e', 'venue', 'fr', 'Salon prive rive gauche', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c1dcab44-e5a6-55e6-abc4-c1fbf23bc5b4', '0ed043fe-531a-511d-940b-5daa55de963e', 'venue', 'en', 'Left Bank private salon', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('e171bcbe-22f3-5c06-9742-d8a49b6fa1ae', '0ed043fe-531a-511d-940b-5daa55de963e', 'address', 'zh', '巴黎第六区圣日耳曼大道 128 号', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('eabb5bc9-f915-5e93-9b1d-722445657fc6', '0ed043fe-531a-511d-940b-5daa55de963e', 'address', 'fr', '128 boulevard Saint-Germain, 75006 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('823e1b05-b46a-5e38-8047-0bfc1ac7df17', '0ed043fe-531a-511d-940b-5daa55de963e', 'address', 'en', '128 Boulevard Saint-Germain, 75006 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('801bfc04-9f7e-5178-bafa-58d3dfe567b4', '0ed043fe-531a-511d-940b-5daa55de963e', 'format', 'zh', '12人主题沙龙', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('0ca86cb5-6c3e-5d0b-99bf-d5b45fc702ff', '0ed043fe-531a-511d-940b-5daa55de963e', 'format', 'fr', 'Salon thematique, 12 personnes', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f1fab27d-b06e-5dad-a32f-eacf91d1b5fd', '0ed043fe-531a-511d-940b-5daa55de963e', 'format', 'en', '12-person themed salon', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('9136df29-bd9c-5f70-a2ab-89ea5b633a70', '0ed043fe-531a-511d-940b-5daa55de963e', 'audience', 'zh', '适合 27-35 岁、希望稳定发展的会员', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f9dc2768-48b0-581d-bce5-f6a206ec1dcb', '0ed043fe-531a-511d-940b-5daa55de963e', 'audience', 'fr', 'Pour 27-35 ans avec intention relationnelle stable', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c310e57d-21f1-58c7-8c2d-c925ee950cf5', '0ed043fe-531a-511d-940b-5daa55de963e', 'audience', 'en', 'For members aged 27-35 seeking stable development', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('08b7091f-4412-52e4-8598-d4d6513988c3', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'title', 'zh', '左岸晚餐局', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('5986ce9b-c38f-57ff-90f9-ab28b74b5329', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'title', 'fr', 'Diner rive gauche', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('faa6f609-43d4-511c-bae3-0a509ae58783', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'title', 'en', 'Left Bank dinner gathering', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('69ba7ece-622a-50b1-8270-c53f828d1cfb', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'summary', 'zh', '适合把线上兴趣转化为线下确认。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('63da2126-201b-5b9c-82c9-82ce4961a1fa', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'summary', 'fr', 'Format intime pour valider une affinite observee en ligne.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('0d37bb47-70f0-5d8e-b5ba-a837b5aaeb28', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'summary', 'en', 'An intimate format to validate affinity first seen online.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('9a581508-62db-5845-8289-e9680bf327e7', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'venue', 'zh', '玛黑区私宴空间', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('790f4bac-d93e-5bd7-a73b-c5fab9e29f26', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'venue', 'fr', 'Table privee au Marais', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('6c550e5d-3fa0-5d9e-8387-a38da2240af2', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'venue', 'en', 'Private dinner in Le Marais', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('dafa2892-c1d6-5de3-9c5d-96f7571ae717', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'address', 'zh', '巴黎玛黑区维埃耶杜唐普勒街 42 号', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('310705cc-3dd8-57ee-b80d-0b70199db207', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'address', 'fr', '42 rue Vieille-du-Temple, 75004 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c3b4196e-18c3-5350-ab8d-a310c33c35cf', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'address', 'en', '42 Rue Vieille-du-Temple, 75004 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('5fbb4fc1-ff8c-51c5-a93b-f9c9c2068d58', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'format', 'zh', '8人精选晚餐', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('5a638e2d-6de3-52ab-9d75-9b1deb613f78', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'format', 'fr', 'Diner selectif, 8 personnes', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('cec43408-960c-5ccb-bf2c-fb21e81fd01e', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'format', 'en', '8-person curated dinner', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('72014f57-07f9-5230-b3be-24391ffafcea', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'audience', 'zh', '主要面向已完成资料审核的会员', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c85132a4-fdaa-5bff-b81e-cf93eefd64a1', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'audience', 'fr', 'Principalement membres verifies', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('4da97f04-6216-560a-bacf-9602d23b3f45', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'audience', 'en', 'Mainly for profile-verified members', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('5e2c742a-cc5e-5a42-ae22-2352ccbd46b7', '1bcb995a-540c-5c66-9b92-52471c43e587', 'title', 'zh', '文化散步与咖啡交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('3a52bf89-db02-54ac-9874-b89c9121616b', '1bcb995a-540c-5c66-9b92-52471c43e587', 'title', 'fr', 'Parcours culturel et cafe', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('dcb85612-b2c9-5f50-91a3-0faf759231f4', '1bcb995a-540c-5c66-9b92-52471c43e587', 'title', 'en', 'Culture walk and coffee exchange', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('0e1c0fbf-752e-57ef-85d3-57d621dab2f7', '1bcb995a-540c-5c66-9b92-52471c43e587', 'summary', 'zh', '以更轻松的方式开启第一次真实见面。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('7c7180ae-6b4c-5498-a7e7-23bae99e3009', '1bcb995a-540c-5c66-9b92-52471c43e587', 'summary', 'fr', 'Un format leger pour transformer le premier contact en rencontre reelle.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ba8888a7-4e0d-51b4-8507-b45795247927', '1bcb995a-540c-5c66-9b92-52471c43e587', 'summary', 'en', 'A lighter format for turning first contact into a real meeting.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('a8660d58-09f2-5386-ac94-b533611d7d4b', '1bcb995a-540c-5c66-9b92-52471c43e587', 'venue', 'zh', '欧洲区文化空间', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('fc89056c-2fb8-5f63-809a-62996a62111c', '1bcb995a-540c-5c66-9b92-52471c43e587', 'venue', 'fr', 'Espace culturel du quartier europeen', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('bed52f4a-ede5-5e6f-9b2f-e0e0fa1a0796', '1bcb995a-540c-5c66-9b92-52471c43e587', 'venue', 'en', 'European Quarter cultural venue', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('0b1dafff-c914-5fad-aeae-84445ce6408a', '1bcb995a-540c-5c66-9b92-52471c43e587', 'address', 'zh', '布鲁塞尔欧洲区舒曼广场 6 号', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('9e75b292-f73f-594b-91ef-3360faf17317', '1bcb995a-540c-5c66-9b92-52471c43e587', 'address', 'fr', '6 rond-point Schuman, 1040 Bruxelles', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f0ec33b0-e29a-5257-8495-4392883a45db', '1bcb995a-540c-5c66-9b92-52471c43e587', 'address', 'en', '6 Schuman Roundabout, 1040 Brussels', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('98c7abb6-1245-50ba-93dd-ea5878bef2f9', '1bcb995a-540c-5c66-9b92-52471c43e587', 'format', 'zh', '城市散步 + 交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('82ba3908-f9ac-5f75-9f14-5efe7c188264', '1bcb995a-540c-5c66-9b92-52471c43e587', 'format', 'fr', 'Balade urbaine + echanges', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('9a8802b6-8510-572a-bea3-db0f140aac5c', '1bcb995a-540c-5c66-9b92-52471c43e587', 'format', 'en', 'City walk plus discussion', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('431ae6c2-bae7-5819-b64f-7c8e4173f0d3', '1bcb995a-540c-5c66-9b92-52471c43e587', 'audience', 'zh', '适合首次参加平台活动的新会员', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('77a40a99-e124-5287-8e9c-f6626815321e', '1bcb995a-540c-5c66-9b92-52471c43e587', 'audience', 'fr', 'Ideal pour une premiere participation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('3e368fd6-5dfe-53d6-9c79-cf1d95748fcd', '1bcb995a-540c-5c66-9b92-52471c43e587', 'audience', 'en', 'Good for first-time participants', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20');

-- 3A.22 cm_event_note_items
insert into cm_event_note_items (id, event_id, sort_order, created_at, updated_at) values
  ('7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', '0ed043fe-531a-511d-940b-5daa55de963e', 1, '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('2b540c39-95cf-54d2-8ae6-6be251c4b254', '38f69abd-73b4-5464-8b07-a95a9bb58547', 1, '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ea365481-9ca7-5e19-b318-0193b796680b', '1bcb995a-540c-5c66-9b92-52471c43e587', 1, '2026-04-01 00:00:00', '2026-05-18 12:07:20');

-- 3A.23 cm_event_note_item_localized_fields
insert into cm_event_note_item_localized_fields (id, note_item_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('27006c38-cc71-548d-a6f0-a79588db75e6', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'title', 'zh', '策展说明', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('2942ca21-c90b-5284-874a-19fb26dbba53', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'description', 'zh', '策展人会在报名后确认资料完整度与参与节奏。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('b184551f-88d2-520f-b9f5-c01da77f9028', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'title', 'fr', 'Note du curateur', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('3a6cc4c7-09f9-591f-a5e1-ada9f44ed112', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'description', 'fr', 'Le curateur confirme le dossier et le rythme apres la demande.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('b9c9e650-5ed7-5193-b653-4ac465f41a52', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'title', 'en', 'Curator note', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('74cd14cc-5631-51e4-8cea-24f693ddaf51', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'description', 'en', 'A curator reviews profile readiness and pacing after submission.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('b1378a53-05a2-5234-9e48-1744b6571e76', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'title', 'zh', '参与说明', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ed59599d-45c7-5822-a54c-3e8952cbcea1', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'description', 'zh', '本场优先邀请已完成资料审核并适合晚餐节奏的会员。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('add5a691-2eaa-5aa8-8110-e62885034894', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'title', 'fr', 'Participation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('2f04bc8b-ed29-5a2c-8444-035eae17951f', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'description', 'fr', 'Priorite aux membres verifies et adaptes au format diner.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('8bdc86c9-d378-58b8-8266-b68bd98604d6', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'title', 'en', 'Participation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('cf9d72f1-d8f2-5128-a663-6d85f2886935', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'description', 'en', 'Priority is given to verified members suited to the dinner format.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('e9516d09-3ceb-51ad-8060-2f5324100aa4', 'ea365481-9ca7-5e19-b318-0193b796680b', 'title', 'zh', '首次参与', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('7ef98175-a68c-5bc5-a0bc-1613dd0c6fbd', 'ea365481-9ca7-5e19-b318-0193b796680b', 'description', 'zh', '适合第一次参加平台活动的会员，策展人会协助控制交流边界。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('2ced69f2-9f68-5554-9c74-8f4c943b98f8', 'ea365481-9ca7-5e19-b318-0193b796680b', 'title', 'fr', 'Premiere participation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ad08c502-3242-50ed-838f-4f5b8fd588a2', 'ea365481-9ca7-5e19-b318-0193b796680b', 'description', 'fr', 'Format adapte a une premiere participation, avec cadrage du curateur.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('271ab3ac-01aa-5472-8529-7ea920d172b5', 'ea365481-9ca7-5e19-b318-0193b796680b', 'title', 'en', 'First participation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('96e7cc06-478f-5c23-b18e-b767198957d2', 'ea365481-9ca7-5e19-b318-0193b796680b', 'description', 'en', 'Good for first participation, with curator-guided boundaries.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20');

-- 3A.24 cm_event_relationship_focuses
insert into cm_event_relationship_focuses (id, event_id, focus_order, locale, value, source, provider, status, created_at, updated_at) values
  ('02b6b13f-2190-5b84-b8e8-e3ccc1bb7b4a', '0ed043fe-531a-511d-940b-5daa55de963e', 0, 'zh', '跨文化关系', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('645200ac-4cfe-533a-bb30-d72d43b626cb', '0ed043fe-531a-511d-940b-5daa55de963e', 0, 'fr', 'Relations interculturelles', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('fae02a3f-70e2-5f68-8e75-cac1e834762f', '0ed043fe-531a-511d-940b-5daa55de963e', 0, 'en', 'Intercultural relationship', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('dd703583-84b2-51f4-b5ca-c65588f9432b', '0ed043fe-531a-511d-940b-5daa55de963e', 1, 'zh', '稳定发展', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('6619bbf6-67c8-5ec6-aabd-0611142f1bef', '0ed043fe-531a-511d-940b-5daa55de963e', 1, 'fr', 'Relation stable', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c6ba32b3-0d7c-583e-abd8-b83d50e7c56d', '0ed043fe-531a-511d-940b-5daa55de963e', 1, 'en', 'Stable development', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f330c8ad-0169-550a-9e6d-a9bfceab7ee5', '38f69abd-73b4-5464-8b07-a95a9bb58547', 0, 'zh', '线下确认', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('bd03385a-dec4-504e-93fc-255f0af0d0e7', '38f69abd-73b4-5464-8b07-a95a9bb58547', 0, 'fr', 'Validation hors ligne', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('5354683c-7344-5a03-b02b-46132fb00afd', '38f69abd-73b4-5464-8b07-a95a9bb58547', 0, 'en', 'Offline confirmation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('50824732-8ca6-5de5-9c6f-9b7b0c63e0b9', '38f69abd-73b4-5464-8b07-a95a9bb58547', 1, 'zh', '高质量晚餐局', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('bb196efd-cd18-5d2a-adba-5bbd82e93b2d', '38f69abd-73b4-5464-8b07-a95a9bb58547', 1, 'fr', 'Diner selectif', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('56874f81-cc0c-5fd2-bbcf-1564f556e805', '38f69abd-73b4-5464-8b07-a95a9bb58547', 1, 'en', 'Curated dinner', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('61f83db8-3975-5c62-ac44-333c1187e7c3', '1bcb995a-540c-5c66-9b92-52471c43e587', 0, 'zh', '首次见面', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('bd0d5c4f-988c-5e59-a0b4-98d29dd5f38e', '1bcb995a-540c-5c66-9b92-52471c43e587', 0, 'fr', 'Premiere rencontre', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('eda7f6fd-c9ca-5d60-85db-e5c99bf5fd68', '1bcb995a-540c-5c66-9b92-52471c43e587', 0, 'en', 'First meeting', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('3aa28729-14c1-5b77-b0fd-7055c9024a89', '1bcb995a-540c-5c66-9b92-52471c43e587', 1, 'zh', '轻量交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('1cc6dfad-3f60-5362-bd0d-7c99a8972462', '1bcb995a-540c-5c66-9b92-52471c43e587', 1, 'fr', 'Echange leger', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('99afc51e-defa-51cd-94b4-88f99f66f0de', '1bcb995a-540c-5c66-9b92-52471c43e587', 1, 'en', 'Light conversation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20');

-- 3A.25 cm_event_language_codes
insert into cm_event_language_codes (event_id, language_code) values
  ('0ed043fe-531a-511d-940b-5daa55de963e', 'zh'),
  ('0ed043fe-531a-511d-940b-5daa55de963e', 'fr'),
  ('0ed043fe-531a-511d-940b-5daa55de963e', 'en'),
  ('38f69abd-73b4-5464-8b07-a95a9bb58547', 'zh'),
  ('38f69abd-73b4-5464-8b07-a95a9bb58547', 'fr'),
  ('38f69abd-73b4-5464-8b07-a95a9bb58547', 'en'),
  ('1bcb995a-540c-5c66-9b92-52471c43e587', 'fr'),
  ('1bcb995a-540c-5c66-9b92-52471c43e587', 'en');

-- 3A.26 cm_event_agenda_items
insert into cm_event_agenda_items (id, event_id, agenda_time, sort_order, created_at, updated_at) values
  ('5853a71e-9a57-5126-82da-bc25a7afb75e', '0ed043fe-531a-511d-940b-5daa55de963e', '18:30 - 19:00', 1, '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('dd835cd9-df78-552a-aa5b-1c5bf84e595c', '0ed043fe-531a-511d-940b-5daa55de963e', '19:00 - 19:45', 2, '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('24bb39e8-5b41-56a5-9270-a600375767dd', '38f69abd-73b4-5464-8b07-a95a9bb58547', '19:00 - 19:30', 1, '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('843e88fb-bf21-593f-a3b0-094f9c75edf9', '1bcb995a-540c-5c66-9b92-52471c43e587', '14:30 - 15:00', 1, '2026-04-01 00:00:00', '2026-05-01 00:00:00');

-- 3A.27 cm_event_agenda_item_localized_fields
insert into cm_event_agenda_item_localized_fields (id, agenda_item_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('7e440946-e3a2-5c8d-8cd3-aefbe83e0450', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'title', 'zh', '签到与活动说明', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('a1831cd3-6a85-5aea-80db-3cd4f6af3749', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'title', 'fr', 'Accueil et cadrage de l evenement', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f764a51b-9fe0-5df7-8f81-0c6ff471bb89', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'title', 'en', 'Check-in and event framing', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('3bfbf9ea-e02b-5c58-a6d7-def409b960c1', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'description', 'zh', '确认到场信息并说明当晚节奏。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('018e46ee-6f02-581e-9d79-35175fb6b7a3', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'description', 'fr', 'Verification des arrivees et du rythme de la soiree.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('9baf8055-f075-5281-8fe0-a76207d7e1fd', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'description', 'en', 'Arrival verification and evening pacing overview.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('27b85a30-24c0-5f53-8e8d-8b8a51f136ca', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'title', 'zh', '主题小组交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('bd2913a2-8683-523f-8d30-25c9e4001c12', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'title', 'fr', 'Echanges thematiques', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('448fe0b6-424d-56dc-b657-d088d767f772', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'title', 'en', 'Themed small-group exchange', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ef1d4784-372a-5b70-b373-863bad51edcc', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'description', 'zh', '围绕关系、工作和城市生活展开交流。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('57c2cd3e-e2a0-5ec1-b138-987622b72456', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'description', 'fr', 'Echanges autour des relations, du travail et de la vie urbaine.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c8cf352c-f38d-52c8-b3b2-c1d29b63a6ea', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'description', 'en', 'Conversation around relationships, work, and city life.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('e8595393-375c-58bd-8946-ab507f1d2909', '24bb39e8-5b41-56a5-9270-a600375767dd', 'title', 'zh', '入场与座位安排', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('02aa8a47-4144-5c9c-8cf4-c3ed68dbe04b', '24bb39e8-5b41-56a5-9270-a600375767dd', 'title', 'fr', 'Accueil et placement', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('fdec08d4-8925-5402-a22c-767879e593af', '24bb39e8-5b41-56a5-9270-a600375767dd', 'title', 'en', 'Arrival and seating', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('32a74c47-9134-50ec-a52d-0ff9c0a19a33', '24bb39e8-5b41-56a5-9270-a600375767dd', 'description', 'zh', '晚餐节奏与边界说明。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ba046c75-70b5-5ea1-825a-9d9dd66ff2ee', '24bb39e8-5b41-56a5-9270-a600375767dd', 'description', 'fr', 'Rappel du cadre et du rythme du diner.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c44249b9-4eba-533f-b63e-4507d3b43497', '24bb39e8-5b41-56a5-9270-a600375767dd', 'description', 'en', 'Briefing on boundaries and dinner pacing.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('41683288-70b2-5cc6-8f72-e9df0aec16a4', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'title', 'zh', '集合与路线说明', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('e2666abc-e5b8-58cb-a704-01121ce625a3', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'title', 'fr', 'Rassemblement et briefing', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('a0a3ddc8-c76f-5e20-941c-0c9ae4e04113', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'title', 'en', 'Meet-up and route briefing', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('280fd9e6-3220-53bf-a967-d47c88d173f7', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'description', 'zh', '路线与交流节奏说明。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('1be260fc-52d1-505d-ae95-8a2888c880b5', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'description', 'fr', 'Rappel du parcours et du rythme d echange.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('b3ede8cb-287b-5574-9c76-fe48837fe4d9', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'description', 'en', 'Overview of the route and interaction rhythm.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20');

-- 3A.28 cm_event_registrations
insert into cm_event_registrations (id, user_id, event_id, status, requested_at, confirmed_at, declined_at, waitlisted_at, cancelled_at, attended_at, event_quota_consumed_at, event_quota_released_at, created_at, updated_at) values
  ('f44520c6-d6c7-5a4a-a6a2-40aada7743c6', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '0ed043fe-531a-511d-940b-5daa55de963e', 'cancelled', '2026-05-01 09:00:00', '2026-05-14 01:01:44', null, null, '2026-05-14 01:01:46', null, null, null, '2026-05-01 09:00:00', '2026-05-14 01:01:46'),
  ('85c16633-87ee-5350-9667-b5ec96f2b9e8', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'cancelled', '2026-05-01 09:00:00', null, null, null, '2026-05-14 00:37:05', null, null, null, '2026-05-01 09:00:00', '2026-05-14 00:37:05'),
  ('6dcca5e8-969b-5f47-9277-b56dbd051330', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '1bcb995a-540c-5c66-9b92-52471c43e587', 'cancelled', '2026-05-28 21:28:47', null, null, null, '2026-05-28 21:28:48', null, null, null, '2026-05-17 11:01:31', '2026-05-28 21:28:48');

-- 3A.29 cm_favorite_profiles
insert into cm_favorite_profiles (id, user_id, profile_id, created_at, updated_at) values
  ('98ddc269-dbdc-59d7-a1af-9ef27381be0e', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '506ce3c7-b236-5b44-b8d0-459c4250ea03', '2026-03-12 00:00:00', '2026-03-12 00:00:00'),
  ('f658d6c2-87e9-5f5f-b1d5-9562d3cdbf21', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', '2026-03-28 00:00:00', '2026-03-28 00:00:00');

-- 3A.30 cm_private_introduction_requests
insert into cm_private_introduction_requests (id, requester_user_id, requester_profile_id, target_profile_id, status, message, requested_at, expires_at, responded_at, cooldown_until, entitlement_balance_id, created_at, updated_at) values
  ('426dda67-8ff8-52f7-8426-558af6b32f0b', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', null, 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'accepted', null, '2026-05-23 21:31:05', null, '2026-05-27 23:47:13', null, null, '2026-05-23 21:31:05', '2026-05-27 23:47:13');

-- 3A.32 cm_inbox_threads
insert into cm_inbox_threads (id, user_id, category, subject_type, subject_id, status, created_at, updated_at) values
  ('b8ce280f-3553-56b7-999f-d9cb6caa3acf', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'system', 'profile', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'open', '2026-05-20 09:00:00', '2026-05-28 08:30:00'),
  ('d85453a8-274f-566e-8343-e2534ae2fed7', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'system', null, null, 'open', '2026-05-28 06:00:00', '2026-06-01 09:00:00'),
  ('b7698c02-482b-52ce-9c48-ecd94d0a45b1', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'system', 'event', '0ed043fe-531a-511d-940b-5daa55de963e', 'open', '2026-05-25 14:00:00', '2026-05-27 10:00:00');

-- 3A.33 cm_inbox_messages
insert into cm_inbox_messages (id, thread_id, sender_type, sender_user_id, message_type, body, template_code, template_locale, action_type, action_payload, created_at, updated_at) values
  ('dafef4e8-ea97-5808-952a-fcb763a9ee8e', 'b8ce280f-3553-56b7-999f-d9cb6caa3acf', 'system', null, 'system_notice', '你的资料 p-001 平台审核已通过，现状态变更为 open。', 'profile_review_approved', 'zh', null, null, '2026-05-20 09:00:00', '2026-05-20 09:00:00'),
  ('e1b35056-d725-5437-8f19-9590a8edc873', 'b8ce280f-3553-56b7-999f-d9cb6caa3acf', 'system', null, 'text', '你的资料已完成身份认证，可信度已提升。', 'identity_verified', 'zh', null, null, '2026-05-28 08:30:00', '2026-05-28 08:30:00'),
  ('42e5b69a-ad71-56c4-9394-d6b67170e563', 'b7698c02-482b-52ce-9c48-ecd94d0a45b1', 'system', null, 'system_notice', '你报名的活动《巴黎春季交流酒会》报名已确认。', 'event_registration_confirmed', 'zh', null, null, '2026-05-25 14:00:00', '2026-05-25 14:00:00'),
  ('f4a77fc1-6370-5719-b596-b4ea5c0e0c14', 'b7698c02-482b-52ce-9c48-ecd94d0a45b1', 'system', null, 'text', '活动地址：巴黎 8 区 Rue du Faubourg Saint-Honore 25 号。请提前 15 分钟到场。', 'event_reminder', 'zh', null, null, '2026-05-27 10:00:00', '2026-05-27 10:00:00'),
  ('0fc92207-16a5-5a1f-ae42-cc856d2b40a6', 'd85453a8-274f-566e-8343-e2534ae2fed7', 'system', null, 'text', '欢迎使用相约巴黎！你可以创建资料、浏览活动、收藏感兴趣的会员。', 'welcome_message', 'zh', null, null, '2026-05-28 06:00:00', '2026-05-28 06:00:00');

-- 3A.34 cm_inbox_reads
insert into cm_inbox_reads (id, thread_id, user_id, last_read_at, created_at, updated_at) values
  ('59a024c0-aa7b-5075-8dcc-d13d777318a0', 'd85453a8-274f-566e-8343-e2534ae2fed7', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-05-28 07:00:00', '2026-05-28 07:00:00', '2026-05-28 07:00:00'),
  ('58938e35-a25f-57f3-816b-047224a3777d', 'b8ce280f-3553-56b7-999f-d9cb6caa3acf', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-05-28 00:13:32', '2026-05-28 00:13:32', '2026-05-28 00:13:32');

-- 3A.35 Inbox admin dispatch records
insert into cm_inbox_broadcasts (id, staff_user_id, scope, tier, mode, template_code, locale, subject_type, payload_json, target_count, success_count, failure_count, created_at, updated_at) values
  ('a5000000-0000-4000-8000-000000000001', '13', 'membership_tier', 'gold', 'template', 'welcome_message', 'zh', null, '{"scope":"membership_tier","tier":"gold","templateCode":"welcome_message","locale":"zh"}', 2, 1, 1, '2026-06-02 09:00:00', '2026-06-02 09:00:30');

insert into cm_inbox_broadcast_targets (id, broadcast_id, user_id, message_id, status, error_message, retry_count, next_retry_at, created_at) values
  ('a5100000-0000-4000-8000-000000000001', 'a5000000-0000-4000-8000-000000000001', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '0fc92207-16a5-5a1f-ae42-cc856d2b40a6', 'success', null, 0, null, '2026-06-02 09:00:01'),
  ('a5100000-0000-4000-8000-000000000002', 'a5000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000003', null, 'retrying', 'temporary_inbox_write_failure', 1, '2026-06-02 09:05:00', '2026-06-02 09:00:30');

insert into cm_inbox_single_dispatches (id, staff_user_id, user_id, message_id, mode, template_code, locale, subject_type, subject_id, payload_json, status, error_message, retry_count, next_retry_at, created_at, updated_at) values
  ('a5200000-0000-4000-8000-000000000001', '13', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'e1b35056-d725-5437-8f19-9590a8edc873', 'template', 'verification_approved', 'zh', 'profile', '503a9c99-2842-54db-8858-24fbd3108e3b', '{"templateCode":"verification_approved","variables":{"verificationType":"身份"}}', 'success', null, 0, null, '2026-05-28 08:30:00', '2026-05-28 08:30:00'),
  ('a5200000-0000-4000-8000-000000000002', '13', 'b0000000-0000-4000-8000-000000000001', null, 'custom', null, 'fr', null, null, '{"body":"Merci pour votre message, notre equipe reviendra vers vous."}', 'retrying', 'temporary_inbox_write_failure', 1, '2026-06-02 09:10:00', '2026-06-02 09:05:00', '2026-06-02 09:05:00');

insert into cm_inbox_system_failures (id, user_id, template_code, variables_json, subject_id, dedupe_key, status, retry_count, next_retry_at, error_message, created_at, updated_at) values
  ('a5300000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000003', 'event_reminder_24h', '{"eventTitle":"巴黎春季交流酒会","startsAt":"2026-05-12 18:30"}', '0ed043fe-531a-511d-940b-5daa55de963e', 'event_reminder_24h:b0000000-0000-4000-8000-000000000003:0ed043fe-531a-511d-940b-5daa55de963e', 'pending', 2, '2026-06-02 09:15:00', 'temporary_inbox_write_failure', '2026-06-02 09:00:00', '2026-06-02 09:10:00');

-- ============================================================================
-- Additional admin review demo data
-- ============================================================================

-- 4A. Review workflow users
insert into cm_users (id, account_name, avatar_url, preferred_locale, alias_word_code, alias_tag, status, created_at, updated_at) values
  ('90000000-0000-4000-8000-000000000001', 'Aline Durand', '', 'fr', 'quiet_breeze', 'M14Q', 'active', now(), now()),
  ('90000000-0000-4000-8000-000000000002', 'Julien Chen', '', 'zh', 'warm_sunrise', 'T62L', 'active', now(), now()),
  ('90000000-0000-4000-8000-000000000003', 'Élise Bernard', '', 'fr', 'clear_moonlight', 'B08N', 'active', now(), now());

insert into cm_auth_identities (id, user_id, provider, identifier, password_hash, verified_at, created_at, updated_at) values
  ('a6000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000001', 'email', 'aline.durand@rencontreaparis.test', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', now(), now(), now()),
  ('a6000000-0000-4000-8000-000000000002', '90000000-0000-4000-8000-000000000002', 'email', 'julien.chen@rencontreaparis.test', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', now(), now(), now()),
  ('a6000000-0000-4000-8000-000000000003', '90000000-0000-4000-8000-000000000003', 'email', 'elise.bernard@rencontreaparis.test', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', now(), now(), now());

insert into cm_user_preferences (id, user_id, preferred_city_code, preferred_contact_channel, staff_contact_enabled, family_assist_enabled, introduction_updates_enabled, event_reminders_enabled, service_announcements_enabled, marketing_emails_enabled, analytics_consent_enabled, created_at, updated_at) values
  ('a6100000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000001', 'FR:paris', 'email', 1, 0, 1, 1, 1, 0, 0, now(), now()),
  ('a6100000-0000-4000-8000-000000000002', '90000000-0000-4000-8000-000000000002', 'CN:shanghai', 'email', 1, 1, 1, 1, 1, 0, 0, now(), now()),
  ('a6100000-0000-4000-8000-000000000003', '90000000-0000-4000-8000-000000000003', 'FR:lyon', 'email', 1, 0, 1, 1, 1, 0, 0, now(), now());

insert into cm_user_agreement_acceptances (id, user_id, document_type, document_version, accepted_at, created_at) values
  ('a6200000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000001', 'terms', '1.0', now(), now()),
  ('a6200000-0000-4000-8000-000000000002', '90000000-0000-4000-8000-000000000001', 'privacy', '1.0', now(), now()),
  ('a6200000-0000-4000-8000-000000000003', '90000000-0000-4000-8000-000000000002', 'terms', '1.0', now(), now()),
  ('a6200000-0000-4000-8000-000000000004', '90000000-0000-4000-8000-000000000002', 'privacy', '1.0', now(), now()),
  ('a6200000-0000-4000-8000-000000000005', '90000000-0000-4000-8000-000000000003', 'terms', '1.0', now(), now()),
  ('a6200000-0000-4000-8000-000000000006', '90000000-0000-4000-8000-000000000003', 'privacy', '1.0', now(), now());

insert into cm_user_memberships (id, user_id, plan_id, tier, status, started_at, expires_at, created_at, updated_at) values
  ('a6300000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000001', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'free', 'active', now(), null, now(), now()),
  ('a6300000-0000-4000-8000-000000000002', '90000000-0000-4000-8000-000000000002', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'free', 'active', now(), null, now(), now()),
  ('a6300000-0000-4000-8000-000000000003', '90000000-0000-4000-8000-000000000003', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'free', 'active', now(), null, now(), now());

-- 4B. Admin review profiles
insert into cm_profiles (
  id, profile_type, gender, birth_year, height, city_code, country_code, nationality_code,
  profile_status, last_active_at, family_visible, degree_level, education_code, industry_code,
  relationship_goal_code, residence_plan_code, preferred_education_code, family_life_code, exercise_code,
  marital_status, has_children, children_plan, accepts_long_distance, dating_intention_code,
  relocation, preferred_age_min, preferred_age_max, preferred_location, smoking, drinking,
  activity_level, weekend_style, pets, communication_style, archived_at, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111111111', 'self', 'female', 1994, 168, 'FR:paris', 'FR', 'CN',
   'review', now(), 0, 'master', 'master_business', 'technology',
   'other', 'other', 'other', 'other', 'other',
   'never_married', 0, 'open_to_discuss', 1, 'marriage',
   'open_to_discuss', 30, 38, 'international', 'never', 'social',
   'moderate', 'social', 'likes', 'direct', null, now(), now()),
  ('22222222-2222-4222-8222-222222222222', 'family', 'male', 1990, 180, 'CN:shanghai', 'CN', 'CN',
   'open', now(), 1, 'bachelor', 'bachelor_engineering', 'finance',
   'other', 'other', 'other', 'other', 'other',
   'never_married', 0, 'wants', 0, 'serious',
   'willing', 28, 36, 'regional', 'never', 'never',
   'high', 'outdoors', 'none', 'balanced', null, now(), now()),
  ('33333333-3333-4333-8333-333333333333', 'self', 'female', 1988, 165, 'FR:lyon', 'FR', 'FR',
   'review', now(), 0, 'phd', 'phd', 'education',
   'other', 'other', 'other', 'other', 'other',
   'divorced', 1, 'does_not_want', 1, 'cross_border',
   'open_to_discuss', 35, 45, 'international', 'never', 'social',
   'moderate', 'indoors', 'has', 'indirect', null, now(), now());

-- 4C. Profile ownerships
insert into cm_profile_ownerships (
  id, user_id, profile_id, relationship_to_profile, permission, status,
  invited_by_user_id, accepted_at, revoked_at, created_at, updated_at
) values
  ('91000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'self', 'owner', 'active', null, now(), null, now(), now()),
  ('91000000-0000-4000-8000-000000000002', '90000000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'mother', 'manager', 'active', null, now(), null, now(), now()),
  ('91000000-0000-4000-8000-000000000003', '90000000-0000-4000-8000-000000000003', '33333333-3333-4333-8333-333333333333', 'self', 'owner', 'active', null, now(), null, now(), now());

insert into cm_profile_languages (profile_id, language_code) values
  ('11111111-1111-4111-8111-111111111111', 'ZH'),
  ('11111111-1111-4111-8111-111111111111', 'FR'),
  ('11111111-1111-4111-8111-111111111111', 'EN'),
  ('22222222-2222-4222-8222-222222222222', 'ZH'),
  ('22222222-2222-4222-8222-222222222222', 'EN'),
  ('33333333-3333-4333-8333-333333333333', 'FR'),
  ('33333333-3333-4333-8333-333333333333', 'EN'),
  ('33333333-3333-4333-8333-333333333333', 'ZH');

-- 4D. Internal records
insert into cm_profile_internal_records (id, profile_id, is_featured, source, updated_by_user_id, created_at, updated_at) values
  ('92000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 0, 'self_submitted', null, now(), now()),
  ('92000000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 0, 'family_submitted', null, now(), now()),
  ('92000000-0000-4000-8000-000000000003', '33333333-3333-4333-8333-333333333333', 0, 'self_submitted', null, now(), now());

-- 4E. Localized fields
insert into cm_profile_localized_fields (id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('93000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'profile_name', 'zh', '巴黎科技产品经理', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'profile_name', 'fr', 'Cheffe de produit tech a Paris', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'profile_name', 'en', 'Paris tech product manager', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000008', '11111111-1111-4111-8111-111111111111', 'career_direction', 'zh', '产品经理', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000023', '11111111-1111-4111-8111-111111111111', 'career_direction', 'fr', 'Product manager', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000024', '11111111-1111-4111-8111-111111111111', 'career_direction', 'en', 'Product manager', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000009', '11111111-1111-4111-8111-111111111111', 'summary', 'zh', '重视跨文化沟通和稳定节奏，适合验证待审核资料、认证材料和审核流转。', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000010', '11111111-1111-4111-8111-111111111111', 'summary', 'fr', 'Valorise la communication interculturelle et un rythme stable; utile pour verifier le parcours de moderation.', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000011', '11111111-1111-4111-8111-111111111111', 'summary', 'en', 'Values intercultural communication and steady pacing; useful for reviewing moderation flows.', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000101', '22222222-2222-4222-8222-222222222222', 'profile_name', 'zh', '上海金融科技顾问', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000102', '22222222-2222-4222-8222-222222222222', 'profile_name', 'fr', 'Conseiller fintech a Shanghai', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000103', '22222222-2222-4222-8222-222222222222', 'profile_name', 'en', 'Shanghai fintech advisor', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000106', '22222222-2222-4222-8222-222222222222', 'career_direction', 'zh', '投融资', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000121', '22222222-2222-4222-8222-222222222222', 'career_direction', 'fr', 'Investissement et financement', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000122', '22222222-2222-4222-8222-222222222222', 'career_direction', 'en', 'Investment and financing', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000107', '22222222-2222-4222-8222-222222222222', 'summary', 'zh', '由家人协助维护资料，资料已开放但照片仍需审核，适合验证家庭代建流程。', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000123', '22222222-2222-4222-8222-222222222222', 'summary', 'fr', 'Profil gere avec l aide de la famille; les informations sont ouvertes mais la photo attend encore une validation.', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000124', '22222222-2222-4222-8222-222222222222', 'summary', 'en', 'Family-assisted profile; profile details are open while the photo is still pending review.', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000201', '33333333-3333-4333-8333-333333333333', 'profile_name', 'zh', '里昂公共政策研究员', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000202', '33333333-3333-4333-8333-333333333333', 'profile_name', 'fr', 'Chercheuse en politiques publiques a Lyon', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000203', '33333333-3333-4333-8333-333333333333', 'profile_name', 'en', 'Lyon public policy researcher', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000206', '33333333-3333-4333-8333-333333333333', 'career_direction', 'zh', '公共政策研究', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000221', '33333333-3333-4333-8333-333333333333', 'career_direction', 'fr', 'Recherche en politiques publiques', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000222', '33333333-3333-4333-8333-333333333333', 'career_direction', 'en', 'Public policy research', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000207', '33333333-3333-4333-8333-333333333333', 'summary', 'zh', '关注公共议题和长期承诺，当前学历认证需补充更清晰材料。', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000223', '33333333-3333-4333-8333-333333333333', 'summary', 'fr', 'S interesse aux enjeux publics et aux engagements durables; le justificatif d etudes doit etre renvoye plus lisiblement.', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000224', '33333333-3333-4333-8333-333333333333', 'summary', 'en', 'Focused on public issues and long-term commitment; education proof needs a clearer resubmission.', 'manual', 'human', 'ready', now(), now());

-- 4F. Option extra texts
insert into cm_profile_option_extra_texts (id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('93000000-0000-4000-8000-000000000018', '11111111-1111-4111-8111-111111111111', 'education', 'zh', '商学院', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000019', '11111111-1111-4111-8111-111111111111', 'education', 'fr', 'Ecole de commerce', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000020', '11111111-1111-4111-8111-111111111111', 'education', 'en', 'Business school', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000007', '11111111-1111-4111-8111-111111111111', 'industry', 'zh', '科技产品', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000021', '11111111-1111-4111-8111-111111111111', 'industry', 'fr', 'Produit tech', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000022', '11111111-1111-4111-8111-111111111111', 'industry', 'en', 'Tech product', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000116', '22222222-2222-4222-8222-222222222222', 'education', 'zh', '工程', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000117', '22222222-2222-4222-8222-222222222222', 'education', 'fr', 'Ingenierie', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000118', '22222222-2222-4222-8222-222222222222', 'education', 'en', 'Engineering', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000105', '22222222-2222-4222-8222-222222222222', 'industry', 'zh', '金融科技', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000119', '22222222-2222-4222-8222-222222222222', 'industry', 'fr', 'Fintech', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000120', '22222222-2222-4222-8222-222222222222', 'industry', 'en', 'Fintech', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000216', '33333333-3333-4333-8333-333333333333', 'education', 'zh', '公共政策', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000217', '33333333-3333-4333-8333-333333333333', 'education', 'fr', 'Politiques publiques', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000218', '33333333-3333-4333-8333-333333333333', 'education', 'en', 'Public policy', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000205', '33333333-3333-4333-8333-333333333333', 'industry', 'zh', '教育研究', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000219', '33333333-3333-4333-8333-333333333333', 'industry', 'fr', 'Recherche en education', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000220', '33333333-3333-4333-8333-333333333333', 'industry', 'en', 'Education research', 'manual', 'human', 'ready', now(), now());

-- 4G. Localized items
insert into cm_profile_localized_items (id, profile_id, field_name, item_order, locale, value, source, provider, status, created_at, updated_at) values
  ('94000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'tags', 0, 'zh', '待审核', 'manual', 'human', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'tags', 0, 'fr', 'A moderer', 'machine', 'translation_api', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'tags', 0, 'en', 'Pending review', 'machine', 'translation_api', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000004', '22222222-2222-4222-8222-222222222222', 'tags', 0, 'zh', '照片待审', 'manual', 'human', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000005', '33333333-3333-4333-8333-333333333333', 'tags', 0, 'zh', '认证待审', 'manual', 'human', 'ready', now(), now());

-- 4H. Photos
insert into cm_profile_photos (id, profile_id, url, is_primary, sort_order, status, created_at, updated_at) values
  ('aaaa1111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'https://picsum.photos/seed/admin-review-a-1/900/1200', 1, 1, 'review', now(), now()),
  ('aaaa2222-2222-4222-8222-222222222222', '22222222-2222-4222-8222-222222222222', 'https://picsum.photos/seed/admin-review-b-1/900/1200', 1, 1, 'review', now(), now()),
  ('aaaa3333-3333-4333-8333-333333333333', '33333333-3333-4333-8333-333333333333', 'https://picsum.photos/seed/admin-review-c-1/900/1200', 1, 1, 'review', now(), now());

-- 4I. Verifications
insert into cm_profile_verifications (
  id, profile_id, legal_name, date_of_birth, identity_status, education_status,
  income_status, marital_status, review_status, verified_at, verified_by_user_id,
  created_at, updated_at
) values
  ('95000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'Aline Durand', '1994-03-12', 'pending', 'pending', 'pending', 'pending', 'pending', null, null, now(), now()),
  ('95000000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'Julien Chen', '1990-08-20', 'verified', 'verified', 'verified', 'verified', 'approved', now(), '1', now(), now()),
  ('95000000-0000-4000-8000-000000000003', '33333333-3333-4333-8333-333333333333', 'Élise Bernard', '1988-11-05', 'pending', 'rejected', 'pending', 'unverified', 'pending', null, null, now(), now());

-- 4J. Verification materials
insert into cm_profile_verification_materials (
  id, profile_id, material_type, status, legal_name, date_of_birth,
  material_name, material_url, scan_status, scan_message, review_note,
  submitted_by_user_id, submitted_at, reviewed_by_user_id, reviewed_at, rejection_reason, created_at, updated_at
) values
  ('96000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'identity', 'pending', 'Aline Durand', '1994-03-12',
   '护照首页照片', 'private://verification/11111111/identity/passport-front-20260615.jpg', 'passed', null, '用户提交身份证明信息。',
   '90000000-0000-4000-8000-000000000001', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'education', 'pending', null, null,
   '硕士学位证书', 'private://verification/11111111/education/master-diploma-20260615.pdf', 'passed', null, '法国商学院硕士材料。',
   '90000000-0000-4000-8000-000000000001', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'income', 'pending', null, null,
   '近一年税单', 'private://verification/11111111/income/tax-statement-2025.pdf', 'passed', null, '近一年收入证明。',
   '90000000-0000-4000-8000-000000000001', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111', 'marital', 'pending', null, null,
   '未婚声明', 'private://verification/11111111/marital/single-status-declaration.pdf', 'passed', null, '婚姻状态声明。',
   '90000000-0000-4000-8000-000000000001', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000005', '22222222-2222-4222-8222-222222222222', 'identity', 'approved', 'Julien Chen', '1990-08-20',
   '身份证正反面', 'private://verification/22222222/identity/id-card-combined.png', 'passed', null, '历史通过材料。',
   '90000000-0000-4000-8000-000000000002', now(), '1', now(), null, now(), now()),
  ('96000000-0000-4000-8000-000000000006', '22222222-2222-4222-8222-222222222222', 'education', 'approved', null, null,
   '本科学位证书', 'private://verification/22222222/education/bachelor-degree.pdf', 'passed', null, '历史通过材料。',
   '90000000-0000-4000-8000-000000000002', now(), '1', now(), null, now(), now()),
  ('96000000-0000-4000-8000-000000000007', '33333333-3333-4333-8333-333333333333', 'identity', 'pending', 'Élise Bernard', '1988-11-05',
   '护照扫描件', 'private://verification/33333333/identity/passport-scan-20260615.pdf', 'passed', null, '用户重新提交身份信息。',
   '90000000-0000-4000-8000-000000000003', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000008', '33333333-3333-4333-8333-333333333333', 'education', 'rejected', null, null,
   '博士学位证书', 'private://verification/33333333/education/phd-degree-blurry.jpg', 'passed', null, '扫描件不清晰。',
   '90000000-0000-4000-8000-000000000003', now(), '1', now(), '图片不清晰，请重新上传。', now(), now()),
  ('96000000-0000-4000-8000-000000000009', '33333333-3333-4333-8333-333333333333', 'income', 'pending', null, null,
   '自由职业收入说明', 'private://verification/33333333/income/freelance-income-statement.pdf', 'passed', null, '自由职业收入说明。',
   '90000000-0000-4000-8000-000000000003', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000010', '33333333-3333-4333-8333-333333333333', 'marital', 'approved', null, null,
   '离婚证明', 'private://verification/33333333/marital/divorce-certificate.pdf', 'passed', null, '历史通过材料。',
   '90000000-0000-4000-8000-000000000003', now(), '1', now(), null, now(), now()),
  ('96000000-0000-4000-8000-000000000011', '22222222-2222-4222-8222-222222222222', 'income', 'approved', null, null,
   '雇主收入证明', 'private://verification/22222222/income/employer-income-letter.pdf', 'passed', null, 'HR 出具收入证明。',
   '90000000-0000-4000-8000-000000000002', now(), '1', now(), null, now(), now()),
  ('96000000-0000-4000-8000-000000000012', '22222222-2222-4222-8222-222222222222', 'marital', 'rejected', null, null,
   '婚姻状态截图', 'private://verification/22222222/marital/marital-status-screenshot.webp', 'passed', null, '材料缺少官方抬头。',
   '90000000-0000-4000-8000-000000000002', now(), '1', now(), '材料类型不符合认证要求。', now(), now());

-- ============================================================================
-- Additional varied-status demo data
-- ============================================================================

-- 5A. Extra users (varied statuses)
insert into cm_users (id, account_name, avatar_url, preferred_locale, alias_word_code, alias_tag, status, created_at, updated_at) values
  ('d0000000-0000-4000-8000-000000000004', 'Marc Lefèvre', '', 'fr', 'blue_horizon', 'R35D', 'deactivated', '2026-03-15 00:00:00', '2026-05-01 00:00:00'),
  ('e0000000-0000-4000-8000-000000000005', 'Nina Roche', '', 'fr', 'soft_rain', 'H91S', 'suspended', '2026-04-01 00:00:00', '2026-06-01 00:00:00'),
  ('f0000000-0000-4000-8000-000000000006', 'Hugo Lambert', '', 'fr', 'forest_echo', 'P40W', 'active', now(), now());

insert into cm_auth_identities (id, user_id, provider, identifier, password_hash, verified_at, created_at, updated_at) values
  ('a7000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000004', 'email', 'marc.lefevre@rencontreaparis.test', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', '2026-03-15 00:00:00', '2026-03-15 00:00:00', '2026-03-15 00:00:00'),
  ('a7000000-0000-4000-8000-000000000002', 'e0000000-0000-4000-8000-000000000005', 'email', 'nina.roche@rencontreaparis.test', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', '2026-04-01 00:00:00', '2026-04-01 00:00:00', '2026-04-01 00:00:00'),
  ('a7000000-0000-4000-8000-000000000003', 'f0000000-0000-4000-8000-000000000006', 'email', 'hugo.lambert@rencontreaparis.test', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', now(), now(), now());

insert into cm_user_preferences (id, user_id, preferred_city_code, preferred_contact_channel, staff_contact_enabled, family_assist_enabled, introduction_updates_enabled, event_reminders_enabled, service_announcements_enabled, marketing_emails_enabled, analytics_consent_enabled, created_at, updated_at) values
  ('a7100000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000004', 'FR:lyon', 'email', 0, 0, 0, 0, 0, 0, 0, '2026-03-15 00:00:00', '2026-05-01 00:00:00'),
  ('a7100000-0000-4000-8000-000000000002', 'e0000000-0000-4000-8000-000000000005', 'FR:nice', 'email', 0, 0, 0, 0, 0, 0, 0, '2026-04-01 00:00:00', '2026-06-01 00:00:00'),
  ('a7100000-0000-4000-8000-000000000003', 'f0000000-0000-4000-8000-000000000006', 'FR:marseille', 'email', 1, 1, 1, 1, 1, 0, 0, now(), now());

insert into cm_user_agreement_acceptances (id, user_id, document_type, document_version, accepted_at, created_at) values
  ('a7200000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000004', 'terms', '1.0', '2026-03-15 00:00:00', '2026-03-15 00:00:00'),
  ('a7200000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000004', 'privacy', '1.0', '2026-03-15 00:00:00', '2026-03-15 00:00:00'),
  ('a7200000-0000-4000-8000-000000000003', 'e0000000-0000-4000-8000-000000000005', 'terms', '1.0', '2026-04-01 00:00:00', '2026-04-01 00:00:00'),
  ('a7200000-0000-4000-8000-000000000004', 'e0000000-0000-4000-8000-000000000005', 'privacy', '1.0', '2026-04-01 00:00:00', '2026-04-01 00:00:00'),
  ('a7200000-0000-4000-8000-000000000005', 'f0000000-0000-4000-8000-000000000006', 'terms', '1.0', now(), now()),
  ('a7200000-0000-4000-8000-000000000006', 'f0000000-0000-4000-8000-000000000006', 'privacy', '1.0', now(), now());

-- 5B. Extra profiles (varied statuses)
insert into cm_profiles (
  id, profile_type, gender, birth_year, height, city_code, country_code, nationality_code,
  profile_status, last_active_at, family_visible, degree_level, education_code, industry_code,
  relationship_goal_code, residence_plan_code, preferred_education_code, family_life_code, exercise_code,
  marital_status, has_children, children_plan, accepts_long_distance, dating_intention_code,
  relocation, preferred_age_min, preferred_age_max, preferred_location, smoking, drinking,
  activity_level, weekend_style, pets, communication_style, archived_at, created_at, updated_at
) values
  ('dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'self', 'male', 1998, 182, 'FR:lyon', 'FR', 'FR',
   'draft', now(), 0, 'bachelor', 'bachelor_business', 'other',
   'other', 'other', 'other', 'other', 'other',
   'never_married', 0, 'open_to_discuss', 1, 'serious',
   'willing', 22, 30, 'regional', 'never', 'social',
   'high', 'outdoors', 'likes', 'direct', null, now(), now()),
  ('eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'self', 'female', 1985, 165, 'FR:nice', 'FR', 'FR',
   'paused', now(), 0, 'master', 'master_arts', 'education',
   'other', 'other', 'other', 'other', 'other',
   'divorced', 1, 'does_not_want', 1, 'exclusive',
   'willing', 38, 50, 'regional', 'never', 'social',
   'moderate', 'social', 'none', 'balanced', null, now(), now()),
  ('ffffffff-ffff-4fff-8fff-ffffffffffff', 'self', 'male', 1978, 175, 'FR:marseille', 'FR', 'FR',
   'hidden', now(), 0, 'bachelor', 'bachelor_business', 'finance',
   'other', 'other', 'other', 'other', 'other',
   'never_married', 0, 'wants', 1, 'marriage',
   'willing', 35, 48, 'national', 'never', 'social',
   'low', 'indoors', 'has', 'indirect', null, now(), now());

-- 5B2. Profile ownerships for extra profiles
insert into cm_profile_ownerships (id, user_id, profile_id, relationship_to_profile, permission, status, invited_by_user_id, accepted_at, revoked_at, created_at, updated_at) values
  ('d1111111-1111-4111-8111-dddddddddddd', 'd0000000-0000-4000-8000-000000000004', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'self', 'owner', 'active', null, now(), null, now(), now()),
  ('e1111111-1111-4111-8111-eeeeeeeeeeee', 'e0000000-0000-4000-8000-000000000005', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'self', 'owner', 'active', null, now(), null, now(), now()),
  ('f1111111-1111-4111-8111-ffffffffffff', 'f0000000-0000-4000-8000-000000000006', 'ffffffff-ffff-4fff-8fff-ffffffffffff', 'self', 'owner', 'active', null, now(), null, now(), now());

insert into cm_profile_languages (profile_id, language_code) values
  ('dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'FR'),
  ('dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'EN'),
  ('eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'FR'),
  ('eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'EN'),
  ('ffffffff-ffff-4fff-8fff-ffffffffffff', 'FR'),
  ('ffffffff-ffff-4fff-8fff-ffffffffffff', 'EN');

-- 5B3. Internal records for extra profiles
insert into cm_profile_internal_records (id, profile_id, is_featured, source, updated_by_user_id, created_at, updated_at) values
  ('d2222222-2222-4222-8222-dddddddddddd', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 0, 'self_submitted', null, now(), now()),
  ('e2222222-2222-4222-8222-eeeeeeeeeeee', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 0, 'self_submitted', null, now(), now()),
  ('f2222222-2222-4222-8222-ffffffffffff', 'ffffffff-ffff-4fff-8fff-ffffffffffff', 0, 'self_submitted', null, now(), now());

insert into cm_profile_localized_fields (id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('d2300000-0000-4000-8000-000000000001', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'profile_name', 'zh', '里昂自由职业顾问', 'manual', 'human', 'ready', now(), now()),
  ('d2300000-0000-4000-8000-000000000002', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'profile_name', 'fr', 'Consultant independant a Lyon', 'manual', 'human', 'ready', now(), now()),
  ('d2300000-0000-4000-8000-000000000003', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'profile_name', 'en', 'Independent consultant in Lyon', 'manual', 'human', 'ready', now(), now()),
  ('d2300000-0000-4000-8000-000000000004', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'summary', 'zh', '资料仍在草稿阶段，适合验证未开放资料在后台列表和审核入口中的状态。', 'manual', 'human', 'ready', now(), now()),
  ('d2300000-0000-4000-8000-000000000005', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'summary', 'fr', 'Profil encore en brouillon, utile pour verifier les etats non publies.', 'manual', 'human', 'ready', now(), now()),
  ('d2300000-0000-4000-8000-000000000006', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'summary', 'en', 'Draft profile used to verify unpublished profile states in admin review flows.', 'manual', 'human', 'ready', now(), now()),
  ('e2300000-0000-4000-8000-000000000001', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'profile_name', 'zh', '尼斯教育研究者', 'manual', 'human', 'ready', now(), now()),
  ('e2300000-0000-4000-8000-000000000002', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'profile_name', 'fr', 'Chercheuse en education a Nice', 'manual', 'human', 'ready', now(), now()),
  ('e2300000-0000-4000-8000-000000000003', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'profile_name', 'en', 'Education researcher in Nice', 'manual', 'human', 'ready', now(), now()),
  ('e2300000-0000-4000-8000-000000000004', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'summary', 'zh', '账号处于封禁状态，资料暂停开放，用于验证封禁用户资料和跟进事项。', 'manual', 'human', 'ready', now(), now()),
  ('e2300000-0000-4000-8000-000000000005', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'summary', 'fr', 'Compte suspendu et profil mis en pause, utile pour verifier les dossiers sensibles.', 'manual', 'human', 'ready', now(), now()),
  ('e2300000-0000-4000-8000-000000000006', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'summary', 'en', 'Suspended account with a paused profile, useful for sensitive follow-up checks.', 'manual', 'human', 'ready', now(), now()),
  ('f2300000-0000-4000-8000-000000000001', 'ffffffff-ffff-4fff-8fff-ffffffffffff', 'profile_name', 'zh', '马赛金融分析师', 'manual', 'human', 'ready', now(), now()),
  ('f2300000-0000-4000-8000-000000000002', 'ffffffff-ffff-4fff-8fff-ffffffffffff', 'profile_name', 'fr', 'Analyste financier a Marseille', 'manual', 'human', 'ready', now(), now()),
  ('f2300000-0000-4000-8000-000000000003', 'ffffffff-ffff-4fff-8fff-ffffffffffff', 'profile_name', 'en', 'Finance analyst in Marseille', 'manual', 'human', 'ready', now(), now()),
  ('f2300000-0000-4000-8000-000000000004', 'ffffffff-ffff-4fff-8fff-ffffffffffff', 'summary', 'zh', '资料已隐藏但账号正常，用于验证隐藏资料在 C 端和后台的展示边界。', 'manual', 'human', 'ready', now(), now()),
  ('f2300000-0000-4000-8000-000000000005', 'ffffffff-ffff-4fff-8fff-ffffffffffff', 'summary', 'fr', 'Profil masque mais compte actif, utile pour verifier les limites d affichage.', 'manual', 'human', 'ready', now(), now()),
  ('f2300000-0000-4000-8000-000000000006', 'ffffffff-ffff-4fff-8fff-ffffffffffff', 'summary', 'en', 'Hidden profile with an active account, useful for display-boundary checks.', 'manual', 'human', 'ready', now(), now());

-- 5C. Extra memberships (varied statuses)
insert into cm_user_memberships (id, user_id, plan_id, tier, status, started_at, expires_at, created_at, updated_at) values
  ('d3000000-0000-4000-8000-000000000004', 'd0000000-0000-4000-8000-000000000004', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'silver', 'expired', '2026-01-01 00:00:00', '2026-04-01 00:00:00', '2026-01-01 00:00:00', '2026-04-01 00:00:00'),
  ('e3000000-0000-4000-8000-000000000005', 'e0000000-0000-4000-8000-000000000005', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'gold', 'cancelled', '2026-04-01 00:00:00', '2026-07-01 00:00:00', '2026-04-01 00:00:00', '2026-06-01 00:00:00'),
  ('f3000000-0000-4000-8000-000000000006', 'f0000000-0000-4000-8000-000000000006', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'free', 'active', '2026-06-01 00:00:00', null, '2026-06-01 00:00:00', '2026-06-15 00:00:00');

-- 5D. Extra events (varied statuses)
insert into cm_events (id, status, visibility, consumes_membership_quota, city_code, address_visibility, event_date, start_time, end_time, capacity, cover_image_url, created_at, updated_at) values
  ('0dd00000-0000-4000-8000-000000000001', 'draft', 'registered', 0, 'FR:paris', 'registered_only', '2026-08-15', '18:00', '21:00', 20, 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1200&q=80', now(), now()),
  ('0cc00000-0000-4000-8000-000000000001', 'completed', 'member', 1, 'FR:lyon', 'confirmed_attendee_only', '2026-04-10', '19:00', '22:00', 10, 'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?auto=format&fit=crop&w=1200&q=80', '2026-03-01 00:00:00', '2026-04-10 00:00:00');

-- 5D2. Event localized fields for extra events
insert into cm_event_localized_fields (id, event_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('dd100000-0000-4000-8000-000000000001', '0dd00000-0000-4000-8000-000000000001', 'title', 'zh', '秋季品酒交友', 'manual', 'human', 'ready', now(), now()),
  ('dd100000-0000-4000-8000-000000000002', '0dd00000-0000-4000-8000-000000000001', 'title', 'fr', 'Degustation de vin d automne', 'manual', 'human', 'ready', now(), now()),
  ('dd100000-0000-4000-8000-000000000003', '0dd00000-0000-4000-8000-000000000001', 'title', 'en', 'Autumn wine tasting mixer', 'manual', 'human', 'ready', now(), now()),
  ('dd100000-0000-4000-8000-000000000004', '0cc00000-0000-4000-8000-000000000001', 'title', 'zh', '里昂春季晚宴', 'manual', 'human', 'ready', now(), now()),
  ('dd100000-0000-4000-8000-000000000005', '0cc00000-0000-4000-8000-000000000001', 'title', 'fr', 'Diner de printemps a Lyon', 'manual', 'human', 'ready', now(), now()),
  ('dd100000-0000-4000-8000-000000000006', '0cc00000-0000-4000-8000-000000000001', 'title', 'en', 'Spring dinner in Lyon', 'manual', 'human', 'ready', now(), now());

-- 5E. Extra verification materials (varied scan statuses)
insert into cm_profile_verification_materials (
  id, profile_id, material_type, status, legal_name, date_of_birth,
  material_name, material_url, scan_status, scan_message, review_note,
  submitted_by_user_id, submitted_at, reviewed_by_user_id, reviewed_at, rejection_reason, created_at, updated_at
) values
  ('d4000000-0000-4000-8000-000000000001', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'identity', 'rejected', null, null,
   '可疑身份证明', 'private://verification/draft-profile/suspicious-id.jpg', 'failed', 'virus_detected', '扫描检测到异常。',
   'd0000000-0000-4000-8000-000000000004', now(), null, null, '材料扫描未通过安全检查。', now(), now()),
  ('e4000000-0000-4000-8000-000000000001', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'education', 'pending', null, null,
   '博士学位证书', 'private://verification/paused-profile/phd-cert.pdf', 'pending', null, '待系统扫描。',
   'e0000000-0000-4000-8000-000000000005', now(), null, null, null, now(), now());

-- 5F. Extra private introduction requests (varied statuses)
insert into cm_private_introduction_requests (id, requester_user_id, requester_profile_id, target_profile_id, status, message, requested_at, expires_at, responded_at, cooldown_until, entitlement_balance_id, created_at, updated_at) values
  ('d5000000-0000-4000-8000-000000000001', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '503a9c99-2842-54db-8858-24fbd3108e3b', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'declined', '希望可以认识一下。', '2026-05-10 14:00:00', null, '2026-05-12 10:00:00', null, null, '2026-05-10 14:00:00', '2026-05-12 10:00:00'),
  ('d5000000-0000-4000-8000-000000000002', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '503a9c99-2842-54db-8858-24fbd3108e3b', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'cancelled', null, '2026-05-20 09:00:00', null, null, null, null, '2026-05-20 09:00:00', '2026-05-21 18:00:00'),
  ('d5000000-0000-4000-8000-000000000003', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '503a9c99-2842-54db-8858-24fbd3108e3b', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'requested', '希望平台评估是否适合安排一次私人介绍。', '2026-06-24 09:30:00', '2026-07-01 09:30:00', null, null, '202f036e-42b5-506e-9509-1cfb4960555f', '2026-06-24 09:30:00', '2026-06-24 09:30:00');

-- 5G. Extra inbox threads and messages (system notifications)
insert into cm_inbox_threads (id, user_id, category, subject_type, subject_id, status, created_at, updated_at) values
  ('d6000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000004', 'system', null, null, 'open', '2026-05-01 12:00:00', '2026-05-01 12:00:00'),
  ('d6000000-0000-4000-8000-000000000003', 'e0000000-0000-4000-8000-000000000005', 'system', null, null, 'open', '2026-06-01 08:00:00', '2026-06-01 08:00:00');

-- 5G2. Extra inbox messages
insert into cm_inbox_messages (id, thread_id, sender_type, sender_user_id, message_type, body, template_code, template_locale, action_type, action_payload, created_at, updated_at) values
  ('d6100000-0000-4000-8000-000000000001', 'd85453a8-274f-566e-8343-e2534ae2fed7', 'system', null, 'system_notice', '您的会员即将到期，请及时续费以保持权益。', 'membership_expiring', 'zh', null, null, '2026-06-01 09:00:00', '2026-06-01 09:00:00'),
  ('d6100000-0000-4000-8000-000000000002', 'd6000000-0000-4000-8000-000000000002', 'system', null, 'system_notice', '您的账号已被停用，如有疑问请联系客服。', 'account_deactivated', 'zh', null, null, '2026-05-01 12:00:00', '2026-05-01 12:00:00'),
  ('d6100000-0000-4000-8000-000000000003', 'd6000000-0000-4000-8000-000000000003', 'system', null, 'system_notice', '您的账号已被暂停，如需恢复请联系客服。', 'account_suspended', 'zh', null, null, '2026-06-01 08:00:00', '2026-06-01 08:00:00');

-- 5H. Extra event registrations (varied statuses)
insert into cm_event_registrations (id, user_id, event_id, status, requested_at, confirmed_at, declined_at, waitlisted_at, cancelled_at, attended_at, event_quota_consumed_at, event_quota_released_at, created_at, updated_at) values
  ('d7000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000004', '0cc00000-0000-4000-8000-000000000001', 'attended', '2026-03-15 10:00:00', '2026-03-16 10:00:00', null, null, null, '2026-04-10 19:00:00', null, null, '2026-03-15 10:00:00', '2026-04-10 23:00:00'),
  ('d7000000-0000-4000-8000-000000000003', 'e0000000-0000-4000-8000-000000000005', '1bcb995a-540c-5c66-9b92-52471c43e587', 'declined', '2026-05-20 14:00:00', null, '2026-05-22 10:00:00', null, null, null, null, null, '2026-05-20 14:00:00', '2026-05-22 10:00:00');

-- 5I. Staff tasks (varied statuses and priorities)
insert into cm_staff_tasks (id, assignee_sys_user_id, subject_type, subject_id, status, priority, due_at, completed_at, created_at, updated_at) values
  ('d8000000-0000-4000-8000-000000000001', 1, 'profile', '11111111-1111-4111-8111-111111111111', 'open', 'high', '2026-06-30 23:59:59', null, now(), now()),
  ('d8000000-0000-4000-8000-000000000002', 1, 'profile', '22222222-2222-4222-8222-222222222222', 'done', 'normal', '2026-06-15 23:59:59', '2026-06-14 10:00:00', '2026-06-01 00:00:00', '2026-06-14 10:00:00'),
  ('d8000000-0000-4000-8000-000000000003', 13, 'user', 'e0000000-0000-4000-8000-000000000005', 'snoozed', 'low', '2026-07-15 23:59:59', null, '2026-06-10 00:00:00', '2026-06-15 00:00:00');

-- 5I2. Staff task localized fields
insert into cm_staff_task_localized_fields (id, staff_task_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('d8100000-0000-4000-8000-000000000001', 'd8000000-0000-4000-8000-000000000001', 'note', 'zh', '需要优先审核资料 A，用户已提交全部认证材料。', 'manual', 'human', 'ready', now(), now()),
  ('d8100000-0000-4000-8000-000000000002', 'd8000000-0000-4000-8000-000000000002', 'note', 'zh', '资料 B 审核已完成，照片和认证均已通过。', 'manual', 'human', 'ready', '2026-06-14 10:00:00', '2026-06-14 10:00:00'),
  ('d8100000-0000-4000-8000-000000000003', 'd8000000-0000-4000-8000-000000000003', 'note', 'zh', 'Nina Roche 的账号封禁原因待确认，暂时延后处理。', 'manual', 'human', 'ready', now(), now());

-- 5J. Payment customers, subscriptions, orders and payments
insert into cm_payment_customers (id, user_id, provider, environment, provider_customer_id, created_at, updated_at) values
  ('d8800000-0000-4000-8000-000000000001', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'stripe', 'test', 'cus_lin_yuanhang_gold_20260118', '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('d8800000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000004', 'stripe', 'test', 'cus_marc_lefevre_silver_20260101', '2026-01-01 00:00:00', '2026-03-01 00:00:00');

insert into cm_subscriptions (id, user_id, plan_id, membership_id, provider, environment, provider_customer_id, provider_subscription_id, provider_price_id, status, current_period_started_at, current_period_ends_at, cancel_at_period_end, cancelled_at, created_at, updated_at) values
  ('d8900000-0000-4000-8000-000000000001', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'd052548f-34dc-54f9-aab7-6dca95709306', 'stripe', 'test', 'cus_lin_yuanhang_gold_20260118', 'sub_lin_yuanhang_gold_monthly_20260118', 'price_1Tqwt1CsC9pa7rgAoWnyLWo2', 'active', '2026-06-18 00:00:00', '2026-07-18 00:00:00', 0, null, '2026-01-18 00:00:00', '2026-06-18 00:00:00'),
  ('d8900000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000004', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'd3000000-0000-4000-8000-000000000004', 'stripe', 'test', 'cus_marc_lefevre_silver_20260101', 'sub_marc_lefevre_silver_refunded_20260101', 'price_1TqwsPCsC9pa7rgAJEpWaov1', 'canceled', '2026-01-01 00:00:00', '2026-04-01 00:00:00', 1, '2026-03-01 00:00:00', '2026-01-01 00:00:00', '2026-03-01 00:00:00');

insert into cm_orders (id, user_id, plan_id, order_type, provider, environment, provider_checkout_session_id, provider_subscription_id, provider_customer_id, status, amount_cents, currency, paid_at, created_at, updated_at) values
  ('d9000000-0000-4000-8000-000000000001', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'membership_subscription', 'stripe', 'test', 'cs_lin_yuanhang_gold_checkout_20260118', 'sub_lin_yuanhang_gold_monthly_20260118', 'cus_lin_yuanhang_gold_20260118', 'paid', 10000, 'EUR', '2026-01-18 00:00:00', '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('d9000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000004', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'membership_subscription', 'stripe', 'test', 'cs_marc_lefevre_silver_checkout_20260101', 'sub_marc_lefevre_silver_refunded_20260101', 'cus_marc_lefevre_silver_20260101', 'refunded', 6500, 'EUR', '2026-01-01 00:00:00', '2026-01-01 00:00:00', '2026-03-01 00:00:00');

-- 5J2. Payment records
insert into cm_payments (id, order_id, provider, environment, provider_payment_id, provider_invoice_id, provider_subscription_id, provider_charge_id, provider_checkout_session_id, status, raw_status, amount_cents, currency, paid_at, created_at, updated_at) values
  ('d9100000-0000-4000-8000-000000000001', 'd9000000-0000-4000-8000-000000000001', 'stripe', 'test', 'pi_lin_yuanhang_gold_20260118', 'in_lin_yuanhang_gold_20260118', 'sub_lin_yuanhang_gold_monthly_20260118', 'ch_lin_yuanhang_gold_20260118', 'cs_lin_yuanhang_gold_checkout_20260118', 'succeeded', 'succeeded', 10000, 'EUR', '2026-01-18 00:00:00', '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('d9100000-0000-4000-8000-000000000002', 'd9000000-0000-4000-8000-000000000002', 'stripe', 'test', 'pi_marc_lefevre_silver_20260101', 'in_marc_lefevre_silver_20260101', 'sub_marc_lefevre_silver_refunded_20260101', 'ch_marc_lefevre_silver_20260101', 'cs_marc_lefevre_silver_checkout_20260101', 'succeeded', 'succeeded', 6500, 'EUR', '2026-01-01 00:00:00', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('d9100000-0000-4000-8000-000000000003', 'd9000000-0000-4000-8000-000000000002', 'stripe', 'test', 're_marc_lefevre_silver_20260301', 'in_marc_lefevre_silver_refund_20260301', 'sub_marc_lefevre_silver_refunded_20260101', 'ch_marc_lefevre_silver_20260101', 'cs_marc_lefevre_silver_checkout_20260101', 'refunded', 'refunded', 6500, 'EUR', '2026-03-01 00:00:00', '2026-03-01 00:00:00', '2026-03-01 00:00:00');

-- 5J3. Payment webhook events
insert into cm_payment_webhook_events (id, provider, environment, event_id, event_type, payload_json, process_status, process_message, received_at, processed_at, created_at, updated_at) values
  ('d9200000-0000-4000-8000-000000000001', 'stripe', 'test', 'evt_checkout_lin_yuanhang_gold_20260118', 'checkout.session.completed', '{"id":"evt_checkout_lin_yuanhang_gold_20260118","type":"checkout.session.completed","data":{"object":{"id":"cs_lin_yuanhang_gold_checkout_20260118","subscription":"sub_lin_yuanhang_gold_monthly_20260118","customer":"cus_lin_yuanhang_gold_20260118"}}}', 'processed', '订单已支付并开通会员。', '2026-01-18 00:00:05', '2026-01-18 00:00:06', '2026-01-18 00:00:05', '2026-01-18 00:00:06'),
  ('d9200000-0000-4000-8000-000000000002', 'stripe', 'test', 'evt_invoice_lin_yuanhang_gold_20260618', 'invoice.paid', '{"id":"evt_invoice_lin_yuanhang_gold_20260618","type":"invoice.paid","data":{"object":{"subscription":"sub_lin_yuanhang_gold_monthly_20260118","customer":"cus_lin_yuanhang_gold_20260118","amount_paid":10000}}}', 'processed', '订阅续费发票已记录。', '2026-06-18 00:00:05', '2026-06-18 00:00:06', '2026-06-18 00:00:05', '2026-06-18 00:00:06'),
  ('d9200000-0000-4000-8000-000000000003', 'stripe', 'test', 'evt_refund_marc_lefevre_silver_20260301', 'charge.refunded', '{"id":"evt_refund_marc_lefevre_silver_20260301","type":"charge.refunded","data":{"object":{"id":"ch_marc_lefevre_silver_20260101","amount_refunded":6500}}}', 'processed', '退款已同步为订单已退款。', '2026-03-01 00:00:05', '2026-03-01 00:00:06', '2026-03-01 00:00:05', '2026-03-01 00:00:06');

-- 5J4. Contact leads
insert into cm_contact_leads (id, source, inquiry_type, name, contact_channel, contact_value, message, status, handler_sys_user_id, handler_note, handled_at, created_at, updated_at) values
  ('d9300000-0000-4000-8000-000000000001', 'contact_page', 'membership', 'Camille Martin', 'email', 'camille.martin@rencontreaparis.test', '想了解黄金会员和钻石会员在顾问服务上的区别。', 'new', null, null, null, '2026-06-20 10:00:00', '2026-06-20 10:00:00'),
  ('d9300000-0000-4000-8000-000000000002', 'contact_page', 'event', 'Louis Arnaud', 'wechat', 'louis_arnaud_paris', '想咨询下次巴黎线下活动是否可以带家人一起了解。', 'processing', 13, '已安排用户支持跟进活动报名规则。', null, '2026-06-21 11:30:00', '2026-06-21 12:00:00'),
  ('d9300000-0000-4000-8000-000000000003', 'contact_page', 'partnership', 'Maison Lumière Paris', 'email', 'partnership@maison-lumiere.test', '希望洽谈高端社交活动合作。', 'resolved', 10, '已转给运营管理员评估合作价值。', '2026-06-22 15:00:00', '2026-06-22 09:00:00', '2026-06-22 15:00:00');

-- 5J5. Translation retry queue
insert into cm_translation_retries (id, entity_type, entity_id, field_name, source_locale, target_locale, attempt_count, next_retry_at, last_error, status, created_at, updated_at) values
  ('d9400000-0000-4000-8000-000000000001', 'profile', '33333333-3333-4333-8333-333333333333', 'bio', 'zh', 'fr', 2, '2026-06-16 10:05:00', 'provider_timeout', 'pending', '2026-06-16 09:55:00', '2026-06-16 10:00:00'),
  ('d9400000-0000-4000-8000-000000000002', 'event', '0dd00000-0000-4000-8000-000000000001', 'title', 'zh', 'en', 3, '2026-06-16 10:10:00', 'rate_limited', 'pending', '2026-06-16 09:50:00', '2026-06-16 10:00:00');

-- 5K. Audit logs
insert into cm_audit_logs (id, actor_type, actor_user_id, subject_type, subject_id, action, before_data, after_data, reason, created_at) values
  ('da000000-0000-4000-8000-000000000001', 'staff', '1', 'profile', '11111111-1111-4111-8111-111111111111', 'profile_review_approved', null, '{"profile_status":"open"}', '资料信息真实完整，审核通过。', '2026-06-15 10:00:00'),
  ('da000000-0000-4000-8000-000000000002', 'staff', '1', 'profile', '22222222-2222-4222-8222-222222222222', 'photo_review_approved', null, '{"photo_status":"approved"}', '照片符合平台规范。', '2026-06-15 11:00:00'),
  ('da000000-0000-4000-8000-000000000003', 'staff', '1', 'profile', '33333333-3333-4333-8333-333333333333', 'verification_review_rejected', '{"education_status":"pending"}', '{"education_status":"rejected"}', '学历材料不清晰。', '2026-06-16 09:00:00'),
  ('da000000-0000-4000-8000-000000000004', 'system', null, 'user', 'd0000000-0000-4000-8000-000000000004', 'user_deactivated', '{"status":"active"}', '{"status":"deactivated"}', '用户主动申请停用。', '2026-05-01 12:00:00'),
  ('da000000-0000-4000-8000-000000000005', 'staff', '13', 'user', 'e0000000-0000-4000-8000-000000000005', 'user_suspended', '{"status":"active"}', '{"status":"suspended"}', '违规行为调查中。', '2026-06-01 08:00:00'),
  ('da000000-0000-4000-8000-000000000006', 'staff', '1', 'verification_material', '96000000-0000-4000-8000-000000000008', 'verification_material_rejected', null, '{"status":"rejected"}', '图片不清晰，请重新上传。', '2026-06-16 10:00:00');

commit;
