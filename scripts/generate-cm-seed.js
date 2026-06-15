const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const root = path.resolve(__dirname, '..');
const db = JSON.parse(fs.readFileSync(path.join(root, 'doc/reference-from-app/mock-server/db.json'), 'utf8'));
const outPath = path.join(root, 'sql/cm_seed.sql');
const seedNamespace = '2fca05cb-dad9-4c08-b3d8-6654745ce755';
const password123Bcrypt = '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W';

function deterministicUuid(namespace, legacyId) {
  if (!legacyId) return legacyId;
  const namespaceBytes = Buffer.from(seedNamespace.replace(/-/g, ''), 'hex');
  const bytes = crypto.createHash('sha1')
    .update(namespaceBytes)
    .update(`cupid-match:${namespace}:${legacyId}`)
    .digest()
    .subarray(0, 16);
  bytes[6] = (bytes[6] & 0x0f) | 0x50;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  const hex = bytes.toString('hex');
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
}

function seedPasswordHash(value) {
  if (value === 'mock-sha256:cGFzc3dvcmQxMjM=') return password123Bcrypt;
  return value || null;
}

const entityDefinitions = {
  users: {},
  auth_identities: { userId: 'users' },
  profiles: {},
  profile_ownerships: { userId: 'users', profileId: 'profiles', invitedByUserId: 'users' },
  favorite_profiles: { userId: 'users', profileId: 'profiles' },
  private_introduction_requests: {
    requesterUserId: 'users',
    requesterProfileId: 'profiles',
    targetProfileId: 'profiles',
    entitlementBalanceId: 'user_entitlement_balances',
  },
  profile_photos: { profileId: 'profiles' },
  profile_internal_records: { profileId: 'profiles', updatedByUserId: 'users' },
  profile_verifications: { profileId: 'profiles', verifiedByUserId: 'users' },
  profile_privacy_preferences: { profileId: 'profiles' },
  profile_contacts: { profileId: 'profiles' },
  membership_plans: {},
  user_memberships: { userId: 'users', planId: 'membership_plans' },
  user_entitlement_balances: { userId: 'users', membershipId: 'user_memberships' },
  events: {},
  event_agenda_items: { eventId: 'events' },
  event_registrations: { userId: 'users', eventId: 'events' },
  legal_documents: {},
  legal_document_contents: { documentId: 'legal_documents' },
  user_agreement_acceptances: { userId: 'users' },
  user_preferences: { userId: 'users' },
  inbox_threads: { userId: 'users' },
  inbox_messages: { threadId: 'inbox_threads', senderUserId: 'users' },
  inbox_reads: { threadId: 'inbox_threads', userId: 'users' },
  user_security_settings: { userId: 'users', mfaIdentityId: 'auth_identities' },
  user_security_challenges: { userId: 'users', identityId: 'auth_identities' },
};

for (const [collection, references] of Object.entries(entityDefinitions)) {
  for (const row of db[collection] || []) {
    row.id = deterministicUuid(collection, row.id);
    for (const [field, targetCollection] of Object.entries(references)) {
      if (row[field]) row[field] = deterministicUuid(targetCollection, row[field]);
    }
  }
}

for (const thread of db.inbox_threads || []) {
  if (!thread.subjectId) continue;
  if (thread.subjectType === 'profile') thread.subjectId = deterministicUuid('profiles', thread.subjectId);
  if (thread.subjectType === 'event') thread.subjectId = deterministicUuid('events', thread.subjectId);
}

function validateEntityIds() {
  const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
  const idsByCollection = new Map();

  for (const collection of Object.keys(entityDefinitions)) {
    const ids = new Set();
    for (const row of db[collection] || []) {
      if (!uuidPattern.test(row.id)) throw new Error(`${collection} has invalid UUID: ${row.id}`);
      if (ids.has(row.id)) throw new Error(`${collection} has duplicate UUID: ${row.id}`);
      ids.add(row.id);
    }
    idsByCollection.set(collection, ids);
  }

  for (const [collection, references] of Object.entries(entityDefinitions)) {
    for (const row of db[collection] || []) {
      for (const [field, targetCollection] of Object.entries(references)) {
        const value = row[field];
        if (value && !idsByCollection.get(targetCollection)?.has(value)) {
          throw new Error(`${collection}.${field} references missing ${targetCollection} ID: ${value}`);
        }
      }
    }
  }

  for (const thread of db.inbox_threads || []) {
    if (!thread.subjectId) continue;
    const targetCollection = thread.subjectType === 'profile'
      ? 'profiles'
      : thread.subjectType === 'event' ? 'events' : null;
    if (targetCollection && !idsByCollection.get(targetCollection)?.has(thread.subjectId)) {
      throw new Error(`inbox_threads.subjectId references missing ${targetCollection} ID: ${thread.subjectId}`);
    }
  }
}

validateEntityIds();

function sqlValue(value) {
  if (value === undefined || value === null) return 'null';
  if (typeof value === 'number') return String(value);
  if (typeof value === 'boolean') return value ? '1' : '0';
  return `'${String(value).replace(/\\/g, '\\\\').replace(/'/g, "''")}'`;
}

function toDateTime(value) {
  if (!value) return null;
  const text = String(value);
  if (/^\d{4}-\d{2}-\d{2}$/.test(text)) return `${text} 00:00:00`;
  return text.replace('T', ' ').replace(/\.\d{3}Z$/, '').replace(/Z$/, '');
}

function toDate(value) {
  return value ? String(value).slice(0, 10) : null;
}

function toCode(value, fallback) {
  const raw = String(value || fallback || 'unknown');
  const normalized = raw
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
  return normalized || String(fallback || 'unknown');
}

function localizedCode(record, fieldName, fallback) {
  const value = record && record[fieldName];
  return toCode(value?.en?.value || value?.fr?.value || value?.zh?.value, fallback || fieldName);
}

function insertInto(table, columns, rows) {
  if (!rows.length) return '';
  const lines = [`insert into ${table} (${columns.join(', ')}) values`];
  rows.forEach((row, index) => {
    const values = columns.map((column) => sqlValue(row[column])).join(', ');
    lines.push(`  (${values})${index === rows.length - 1 ? ';' : ','}`);
  });
  return `${lines.join('\n')}\n\n`;
}

function pushLocalizedFieldRows(rows, ownerKey, ownerId, fields, prefix, sourceRecord) {
  fields.forEach(([fieldName, localizedText]) => {
    if (!localizedText) return;
    ['zh', 'fr', 'en'].forEach((locale) => {
      const slot = localizedText[locale];
      if (!slot) return;
      const sequence = `${prefix}-${String(rows.length + 1).padStart(5, '0')}`;
      rows.push({
        id: deterministicUuid(`${prefix}_localized_fields`, sequence),
        [ownerKey]: ownerId,
        field_name: fieldName,
        locale,
        value: slot.value ?? '',
        source: slot.source ?? 'manual',
        provider: slot.provider ?? null,
        status: slot.status ?? 'ready',
        created_at: toDateTime(sourceRecord?.createdAt) || '2026-01-01 00:00:00',
        updated_at: toDateTime(slot.updatedAt || sourceRecord?.updatedAt) || toDateTime(sourceRecord?.createdAt) || '2026-01-01 00:00:00',
      });
    });
  });
}

function pushLocalizedItemRows(rows, profile, fieldName, items) {
  if (!Array.isArray(items)) return;
  items.forEach((localizedText, itemIndex) => {
    ['zh', 'fr', 'en'].forEach((locale) => {
      const slot = localizedText?.[locale];
      if (!slot) return;
      const sequence = `pli-${String(rows.length + 1).padStart(5, '0')}`;
      rows.push({
        id: deterministicUuid('profile_localized_items', sequence),
        profile_id: profile.id,
        field_name: fieldName,
        item_order: itemIndex,
        locale,
        value: slot.value ?? '',
        source: slot.source ?? 'manual',
        provider: slot.provider ?? null,
        status: slot.status ?? 'ready',
        created_at: toDateTime(profile.createdAt),
        updated_at: toDateTime(slot.updatedAt || profile.updatedAt),
      });
    });
  });
}

const sql = [];
sql.push('-- ----------------------------');
sql.push('-- Cupid Match sample seed data');
sql.push('-- Generated from doc/reference-from-app/mock-server/db.json');
sql.push('-- Entity IDs are deterministic UUIDv5 values; regenerating the same source keeps them stable.');
sql.push('-- Run after sql/cm_schema.sql.');
sql.push('-- ----------------------------\n');
sql.push(insertInto('cm_users', ['id', 'account_name', 'avatar_url', 'preferred_locale', 'status', 'created_at', 'updated_at'],
  db.users.map((row) => ({
    id: row.id,
    account_name: row.accountName,
    avatar_url: row.avatarUrl || '',
    preferred_locale: row.preferredLocale,
    status: row.status,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_auth_identities', ['id', 'user_id', 'provider', 'identifier', 'password_hash', 'verified_at', 'created_at', 'updated_at'],
  db.auth_identities.map((row) => ({
    id: row.id,
    user_id: row.userId,
    provider: row.provider,
    identifier: row.identifier,
    password_hash: seedPasswordHash(row.passwordHash),
    verified_at: toDateTime(row.verifiedAt),
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_user_security_settings', ['id', 'user_id', 'mfa_enabled', 'mfa_method', 'mfa_identity_id', 'mfa_enabled_at', 'last_challenge_at', 'created_at', 'updated_at'],
  (db.user_security_settings || []).map((row) => ({
    id: row.id,
    user_id: row.userId,
    mfa_enabled: !!row.mfaEnabled,
    mfa_method: row.mfaMethod || null,
    mfa_identity_id: row.mfaIdentityId || null,
    mfa_enabled_at: toDateTime(row.mfaEnabledAt),
    last_challenge_at: toDateTime(row.lastChallengeAt),
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_user_security_challenges', ['id', 'user_id', 'action', 'method', 'identity_id', 'status', 'challenge_token', 'expires_at', 'verified_at', 'consumed_at', 'created_at', 'updated_at'],
  (db.user_security_challenges || []).map((row) => ({
    id: row.id,
    user_id: row.userId,
    action: row.action,
    method: row.method,
    identity_id: row.identityId,
    status: row.status,
    challenge_token: row.challengeToken || null,
    expires_at: toDateTime(row.expiresAt),
    verified_at: toDateTime(row.verifiedAt),
    consumed_at: toDateTime(row.consumedAt),
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_user_preferences', ['id', 'user_id', 'preferred_city_code', 'preferred_contact_channel', 'staff_contact_enabled', 'family_assist_enabled', 'introduction_updates_enabled', 'event_reminders_enabled', 'service_announcements_enabled', 'marketing_emails_enabled', 'analytics_consent_enabled', 'created_at', 'updated_at'],
  (db.user_preferences || []).map((row) => ({
    id: row.id,
    user_id: row.userId,
    preferred_city_code: toCode(row.preferredCity, null),
    preferred_contact_channel: row.preferredContactChannel || null,
    staff_contact_enabled: row.staffContactEnabled ?? true,
    family_assist_enabled: row.familyAssistEnabled ?? true,
    introduction_updates_enabled: row.introductionUpdatesEnabled ?? true,
    event_reminders_enabled: row.eventRemindersEnabled ?? true,
    service_announcements_enabled: row.serviceAnnouncementsEnabled ?? true,
    marketing_emails_enabled: row.marketingEmailsEnabled ?? false,
    analytics_consent_enabled: row.analyticsConsentEnabled ?? false,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_legal_documents', ['id', 'type', 'version', 'status', 'effective_at', 'created_at', 'updated_at'],
  (db.legal_documents || []).map((row) => ({
    id: row.id,
    type: row.type,
    version: row.version,
    status: row.status,
    effective_at: toDateTime(row.effectiveAt),
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_legal_document_contents', ['id', 'document_id', 'locale', 'title', 'sections', 'created_at', 'updated_at'],
  (db.legal_document_contents || []).map((row) => ({
    id: row.id,
    document_id: row.documentId,
    locale: row.locale,
    title: row.title,
    sections: JSON.stringify(row.sections),
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_user_agreement_acceptances', ['id', 'user_id', 'document_type', 'document_version', 'accepted_at', 'created_at'],
  (db.user_agreement_acceptances || []).map((row) => ({
    id: row.id,
    user_id: row.userId,
    document_type: row.documentType,
    document_version: row.documentVersion,
    accepted_at: toDateTime(row.acceptedAt),
    created_at: toDateTime(row.createdAt),
  }))));

sql.push(insertInto('cm_profiles', ['id', 'profile_type', 'gender', 'birth_year', 'height', 'city_code', 'country_code', 'nationality_code', 'profile_status', 'last_active_at', 'family_visible', 'degree_level', 'education_code', 'industry_code', 'marital_status', 'has_children', 'children_plan', 'accepts_long_distance', 'dating_intention_code', 'relocation', 'preferred_age_min', 'preferred_age_max', 'preferred_location', 'smoking', 'drinking', 'activity_level', 'weekend_style', 'pets', 'communication_style', 'archived_at', 'created_at', 'updated_at'],
  db.profiles.map((row) => ({
    id: row.id,
    profile_type: row.profileType,
    gender: row.gender,
    birth_year: row.birthYear,
    height: row.height,
    city_code: localizedCode(row, 'city', 'city'),
    country_code: localizedCode(row, 'country', 'country'),
    nationality_code: localizedCode(row, 'nationality', 'nationality'),
    profile_status: row.profileStatus,
    last_active_at: toDateTime(row.lastActiveAt),
    family_visible: !!row.familyVisible,
    degree_level: row.degreeLevel,
    education_code: localizedCode(row, 'education', row.degreeLevel),
    industry_code: localizedCode(row, 'industry', 'industry'),
    marital_status: row.maritalStatus,
    has_children: !!row.hasChildren,
    children_plan: row.childrenPlan,
    accepts_long_distance: !!row.acceptsLongDistance,
    dating_intention_code: row.datingIntentionCode,
    relocation: row.relocation,
    preferred_age_min: row.preferredAgeMin,
    preferred_age_max: row.preferredAgeMax,
    preferred_location: row.preferredLocation,
    smoking: row.smoking,
    drinking: row.drinking,
    activity_level: row.activityLevel,
    weekend_style: row.weekendStyle,
    pets: row.pets,
    communication_style: row.communicationStyle,
    archived_at: toDateTime(row.archivedAt),
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_profile_languages', ['profile_id', 'language_code'],
  db.profiles.flatMap((profile) => (profile.languages || []).map((languageCode) => ({
    profile_id: profile.id,
    language_code: languageCode,
  })))));

sql.push(insertInto('cm_profile_relationship_values', ['profile_id', 'value_code'],
  db.profiles.flatMap((profile) => (profile.relationshipValues || []).map((valueCode) => ({
    profile_id: profile.id,
    value_code: valueCode,
  })))));

const profileLocalizedRows = [];
db.profiles.forEach((profile) => {
  pushLocalizedFieldRows(profileLocalizedRows, 'profile_id', profile.id, [
    ['profile_name', profile.profileName],
    ['city', profile.city],
    ['country', profile.country],
    ['nationality', profile.nationality],
    ['education', profile.education],
    ['industry', profile.industry],
    ['career_direction', profile.careerDirection],
    ['relationship_goal', profile.relationshipGoal],
    ['residence_plan', profile.residencePlan],
    ['preferred_education', profile.preferredEducation],
    ['family_life', profile.familyLife],
    ['exercise', profile.exercise],
    ['summary', profile.summary],
  ], 'plf', profile);
});
sql.push(insertInto('cm_profile_localized_fields', ['id', 'profile_id', 'field_name', 'locale', 'value', 'source', 'provider', 'status', 'created_at', 'updated_at'], profileLocalizedRows));

const profileLocalizedItemRows = [];
db.profiles.forEach((profile) => {
  pushLocalizedItemRows(profileLocalizedItemRows, profile, 'deal_breakers', profile.dealBreakers);
  pushLocalizedItemRows(profileLocalizedItemRows, profile, 'personality_traits', profile.personalityTraits);
  pushLocalizedItemRows(profileLocalizedItemRows, profile, 'interests', profile.interests);
  pushLocalizedItemRows(profileLocalizedItemRows, profile, 'tags', profile.tags);
});
sql.push(insertInto('cm_profile_localized_items', ['id', 'profile_id', 'field_name', 'item_order', 'locale', 'value', 'source', 'provider', 'status', 'created_at', 'updated_at'], profileLocalizedItemRows));

sql.push(insertInto('cm_profile_photos', ['id', 'profile_id', 'url', 'is_primary', 'sort_order', 'status', 'created_at', 'updated_at'],
  (db.profile_photos || []).map((row) => ({
    id: row.id,
    profile_id: row.profileId,
    url: row.url,
    is_primary: !!row.isPrimary,
    sort_order: row.sortOrder,
    status: row.status,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_profile_ownerships', ['id', 'user_id', 'profile_id', 'relationship_to_profile', 'permission', 'status', 'invited_by_user_id', 'accepted_at', 'revoked_at', 'created_at', 'updated_at'],
  (db.profile_ownerships || []).map((row) => ({
    id: row.id,
    user_id: row.userId,
    profile_id: row.profileId,
    relationship_to_profile: row.relationshipToProfile,
    permission: row.permission,
    status: row.status,
    invited_by_user_id: row.invitedByUserId || null,
    accepted_at: toDateTime(row.acceptedAt),
    revoked_at: toDateTime(row.revokedAt),
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_profile_internal_records', ['id', 'profile_id', 'is_featured', 'source', 'updated_by_user_id', 'created_at', 'updated_at'],
  (db.profile_internal_records || []).map((row) => ({
    id: row.id,
    profile_id: row.profileId,
    is_featured: !!row.isFeatured,
    source: row.source || null,
    updated_by_user_id: row.updatedByUserId || null,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

const profileInternalLocalizedRows = [];
(db.profile_internal_records || []).forEach((record) => {
  pushLocalizedFieldRows(profileInternalLocalizedRows, 'internal_record_id', record.id, [
    ['employer', record.employer],
    ['income_range', record.incomeRange],
    ['staff_notes', record.staffNotes],
  ], 'pilf', record);
});
sql.push(insertInto('cm_profile_internal_localized_fields', ['id', 'internal_record_id', 'field_name', 'locale', 'value', 'source', 'provider', 'status', 'created_at', 'updated_at'], profileInternalLocalizedRows));

sql.push(insertInto('cm_profile_verifications', ['id', 'profile_id', 'legal_name', 'date_of_birth', 'identity_status', 'education_status', 'income_status', 'marital_status', 'review_status', 'verified_at', 'verified_by_user_id', 'created_at', 'updated_at'],
  (db.profile_verifications || []).map((row) => ({
    id: row.id,
    profile_id: row.profileId,
    legal_name: row.legalName || null,
    date_of_birth: toDate(row.dateOfBirth),
    identity_status: row.identityStatus,
    education_status: row.educationStatus,
    income_status: row.incomeStatus,
    marital_status: row.maritalStatus,
    review_status: row.reviewStatus,
    verified_at: toDateTime(row.verifiedAt),
    verified_by_user_id: row.verifiedByUserId || null,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_profile_contacts', ['id', 'profile_id', 'phone', 'email', 'wechat', 'preferred_channel', 'visibility', 'created_at', 'updated_at'],
  (db.profile_contacts || []).map((row) => ({
    id: row.id,
    profile_id: row.profileId,
    phone: row.phone || null,
    email: row.email || null,
    wechat: row.wechat || null,
    preferred_channel: row.preferredChannel || null,
    visibility: row.visibility,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_profile_privacy_preferences', ['id', 'profile_id', 'hide_marital_status', 'hide_has_children', 'hide_children_plan', 'hide_accepts_long_distance', 'hide_smoking', 'hide_drinking', 'created_at', 'updated_at'],
  (db.profile_privacy_preferences || []).map((row) => ({
    id: row.id,
    profile_id: row.profileId,
    hide_marital_status: !!row.hideMaritalStatus,
    hide_has_children: !!row.hideHasChildren,
    hide_children_plan: !!row.hideChildrenPlan,
    hide_accepts_long_distance: !!row.hideAcceptsLongDistance,
    hide_smoking: !!row.hideSmoking,
    hide_drinking: !!row.hideDrinking,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_membership_plans', ['id', 'tier', 'price_cents', 'currency', 'cny_price_cents', 'billing_type', 'billing_period', 'validity_months', 'private_introduction_quota', 'private_introduction_period', 'event_quota', 'event_priority_enabled', 'staff_review_enabled', 'profile_detail_access_level', 'staff_support_level', 'concierge_priority', 'featured', 'sort_order', 'is_active', 'created_at', 'updated_at'],
  (db.membership_plans || []).map((row) => ({
    id: row.id,
    tier: row.tier,
    price_cents: row.priceCents,
    currency: row.currency,
    cny_price_cents: row.cnyPriceCents,
    billing_type: row.billingType,
    billing_period: row.billingPeriod || null,
    validity_months: row.validityMonths ?? null,
    private_introduction_quota: row.privateIntroductionQuota,
    private_introduction_period: row.privateIntroductionPeriod,
    event_quota: row.eventQuota,
    event_priority_enabled: !!row.eventPriorityEnabled,
    staff_review_enabled: !!row.staffReviewEnabled,
    profile_detail_access_level: row.profileDetailAccessLevel,
    staff_support_level: row.staffSupportLevel,
    concierge_priority: !!row.conciergePriority,
    featured: !!row.featured,
    sort_order: row.sortOrder,
    is_active: !!row.isActive,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

const planLocalizedRows = [];
(db.membership_plans || []).forEach((plan) => {
  pushLocalizedFieldRows(planLocalizedRows, 'plan_id', plan.id, [
    ['name', plan.name],
    ['description', plan.description],
  ], 'mplf', plan);
});
sql.push(insertInto('cm_membership_plan_localized_fields', ['id', 'plan_id', 'field_name', 'locale', 'value', 'source', 'provider', 'status', 'created_at', 'updated_at'], planLocalizedRows));

sql.push(insertInto('cm_user_memberships', ['id', 'user_id', 'plan_id', 'tier', 'status', 'started_at', 'expires_at', 'created_at', 'updated_at'],
  (db.user_memberships || []).map((row) => ({
    id: row.id,
    user_id: row.userId,
    plan_id: row.planId,
    tier: row.tier,
    status: row.status,
    started_at: toDateTime(row.startedAt),
    expires_at: toDateTime(row.expiresAt),
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_user_entitlement_balances', ['id', 'user_id', 'membership_id', 'entitlement_code', 'period_started_at', 'period_ends_at', 'quota_total', 'quota_used', 'quota_remaining', 'created_at', 'updated_at'],
  (db.user_entitlement_balances || []).map((row) => ({
    id: row.id,
    user_id: row.userId,
    membership_id: row.membershipId,
    entitlement_code: row.entitlementCode,
    period_started_at: toDateTime(row.periodStartedAt),
    period_ends_at: toDateTime(row.periodEndsAt),
    quota_total: row.quotaTotal,
    quota_used: row.quotaUsed,
    quota_remaining: row.quotaRemaining,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_events', ['id', 'slug', 'status', 'visibility', 'consumes_membership_quota', 'city_code', 'address_visibility', 'event_date', 'start_time', 'end_time', 'capacity', 'cover_image_url', 'created_at', 'updated_at'],
  (db.events || []).map((row) => ({
    id: row.id,
    slug: row.slug,
    status: row.status,
    visibility: row.visibility,
    consumes_membership_quota: !!row.consumesMembershipQuota,
    city_code: localizedCode(row, 'city', 'city'),
    address_visibility: row.addressVisibility,
    event_date: toDate(row.date),
    start_time: row.startTime,
    end_time: row.endTime,
    capacity: row.capacity,
    cover_image_url: row.coverImageUrl,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

const eventLocalizedRows = [];
(db.events || []).forEach((event) => {
  pushLocalizedFieldRows(eventLocalizedRows, 'event_id', event.id, [
    ['title', event.title],
    ['summary', event.summary],
    ['city', event.city],
    ['venue', event.venue],
    ['address', event.address],
    ['format', event.format],
    ['audience', event.audience],
    ['curator_note', event.curatorNote],
  ], 'elf', event);
});
sql.push(insertInto('cm_event_localized_fields', ['id', 'event_id', 'field_name', 'locale', 'value', 'source', 'provider', 'status', 'created_at', 'updated_at'], eventLocalizedRows));

const eventFocusRows = [];
(db.events || []).forEach((event) => {
  (event.relationshipFocus || []).forEach((localizedText, focusOrder) => {
    ['zh', 'fr', 'en'].forEach((locale) => {
      const slot = localizedText?.[locale];
      if (!slot) return;
      const sequence = `erf-${String(eventFocusRows.length + 1).padStart(5, '0')}`;
      eventFocusRows.push({
        id: deterministicUuid('event_relationship_focuses', sequence),
        event_id: event.id,
        focus_order: focusOrder,
        locale,
        value: slot.value ?? '',
        source: slot.source ?? 'manual',
        provider: slot.provider ?? null,
        status: slot.status ?? 'ready',
        created_at: toDateTime(event.createdAt),
        updated_at: toDateTime(slot.updatedAt || event.updatedAt),
      });
    });
  });
});
sql.push(insertInto('cm_event_relationship_focuses', ['id', 'event_id', 'focus_order', 'locale', 'value', 'source', 'provider', 'status', 'created_at', 'updated_at'], eventFocusRows));

sql.push(insertInto('cm_event_language_codes', ['event_id', 'language_code'],
  (db.events || []).flatMap((event) => (event.languageCodes || []).map((languageCode) => ({
    event_id: event.id,
    language_code: languageCode,
  })))));

sql.push(insertInto('cm_event_agenda_items', ['id', 'event_id', 'agenda_time', 'sort_order', 'created_at', 'updated_at'],
  (db.event_agenda_items || []).map((row) => ({
    id: row.id,
    event_id: row.eventId,
    agenda_time: row.time,
    sort_order: row.sortOrder,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

const agendaLocalizedRows = [];
(db.event_agenda_items || []).forEach((item) => {
  pushLocalizedFieldRows(agendaLocalizedRows, 'agenda_item_id', item.id, [
    ['title', item.title],
    ['description', item.description],
  ], 'ealf', item);
});
sql.push(insertInto('cm_event_agenda_item_localized_fields', ['id', 'agenda_item_id', 'field_name', 'locale', 'value', 'source', 'provider', 'status', 'created_at', 'updated_at'], agendaLocalizedRows));

sql.push(insertInto('cm_event_registrations', ['id', 'user_id', 'event_id', 'status', 'requested_at', 'confirmed_at', 'declined_at', 'waitlisted_at', 'cancelled_at', 'attended_at', 'event_quota_consumed_at', 'event_quota_released_at', 'created_at', 'updated_at'],
  (db.event_registrations || []).map((row) => ({
    id: row.id,
    user_id: row.userId,
    event_id: row.eventId,
    status: row.status,
    requested_at: toDateTime(row.requestedAt),
    confirmed_at: toDateTime(row.confirmedAt),
    declined_at: toDateTime(row.declinedAt),
    waitlisted_at: toDateTime(row.waitlistedAt),
    cancelled_at: toDateTime(row.cancelledAt),
    attended_at: toDateTime(row.attendedAt),
    event_quota_consumed_at: toDateTime(row.eventQuotaConsumedAt),
    event_quota_released_at: toDateTime(row.eventQuotaReleasedAt),
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_favorite_profiles', ['id', 'user_id', 'profile_id', 'created_at', 'updated_at'],
  (db.favorite_profiles || []).map((row) => ({
    id: row.id,
    user_id: row.userId,
    profile_id: row.profileId,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_private_introduction_requests', ['id', 'requester_user_id', 'requester_profile_id', 'target_profile_id', 'status', 'message', 'requested_at', 'expires_at', 'responded_at', 'cooldown_until', 'entitlement_balance_id', 'created_at', 'updated_at'],
  (db.private_introduction_requests || []).map((row) => ({
    id: row.id,
    requester_user_id: row.requesterUserId,
    requester_profile_id: row.requesterProfileId || null,
    target_profile_id: row.targetProfileId,
    status: row.status,
    message: row.message || null,
    requested_at: toDateTime(row.requestedAt),
    expires_at: toDateTime(row.expiresAt),
    responded_at: toDateTime(row.respondedAt),
    cooldown_until: toDateTime(row.cooldownUntil),
    entitlement_balance_id: row.entitlementBalanceId || null,
    created_at: toDateTime(row.createdAt || row.requestedAt),
    updated_at: toDateTime(row.updatedAt || row.respondedAt || row.requestedAt),
  }))));

sql.push(insertInto('cm_inbox_threads', ['id', 'user_id', 'category', 'subject_type', 'subject_id', 'status', 'created_at', 'updated_at'],
  (db.inbox_threads || []).map((row) => ({
    id: row.id,
    user_id: row.userId,
    category: row.category,
    subject_type: row.subjectType || null,
    subject_id: row.subjectId || null,
    status: row.status,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_inbox_messages', ['id', 'thread_id', 'sender_type', 'sender_user_id', 'message_type', 'body', 'template_code', 'template_locale', 'action_type', 'action_payload', 'created_at', 'updated_at'],
  (db.inbox_messages || []).map((row) => ({
    id: row.id,
    thread_id: row.threadId,
    sender_type: row.senderType,
    sender_user_id: row.senderUserId || null,
    message_type: row.messageType,
    body: row.body,
    template_code: row.templateCode || null,
    template_locale: row.templateLocale || null,
    action_type: row.actionType || null,
    action_payload: row.actionPayload ? JSON.stringify(row.actionPayload) : null,
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

sql.push(insertInto('cm_inbox_reads', ['id', 'thread_id', 'user_id', 'last_read_at', 'created_at', 'updated_at'],
  (db.inbox_reads || []).map((row) => ({
    id: row.id,
    thread_id: row.threadId,
    user_id: row.userId,
    last_read_at: toDateTime(row.lastReadAt),
    created_at: toDateTime(row.createdAt),
    updated_at: toDateTime(row.updatedAt),
  }))));

fs.writeFileSync(outPath, `${sql.filter(Boolean).join('\n').trimEnd()}\n`, 'utf8');
console.log(`Generated ${path.relative(root, outPath)}`);
