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
2. 再做 `8.2.4.2`：从 API 出发，把前端已有的 code 文案来源逐段切到后端 options/dictionary。
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

8.2.4.1 当前实现先使用资料范围 API：

```text
GET /api/profiles/options?version={clientVersion}
```

语言不应由页面或业务 store 手动传入。C 端 `http.ts` 已经统一维护当前 locale，后续请求应复用统一语言注入；后端从统一请求上下文读取语言。若后端暂时仍保留 `locale` 参数，只作为兼容入口，不作为页面层必须显式传入的业务参数。

8.2.4.2 需要评估并逐步收敛为更通用的 options/dictionary 入口，例如：

```text
GET /api/common/options?scope=profile&version={clientVersion}
GET /api/common/options?scope=account&version={clientVersion}
GET /api/common/options?scope=event&version={clientVersion}
```

`/api/profiles/options` 可以作为 profile scope 的当前实现或兼容别名；新模块不应继续新增各自分散的本地枚举文案表。

返回规则：

- 前端首次进入需要枚举选项的页面时，请求当前语言的 options；语言由 `http.ts` 统一注入。
- 请求附带本地缓存的 `version` 或 `updatedAt`。
- 如果前端版本与后端一致，后端返回“不需要更新”的轻量响应。
- 如果版本不一致，后端返回新的 options、版本号和更新时间。
- 每种语言独立缓存，语言切换后按对应语言重新校验版本。
- 版本号由后端维护一个整体 `profileOptionsVersion`，可以使用更新时间戳或内容 hash；8.2.4.1 不做每个 group 的独立版本。

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

- 新增 profile scope options 接口；当前实现路径为 `GET /api/profiles/options?version={version}`，语言后续统一由 `http.ts` 注入。
- 新增后端代码常量版 profile options，并返回整体 `version` 与 `unchanged`。
- `cm_profiles` 增加 `relationship_goal_code`、`residence_plan_code`、`preferred_education_code`、`family_life_code`、`exercise_code`。
- 新增 `cm_profile_option_extra_texts`，用于保存枚举 `other` 的当前语言补充说明。
- `cm_schema.sql` 已同步新列、新表和 localized fields 职责收窄，当前以全量重建脚本为准。
- Account profile owner detail 仅返回 `xxxCode`，不再返回旧 `xxx` 字段或 `xxxLabel`。
- Account profile 保存链路已改为保存 code 字段，`other` 补充说明写入专用表。
- C 端公开目录/detail 中已完成新增枚举化字段的展示整理：city、country、nationality、education、industry、relationshipGoal、residencePlan、preferredEducation、familyLife、exercise 可按后端 options 语义展示；编辑接口仍只返回 code。
- 目录 education 筛选与 facet 已从 `degree_level` 调整为 `education_code`。

已完成的 C 端部分：

- 新增持久化 Pinia options store：`src/stores/modules/profile-options.ts`。
- C 端调用 `/api/profiles/options` 并按 locale/version 缓存；8.2.4.2 需要移除业务 store 手动传 locale 的写法，改为复用 `http.ts` 的统一语言注入。
- Account Profile Detail 将 `city/country/nationality/education/industry/relationshipGoal/residencePlan/preferredEducation/familyLife/exercise` 改为枚举选择。
- Account Profile Detail 保存 payload 改为提交 `xxxCode`，并提交 `optionExtraTexts`。
- `other` 选项编辑态显示补充说明输入框，非编辑态显示具体补充说明而不是“其他”。
- Account Settings 的 `preferredCity` 改为复用城市 options 并保存 city code。
- C 端已通过 `npm.cmd run type-check`。

当前阻塞：

- 当前 server shell 未配置 `mvn` / `mvn.cmd`，后端 Maven 编译未能执行；已执行 `git diff --check`，未发现 whitespace 问题。

## 8.2.4.2 枚举文案来源统一到后端 options

### 范围

本步骤从 API 出发处理枚举文案来源。只处理“数据库与业务 API 已经使用稳定 code，但前端仍通过本地 i18n key、映射函数或硬编码 options 翻译”的字段。

本步骤不把编辑、筛选、提交链路的业务 API 大量改成 label 返回。业务 API 继续传递稳定 code，前端通过后端下发的 options/dictionary 做通用 `value -> label` 查表。

不处理：

- 日期格式化。
- 年龄计算。
- 身高单位。
- 空值展示。
- 数组显示样式。
- 页面静态文案。
- 编辑、筛选、提交 payload 的 code 结构。
- 状态机和权限分支判断使用的 code。

### 执行方法

每个分区都按同一流程：

1. 列出该分区 API 返回的稳定 code 字段。
2. 找到当前 C 端或 Admin 前端的映射函数、i18n key 或本地 options。
3. 确认该 code 字段已经存在于后端 options/dictionary 分组；缺失时先补 options 分组。
4. 前端删除对应本地枚举文案表，改为统一调用 options store 的 `optionLabel(group, value)` 或 `optionsFor(group)`。
5. 保留前端格式化逻辑，例如日期、年龄、身高、空值、数组拼接和页面静态文案。
6. 运行对应构建或类型检查。

如果某个接口本来就是纯展示接口，可以在后续分区中评估是否直接返回展示文本；但这不是 8.2.4.2 的默认策略。默认策略是“业务 API 保持 code，后端 options 作为唯一文案来源”。

### 分区顺序

1. Profile 目录与详情。
2. Account 中心、Account Profile Detail、Account Settings。
3. Event 目录、详情、报名与账号活动。
4. Membership、Introduction、Inbox、Relationship。
5. Admin Profile、资料审核、资料库、资料运营、照片审核、认证审核。

### 每个分区需要记录

- API endpoint。
- code 字段。
- options/dictionary 分组名。
- 前端删除或替换的映射文件、i18n key 或硬编码 options。
- 是否存在数据库字段迁移。
- 手工校验点。

### 验收标准

- 该分区不再通过前端本地枚举文案表翻译后端返回的稳定 code。
- 编辑、筛选、提交链路仍使用稳定 code。
- label 统一来自后端 options/dictionary。
- 前端仅保留格式化和页面展示逻辑。
- 构建或类型检查通过。

## 8.2.4.3 枚举值动态管理

本步骤必须等 `8.2.4.1` 和 `8.2.4.2` 稳定后再做。

需要评估：

- 复用 RuoYi `sys_dict` 还是新建 Cupid 专用字典表。
- 多语言 label 的存储方式。
- 排序、启用、停用、默认值。
- 审计日志。
- 缓存刷新。
- C 端和 Admin 的 options 拉取方式。

不应动态管理：

- 状态机 code。
- 权益消费 code。
- 会影响业务分支判断的硬规则 code。

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
