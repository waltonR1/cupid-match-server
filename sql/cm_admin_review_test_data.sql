-- Cupid Match Phase 8.2 后台审核测试数据
-- 用途：手工验收资料审核、照片审核、认证审核页面。
-- 可重复执行；仅清理本文件固定 ID 的测试数据。

delete from cm_audit_logs
where subject_id in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222',
  '33333333-3333-4333-8333-333333333333',
  'aaaa1111-1111-4111-8111-111111111111',
  'aaaa2222-2222-4222-8222-222222222222',
  'aaaa3333-3333-4333-8333-333333333333'
);

delete from cm_profile_verifications
where profile_id in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222',
  '33333333-3333-4333-8333-333333333333'
);

delete from cm_profile_photos
where profile_id in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222',
  '33333333-3333-4333-8333-333333333333'
);

delete from cm_profile_localized_items
where profile_id in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222',
  '33333333-3333-4333-8333-333333333333'
);

delete from cm_profile_localized_fields
where profile_id in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222',
  '33333333-3333-4333-8333-333333333333'
);

delete from cm_profile_internal_records
where profile_id in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222',
  '33333333-3333-4333-8333-333333333333'
);

delete from cm_profile_ownerships
where profile_id in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222',
  '33333333-3333-4333-8333-333333333333'
);

delete from cm_profiles
where id in (
  '11111111-1111-4111-8111-111111111111',
  '22222222-2222-4222-8222-222222222222',
  '33333333-3333-4333-8333-333333333333'
);

delete from cm_users
where id in (
  '90000000-0000-4000-8000-000000000001',
  '90000000-0000-4000-8000-000000000002',
  '90000000-0000-4000-8000-000000000003'
);

insert into cm_users (id, account_name, avatar_url, preferred_locale, status, created_at, updated_at) values
  ('90000000-0000-4000-8000-000000000001', '审核测试用户 A', '', 'zh', 'active', now(), now()),
  ('90000000-0000-4000-8000-000000000002', '审核测试用户 B', '', 'zh', 'active', now(), now()),
  ('90000000-0000-4000-8000-000000000003', '审核测试用户 C', '', 'zh', 'active', now(), now());

insert into cm_profiles (
  id, profile_type, gender, birth_year, height, city_code, country_code, nationality_code,
  profile_status, last_active_at, family_visible, degree_level, education_code, industry_code,
  marital_status, has_children, children_plan, accepts_long_distance, dating_intention_code,
  relocation, preferred_age_min, preferred_age_max, preferred_location, smoking, drinking,
  activity_level, weekend_style, pets, communication_style, archived_at, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111111111', 'self', 'female', 1994, 168, 'paris', 'france', 'china',
   'review', now(), 0, 'master', 'business_school', 'tech',
   'never_married', 0, 'open_to_discuss', 1, 'marriage',
   'open_to_discuss', 30, 38, 'international', 'never', 'social',
   'moderate', 'social', 'likes', 'direct', null, now(), now()),
  ('22222222-2222-4222-8222-222222222222', 'family', 'male', 1990, 180, 'shanghai', 'china', 'china',
   'open', now(), 1, 'bachelor', 'engineering', 'finance',
   'never_married', 0, 'wants', 0, 'serious',
   'willing', 28, 36, 'regional', 'never', 'never',
   'high', 'outdoors', 'none', 'balanced', null, now(), now()),
  ('33333333-3333-4333-8333-333333333333', 'self', 'female', 1988, 165, 'lyon', 'france', 'france',
   'review', now(), 0, 'phd', 'public_policy', 'education',
   'divorced', 1, 'does_not_want', 1, 'cross_border',
   'open_to_discuss', 35, 45, 'international', 'never', 'social',
   'moderate', 'indoors', 'has', 'indirect', null, now(), now());

insert into cm_profile_ownerships (
  id, user_id, profile_id, relationship_to_profile, permission, status,
  invited_by_user_id, accepted_at, revoked_at, created_at, updated_at
) values
  ('91000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'self', 'owner', 'active', null, now(), null, now(), now()),
  ('91000000-0000-4000-8000-000000000002', '90000000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'mother', 'manager', 'active', null, now(), null, now(), now()),
  ('91000000-0000-4000-8000-000000000003', '90000000-0000-4000-8000-000000000003', '33333333-3333-4333-8333-333333333333', 'self', 'owner', 'active', null, now(), null, now(), now());

insert into cm_profile_internal_records (id, profile_id, is_featured, source, updated_by_user_id, created_at, updated_at) values
  ('92000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 0, 'self_submitted', null, now(), now()),
  ('92000000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 0, 'family_submitted', null, now(), now()),
  ('92000000-0000-4000-8000-000000000003', '33333333-3333-4333-8333-333333333333', 0, 'self_submitted', null, now(), now());

insert into cm_profile_localized_fields (id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('93000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'profile_name', 'zh', '审核测试 A', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'profile_name', 'fr', 'Test moderation A', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'profile_name', 'en', 'Review test A', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111', 'city', 'zh', '巴黎', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000005', '11111111-1111-4111-8111-111111111111', 'city', 'fr', 'Paris', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000006', '11111111-1111-4111-8111-111111111111', 'city', 'en', 'Paris', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000012', '11111111-1111-4111-8111-111111111111', 'country', 'zh', '法国', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000013', '11111111-1111-4111-8111-111111111111', 'country', 'fr', 'France', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000014', '11111111-1111-4111-8111-111111111111', 'country', 'en', 'France', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000015', '11111111-1111-4111-8111-111111111111', 'nationality', 'zh', '中国', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000016', '11111111-1111-4111-8111-111111111111', 'nationality', 'fr', 'Chinoise', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000017', '11111111-1111-4111-8111-111111111111', 'nationality', 'en', 'Chinese', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000018', '11111111-1111-4111-8111-111111111111', 'education', 'zh', '商学院', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000019', '11111111-1111-4111-8111-111111111111', 'education', 'fr', 'Ecole de commerce', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000020', '11111111-1111-4111-8111-111111111111', 'education', 'en', 'Business school', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000007', '11111111-1111-4111-8111-111111111111', 'industry', 'zh', '科技产品', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000021', '11111111-1111-4111-8111-111111111111', 'industry', 'fr', 'Produit tech', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000022', '11111111-1111-4111-8111-111111111111', 'industry', 'en', 'Tech product', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000008', '11111111-1111-4111-8111-111111111111', 'career_direction', 'zh', '产品经理', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000023', '11111111-1111-4111-8111-111111111111', 'career_direction', 'fr', 'Product manager', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000024', '11111111-1111-4111-8111-111111111111', 'career_direction', 'en', 'Product manager', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000009', '11111111-1111-4111-8111-111111111111', 'summary', 'zh', '测试资料：用于验证资料审核通过后按钮禁用和审计写入。', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000010', '11111111-1111-4111-8111-111111111111', 'summary', 'fr', 'Profil de test pour verifier la moderation multilingue.', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000011', '11111111-1111-4111-8111-111111111111', 'summary', 'en', 'Test profile for multilingual moderation checks.', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000101', '22222222-2222-4222-8222-222222222222', 'profile_name', 'zh', '审核测试 B', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000102', '22222222-2222-4222-8222-222222222222', 'profile_name', 'fr', 'Test moderation B', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000103', '22222222-2222-4222-8222-222222222222', 'profile_name', 'en', 'Review test B', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000104', '22222222-2222-4222-8222-222222222222', 'city', 'zh', '上海', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000108', '22222222-2222-4222-8222-222222222222', 'city', 'fr', 'Shanghai', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000109', '22222222-2222-4222-8222-222222222222', 'city', 'en', 'Shanghai', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000110', '22222222-2222-4222-8222-222222222222', 'country', 'zh', '中国', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000111', '22222222-2222-4222-8222-222222222222', 'country', 'fr', 'Chine', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000112', '22222222-2222-4222-8222-222222222222', 'country', 'en', 'China', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000113', '22222222-2222-4222-8222-222222222222', 'nationality', 'zh', '中国', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000114', '22222222-2222-4222-8222-222222222222', 'nationality', 'fr', 'Chinoise', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000115', '22222222-2222-4222-8222-222222222222', 'nationality', 'en', 'Chinese', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000116', '22222222-2222-4222-8222-222222222222', 'education', 'zh', '工程', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000117', '22222222-2222-4222-8222-222222222222', 'education', 'fr', 'Ingenierie', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000118', '22222222-2222-4222-8222-222222222222', 'education', 'en', 'Engineering', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000105', '22222222-2222-4222-8222-222222222222', 'industry', 'zh', '金融科技', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000119', '22222222-2222-4222-8222-222222222222', 'industry', 'fr', 'Fintech', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000120', '22222222-2222-4222-8222-222222222222', 'industry', 'en', 'Fintech', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000106', '22222222-2222-4222-8222-222222222222', 'career_direction', 'zh', '投融资', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000121', '22222222-2222-4222-8222-222222222222', 'career_direction', 'fr', 'Investissement et financement', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000122', '22222222-2222-4222-8222-222222222222', 'career_direction', 'en', 'Investment and financing', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000107', '22222222-2222-4222-8222-222222222222', 'summary', 'zh', '测试资料：资料本身已开放，但照片仍在待审核。', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000201', '33333333-3333-4333-8333-333333333333', 'profile_name', 'zh', '审核测试 C', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000202', '33333333-3333-4333-8333-333333333333', 'profile_name', 'fr', 'Test moderation C', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000203', '33333333-3333-4333-8333-333333333333', 'profile_name', 'en', 'Review test C', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000204', '33333333-3333-4333-8333-333333333333', 'city', 'zh', '里昂', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000208', '33333333-3333-4333-8333-333333333333', 'city', 'fr', 'Lyon', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000209', '33333333-3333-4333-8333-333333333333', 'city', 'en', 'Lyon', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000210', '33333333-3333-4333-8333-333333333333', 'country', 'zh', '法国', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000211', '33333333-3333-4333-8333-333333333333', 'country', 'fr', 'France', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000212', '33333333-3333-4333-8333-333333333333', 'country', 'en', 'France', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000213', '33333333-3333-4333-8333-333333333333', 'nationality', 'zh', '法国', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000214', '33333333-3333-4333-8333-333333333333', 'nationality', 'fr', 'Francaise', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000215', '33333333-3333-4333-8333-333333333333', 'nationality', 'en', 'French', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000216', '33333333-3333-4333-8333-333333333333', 'education', 'zh', '公共政策', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000217', '33333333-3333-4333-8333-333333333333', 'education', 'fr', 'Politiques publiques', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000218', '33333333-3333-4333-8333-333333333333', 'education', 'en', 'Public policy', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000205', '33333333-3333-4333-8333-333333333333', 'industry', 'zh', '教育研究', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000219', '33333333-3333-4333-8333-333333333333', 'industry', 'fr', 'Recherche en education', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000220', '33333333-3333-4333-8333-333333333333', 'industry', 'en', 'Education research', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000206', '33333333-3333-4333-8333-333333333333', 'career_direction', 'zh', '公共政策研究', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000221', '33333333-3333-4333-8333-333333333333', 'career_direction', 'fr', 'Recherche en politiques publiques', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000222', '33333333-3333-4333-8333-333333333333', 'career_direction', 'en', 'Public policy research', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000207', '33333333-3333-4333-8333-333333333333', 'summary', 'zh', '测试资料：用于验证认证待审核状态和三语言展示。', 'manual', 'human', 'ready', now(), now());

insert into cm_profile_localized_items (id, profile_id, field_name, item_order, locale, value, source, provider, status, created_at, updated_at) values
  ('94000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'tags', 0, 'zh', '待审核', 'manual', 'human', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'tags', 0, 'fr', 'A moderer', 'machine', 'translation_api', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'tags', 0, 'en', 'Pending review', 'machine', 'translation_api', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000004', '22222222-2222-4222-8222-222222222222', 'tags', 0, 'zh', '照片待审', 'manual', 'human', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000005', '33333333-3333-4333-8333-333333333333', 'tags', 0, 'zh', '认证待审', 'manual', 'human', 'ready', now(), now());

insert into cm_profile_photos (id, profile_id, url, is_primary, sort_order, status, created_at, updated_at) values
  ('aaaa1111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'https://picsum.photos/seed/admin-review-a-1/900/1200', 1, 1, 'review', now(), now()),
  ('aaaa2222-2222-4222-8222-222222222222', '22222222-2222-4222-8222-222222222222', 'https://picsum.photos/seed/admin-review-b-1/900/1200', 1, 1, 'review', now(), now()),
  ('aaaa3333-3333-4333-8333-333333333333', '33333333-3333-4333-8333-333333333333', 'https://picsum.photos/seed/admin-review-c-1/900/1200', 1, 1, 'review', now(), now());

insert into cm_profile_verifications (
  id, profile_id, legal_name, date_of_birth, identity_status, education_status,
  income_status, marital_status, review_status, verified_at, verified_by_user_id,
  created_at, updated_at
) values
  ('95000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'Test A', '1994-03-12', 'pending', 'pending', 'pending', 'pending', 'pending', null, null, now(), now()),
  ('95000000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'Test B', '1990-08-20', 'verified', 'verified', 'verified', 'verified', 'approved', now(), '1', now(), now()),
  ('95000000-0000-4000-8000-000000000003', '33333333-3333-4333-8333-333333333333', 'Test C', '1988-11-05', 'pending', 'pending', 'pending', 'pending', 'pending', null, null, now(), now());

commit;
