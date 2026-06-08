# Cupid Match Backend Implementation Plan

本文记录 `cupid-match-server` 的后端重构实施计划。当前数据库已经执行：

- `sql/cm_schema.sql`
- `sql/cm_seed.sql`

RuoYi 原生系统表继续作为后台管理、权限、菜单、登录日志和操作日志底座；Cupid Match 业务使用 `cm_` 表。

## 目标边界

- 前台产品 API 复刻 `doc/reference-from-app/final-api-contract.md`。
- 领域数据结构以 `sql/cm_schema.sql` 为准。
- 样例数据以 `sql/cm_seed.sql` 为准。
- 多语言、筛选字段和 JSON 取舍以 `doc/cm-schema-structure-notes.md` 为准。
- `cm_*` 实体 ID 统一使用 UUID，seed 通过 `scripts/generate-cm-seed.js` 生成稳定 UUIDv5。
- 业务代码通过 `tier`、`slug`、`type` 等字段查询业务对象，不依赖具体 UUID。
- 不把前台用户塞进 RuoYi `sys_user`。
- 不把 RuoYi 后台员工塞进 `cm_users`。
- 后台员工通过 `cm_staff_members.sys_user_id` 桥接到 RuoYi `sys_user.user_id`。

## Debug 策略

当前 app 侧 mock-server 的 debug API 只用于本地验证，不直接作为正式后端产品接口。

处理策略：

- 第一阶段不实现 `/api/debug/*`。
- 需要保留的 debug 能力，应改造成 RuoYi 后台运营能力。
- 对用户可见的状态变更，优先通过正式业务 API、staff 后台操作和 inbox 消息表达。
- 调试验证码查看、强制审核、强制活动状态切换这类能力，只允许后台登录用户使用。
- Debug 能力不能绕过业务审计；重要操作要写 `cm_audit_logs` 或 RuoYi 操作日志。

后续映射方向：

- `/api/debug/verification-codes` -> 本地开发工具或后台受限页面，不进入生产。
- `/api/debug/profile-photos/*/review/*` -> 后台照片审核。
- `/api/debug/profile-verifications/*` -> 后台资料认证审核。
- `/api/debug/private-introductions/*/accept|decline` -> 后台私人介绍处理。
- `/api/debug/event-registrations/*/review/*` -> 后台活动报名审核。
- `/api/debug/events/:id/status` -> 后台活动管理。
- `/api/debug/inbox/notify` -> 后台消息通知工具。

结论：现在先记录策略，不先写 debug API。

## RuoYi 后台策略

不要一开始重写完整后台。

阶段策略：

1. 先实现前台 API 的 Java 后端闭环。
2. 后台只保留 RuoYi 原生登录、角色、菜单、权限。
3. 当前需要 staff 介入的业务，先通过 service 方法和最小后台接口支撑。
4. 等前台核心链路稳定后，再逐步建设 RuoYi 后台菜单和页面。

优先后台模块：

- 资料审核：profile verification / review status。
- 照片审核：profile photos。
- 私人介绍处理：private introduction requests。
- 活动报名审核：event registrations。
- 活动管理：events。
- 用户风控：user suspended / deactivated。
- 消息通知：inbox thread/message。

不要先做：

- 全量 CRUD 后台。
- 复杂 dashboard。
- 支付后台。
- 完整 CRM 工作流。

## 包结构

建议新增业务包，不混入 RuoYi `system` 业务语义。

```text
ruoyi-system/src/main/java/com/ruoyi/cupid/
  domain/
  mapper/
  service/
  service/impl/
  dto/
  query/
  support/

ruoyi-admin/src/main/java/com/ruoyi/web/controller/cupid/
  api/
  admin/
```

说明：

- `api/` 放前台产品 API。
- `admin/` 放后续 RuoYi 后台运营接口。
- `support/` 放 localized field 聚合、viewer context、access masking、code label resolver 等通用领域帮助类。

## 阶段一：Legal / Auth / Account 最小闭环

目标：证明 Java 后端能读取 `cm_` 表并返回前台需要的 DTO。

接口：

- `GET /api/legal/documents/{type}`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `POST /api/auth/verification-code`
- `POST /api/auth/register`
- `POST /api/auth/password-reset-code`
- `POST /api/auth/password/reset`
- `GET /api/account/me`

涉及表：

- `cm_users`
- `cm_auth_identities`
- `cm_user_preferences`
- `cm_user_security_settings`
- `cm_legal_documents`
- `cm_legal_document_contents`
- `cm_user_agreement_acceptances`

产出：

- domain/entity
- mapper xml
- service
- controller
- token / user context 初版
- Redis session 与一次性验证码
- localized legal document mapper

验收：

- 能用 `lin@example.com / password123` 或 seed 中的账户登录。
- 登录后能返回 account me。
- logout 后当前 JWT 立即失效。
- 注册验证码可创建、过期并一次性消费，注册后默认账户数据完整。
- 密码重置后旧密码失效，且该用户全部旧 JWT 立即失效。
- legal terms/privacy 能按 locale 返回。

## 阶段二：Profile 目录和详情

目标：打通前台资料浏览。

接口：

- `GET /api/profiles/featured`
- `GET /api/profiles/self`
- `GET /api/profiles/family`
- `GET /api/profiles/self/{id}`
- `GET /api/profiles/family/{id}`

涉及表：

- `cm_profiles`
- `cm_profile_languages`
- `cm_profile_relationship_values`
- `cm_profile_localized_fields`
- `cm_profile_localized_items`
- `cm_profile_photos`
- `cm_profile_verifications`
- `cm_profile_privacy_preferences`
- `cm_profile_internal_records`
- `cm_user_memberships`
- `cm_user_entitlement_balances`
- `cm_favorite_profiles`
- `cm_private_introduction_requests`

重点：

- localized 字段批量加载。
- displayName / avatarUrl / age 派生。
- viewer role 和 access masking。
- guest / free / member / owner / staff 权限差异。
- facets 由 code 字段和关系表派生。

验收：

- self/family 列表有数据。
- 详情页能按 viewer 返回锁定字段。
- 不从 profile detail 泄露 phone/email/wechat。

## 阶段三：Account Profile 管理

目标：打通资料创建、编辑、归档、隐私设置。

接口：

- `GET /api/account/profiles`
- `GET /api/account/profiles/{profileId}`
- `POST /api/account/profiles/save`
- `POST /api/account/profiles/{profileId}/archive`
- `POST /api/account/profiles/{profileId}/privacy-preferences`

涉及表：

- `cm_profiles`
- `cm_profile_ownerships`
- `cm_profile_contacts`
- `cm_profile_photos`
- `cm_profile_verifications`
- `cm_profile_privacy_preferences`
- `cm_profile_localized_fields`
- `cm_profile_localized_items`

重点：

- 一个 save API 同步主表、关系表、多语言表、联系方式、照片草稿。
- 写操作使用事务。
- owner/manager 权限检查。
- archive 前检查是否有未完成正式流程。

## 阶段四：Membership / Entitlement

目标：打通会员和权益。

接口：

- `GET /api/account/membership`
- `GET /api/membership/plans`
- `POST /api/account/membership/upgrade`

涉及表：

- `cm_membership_plans`
- `cm_membership_plan_localized_fields`
- `cm_user_memberships`
- `cm_user_entitlement_balances`
- `cm_orders`
- `cm_payments`

说明：

- `upgrade` 初期可以保持外部流程入口。
- 支付正式接入前，会员变更应由后台或测试工具确认。
- 最终支付成功后再写 membership / entitlement。

## 阶段五：Events

目标：打通活动浏览、报名、取消。

接口：

- `GET /api/events`
- `GET /api/events/{id}`
- `POST /api/events/{id}/register`
- `POST /api/events/{id}/cancel`
- `GET /api/account/events`

涉及表：

- `cm_events`
- `cm_event_localized_fields`
- `cm_event_relationship_focuses`
- `cm_event_language_codes`
- `cm_event_agenda_items`
- `cm_event_agenda_item_localized_fields`
- `cm_event_registrations`
- `cm_user_memberships`

重点：

- registeredCount / waitlistCount 从 registrations 派生。
- 精确地址按 `address_visibility` 和报名状态返回。
- member-only event 需要会员判断。

## 阶段六：Favorite / Private Introduction / Inbox

目标：打通关系动作和通知。

接口：

- `POST /api/favorites/{profileId}`
- `DELETE /api/favorites/{profileId}`
- `GET /api/account/favorites`
- `POST /api/profiles/self/{id}/private-introduction`
- `POST /api/profiles/family/{id}/private-introduction`
- `GET /api/account/private-introductions`
- `GET /api/account/private-introductions/{requestId}/contact`
- `GET /api/inbox/threads`
- `GET /api/inbox/threads/{id}/messages`
- `POST /api/inbox/threads/{id}/read`

涉及表：

- `cm_favorite_profiles`
- `cm_private_introduction_requests`
- `cm_profile_contacts`
- `cm_user_entitlement_balances`
- `cm_inbox_threads`
- `cm_inbox_messages`
- `cm_inbox_reads`

重点：

- 私人介绍申请消耗权益。
- accepted 后才允许 contact reveal。
- 用户可见提醒进入 inbox。
- `expired` 不持久化为 private introduction status，由 `expires_at` 派生。

## 阶段七：RuoYi 后台运营

目标：把必要 debug 能力转成正式后台能力。

后台模块建议：

- Profile 审核
- Photo 审核
- Verification 审核
- Private Introduction 处理
- Event 管理
- Event Registration 审核
- Inbox 通知工具
- User 状态管理
- Staff tasks

涉及：

- RuoYi `sys_menu`
- RuoYi `sys_role`
- RuoYi 权限注解
- `cm_staff_members`
- `cm_staff_tasks`
- `cm_audit_logs`

要求：

- 后台操作必须校验 RuoYi 登录态和权限。
- 重要操作写审计。
- 不开放 `/api/debug/*` 给生产前端。

## 阶段八：审计、支付和生产化

目标：补齐生产能力。

内容：

- `cm_audit_logs` 写入策略。
- 真实密码哈希策略确认。
- JWT / token 刷新策略。
- 验证码通道：email / SMS。
- 上传存储：本地到对象存储。
- 支付接入：Stripe 或 manual confirmation。
- 数据备份和迁移脚本管理。
- 性能索引复核。

## 当前不做

- 不全量生成 42 张表的 CRUD。
- 不直接复刻 mock-server debug routes。
- 不重写 RuoYi 原有用户/角色/菜单系统。
- 不先做完整后台 UI。
- 不把前台用户和后台员工合并到一张用户表。

## 推荐下一步

从阶段一开始：

1. 创建 `com.ruoyi.cupid` 业务包结构。
2. 先实现 Legal document 查询。
3. 再实现 Auth login。
4. 再实现 Account me。
5. 完成后用 seed 数据做接口验证。
