# Cupid Match Schema Structure Notes

本文记录 `sql/cm_schema.sql` 的结构设计取舍，尤其是从“较多 JSON 字段”调整为“关系型多表 + 少量 JSON”的规则。

完整数据库初始化、RuoYi 原始 SQL、Quartz、Cupid seed 和后台菜单脚本的执行顺序见 `doc/cm-database-initialization.md`。

## 总体原则

- RuoYi 原生 `sys_*`、Quartz 表保持不变。
- Cupid Match 业务表统一使用 `cm_` 前缀。
- `cm_*` 表不单独声明字符集或排序规则，统一继承目标数据库的默认 character set 与 collation。
- `cm_*` 实体表的代理主键及其引用统一使用 36 字符 UUID；Java 运行时使用 `IdUtils.fastUUID()`。
- seed 生成器把 mock 的可读 ID 确定性映射为 UUIDv5，同一份源数据重复生成时 ID 保持稳定。
- ID 只表达身份，不承载实体类型或业务含义；禁止根据 `u-`、`p-` 等前缀编写判断。
- `tier`、`type`、`entitlement_code` 等稳定业务含义保留在独立字段。
- 前台产品用户使用 `cm_users`，不复用 RuoYi `sys_user`。
- 后台员工直接使用 RuoYi `sys_user`、`sys_role`、`sys_user_role` 和 `sys_menu` 表达账号、角色与权限，不另建业务 staff 映射。
- 不建立 `cm_staff_members`；后台员工直接复用 RuoYi 原生账号和授权体系。
- 可查询、筛选、排序、约束、关联的数据使用普通列或关系表。
- 多语言展示文案使用领域本地化表。
- JSON 只保留给结构复杂且不用于高频查询的数据。

## JSON 保留范围

当前只保留以下 JSON 字段：

- `cm_legal_document_contents.sections`：法律正文结构。
- `cm_inbox_messages.action_payload`：消息动作参数。
- `cm_audit_logs.before_data` / `cm_audit_logs.after_data`：审计快照。

这些数据不参与常规筛选、排序或唯一约束，使用 JSON 可以降低表结构复杂度。

Inbox 通知模板使用 `cm_inbox_templates` 保存稳定 code 和行为字段，使用
`cm_inbox_template_localized_fields` 保存三语名称与正文。消息仅保存发送时渲染后的正文，
并通过 `cm_inbox_messages.dedupe_key` 防止自动通知和同一群发任务重复写入。

## 扁平化主表字段

主表只保存稳定事实和高频查询字段。

`cm_profiles` 中保留：

- 身份和生命周期：`profile_type`、`profile_status`、`archived_at`
- 基础筛选：`gender`、`birth_year`、`height`
- 地理与筛选 code：`city_code`、`country_code`、`nationality_code`
- 学历与行业筛选：`degree_level`、`education_code`、`industry_code`
- 关系偏好 code：`dating_intention_code`、`relocation`、`preferred_location`
- 生活习惯 code：`smoking`、`drinking`、`activity_level`、`weekend_style`、`pets`、`communication_style`
- 时间：`last_active_at`、`created_at`、`updated_at`

`cm_events` 中保留：

- `status`
- `visibility`
- `consumes_membership_quota`
- `city_code`
- `address_visibility`
- `event_date`
- `start_time`
- `end_time`
- `capacity`
- `cover_image_url`

这些字段方便目录筛选、排序、索引和后台运营查询。

`cm_membership_plans` 中价格与权益使用普通列：

- `price_cents` + `currency`：欧元确定价格
- `cny_price_cents`：人民币确定价格，不按运行时汇率换算
- `billing_type`、`billing_period`、`validity_months`：区分免费、一次性购买、周期扣费和实际有效期
- `private_introduction_quota`、`private_introduction_period`
- `event_quota`：一次会员有效期内包含的受控活动次数

活动实际余额不直接从报名数量推导，保存在 `cm_user_entitlement_balances`，权益码为 `event_registration`。`cm_event_registrations.event_quota_consumed_at` 和 `event_quota_released_at` 记录单次报名是否已经扣减或返还，用于保证确认与取消幂等。

## 多值字段关系表

多值筛选字段不再放 JSON，改用关系表。

- `cm_profile_languages`
- `cm_profile_relationship_values`
- `cm_event_language_codes`

这些表支持按语言、关系价值、活动语言做筛选、统计和推荐。

## 索引与约束策略

`cm_schema.sql` 当前以主键、业务唯一键和必要查询索引为主，不在重构早期补全所有真实外键。

- 主键和业务唯一键必须随表结构同步维护，避免重复账户身份、重复收藏、重复报名和重复本地化字段。
- 高频查询索引按已经落地的 mapper 和真实慢查询补充，不提前为尚未实现的接口批量创建索引。
- 外键约束暂缓统一评估；重构期优先通过 service 事务、权限校验和业务写入规则保证逻辑外键一致。
- 后端核心接口完成后，需要基于最终 mapper 做一次索引与约束审计，再决定是否加入真实外键或只保留逻辑外键说明。

## 多语言字段表

多语言展示内容不放在主表，也不放 JSON，而是拆到领域本地化表。

Profile 相关：

- `cm_profile_localized_fields`
- `cm_profile_localized_items`
- `cm_profile_internal_localized_fields`

Membership 相关：

- `cm_membership_plan_localized_fields`

Event 相关：

- `cm_event_localized_fields`
- `cm_event_relationship_focuses`
- `cm_event_agenda_item_localized_fields`

Staff task 相关：

- `cm_staff_task_localized_fields`

这些表统一包含：

- `field_name`
- `locale`
- `value`
- `source`
- `provider`
- `status`
- `created_at`
- `updated_at`

这样既能保留 `LocalizedText` 的状态模型，又不会让主表变成大 JSON 文档。

## Profile 字段映射

原文档中的 `LocalizedText` 字段拆分如下：

- 单值文案进入 `cm_profile_localized_fields`
- 列表文案进入 `cm_profile_localized_items`
- 可筛选的地理/行业/学历字段在 `cm_profiles` 中保留 code 列

示例：

- `city` -> `cm_profiles.city_code` + `cm_profile_localized_fields(field_name = 'city')`
- `country` -> `cm_profiles.country_code` + `cm_profile_localized_fields(field_name = 'country')`
- `industry` -> `cm_profiles.industry_code` + `cm_profile_localized_fields(field_name = 'industry')`
- `summary` -> `cm_profile_localized_fields(field_name = 'summary')`
- `tags` -> `cm_profile_localized_items(field_name = 'tags')`
- `interests` -> `cm_profile_localized_items(field_name = 'interests')`
- `dealBreakers` -> `cm_profile_localized_items(field_name = 'deal_breakers')`

## Event 字段映射

Event 主表保留可查询字段，本地化文案拆表。

示例：

- `title` -> `cm_event_localized_fields(field_name = 'title')`
- `summary` -> `cm_event_localized_fields(field_name = 'summary')`
- `city` -> `cm_events.city_code` + `cm_event_localized_fields(field_name = 'city')`
- `venue` -> `cm_event_localized_fields(field_name = 'venue')`
- `address` -> `cm_event_localized_fields(field_name = 'address')`
- `relationshipFocus` -> `cm_event_relationship_focuses`
- `languageCodes` -> `cm_event_language_codes`
- agenda `title` / `description` -> `cm_event_agenda_item_localized_fields`

## Staff 与 RuoYi 的边界

后台员工不进入 `cm_users`。

- `sys_user`：RuoYi 后台账号、登录状态和启停状态。
- `sys_role`、`sys_user_role`：Cupid 后台岗位角色与用户授权。
- `sys_menu`、`sys_role_menu`：Cupid 菜单、按钮和接口权限。
- `cm_staff_tasks.assignee_sys_user_id`：任务分配给 RuoYi 后台用户。

Cupid 后台可建立 `cupid_admin`、`cupid_operator`、`cupid_reviewer`、`cupid_event_manager`、`cupid_support` 等专用角色。不得另建 staff 角色或启停状态表，避免出现两套互相冲突的权威来源。

现有 `cm_*` 表中用于记录 staff actor 的 `varchar(36)` 字段，统一保存 `sys_user.user_id` 的字符串形式；`cm_staff_tasks.assignee_sys_user_id` 已使用 `bigint`，直接保存原始 `sys_user.user_id`。

前台用户不进入 RuoYi `sys_user`。

- `cm_users`：前台账户主体。
- `cm_auth_identities`：email / phone / wechat / google 登录身份。
- `cm_user_security_settings`：MFA 设置。
- `cm_user_security_challenges`：敏感操作挑战。

## 后续实现注意点

- 新增实体必须生成 UUID，不再创建 `u-002`、`p-003`、`plan-free` 形式的主键。
- 会员套餐通过唯一 `tier` 查找。业务代码不得依赖具体套餐 UUID。
- 公共套餐目录和账户可升级套餐必须复用同一套餐查询与本地化组装逻辑。
- 只有 `cm_events.consumes_membership_quota = 1` 的活动才校验 `event_registration` 余额。
- `sys_user.user_id` 继续遵守 RuoYi 规则；`cm_staff_tasks.assignee_sys_user_id` 和审计 actor 引用该 ID 时不要求改造 RuoYi 主键。
- Java entity 可以先按主表和关系表生成，localized 表单独建 service/helper 聚合 DTO。
- Profile / Event 的列表查询应先查主表和关系表，再按 locale 批量加载 localized 字段。
- DTO 不应直接暴露 localized 表结构；service/mapper 应组装为 contract 中定义的扁平字段。
- 写入 profile 或 event 时，需要在同一业务事务中同步主表、关系表和 localized 表。
- 审计日志可以记录业务变更前后的 DTO 或聚合快照到 JSON 字段。

## 数据库重建顺序

当样例数据或 ID 映射规则变化时，直接维护 `sql/cm_seed.sql`，然后在目标数据库依次完整执行：

```text
sql/cm_schema.sql
sql/cm_seed.sql
```

`cm_schema.sql` 会删除并重建全部 `cm_*` 表，因此只适用于当前重构期或明确允许重建的环境。不要在已有正式业务数据的环境直接执行。

该流程只重建 Cupid 业务表和样例数据，不修改 RuoYi、Quartz 或 Cupid 后台菜单。完整开发数据库重建顺序为：

```text
sql/ry_20260417.sql
sql/quartz.sql
sql/cm_schema.sql
sql/cm_seed.sql
```

具体环境限制统一以 `doc/cm-database-initialization.md` 为准。
