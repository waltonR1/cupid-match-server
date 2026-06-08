# Cupid Match Backend Implementation Plan

本文是 `cupid-match-server` 的实施与验收基线，供代码执行者按阶段开发，供 Codex 做独立校验。

数据库已执行：

- `sql/cm_schema.sql`
- `sql/cm_seed.sql`

RuoYi 原生系统表继续承载后台登录、角色、菜单、权限和系统日志；Cupid Match 前台业务只使用 `cm_` 表。

## 1. 权威来源

发生冲突时按以下优先级处理：

1. `doc/reference-from-app/final-api-contract.md`：接口路径、请求和响应 DTO。
2. `sql/cm_schema.sql`：实际表、字段、索引和约束。
3. `doc/reference-from-app/final-data-flow-contract.md`：跨表读写和业务流程。
4. `doc/cm-schema-structure-notes.md`：JSON、扁平字段和外接表的设计说明。
5. `sql/cm_seed.sql`：本地验收样例数据。
6. 本文：实施顺序、阶段边界和验收要求。

不要从 `mock-server` 推断最终接口；它只能辅助理解样例行为。契约与 mock 不一致时，以最终契约为准。

## 2. 固定架构边界

- `cm_*` 实体 ID 使用 UUID；业务逻辑通过 `tier`、`slug`、`type`、`code` 等业务键查找，不硬编码 UUID。
- 前台用户只进入 `cm_users`，不进入 RuoYi `sys_user`。
- 后台员工仍使用 `sys_user`，通过 `cm_staff_members.sys_user_id` 建立业务身份。
- Java 产品 API 统一返回 RuoYi `code + msg + data?`。
- controller 只做 HTTP 参数接收、认证主体获取和响应封装。
- framework 负责认证、JWT、Redis session、验证码以及与 Spring Security 的集成。
- system 负责 `cm_` 领域模型、mapper 和数据库事务。
- framework 不直接注入 mapper，必须通过 system service 访问数据库。
- mapper 接口与 mapper XML 必须一一对应，不保留未使用查询。
- DTO 不直接复用数据库 domain；新增业务阶段时在 `com.ruoyi.cupid.dto`、`query`、`support` 中按需创建。
- 写入多个表的业务操作必须由 service 事务包裹。
- 禁止为兼容旧 mock ID、旧接口或旧字段增加临时兼容分支。
- 禁止无需求修改 RuoYi 原生认证和后台模块。

推荐目录：

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
  app/
  admin/
```

## 3. 执行与校验协议

### 3.1 单次执行范围

每次只执行一个阶段，或该阶段中一个明确子任务。开始前必须：

1. 阅读本文当前阶段。
2. 阅读 `final-api-contract.md` 中对应接口章节。
3. 阅读 `final-data-flow-contract.md` 中对应流程。
4. 核对 `cm_schema.sql` 的相关表。
5. 检查现有代码，复用 RuoYi 和 Cupid 已有能力。

没有进入当前阶段的接口、后台页面、通用抽象和重构不要顺带实现。

### 3.2 执行者交付内容

每次交付必须说明：

- 实现了哪些接口或规则。
- 修改了哪些模块。
- 使用了哪些表。
- 执行了哪些构建或测试。
- 哪些验收项尚未覆盖。
- 是否修改数据库结构、种子或契约。

不得只报告“已完成”。

### 3.3 Codex 校验顺序

Codex 按以下顺序检查：

1. `git diff`：确认修改范围没有越过当前阶段。
2. 契约：路径、HTTP 方法、参数、DTO 和错误响应是否一致。
3. 分层：controller、framework、system、mapper 职责是否正确。
4. 数据：字段映射、事务、唯一约束、状态流转和权限过滤。
5. 安全：认证、对象归属、敏感字段、Redis session 和验证码。
6. 构建：执行完整 Maven 构建。
7. 冒烟：使用真实 MySQL、Redis 和 seed 数据调用接口。
8. 文档：只有事实或计划发生变化时才更新。

发现阻断问题时不提交；修复后从受影响的检查项重新验证。

### 3.4 通用完成定义

每个阶段必须同时满足：

- 接口与最终 API 契约一致。
- 未认证、无权限、资源不存在和业务冲突有明确响应。
- 列表接口的过滤、排序、分页行为稳定。
- 多语言读取有指定 locale 和回退策略。
- 不泄露联系方式、密码哈希、内部备注和后台字段。
- 多表写入具备事务性，失败不留下半成品。
- mapper 方法、XML statement 和 domain 字段完全对应。
- `mvn -pl ruoyi-admin -am -DskipTests package` 通过。
- 当前阶段的真实接口冒烟通过。
- 工作区只包含当前任务相关修改。

## 4. 当前状态

| 阶段 | 状态 | 说明 |
| --- | --- | --- |
| 阶段一：Legal / Auth / Account Me | 已完成并验收 | 2026-06-08 已通过构建和真实运行冒烟 |
| 阶段二：Profile 只读目录与详情 | 下一阶段 | 尚未开始 |
| 阶段三：Account Profile 管理与上传 | 未开始 | 依赖阶段二 DTO 聚合 |
| 阶段四：Account 设置与安全 | 未开始 | 复用阶段一认证能力 |
| 阶段五：Membership / Entitlement | 未开始 | Profile masking 可先只读取现有会员数据 |
| 阶段六：Events | 未开始 | 依赖会员判断 |
| 阶段七：Favorite / Private Introduction / Inbox / Dashboard | 未开始 | 依赖 Profile、Membership、Events |
| 阶段八：RuoYi 后台运营 | 未开始 | 前台核心链路稳定后执行 |
| 阶段九：支付、审计与生产化 | 未开始 | 最后执行 |

## 5. 阶段一：Legal / Auth / Account Me

### 状态

已实现并验收。后续阶段原则上不重构此链路，只允许修复明确缺陷或扩展已规划的账户安全能力。

### 已实现接口

- `GET /api/legal/documents/{type}`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `POST /api/auth/verification-code`
- `POST /api/auth/register`
- `POST /api/auth/password-reset-code`
- `POST /api/auth/password/reset`
- `GET /api/account/me`

### 已建立基线

- `CupidAuthService` 编排认证流程，通过 `ICupidUserService`、`ICupidLegalService` 访问数据库。
- `CupidTokenService` 创建和解析前台 JWT，并以 Redis session 控制有效性。
- Redis session 滑动续期与 RuoYi `TokenService` 的职责边界一致。
- logout 删除当前 session；密码重置通过 `deleteUserTokens(userId)` 删除该用户全部 session。
- `CupidVerificationCodeService` 使用 Redis 保存、过期和一次性消费验证码。
- 登录和注册接受当前生效 legal documents。
- framework 不直接调用 Cupid mapper。

### 回归验收

- `lin@example.com / password123` 登录返回 `code=200` 和 token。
- token 可访问 `GET /api/account/me`。
- logout 后同一 token 返回业务 `code=401`。
- terms/privacy 可按 `lang` 返回，找不到目标语言时按服务规则回退。
- 密码重置后旧密码和全部旧 token 失效。
- 注册验证码不可重复消费。

## 6. 阶段二：Profile 只读目录与详情

### 目标

完成首页精选、自助征婚和家庭征婚的只读浏览，为后续 owner 编辑复用同一套 DTO 聚合和权限遮罩能力。

### 接口

- `GET /api/profiles/featured`
- `GET /api/profiles/self`
- `GET /api/profiles/family`
- `GET /api/profiles/self/{id}`
- `GET /api/profiles/family/{id}`

### 主要表

- `cm_profiles`
- `cm_profile_languages`
- `cm_profile_relationship_values`
- `cm_profile_localized_fields`
- `cm_profile_localized_items`
- `cm_profile_photos`
- `cm_profile_verifications`
- `cm_profile_privacy_preferences`
- `cm_profile_internal_records`
- `cm_profile_internal_localized_fields`
- `cm_profile_ownerships`
- `cm_user_memberships`
- `cm_favorite_profiles`
- `cm_private_introduction_requests`

### 实施顺序

1. 定义目录 query、分页 DTO、facet DTO、card DTO 和 detail DTO。
2. 实现 profile 主表、语言、关系值和本地化字段的批量查询。
3. 实现单次聚合所需的 photo、verification、internal record 查询。
4. 建立 locale 回退工具，避免在 controller 或 mapper 中拼 DTO。
5. 建立 viewer context：guest、free、member、owner、staff。
6. 建立统一字段访问和 masking 规则。
7. 实现 self/family 目录，再实现 featured。
8. 复用聚合器实现 self/family detail。

### 强制规则

- 列表查询禁止逐条查询 localized、photo、favorite 等子表，避免 N+1。
- `displayName`、`avatarUrl`、`age` 等展示字段由服务聚合，不冗余写回数据库。
- profile 类型必须与入口匹配；不能通过 self 详情入口读取 family profile。
- guest/free/member 的字段访问严格按契约处理。
- owner 能读取自己管理的资料，但 owner 身份必须通过 `cm_profile_ownerships` 校验。
- `cm_profile_privacy_preferences` 只能进一步隐藏字段，不能放宽系统默认权限。
- phone、email、wechat 永远不进入公开 profile detail。
- 内部备注、审核内部字段和 staff 信息不得进入前台 DTO。

### 验收矩阵

- featured 只返回符合精选和可见状态的 self profiles。
- self/family 目录不会混入另一类型。
- locale 为 `zh`、`en`、`fr` 时均能返回；缺失翻译时回退稳定。
- 过滤、排序、分页和 facets 与契约字段一致。
- guest、free、member 查看同一详情时，限制字段结果符合权限差异。
- owner 查看自己管理的资料时得到 owner 视图。
- 不存在、已归档、不可见或类型不匹配的 profile 不被越权读取。
- SQL 日志或代码检查确认列表聚合不存在逐条子查询。

### 阶段完成后提交建议

将“DTO/查询基础”“目录”“详情与 masking”分开提交，避免一次提交覆盖整个阶段。

## 7. 阶段三：Account Profile 管理与上传

### 前置条件

阶段二的 detail DTO 聚合与 owner viewer context 已稳定。

### 接口

- `GET /api/account/profiles`
- `GET /api/account/profiles/{profileId}`
- `POST /api/account/profiles/save`
- `POST /api/account/profiles/{profileId}/archive`
- `POST /api/account/profiles/{profileId}/privacy-preferences`
- `POST /api/upload`

### 主要表

- `cm_profiles`
- `cm_profile_ownerships`
- `cm_profile_contacts`
- `cm_profile_photos`
- `cm_profile_verifications`
- `cm_profile_privacy_preferences`
- `cm_profile_languages`
- `cm_profile_relationship_values`
- `cm_profile_localized_fields`
- `cm_profile_localized_items`

### 实施顺序

1. 先实现 owner profile 列表和详情。
2. 定义 save payload，区分新建与更新。
3. 在单一事务中同步主表、ownership、contacts、verification 草稿、photos 和 localized 数据。
4. 实现 privacy preference upsert。
5. 实现 archive 业务前置检查。
6. 最后接入 upload；数据库只保存公开 asset URL 和必要元数据。

### 强制规则

- `/profiles/save` 是 owner 侧唯一资料写入口，不恢复旧 mock mutation API。
- 更新必须先校验当前用户是否拥有 owner/manager 权限。
- 客户端不得写审核结果、内部推荐状态、featured 或 staff 字段。
- contacts 只能通过 owner API 写入，不能出现在公共详情响应。
- photos payload 采用对账式更新时，必须防止删除或修改其他 profile 的照片。
- archive 前检查契约规定的未完成正式流程。
- 上传必须限制文件类型、大小和生成文件名；不得信任原始文件名作为存储路径。

### 验收矩阵

- 新建 self 和 family profile 均能生成正确 ownership。
- 保存失败时所有关联表回滚。
- 非 owner 无法读取、修改、归档或更新隐私设置。
- 修改 localized 数组后，旧值按约定删除或保留，不产生重复行。
- 照片新增、排序、替换和删除后返回 DTO 与数据库一致。
- archive 后公共目录不可见，owner 侧结果符合契约。
- 上传拒绝非法类型和超限文件。

## 8. 阶段四：Account 设置与安全

### 接口

- `POST /api/account/me`
- `GET /api/account/settings`
- `POST /api/account/settings/preferences`
- `GET /api/account/mfa/status`
- `POST /api/account/mfa/verification-code`
- `POST /api/account/mfa/enable`
- `POST /api/account/mfa/disable`
- `POST /api/account/security/challenge-code`
- `POST /api/account/security/challenge`
- `POST /api/account/password/change`
- `POST /api/account/export`
- `GET /api/account/export/download`
- `POST /api/account/deactivate`
- `POST /api/account/identities/verification-code`
- `POST /api/account/identities`
- `DELETE /api/account/identities/{id}`

### 主要表

- `cm_users`
- `cm_auth_identities`
- `cm_user_preferences`
- `cm_user_security_settings`
- `cm_user_security_challenges`
- 账户 dashboard 所需业务表

### 强制规则

- account me 更新不能修改身份标识、密码和账号状态。
- 至少保留一个可登录 identity；不得解绑最后一个身份。
- identity provider + identifier 必须保持全局唯一。
- MFA 只能绑定已验证 identity。
- challenge token 必须短期有效、限定 purpose，并且一次性消费。
- 修改密码、停用账户和高风险身份变更后清理该用户全部 session。
- 产品 API 不返回验证码。
- 导出结果只能包含当前用户有权获取的数据，不能包含密码哈希或内部审核信息。

### 验收矩阵

- preferences 更新后 settings 返回一致。
- identity 绑定、重复绑定、解绑最后身份分别得到正确结果。
- MFA 开启、关闭和错误/过期验证码路径完整。
- challenge token 不能跨 purpose 使用，也不能重复使用。
- 修改密码后全部旧 token 失效，新密码可登录。
- deactivated 用户全部 token 失效，再次登录时按既定策略恢复。
- A 用户无法下载 B 用户导出。

## 9. 阶段五：Membership / Entitlement

### 接口

- `GET /api/account/membership`
- `POST /api/account/membership/upgrade`

### 主要表

- `cm_membership_plans`
- `cm_membership_plan_localized_fields`
- `cm_user_memberships`
- `cm_user_entitlement_balances`
- `cm_orders`
- `cm_payments`

### 强制规则

- 套餐通过 `tier` 查询，禁止硬编码 free plan UUID。
- 当前会员由状态和有效期共同判定。
- entitlement 使用数据库余额和周期，不从 tier 名称临时推导。
- `upgrade` 初期只创建外部流程或订单入口；支付或 staff 确认前不得直接激活会员。
- 会员变更和 entitlement 初始化必须在同一事务中。

### 验收矩阵

- plan 按 locale 和 sort order 返回。
- `GET /api/account/membership` 同时返回当前会员、entitlement 和契约所需的可升级套餐数据，不另造 plans endpoint。
- free、active paid、expired 三类用户得到正确会员视图。
- 重复 upgrade 不产生冲突的活动订单。
- 未确认支付不会改变 membership。
- 已确认流程不会重复增加 entitlement。

## 10. 阶段六：Events

### 接口

- `GET /api/events`
- `GET /api/events/{id}`
- `POST /api/events/{id}/register`
- `POST /api/events/{id}/cancel`
- `GET /api/account/events`

### 主要表

- `cm_events`
- `cm_event_localized_fields`
- `cm_event_relationship_focuses`
- `cm_event_language_codes`
- `cm_event_agenda_items`
- `cm_event_agenda_item_localized_fields`
- `cm_event_registrations`
- `cm_user_memberships`

### 强制规则

- `registeredCount`、`waitlistCount` 从 registration 状态派生。
- 精确地址按 `address_visibility`、活动状态和当前用户报名状态返回。
- member-only event 必须由有效会员状态判断。
- 报名和取消使用唯一约束避免重复记录。
- 容量判断与写 registration 必须在事务中完成，并防止并发超卖。
- 活动过期状态优先由日期和正式状态规则判定，不由前端决定。

### 验收矩阵

- 目录过滤、分页、本地化和状态展示正确。
- guest、free、member 对 member-only event 的结果正确。
- 重复报名不会重复计数。
- 满员后按契约进入 waitlist 或拒绝。
- 取消后计数和用户 account events 同步。
- 未满足地址开放条件时不泄露精确地址。

## 11. 阶段七：Favorite / Private Introduction / Inbox / Dashboard

### 接口

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
- `POST /api/inbox/threads/{id}/messages`，只保留受控能力，当前 UI 不开放
- `GET /api/account/dashboard`

### 主要表

- `cm_favorite_profiles`
- `cm_private_introduction_requests`
- `cm_profile_contacts`
- `cm_user_entitlement_balances`
- `cm_inbox_threads`
- `cm_inbox_messages`
- `cm_inbox_reads`

### 强制规则

- 收藏使用唯一约束保证幂等。
- 私人介绍只能申请可见且类型与入口匹配的 profile。
- 创建申请与扣减 entitlement 必须原子执行。
- `expired` 由 `expires_at` 派生，不作为持久化 status。
- contact 只对该申请 requester 开放，且必须为 accepted。
- accepted 不自动创建聊天房间。
- inbox thread 和 message 必须校验当前 user_id。
- `before + limit` 分页排序稳定，不重复、不漏项。
- dashboard 只做已完成领域 service 的只读聚合，不反向创建一套 dashboard 专用数据模型。

### 验收矩阵

- 重复收藏和重复取消结果幂等。
- 无 entitlement、重复活动申请、不可见 profile 均被拒绝。
- 申请失败不扣 entitlement。
- 非 requester 或未 accepted 时无法读取 contact。
- 用户不能读取或标记他人的 thread。
- unread count、read 状态和消息分页一致。
- dashboard 中 profiles、membership、entitlements、events、introductions 和 favoriteCount 与各独立接口结果一致。

## 12. 阶段八：RuoYi 后台运营

### 目标

将必要 debug 能力转成受权限和审计约束的正式后台能力。

优先模块：

- Profile、Photo、Verification 审核
- Private Introduction 处理
- Event 管理与报名审核
- Inbox 通知工具
- User 状态管理
- Staff tasks

### 强制规则

- 后台接口放入 `controller/cupid/admin`。
- 使用 RuoYi 登录态、角色、菜单和权限注解。
- 通过 `cm_staff_members` 获取业务 staff 身份。
- 重要状态修改写 `cm_audit_logs` 或明确复用 RuoYi 操作日志。
- 不开放 `/api/debug/*`。
- 不先生成所有表的通用 CRUD。

### Debug 映射

- verification code 查看：仅本地开发工具，不进入生产。
- profile/photo verification：后台审核。
- private introduction accept/decline：后台处理。
- event registration review：后台审核。
- event status：后台活动管理。
- inbox notify：后台通知工具。

## 13. 阶段九：支付、审计与生产化

内容：

- `cm_audit_logs` 完整写入策略。
- Email/SMS 验证码真实通道。
- 本地上传迁移至对象存储。
- Stripe 或人工确认支付流程。
- 数据库迁移工具和版本管理。
- 数据备份、恢复演练和敏感配置管理。
- 性能索引、慢查询和批量查询复核。
- HTTPS、CORS、限流、验证码频率和登录防爆破。
- 自动化集成测试与部署健康检查。

生产化完成前，不把测试验证码、人工支付捷径或本地文件路径暴露给生产前端。

## 14. 当前禁止事项

- 不全量生成所有 `cm_` 表 CRUD。
- 不复刻 mock-server debug routes。
- 不合并前台用户和 RuoYi 后台用户。
- 不重写 RuoYi 原生用户、角色和菜单体系。
- 不为 seed UUID 或旧 `u-001` ID 增加兼容代码。
- 不在 controller 中写 SQL 聚合、权限规则或事务流程。
- 不在业务代码中硬编码 `plan-free` UUID 等数据库主键。
- 不在未进入支付阶段时伪造正式支付成功。

## 15. 下一执行入口

下一任务是阶段二的第一个子任务：

1. 对照 `final-api-contract.md` 的 Profile Directory 与 Profile Detail 章节定义 DTO 和 query。
2. 设计目录所需的批量 mapper 查询，先证明不存在 N+1。
3. 暂不实现 controller、masking 或详情聚合。
4. 交付 DTO、query、mapper 设计和对应构建结果，由 Codex 校验后再继续目录 service。

该拆分用于先固定传输结构和数据读取边界，避免实现过程中反复改 mapper 与 DTO。
