# Phase 8.2.4 枚举与展示语义重整计划

本文档承接 `cm-admin-implementation-plan.md` 中的 Phase 8.2.4。主计划只保留引用，8.2.4 的实际执行以本文为准。

## 目标

Phase 8.2.4 不新增主要业务流程，目标是把 C 端和 Admin 后台分散维护的枚举、状态、可选项展示语义逐步收回到后端 options/dictionary 来源，避免同一个 code 在不同前端页面被翻译成不同含义。

这不是一次全局大重构。执行时必须按字段、接口和页面分区推进，每个分区完成后再进入下一个分区。

## 基本原则

- 数据库优先存稳定 code，不在业务表里存中文、英文、法文展示名。
- 保存接口只接收 code；编辑、筛选、提交链路的业务 API 默认继续返回 code。
- 后端负责稳定业务 code 的语义来源，例如状态、学历、行业、婚恋偏好、活动状态、会员权益等；前端通过 options/dictionary 查表显示 label。
- 前端继续负责格式化，例如日期、年龄、身高单位、空值展示、数组拼接、页面文案和布局。
- 前端不再为后端返回的稳定 code 维护本地枚举文案表，只保留通用 `value -> label` 查表逻辑。
- 不在字段边界未确认前建设动态字典中心。
- 不把所有模块一次性改完，每次只处理一个 API 或页面分区。

## 执行顺序

1. 先做 `8.2.4.1`：框定可写字段和筛选字段中哪些必须变成枚举，评估是否需要调整数据库。
2. 再做 `8.2.4.2`：从页面和 API 出发，把前端已有的 code 文案来源逐段切到 common options，业务 API 仍保持 code。
3. 最后做 `8.2.4.3`：在语义边界稳定后，再评估枚举值动态管理。

## 8.2.4.1 可写字段枚举边界与页面优化

### 范围

本步骤先解决“哪些字段应该是固定选项”。

需要盘点：

- C 端 Account Profile Detail 的创建、编辑字段。
- C 端 Account Settings 的偏好字段，例如偏好城市。
- C 端 Account Profile Detail 中的联系方式、归属关系和家庭协助字段。

### 产出

需要形成字段决策表，至少包含：

- 模块和页面。
- 字段名。
- 当前数据库字段。
- 当前前端输入方式。
- 目标类型：自由文本、多语言文本、单选枚举、多选枚举、数字、布尔、日期。
- 是否需要数据库调整。
- 是否需要接口调整。
- C 端影响。
- 当前决策和争议点。

### 初步字段判断

优先按枚举处理：

- `gender`
- `degreeLevel`
- `maritalStatus`
- `childrenPlan`
- `datingIntentionCode`
- `relocation`
- `preferredLocation`
- `smoking`
- `drinking`
- `activityLevel`
- `weekendStyle`
- `pets`
- `communicationStyle`
- `relationshipValues`
- `languages`
- `preferredChannel`
- `profileStatus`
- `photoStatus`
- `verificationStatus`
- `eventStatus`
- `registrationStatus`
- `membershipTier`
- `entitlementCode`

需要重点评估后再定：

- `country`
- `nationality`
- `city`
- `preferredCity`
- `industry`
- `relationshipGoal`
- `residencePlan`
- `preferredEducation`
- `familyLife`
- `exercise`

倾向继续作为文本或多语言文本：

- `profileName`
- `summary`
- `careerDirection`
- `education`
- `tags`
- `interests`
- `dealBreakers`
- `personalityTraits`
- 运营内部备注
- 认证材料备注

### 数据库判断

如果字段被确定为枚举，数据库应存 code。若当前字段实际存的是展示文案，需要先定义迁移方案，再改前后端。

不因为一个字段“看起来需要展示翻译”就直接改数据库。先判断它是不是稳定枚举，再决定是否迁移。

### 验收标准

- 字段决策表完整覆盖 C 端当前写入口。
- 必须迁移数据库的字段被明确列出。
- 不再把自由文本字段误改成枚举。
- Account Profile Detail 的必填字段排在选填字段前。
- 可写字段 options 的来源明确，前端不再复制多套同义枚举。

### 8.2.4.1 确认结论

本轮确认只覆盖 C 端写入口，不覆盖 Admin 后台。Admin 后台筛选、审核、资料库、资料运营里的 options 和 label 统一，放到后续 Admin 分区处理。

#### C 端字段评判表

Account Profile Detail：基础资料

| C 端中文名 | 字段 | 当前输入 | 当前存储 | 建议目标 | 需要你判断 |
| --- | --- | --- | --- | --- | --- |
| 称呼 | `profileName` | 文本 | `cm_profile_localized_fields.profile_name` | 多语言文本 | 保留文本 |
| 性别 | `gender` | 枚举 | `cm_profiles.gender` | 单选枚举 | 已确认 |
| 出生年份 | `birthYear` | 数字 | `cm_profiles.birth_year` | 数字 | 已确认 |
| 身高 | `height` | 数字 | `cm_profiles.height` | 数字 | 已确认 |
| 城市 | `city` | 文本 | `cm_profiles.city_code` + `localized_fields.city` | 城市 code + label | 固定城市选项，code 使用 `FR:paris` 格式 |
| 国家 | `country` | 文本 | `cm_profiles.country_code` + `localized_fields.country` | ISO alpha-2 code + label | 使用稳定国家 code |
| 国籍 | `nationality` | 文本 | `cm_profiles.nationality_code` + `localized_fields.nationality` | ISO alpha-2 code + label | 与国家共用 options |
| 语言 | `languages` | 多选 | `cm_profile_languages.language_code` | 多选枚举 | 已确认 |
| 最高学历 | `degreeLevel` | 枚举 | `cm_profiles.degree_level` | 单选枚举 | 已确认 |
| 教育背景 | `education` | 文本 | `cm_profiles.education_code` + `localized_fields.education` | 教育/专业 code + label | 固定为笼统教育背景选项，保留“其他”并要求补充说明 |
| 行业 | `industry` | 文本 | `cm_profiles.industry_code` + `localized_fields.industry` | 行业 code + label | 固定为笼统行业选项，保留“其他”并要求补充说明 |
| 职业方向 | `careerDirection` | 文本 | `localized_fields.career_direction` | 多语言文本 | 建议保留文本 |

Account Profile Detail：婚恋与未来

| C 端中文名 | 字段 | 当前输入 | 当前存储 | 建议目标 | 需要你判断 |
| --- | --- | --- | --- | --- | --- |
| 婚姻状态 | `maritalStatus` | 枚举 | `cm_profiles.marital_status` | 单选枚举 | 已确认 |
| 是否有孩子 | `hasChildren` | 布尔 | `cm_profiles.has_children` | 布尔 | 已确认 |
| 子女计划 | `childrenPlan` | 枚举 | `cm_profiles.children_plan` | 单选枚举 | 已确认 |
| 是否接受异地 | `acceptsLongDistance` | 布尔 | `cm_profiles.accepts_long_distance` | 布尔 | 已确认 |
| 关系目标 | `datingIntentionCode` | 枚举 | `cm_profiles.dating_intention_code` | 单选枚举 | 已确认 |
| 关系期望 | `relationshipGoal` | 文本 | `localized_fields.relationship_goal` | code + label | 固定为选项 |
| 定居规划 | `residencePlan` | 文本 | `localized_fields.residence_plan` | code + label | 固定为选项 |
| 迁居意愿 | `relocation` | 枚举 | `cm_profiles.relocation` | 单选枚举 | 已确认 |
| 关系价值观 | `relationshipValues` | 多选 | `cm_profile_relationship_values.value_code` | 多选枚举 | 已确认 |

Account Profile Detail：择偶偏好

| C 端中文名 | 字段 | 当前输入 | 当前存储 | 建议目标 | 需要你判断 |
| --- | --- | --- | --- | --- | --- |
| 偏好年龄 | `preferredAgeMin` / `preferredAgeMax` | 数字区间 | `cm_profiles.preferred_age_min/max` | 数字区间 | 已确认 |
| 地域偏好 | `preferredLocation` | 枚举 | `cm_profiles.preferred_location` | 单选枚举 | 已确认 |
| 学历偏好 | `preferredEducation` | 文本 | `localized_fields.preferred_education` | code + label | 固定为选项 |
| 家庭生活 | `familyLife` | 文本 | `localized_fields.family_life` | code + label | 固定为选项 |
| 不能接受的点 | `dealBreakers` | 列表文本 | `cm_profile_localized_items.deal_breakers` | 多语言列表文本 | 建议保留文本 |

Account Profile Detail：生活方式

| C 端中文名 | 字段 | 当前输入 | 当前存储 | 建议目标 | 需要你判断 |
| --- | --- | --- | --- | --- | --- |
| 吸烟 | `smoking` | 枚举 | `cm_profiles.smoking` | 单选枚举 | 已确认 |
| 饮酒 | `drinking` | 枚举 | `cm_profiles.drinking` | 单选枚举 | 已确认 |
| 运动 | `exercise` | 文本 | `localized_fields.exercise` | code + label | 固定为选项 |
| 活跃程度 | `activityLevel` | 枚举 | `cm_profiles.activity_level` | 单选枚举 | 已确认 |
| 周末节奏 | `weekendStyle` | 枚举 | `cm_profiles.weekend_style` | 单选枚举 | 已确认 |
| 宠物 | `pets` | 枚举 | `cm_profiles.pets` | 单选枚举 | 已确认 |

Account Profile Detail：个性与表达

| C 端中文名 | 字段 | 当前输入 | 当前存储 | 建议目标 | 需要你判断 |
| --- | --- | --- | --- | --- | --- |
| 性格关键词 | `personalityTraits` | 列表文本 | `cm_profile_localized_items.personality_traits` | 多语言列表文本 | 建议保留文本 |
| 兴趣 | `interests` | 列表文本 | `cm_profile_localized_items.interests` | 多语言列表文本 | 建议保留文本 |
| 沟通方式 | `communicationStyle` | 枚举 | `cm_profiles.communication_style` | 单选枚举 | 已确认 |
| 简介 | `summary` | 文本 | `localized_fields.summary` | 多语言文本 | 保留文本 |
| 标签 | `tags` | 列表文本 | `cm_profile_localized_items.tags` | 多语言列表文本 | 建议保留文本 |

Account Profile Detail：家庭协助与联系方式

| C 端中文名 | 字段 | 当前输入 | 当前存储 | 建议目标 | 需要你判断 |
| --- | --- | --- | --- | --- | --- |
| 家庭可见 | `familyVisible` | 布尔 | `cm_profiles.family_visible` | 布尔 | 已确认 |
| 与资料本人的关系 | `relationshipToProfile` | 枚举 | `cm_profile_ownerships.relationship_to_profile` | 单选枚举 | 已确认 |
| 手机 | `phone` | 文本 | `cm_profile_contacts.phone` | 文本 | 保留文本 |
| 邮箱 | `email` | 文本 | `cm_profile_contacts.email` | 文本 | 保留文本 |
| 微信 | `wechat` | 文本 | `cm_profile_contacts.wechat` | 文本 | 保留文本 |
| 首选联系 | `preferredChannel` | 枚举 | `cm_profile_contacts.preferred_channel` | 单选枚举 | 已确认 |
| 联系方式开放 | `contactVisibility` | 枚举 | `cm_profile_contacts.visibility` | 单选枚举 | 已确认 |

Account Settings：偏好设置

| C 端中文名 | 字段 | 当前输入 | 当前存储 | 建议目标 | 需要你判断 |
| --- | --- | --- | --- | --- | --- |
| 偏好城市 | `preferredCity` | 文本 | `cm_user_preferences.preferred_city_code` | 城市 code + label | 与资料城市共用 options，code 使用 `FR:paris` 格式 |
| 偏好联系方式 | `preferredContactChannel` | 枚举 | `cm_user_preferences.preferred_contact_channel` | 单选枚举 | 已确认 |
| 员工联系 | `staffContactEnabled` | 开关 | `cm_user_preferences.staff_contact_enabled` | 布尔 | 已确认 |
| 家庭协助 | `familyAssistEnabled` | 开关 | `cm_user_preferences.family_assist_enabled` | 布尔 | 已确认 |
| 私人介绍更新 | `introductionUpdatesEnabled` | 开关 | `cm_user_preferences.introduction_updates_enabled` | 布尔 | 已确认 |
| 活动提醒 | `eventRemindersEnabled` | 开关 | `cm_user_preferences.event_reminders_enabled` | 布尔 | 已确认 |
| 服务公告 | `serviceAnnouncementsEnabled` | 开关 | `cm_user_preferences.service_announcements_enabled` | 布尔 | 已确认 |
| 营销邮件 | `marketingEmailsEnabled` | 开关 | `cm_user_preferences.marketing_emails_enabled` | 布尔 | 已确认 |
| 数据分析授权 | `analyticsConsentEnabled` | 开关 | `cm_user_preferences.analytics_consent_enabled` | 布尔 | 已确认 |

本轮已拍板：

| C 端中文名 | 字段 | 结论 |
| --- | --- | --- |
| 城市 | `city` | 固定为城市选项，保存 `FR:paris` 格式城市 code |
| 偏好城市 | `preferredCity` | 与资料城市共用城市 options |
| 国家 | `country` | 使用 ISO alpha-2 稳定国家 code |
| 国籍 | `nationality` | 与国家共用 ISO alpha-2 options |
| 教育背景 | `education` | 改为教育/专业 code，选项写笼统一些，底部保留“其他”，选其他后补充说明 |
| 行业 | `industry` | 固定为行业选项，选项写笼统一些，底部保留“其他”，选其他后补充说明 |
| 职业方向 | `careerDirection` | 保留文本 |
| 关系期望 | `relationshipGoal` | 固定为选项 |
| 定居规划 | `residencePlan` | 固定为选项 |
| 学历偏好 | `preferredEducation` | 固定为选项 |
| 家庭生活 | `familyLife` | 固定为选项 |
| 不能接受的点 | `dealBreakers` | 保留文本 |
| 运动 | `exercise` | 固定为选项 |
| 性格关键词 | `personalityTraits` | 保留文本 |
| 兴趣 | `interests` | 保留文本 |
| 简介 | `summary` | 保留文本 |
| 标签 | `tags` | 保留文本 |
| 手机 / 邮箱 / 微信 | `phone` / `email` / `wechat` | 保留文本 |

#### C 端枚举 options 获取与缓存方案

8.2.4.1 需要新增 C 端枚举 options API，并新增持久化 Pinia store 缓存后端下发的可选项。

该 API 只负责读取可选项，不提供后台维护能力；枚举值动态管理仍属于 8.2.4.3。

当前实现已提供通用 options API：

```text
GET /api/common/options?version={clientVersion}
```

语言不由页面或业务 store 手动传入。C 端 `http.ts` 已经统一维护当前 locale，后端从统一请求参数 `lang` 读取语言。`locale` query 只作为旧兼容兜底。

options API 已从 profile 业务接口中移出；新模块不应继续新增各自分散的本地枚举文案表。

返回规则：

- 前端首次进入需要枚举选项的页面时，请求当前语言的 options；语言由 `http.ts` 统一注入。
- 请求附带本地缓存的 `version` 或 `updatedAt`。
- 如果前端版本与后端一致，后端返回“不需要更新”的轻量响应。
- 如果版本不一致，后端返回新的 options、版本号和更新时间。
- 每种语言独立缓存，语言切换后按对应语言重新校验版本。
- 版本号由后端维护一个整体 `commonOptionsVersion`，可以使用更新时间戳或内容 hash；8.2.4.1 不做每个 group 的独立版本。

建议响应结构：

```ts
{
  version: "2026-06-24T00:00:00Z",
  unchanged: false,
  groups: {
    city: [{ value: "FR:paris", label: "巴黎" }],
    country: [{ value: "FR", label: "法国" }],
    nationality: [{ value: "CN", label: "中国" }],
    education: [{ value: "master_general", label: "硕士及以上" }, { value: "other", label: "其他", requiresExtraText: true }],
    industry: [{ value: "finance", label: "金融" }, { value: "other", label: "其他", requiresExtraText: true }],
    relationshipGoal: [],
    residencePlan: [],
    preferredEducation: [],
    familyLife: [],
    exercise: []
  }
}
```

Pinia store 要求：

- 使用持久化缓存保存 `locale -> version -> groups`。
- 页面读取 options 时只读 store，不在页面里硬编码枚举 label。
- store 负责判断是否需要向后端刷新。
- 如果刷新失败，允许继续使用本地缓存；没有缓存时页面显示加载失败或禁用相关选择器。
- 保存 payload 只提交 `value`，不提交 `label`。

options API 必须返回的分组：

- 本轮新增枚举化字段：`city`、`country`、`nationality`、`education`、`industry`、`relationshipGoal`、`residencePlan`、`preferredEducation`、`familyLife`、`exercise`。
- C 端现有固定枚举字段：`gender`、`degreeLevel`、`maritalStatus`、`childrenPlan`、`datingIntentionCode`、`relocation`、`relationshipValues`、`preferredLocation`、`smoking`、`drinking`、`activityLevel`、`weekendStyle`、`pets`、`communicationStyle`、`relationshipToProfile`、`preferredChannel`、`contactVisibility`。
- 布尔字段不需要进入 options API，继续由前端通用 yes/no 控件处理。

#### code 格式与“其他”补充说明

已确认 code 格式：

- `country` / `nationality` 使用 ISO alpha-2，例如 `FR`、`CN`、`US`。
- `city` 使用带国家前缀的稳定 code，例如 `FR:paris`、`CN:shanghai`。
- 业务枚举使用 snake_case，例如 `open_to_discuss`、`master_general`。
- `other` 是合法 code，但必须支持补充说明。

`other` 补充说明要求：

- 用户选择“其他”后必须填写补充说明。
- 补充说明不替代 code；保存时仍保存 `other`，另存对应的说明文本。
- 补充说明需要支持多语言编辑和翻译流程，不能写入 options label。
- 8.2.4.1 新增专用补充说明表，不复用原 `cm_profile_localized_fields`。
- 允许选择“其他”的字段限定为：`education`、`industry`、`relationshipGoal`、`residencePlan`、`preferredEducation`、`familyLife`、`exercise`。
- `country`、`nationality`、`city` 不提供“其他”，避免破坏稳定 code 体系。

建议新增表：

```sql
cm_profile_option_extra_texts (
  id,
  profile_id,
  field_name,
  locale,
  value,
  source,
  provider,
  status,
  created_at,
  updated_at
)
```

该表只保存 `other` 的补充说明。字段 code 仍保存在主表或关系表中。

#### 数据迁移与 localized_fields 调整

8.2.4.1 需要把初始化 SQL 和现有数据来源一步到位调整到 code 结构。

迁移原则：

- 枚举字段的权威值统一迁移到主表 code 字段或关系表 code 字段。
- 已改为枚举的字段不再以 `cm_profile_localized_fields` 作为权威来源。
- `cm_profile_localized_fields` 中对应枚举字段的旧展示文本在迁移后删除，不保留为后端读取来源。
- 若旧值无法映射到新 code，迁移为 `other`，并写入 `cm_profile_option_extra_texts`。
- 保存接口不再为这些枚举字段写 localized value。
- Account 编辑详情接口只返回 code；页面展示 label 时从 options store 取值。
- C 端公开展示类接口可以继续返回后端 resolver 得到的展示文本，后续按 API 分区逐步收敛。

options 来源：

- 8.2.4.1 先使用后端代码常量维护 options。
- 不在 8.2.4.1 建动态字典表。
- 8.2.4.3 再评估是否接入 RuoYi 字典或 Cupid 专用字典管理。
- 现有固定枚举字段直接复用当前 C 端已经使用的枚举值，不重新设计。
- 本轮新增枚举化字段只提供 2-3 个示例值，加上必要的 `other` 兜底。
- 完整枚举值补充、排序、启停、多语言维护放到 8.2.4.3。

新增枚举化字段的 8.2.4.1 初始值要求：

| 字段 | 初始值策略 |
| --- | --- |
| `city` | 提供 2-3 个示例城市，例如 `FR:paris`、`CN:shanghai`，不提供 `other` |
| `country` | 提供 2-3 个示例国家，例如 `FR`、`CN`，不提供 `other` |
| `nationality` | 与 `country` 共用 options，不提供 `other` |
| `education` | 提供 2-3 个笼统教育/专业选项，并提供 `other` |
| `industry` | 提供 2-3 个笼统行业选项，并提供 `other` |
| `relationshipGoal` | 提供 2-3 个示例选项，并提供 `other` |
| `residencePlan` | 提供 2-3 个示例选项，并提供 `other` |
| `preferredEducation` | 提供 2-3 个示例选项，并提供 `other` |
| `familyLife` | 提供 2-3 个示例选项，并提供 `other` |
| `exercise` | 提供 2-3 个示例选项，并提供 `other` |

接口字段命名：

- 保存 payload 中的枚举字段改为明确的 code 字段，例如 `cityCode`、`countryCode`、`nationalityCode`、`educationCode`、`industryCode`。
- Account 编辑详情响应只返回 code，不返回冗余 label。
- Account 页面展示时通过 options store 将 code 转为 label；若 code 为 `other`，非编辑态优先展示 `cm_profile_option_extra_texts` 中的补充说明。

本轮涉及从 localized fields 退出的字段：

- `city`
- `country`
- `nationality`
- `education`
- `industry`
- `relationship_goal`
- `residence_plan`
- `preferred_education`
- `family_life`
- `exercise`

保留在 localized fields 的字段：

- `profile_name`
- `career_direction`
- `summary`

保留在 localized items 的字段：

- `deal_breakers`
- `personality_traits`
- `interests`
- `tags`

### 8.2.4.1 当前实现状态

已完成的服务端部分：

- 新增通用 options 接口；当前实现路径为 `GET /api/common/options?version={version}`，语言由 `http.ts` 统一注入。
- 新增后端代码常量版 profile options，并返回整体 `version` 与 `unchanged`。
- `cm_profiles` 增加 `relationship_goal_code`、`residence_plan_code`、`preferred_education_code`、`family_life_code`、`exercise_code`。
- 新增 `cm_profile_option_extra_texts`，用于保存枚举 `other` 的当前语言补充说明。
- `cm_schema.sql` 已同步新列、新表和 localized fields 职责收窄，当前以全量重建脚本为准。
- Account profile owner detail 仅返回 `xxxCode`，不再返回旧 `xxx` 字段或 `xxxLabel`。
- Account profile 保存链路已改为保存 code 字段，`other` 补充说明写入专用表。
- C 端公开目录/detail 中已完成新增枚举化字段的展示整理：city、country、nationality、education、industry、relationshipGoal、residencePlan、preferredEducation、familyLife、exercise 可按后端 options 语义展示；编辑接口仍只返回 code。
- 目录 education 筛选与 facet 已从 `degree_level` 调整为 `education_code`。

已完成的 C 端部分：

- 新增持久化 Pinia options store：`src/stores/modules/options.ts`。
- C 端调用 `/api/common/options` 并按 locale/version 缓存；业务 store 不再手动传 locale，统一复用 `http.ts` 的语言注入。
- Account Profile Detail 将 `city/country/nationality/education/industry/relationshipGoal/residencePlan/preferredEducation/familyLife/exercise` 改为枚举选择。
- Account Profile Detail 保存 payload 改为提交 `xxxCode`，并提交 `optionExtraTexts`。
- `other` 选项编辑态显示补充说明输入框，非编辑态显示具体补充说明而不是“其他”。
- Account Settings 的 `preferredCity` 改为复用城市 options 并保存 city code。
- C 端已通过 `npm.cmd run type-check`。

当前阻塞：

- 当前 server shell 未配置 `mvn` / `mvn.cmd`，后端 Maven 编译未能执行；已执行 `git diff --check`，未发现 whitespace 问题。

## 8.2.4.2 前端枚举文案源切换到 common options

### 目标

本步骤只解决一件事：把前端本地维护的枚举文案、枚举 options、`t(code)` 兜底翻译，逐步切换为读取后端 `GET /api/common/options` 下发的 `{ value, label }`。

业务 API 的职责不变：

- 数据库继续保存稳定 code。
- 编辑、筛选、提交、状态判断等业务 API 继续传递稳定 code。
- 前端保存 payload 继续提交 code，不提交 label。
- 前端只做通用 `value -> label` 查表，不再维护每个枚举的本地文案表。

### 当前接口边界

8.2.4.1 已完成接口收口：

```text
GET /api/common/options?version={clientVersion}
```

- 当前一次性返回全部已接入 options，group 使用模块前缀，例如 `profile.gender`、`profile.city`。
- 语言由 `http.ts` 统一注入 `lang`，页面、hook、store 不手动传 `locale`。
- `version` 用于本地缓存校验。
- C 端统一通过 `src/api/common/options.ts` 和 `src/stores/modules/options.ts` 读取。
- `/api/profiles/options` 不再作为对外 API。

### 不做的事

- 不把业务 API 的 code 字段批量改成 label 字段。
- 不新增 `xxxLabel` 作为兼容字段。
- 不迁移数据库字段。
- 不把日期、年龄、身高、空值、数组拼接、页面静态文案交给 options API。
- 不把状态机、权限分支、权益消费等硬规则 code 做成可随意配置的动态字典。
- 不一次性替换 C 端和 Admin 的所有 i18n。

### 执行方法

每个分区按同一流程推进：

1. 列出该分区使用到的 code 字段。
2. 标明字段来自哪个 API endpoint。
3. 标明对应的 common options group。
4. 若后端 options 缺少 group，先补 group。
5. 删除或替换前端本地枚举文案来源，包括 i18n key、switch、map、硬编码 options。
6. 前端改为调用 `optionsStore.optionsFor(locale, group)` 或封装后的 `optionLabel(group, value)`。
7. 保留格式化逻辑和页面结构。
8. 每完成一个分区，运行对应类型检查或构建，并记录手工校验点。

### 分区顺序

1. C 端 Account Profile Detail 与 Account Settings。
2. C 端 Profile 目录与详情。
3. C 端 Event 目录、详情、报名与账号活动。
4. C 端 Membership、Introduction、Inbox、Relationship。
5. Admin 资料审核、资料库、资料运营、照片审核、认证审核。
6. Admin 系统已有模块中被 Cupid 复用的字典、参数或状态展示。

### 当前完成分区

#### C 端 Account Profile Detail 与 Account Settings

| 项目 | 说明 |
| --- | --- |
| 页面/模块 | Account Profile Detail、Account Settings |
| API endpoint | `/api/account/profiles/{id}`、`/api/account/preferences`、`/api/common/options` |
| code 字段 | `gender`、`degreeLevel`、`city`、`country`、`nationality`、`languages`、`education`、`industry`、`maritalStatus`、`childrenPlan`、`datingIntentionCode`、`relationshipGoal`、`residencePlan`、`relocation`、`relationshipValues`、`preferredLocation`、`preferredEducation`、`familyLife`、`smoking`、`drinking`、`exercise`、`activityLevel`、`weekendStyle`、`pets`、`communicationStyle`、`relationshipToProfile`、`preferredChannel`、`contactVisibility`、`profileStatus`、`photoStatus`、`verificationStatus`、`reviewStatus`、`preferred_city`、`preferred_contact_channel` |
| group | `profile.*` |
| 原前端映射 | `profiles.detail.values.*`、`profiles.relationship.*`、`settings.contactChannel.*`、页面内硬编码 options |
| 新读取方式 | `src/stores/modules/options.ts` 读取 `/api/common/options` 后，用 `profile.<field>` group 查询 label/options |
| 不改原因 | `preferredLocale`、布尔值、空值、日期仍按页面原有格式化与静态文案处理 |
| 校验点 | Account Profile Detail 创建/编辑/回显；多语言切换；`other` 补充说明展示；Account Settings 偏好城市和首选联系渠道显示/保存 |

#### C 端 Profile 目录与详情

| 项目 | 说明 |
| --- | --- |
| 页面/模块 | Self Profile Directory、Family Profile Directory、Self Profile Detail、Family Profile Detail |
| API endpoint | `/api/profiles/self`、`/api/profiles/family`、`/api/profiles/self/{id}`、`/api/profiles/family/{id}`、`/api/common/options` |
| code 字段 | `languages`、`gender`、`degreeLevel`、`maritalStatus`、`childrenPlan`、`datingIntentionCode`、`relationshipValues`、`communicationStyle`、`preferredLocation`、`relocation`、`activityLevel`、`weekendStyle`、`smoking`、`drinking`、`pets` |
| group | `profile.*` |
| 原前端映射 | `formatProfileLanguages`、`profiles.detail.values.*`、目录卡片里的 intent/marital switch、目录筛选里的 gender/education/marital 静态 i18n |
| 新读取方式 | Profile 目录与详情 hook 通过 `src/stores/modules/options.ts` 读取 `/api/common/options`，向 mapper 传入 `optionLabel(fieldKey, value)`；mapper 只做纯展示转换 |
| 不改原因 | 年龄、身高、空值、数组拼接、是否有子女、是否接受异地、认证状态、资料状态、排序文案仍属于前端格式化或页面静态文案；目录 facet 中的城市、行业、交友意向已由后端返回 label |
| 校验点 | Self/Family 目录卡片徽章和语言展示；目录筛选项性别/学历/婚姻/语言展示；Self/Family 详情婚恋、生活方式、语言、关系价值观展示；语言切换后 label 更新 |

#### C 端 Event 目录、详情、报名与首页预览

| 项目 | 说明 |
| --- | --- |
| 页面/模块 | Events Directory、Event Detail、Home Events Preview |
| API endpoint | `/api/events`、`/api/events/{id}`、`/api/events/{id}/register`、`/api/events/{id}/registration`、`/api/common/options` |
| code 字段 | `status`、`languageCodes` |
| group | `event.status`、`profile.languages` |
| 原前端映射 | 活动卡片 `status.${code}`，详情页语言 `toUpperCase().join(' / ')` |
| 新读取方式 | Event hooks 通过 `src/stores/modules/options.ts` 读取 `/api/common/options`，向 mapper 传入 `optionLabel(group, value)`；活动语言复用 `profile.languages`，活动卡片状态使用 `event.status` |
| 不改原因 | 报名状态的 title/description/action 是页面状态说明和操作文案，不是简单枚举 label；活动 format、audience、relationshipFocus 当前由后端直接返回展示文本；日期、席位、地址锁定提示仍由前端格式化和页面文案处理 |
| 校验点 | 首页活动卡片、活动目录卡片、活动详情 hero 和 facts 中的状态/语言展示；语言切换后 label 更新；报名/取消按钮文案不回退为裸 code |

#### C 端 Membership、Introduction、Relationship 与账户摘要

| 项目 | 说明 |
| --- | --- |
| 页面/模块 | Account Shell、Account Home、Account Events、Account Membership、Account Relationship、Account Profiles、Account Profile Detail |
| API endpoint | `/api/account/dashboard`、`/api/account/events`、`/api/account/membership`、`/api/account/private-introductions`、`/api/account/profiles`、`/api/account/profiles/{id}`、`/api/common/options` |
| code 字段 | `membershipTier`、`membership.status`、`entitlement.code`、`eventRegistration.status`、`introduction.status`、`relationshipToProfile`、`profileStatus` |
| group | `membership.tier`、`membership.status`、`membership.entitlement`、`event.registrationStatus`、`introduction.status`、`profile.relationshipToProfile`、`profile.profileStatus` |
| 原前端映射 | `home.membership.tier.*`、`membership.status.*`、`membership.entitlement.*`、`events.registrationStatus.*`、`introduction.status.*`、`profiles.relationship.*`、`profiles.status.*` |
| 新读取方式 | 对应页面或组件通过 `src/stores/modules/options.ts` 读取 `/api/common/options`，使用 `optionLabel(group, value)` 显示短 label |
| 不改原因 | `membership.tierPositioning.*`、`membership.entitlementDescription.*`、`relationship.contactReason.*`、`home.actions.*`、账号状态、语言、MFA、登录方式 provider、设置项名称是页面说明、操作文案或账号安全流程文案，不是本轮业务枚举 label |
| 校验点 | 账户侧栏会员等级、账户首页活动/资料状态、我的资料列表、资料详情标题和状态、我的活动报名状态、我的会员状态和权益名称、私人介绍状态；语言切换后 label 更新 |

#### Admin 资料审核、资料库、资料运营、照片审核、认证审核

| 项目 | 说明 |
| --- | --- |
| 页面/模块 | Cupid Admin review utils、资料审核、资料库、资料运营、照片审核、认证材料审核 |
| API endpoint | `/api/common/options`、`/cupid/profile/*`、`/cupid/photo/*`、`/cupid/verification/*` |
| code 字段 | `profileType`、`profileStatus`、`photoStatus`、`reviewStatus`、`verificationStatus`、`verificationMaterialType`、`verificationMaterialStatus`、`gender`、`degreeLevel`、`maritalStatus`、`childrenPlan`、`datingIntentionCode`、`relocation`、`smoking`、`drinking`、`activityLevel`、`weekendStyle`、`pets`、`communicationStyle`、`relationshipValues`、`preferredLocation`、`languages`、`preferredChannel`、`contactVisibility`、`relationshipToProfile` |
| group | `profile.*`、`verification.materialType`、`verification.materialStatus` |
| 原前端映射 | `src/views/cupid/review-utils.ts` 中的静态 options、`optionLocaleLabels` 和 `labelOf/labelsOf` |
| 新读取方式 | Admin 新增 `src/api/cupid/options.ts` 与 `src/store/modules/cupidOptions.ts`；`review-utils.labelOf/labelsOf/profileCodeLabel` 从 Pinia options store 读取 `/api/common/options` 的后端 label；options store 复用 RuoYi `cache.local` 持久化 locale/version/groups |
| 不改原因 | 排序选项、拒绝快捷原因、审核操作文案、来源/翻译来源、yes/no、时间、空值仍属于页面控制或格式化；动态管理放到 8.2.4.3 |
| 校验点 | 资料审核/资料库/资料运营/照片审核/认证审核中短枚举 label 不再裸露 code；切换资料详情语言时仍能显示 label；options 缓存由 Admin Pinia store 统一维护 |

### 每个分区需要记录

| 项目 | 说明 |
| --- | --- |
| 页面/模块 | 例如 Account Profile Detail |
| API endpoint | 例如 `/api/account/profiles/{id}` |
| code 字段 | 例如 `gender`、`maritalStatus` |
| group | 例如 `profile.gender` |
| 原前端映射 | i18n key、switch、map 或硬编码 options 文件 |
| 新读取方式 | options store 或通用 helper |
| 不改原因 | 若某字段保留本地格式化，需要说明原因 |
| 校验点 | 页面、语言切换、保存回显、筛选等 |

### 验收标准

- 已处理分区不再维护该分区的本地枚举文案表。
- 已处理分区的 label 统一来自 common options。
- 业务 API、保存 payload、筛选参数仍使用稳定 code。
- 语言切换后 options 能按当前 locale 重新读取或使用对应缓存。
- 没有裸 code 出现在用户可见 UI。
- 类型检查或构建通过。

## 8.2.4.3 枚举值动态管理

本步骤必须等 `8.2.4.1` 和 `8.2.4.2` 稳定后再做。

本步骤不是继续扩大枚举覆盖范围，而是把已经接入 `/api/common/options`、且确实适合运营维护的 options 从代码常量迁移到后台可维护来源。

需要评估：

- 复用 RuoYi `sys_dict` 还是新建 Cupid 专用字典表。
- 多语言 label 的存储方式。
- 排序、启用、停用、默认值。
- 审计日志。
- 缓存刷新。
- C 端和 Admin 的 options 拉取方式。

### 8.2.4.3 动态管理边界

可进入动态管理的 group 必须满足：

- 只影响展示 label、选择器 options、筛选项，不直接改变状态机流转。
- 新增或停用某个 value 后，业务代码不需要新增分支判断。
- 保存接口仍只保存稳定 code。
- 禁用已有 value 时，不删除历史数据；历史数据展示仍能按 code 回显，必要时标记为已停用。

优先进入动态管理：

| group | 用途 | 说明 |
| --- | --- | --- |
| `profile.city` | 资料城市、偏好城市 | 运营需要维护城市列表与排序 |
| `profile.country` | 国家 | 国家 code 稳定，label 可维护 |
| `profile.nationality` | 国籍 | 与国家可共用基础数据，但 options group 保持独立 |
| `profile.languages` | 语言 | 语言 code 稳定，label 和排序可维护 |
| `profile.education` | 教育背景 | 8.2.4.1 新增枚举化字段，需要后续补全值 |
| `profile.industry` | 行业 | 8.2.4.1 新增枚举化字段，需要后续补全值 |
| `profile.relationshipGoal` | 关系目标 | 可作为运营维护的选择项 |
| `profile.residencePlan` | 居住计划 | 可作为运营维护的选择项 |
| `profile.preferredEducation` | 期望学历 | 可作为运营维护的选择项 |
| `profile.familyLife` | 家庭生活 | 可作为运营维护的选择项 |
| `profile.exercise` | 运动习惯 | 可作为运营维护的选择项 |
| `profile.degreeLevel` | 最高学历 | 展示与筛选枚举，允许维护 label 和排序 |
| `profile.maritalStatus` | 婚姻状态 | 展示与筛选枚举，新增值需谨慎但不应影响状态机 |
| `profile.childrenPlan` | 子女计划 | 展示与筛选枚举 |
| `profile.datingIntentionCode` | 交友意向 | 展示与筛选枚举 |
| `profile.relocation` | 迁居意愿 | 展示与筛选枚举 |
| `profile.relationshipValues` | 关系价值观 | 多选展示枚举 |
| `profile.preferredLocation` | 地域偏好 | 展示与筛选枚举 |
| `profile.smoking` | 吸烟 | 展示与筛选枚举 |
| `profile.drinking` | 饮酒 | 展示与筛选枚举 |
| `profile.activityLevel` | 活跃程度 | 展示与筛选枚举 |
| `profile.weekendStyle` | 周末节奏 | 展示与筛选枚举 |
| `profile.pets` | 宠物 | 展示与筛选枚举 |
| `profile.communicationStyle` | 沟通方式 | 展示与筛选枚举 |

暂不进入动态管理，继续代码常量维护：

| group | 原因 |
| --- | --- |
| `profile.profileType` | 资料类型影响页面和权限分支 |
| `profile.profileStatus` | 资料状态机 |
| `profile.photoStatus` | 照片审核状态机 |
| `profile.reviewStatus` | 审核状态机 |
| `profile.verificationStatus` | 认证状态机 |
| `profile.relationshipToProfile` | 资料归属权限语义，新增值需要代码处理 |
| `profile.preferredChannel` | 联系方式字段固定，新增值需要表单和展示支持 |
| `profile.contactVisibility` | 联系方式开放规则，影响权限判断 |
| `profile.ownershipPermission` | 归属权限规则 |
| `profile.ownershipStatus` | 归属状态机 |
| `profile.internalRecordSource` | 内部来源语义，暂不开放给运营维护 |
| `account.status` | 账号状态机 |
| `account.locale` | 系统支持语言范围 |
| `account.identityProvider` | 登录方式，需要认证链路支持 |
| `account.preference` | 设置项名称，不是用户可选枚举值 |
| `event.status` | 活动状态机 |
| `event.registrationStatus` | 活动报名状态机 |
| `introduction.status` | 私人介绍状态机 |
| `membership.status` | 会员状态机 |
| `membership.tier` | 会员套餐，涉及权益与价格，不在字典页维护 |
| `membership.entitlement` | 权益 code，涉及消费规则 |
| `message.subjectType` | 消息主题类型，涉及消息生成逻辑 |
| `relationship.contactReason` | 联系方式不可见原因，属于业务分支文案 |
| `event.addressLockReason` | 活动地址锁定原因，属于业务分支文案 |
| `localized.status` | 翻译任务状态 |
| `localized.source` | 本地化来源语义 |
| `localized.provider` | 翻译提供方语义 |
| `verification.materialType` | 认证材料类型，涉及审核页面和业务字段 |
| `verification.materialStatus` | 认证材料状态机 |
| `verification.scanStatus` | 材料安全扫描状态机 |

不应动态管理：

- 状态机 code。
- 权益消费 code。
- 会影响业务分支判断的硬规则 code。

### 8.2.4.3 建议执行顺序

1. 先确定数据来源方案：优先评估 RuoYi `sys_dict` 是否足够承载 `group/value/label/sort/status`，若多语言与版本刷新成本过高，再新建 Cupid 专用 options 表。
2. 建立只读迁移：后端 `/api/common/options` 先支持从动态来源读取；动态来源缺失时仍可回落到代码常量，但只作为迁移保护。
3. 建立后台管理页：只开放“优先进入动态管理”的 group，支持中/法/英 label、排序、启停、requiresExtraText。
4. 建立版本刷新：动态 options 改动后更新整体 `commonOptionsVersion`，C 端和 Admin 继续沿用现有缓存逻辑。
5. 建立审计：新增、修改、启停 options 写入业务审计日志。
6. 迁移初始数据：把当前代码常量中的动态 group 初始化到数据库，代码常量只保留 static/system group。
7. 校验 C 端和 Admin：确认动态 group 的新增、停用、排序、多语言切换都能正常回显。

## 非目标

- 不重写整个 Account Profile Detail 页面。
- 不一次性替换所有前端 i18n。
- 不把格式化逻辑搬到后端。
- 不在 8.2.4.1 或 8.2.4.2 建设完整字典管理后台。
- 不把动态枚举、数据库迁移、C 端 UI 重构、Admin UI 重构混在同一个提交里。

## 手工校验清单

- C 端 Account Profile Detail 创建和编辑资料，枚举字段可选择、可保存、可回显。
- C 端 Account Settings 偏好字段可选择、可保存、可回显。
- C 端 Profile 目录和详情展示字段含义正确。
- C 端 Event、Membership、Introduction、Inbox、Relationship 页面不再出现裸 code。
- Admin 资料审核、资料库、资料运营、照片审核、认证审核不再出现应翻译的裸 code。
- 日期、年龄、身高、空值、数组展示仍由前端按原体验格式化。

## 提交策略

建议拆分提交：

- `docs(admin): split phase 8.2.4 enum plan`
- `refactor(profile): classify editable enum fields`
- `refactor(account): centralize account enum labels`
- `refactor(events): centralize event enum labels`
- `refactor(admin): consume backend enum labels`
- `feat(admin): add enum dictionary management`
