# Cupid Match Backend Implementation Plan

本文是 `cupid-match-server` 的实施与验收基线，供代码执行者按阶段开发，供 Codex 做独立校验。

数据库已执行：

- `sql/cm_schema.sql`
- `sql/cm_seed.sql`

RuoYi 原生系统表继续承载后台登录、角色、菜单、权限和系统日志；Cupid Match 前台业务只使用 `cm_` 表。

## 1. 权威来源

发生冲突时按以下优先级处理：

1. `doc/reference-from-app/final-api-contract.md`：接口路径、请求参数和响应结构。
2. `sql/cm_schema.sql`：实际表、字段、索引和约束。
3. `doc/reference-from-app/final-data-flow-contract.md`：跨表读写和业务流程。
4. `doc/cm-schema-structure-notes.md`：JSON、扁平字段和外接表的设计说明。
5. `sql/cm_seed.sql`：本地验收样例数据。
6. 本文：实施顺序、阶段边界和验收要求。

不要从 `mock-server` 推断最终接口；它只能辅助理解样例行为。契约与 mock 不一致时，以最终契约为准。

## 2. 固定架构边界

- `cm_*` 实体 ID 使用 UUID；业务逻辑通过 `tier`、`slug`、`type`、`code` 等业务键查找，不硬编码 UUID。
- 前台用户只进入 `cm_users`，不进入 RuoYi `sys_user`。
- 后台员工直接使用 RuoYi `sys_user`、角色、菜单和权限体系；不再通过 `cm_staff_members` 建立第二套业务身份。
- Java 产品 API 统一返回 RuoYi `code + msg + data?`。
- controller 只做 HTTP 参数接收、认证主体获取和响应封装。
- framework 负责认证、JWT、Redis session、验证码以及与 Spring Security 的集成。
- system 负责 `cm_` 领域模型、mapper 和数据库事务。
- framework 不直接注入 mapper，必须通过 system service 访问数据库。
- mapper 接口与 mapper XML 必须一一对应，不保留未使用查询。
- Cupid 业务沿用当前 RuoYi 的 `controller -> service -> mapper -> domain` 结构，不另建一套独立领域架构。
- `final-api-contract.md` 中的 TypeScript DTO 用于约束 JSON 响应形状，不代表 Java 必须为每个 interface 创建同名 DTO 类。
- 查询条件优先放在对应 domain 的非表查询字段、适用时使用 `BaseEntity.params`，或直接作为 mapper 方法参数；默认不创建 `query` 包。
- mapper 默认返回 domain 或少量与表结构紧密相关的关联 domain，不为每条 SQL 创建 projection/row 类。
- service 负责批量查询、跨表聚合、多语言回退、权限判断、字段遮罩和最终响应结构组装。
- 产品响应默认由 service 使用 `Map<String, Object>` 和集合显式挑选字段，不直接把含数据库或内部字段的 domain 整体序列化给前端。
- 只有响应结构稳定、类型复杂且会被多个 service/controller 复用时，才增加少量 VO/DTO。
- 不允许机械复制 `final-api-contract.md` 中的每一个 TypeScript interface，也不允许创建只有空继承关系的 DTO。
- 通用帮助方法先作为对应 service 的私有方法；确认被多个 service 重复使用后，才提取公共组件，不预建 `support` 层。
- 不以文件行数作为单独拆分依据。后续阶段新增功能前，先检查已有 service、mapper 和私有方法能否直接复用；只有新需求形成第二个真实调用点、明显重复或现有职责已无法清晰承载时，才随该需求做最小范围提取。
- 不单独安排预防性“大拆分”。提取后的类或方法必须服务当前实际调用方，并保持原有 controller、service、mapper 分层和接口行为不变。
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

ruoyi-admin/src/main/java/com/ruoyi/web/controller/cupid/
  app/
  admin/
```

只有出现经过验证的实际需求时，才允许在上述结构之外增加目录。新增目录前必须说明现有 RuoYi 分层为什么无法清晰承载该职责，并由校验者确认。

以上架构约束适用于阶段二至阶段九，不是 Profile 阶段的临时规则。

## 3. 执行与校验协议

### 3.1 单次执行范围

每次只执行一个阶段，或该阶段中一个明确子任务。开始前必须：

1. 阅读本文当前阶段。
2. 阅读 `final-api-contract.md` 中对应接口章节。
3. 阅读 `final-data-flow-contract.md` 中对应流程。
4. 检查已有 domain、mapper、service 及私有聚合方法，记录本任务可以直接复用的实现；只有确认复用会造成重复或职责混乱时，才进行必要提取。
5. 核对 `cm_schema.sql` 的相关表。
6. 检查现有代码，复用 RuoYi 和 Cupid 已有能力。

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
2. 契约：路径、HTTP 方法、参数、JSON 响应结构和错误响应是否一致。
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
- 没有无必要的 DTO、query、projection、support 或空接口抽象。
- service 承担业务聚合，controller 和 mapper 中没有混入响应拼装或权限流程。
- `mvn -pl ruoyi-admin -am -DskipTests package` 通过。
- 当前阶段的真实接口冒烟通过。
- 工作区只包含当前任务相关修改。

## 4. 当前状态

| 阶段 | 状态 | 说明 |
| --- | --- | --- |
| 阶段一：Legal / Auth / Account Me | 已完成并验收 | 2026-06-08 已通过构建和真实运行冒烟 |
| 阶段二：Profile 只读目录与详情 | 已完成并验收 | 2026-06-09 已通过构建与真实接口冒烟 |
| 阶段三：Account Profile 管理与上传 | 已完成并验收 | 2026-06-10 已通过构建；owner 读写、上传、隐私、归档和异步翻译链路已接入 |
| 阶段四：Account 设置与安全 | 已完成并验收 | 2026-06-11 已通过构建；settings、preferences、身份绑定/解绑、MFA、安全挑战、密码修改、导出和停用链路已接入 |
| 阶段五：Membership / Entitlement | 已完成并验收 | 2026-06-11 已通过完整构建和真实接口冒烟；套餐、会员、当前周期权益、升级占位及 Profile 权限已验证 |
| 阶段六：Events | 已完成并验收 | 2026-06-12 已通过完整构建和真实接口冒烟；目录、详情、报名、取消、地址权限、额度返还和账户活动聚合已验证 |
| 阶段七：Favorite / Private Introduction / Inbox / Dashboard | 已完成并验收 | 2026-06-12 已通过完整构建和真实接口冒烟；收藏幂等、介绍状态、联系方式、Inbox 分页/已读/权限和 Dashboard 聚合已验证 |
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

完成首页精选、自助征婚和家庭征婚的只读浏览，为后续 owner 编辑复用同一套 service 聚合与权限遮罩能力。

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

1. 按 `cm_profiles` 建立 `CupidProfile` domain，在其中保留必要的非表查询字段和关联结果字段。
2. 为语言、关系值、本地化字段、照片、认证、隐私设置和内部记录建立必要的关联 domain；不建立 SQL projection 体系。
3. 在 `CupidProfileMapper` 中实现主表分页和子表批量查询，mapper 参数使用 domain 或明确的普通参数。
4. 创建 `ICupidProfileService` 与 `CupidProfileServiceImpl`，先完成 self/family 目录的 service 聚合。
5. 在 service 中处理筛选值规范化、分页、facet、多语言回退、展示字段派生和响应结构。
6. 完成 featured 查询，复用目录已有 mapper 和 service 私有聚合方法。
7. 在 service 中建立 guest、free、member、owner、staff 判断和字段 masking。
8. 复用已有 domain、mapper 和 service 方法完成 self/family detail。
9. 最后增加 app controller，只负责参数传递、当前用户获取和 `AjaxResult` 包装。

### 强制规则

- 列表查询禁止逐条查询 localized、photo、favorite 等子表，避免 N+1。
- `displayName`、`avatarUrl`、`age` 等展示字段由服务聚合，不冗余写回数据库。
- TypeScript 的 directory item、facets、detail、access 等 interface 不要求逐一生成 Java 类。
- 目录和详情最终 JSON 可以由 service 使用有序 `Map` 和集合组装，但字段名、可选字段和嵌套结构必须严格符合契约。
- 如果实际代码证明一个响应模型会被多处稳定复用，可增加一个明确用途的 VO/DTO；不得一次性预生成整个 Profile DTO 家族。
- query string 的枚举和区间值必须按契约解析，例如 `under25`、`25to29`、`yes/no`，不能自行改成另一种格式。
- mapper 的批量关联结果必须保留 `profile_id`，确保 service 能按 profile 分组。
- profile 类型必须与入口匹配；不能通过 self 详情入口读取 family profile。
- guest/free/member 的字段访问严格按契约处理。
- owner 能读取自己管理的资料，但 owner 身份必须通过 `cm_profile_ownerships` 校验。
- `cm_profile_privacy_preferences` 只能进一步隐藏字段，不能放宽系统默认权限。
- phone、email、wechat 永远不进入公开 profile detail。
- 内部备注、审核内部字段和 staff 信息不得进入前台响应。

### 验收矩阵

- featured 返回业务可见的 self profiles，按最近活跃时间排序并受 `pageSize` 限制。
- self/family 目录不会混入另一类型。
- locale 为 `zh`、`en`、`fr` 时均能返回；缺失翻译时回退稳定。
- 过滤、排序、分页和 facets 与契约字段一致。
- guest、free、member 查看同一详情时，限制字段结果符合权限差异。
- owner 查看自己管理的资料时得到 owner 视图。
- 不存在、已归档、不可见或类型不匹配的 profile 不被越权读取。
- SQL 日志或代码检查确认列表聚合不存在逐条子查询。

### 阶段完成后提交建议

将“domain 与 mapper”“目录 service 与 controller”“详情与 masking”分开提交，避免一次提交覆盖整个阶段。

## 7. 阶段三：Account Profile 管理与上传

### 前置条件

阶段二的 profile 聚合方法与 owner viewer context 已稳定。

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
2. controller 接收契约规定的 save payload；只在 Map 已明显影响校验和复用时增加一个保存参数对象。
3. 在单一事务中同步主表、ownership、contacts、verification 草稿、photos 和 localized 数据。
4. 实现 privacy preference upsert。
5. 实现 archive 业务前置检查。
6. 最后接入 upload；数据库只保存公开 asset URL 和必要元数据。
7. 机器翻译由 `cupid.translation.enabled` 控制；启用时保存源语言后先写入目标语言 `pending`，事务提交后异步调用 LibreTranslate。
8. `cupid.translation.fail-fast` 启用时，应用启动阶段检查翻译器可用性；运行中翻译失败只更新为 `failed` 并记录日志，不影响资料保存。

### 强制规则

- `/profiles/save` 是 owner 侧唯一资料写入口，不恢复旧 mock mutation API。
- 更新必须先校验当前用户是否拥有 owner/manager 权限。
- 客户端不得写审核结果、内部推荐状态、featured 或 staff 字段。
- contacts 只能通过 owner API 写入，不能出现在公共详情响应。
- photos payload 采用对账式更新时，必须防止删除或修改其他 profile 的照片。
- archive 前检查契约规定的未完成正式流程。
- `/api/upload` 使用 `multipart/form-data`，图片字段名固定为 `file`，并复用 RuoYi `FileUploadUtils` 完成图片类型与大小校验。
- 上传必须限制文件类型、大小和生成文件名；不得信任原始文件名作为存储路径。

### 验收矩阵

- 新建 self 和 family profile 均能生成正确 ownership。
- 保存失败时所有关联表回滚。
- 非 owner 无法读取、修改、归档或更新隐私设置。
- 修改 localized 数组后，旧值按约定删除或保留，不产生重复行。
- 照片新增、排序、替换和删除后返回结构与数据库一致。
- archive 后公共目录不可见，owner 侧结果符合契约。
- 上传拒绝非法类型和超限文件。
- 翻译器正常时 pending 能更新为 ready；翻译器运行中失败时 pending 更新为 failed，公共详情不读取 pending/failed。

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

### 状态

已完成并验收。2026-06-11 使用真实 MySQL、Redis 和 seed 数据验证了公共套餐、账户会员、权益周期、套餐权限、过期会员、升级占位和无数据库写入行为，并通过完整 Maven package。

### 当前基础

- `cm_membership_plans` 已包含 EUR/CNY 价格、购买类型、计费周期、有效期、私人介绍额度、活动额度和各类能力开关。
- 套餐名称和描述已经拆入 `cm_membership_plan_localized_fields`，仅使用 `status = 'ready'` 的本地化值并按请求 locale 回退。
- 注册流程已通过 `tier = 'free'` 查询启用的免费套餐并创建初始会员，不依赖固定套餐 UUID。
- 已有 active membership 查询同时检查 `status = 'active'` 和 `expires_at`。
- Membership 领域 service 已复用 `CupidUserMembership`、`CupidUserEntitlementBalance` 和 Profile 私人介绍额度查询口径。
- Profile 已改为读取套餐的 `profile_detail_access_level` 判断查看角色，不再按 tier 名称推导权限。

### 接口

- `GET /api/membership/catalog`
- `GET /api/account/membership`
- `POST /api/account/membership/upgrade`

### 响应约定

- `GET /api/membership/catalog` 返回 `{ plans: MembershipPlanDTO[] }`，与当前前端 API 和公共会员页面调用保持一致。
- `GET /api/account/membership` 返回 `{ membership, entitlements, availablePlans }`。
- `membership` 必须包含当前套餐的本地化名称、状态、起止时间、`staffSupportLevel` 和 `conciergePriority`。
- `entitlements` 只返回当前有效会员、当前有效周期的余额；每项包含 `code`、`quotaTotal`、`quotaUsed`、`quotaRemaining`、`periodStartedAt` 和 `periodEndsAt`。
- `availablePlans` 与公共 catalog 复用同一套餐 DTO 组装方法，不允许形成第二套字段映射。
- `POST /api/account/membership/upgrade` 本阶段只返回 `{ status: 'pending_external_flow', requestedTier }`，不创建订单、不修改会员、不初始化权益。

### 主要表

- `cm_membership_plans`
- `cm_membership_plan_localized_fields`
- `cm_user_memberships`
- `cm_user_entitlement_balances`

`cm_orders` 和 `cm_payments` 已在 schema 中预留，但不属于本阶段实现范围；正式支付或 staff 确认流程在阶段九处理。

### 实施顺序

1. 先建立 Membership 套餐 domain、mapper 和 service，集中完成启用套餐查询、本地化回退和 `MembershipPlanDTO` 组装。
2. 实现公共 catalog，并确认无需登录即可按 `sort_order` 返回全部启用套餐。
3. 扩展当前会员查询，使会员记录与对应套餐能力在一次领域查询或聚合中返回。
4. 查询当前会员对应、当前周期有效的 entitlement balances，禁止返回历史会员或历史周期余额。
5. 实现账户会员聚合接口，复用公共 catalog 的套餐组装结果生成 `availablePlans`。
6. 实现无数据库写入的 upgrade 外部流程占位响应，并校验请求 tier 对应启用套餐。
7. 将 Profile 详情权限从 `tier != 'free'` 调整为读取 `profile_detail_access_level`；私人介绍仍读取数据库中的当前 entitlement balance。
8. 最后检查已有 Profile 代码是否存在可复用的会员或权益查询，只提取实际重复逻辑，不预先建立额外 support/query/projection 层。

### 强制规则

- 套餐通过 `tier` 查询，禁止硬编码 free plan UUID。
- 欧元价格、人民币价格、购买类型、有效期和两类额度必须读取结构化套餐字段，禁止从本地化文案解析。
- 公共 catalog 与账户接口中的可升级套餐必须复用同一 mapper/service 组装逻辑。
- 当前会员由状态和有效期共同判定。
- entitlement 使用数据库余额和周期，不从 tier 名称或套餐额度临时推导。
- entitlement 查询必须限定当前 `membership_id` 和当前有效周期，不能只按 `user_id + entitlement_code` 查询。
- Profile 详情访问读取 `profile_detail_access_level`，活动优先、staff review、顾问支持和 concierge 权限分别读取对应套餐字段。
- 本阶段 `upgrade` 不创建订单；支付或 staff 确认前不得直接激活会员或增加 entitlement。
- 会员变更和 entitlement 初始化同事务属于阶段九正式确认流程的强制规则，本阶段只保留边界，不提前实现。

### 验收矩阵

- `GET /api/membership/catalog` 无需登录，以 `{ plans }` 结构按 locale 和 sort order 返回启用套餐。
- catalog 的价格、周期、额度和能力字段全部来自结构化列，名称和描述按 locale 正确回退。
- `GET /api/account/membership` 同时返回当前会员、当前周期 entitlement 和可升级套餐。
- 账户接口与公共 catalog 对同一套餐返回一致的 `MembershipPlanDTO`。
- free、Silver、Gold、Diamond、无有效会员和已过期会员得到正确会员视图。
- Silver 的 `profile_detail_access_level = 'registered'` 不会被错误当作 premium；Gold/Diamond 按套餐能力获得对应权限。
- 当前会员存在多期或历史 entitlement 时，账户页只返回当前会员当前周期的余额。
- `upgrade` 对不存在、停用或非法 tier 返回错误；有效 tier 返回 `pending_external_flow`。
- 调用 `upgrade` 前后 `cm_user_memberships`、`cm_user_entitlement_balances`、`cm_orders` 和 `cm_payments` 均不发生变化。

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
- `cm_user_entitlement_balances`

### 强制规则

- `registeredCount`、`waitlistCount` 从 registration 状态派生。
- 精确地址按 `address_visibility`、活动状态和当前用户报名状态返回。
- member-only event 必须由有效会员状态判断。
- 只有 `consumes_membership_quota = 1` 的活动才使用 `event_registration` 余额。
- 提交申请只写 `requested`，不扣活动额度。
- 后台确认、候补和拒绝属于阶段八报名审核；确认时必须在同一事务内校验容量并原子扣减 1 次活动额度，余额不足则确认失败。
- 已扣额度的报名在 attended 前取消时原子返还 1 次。
- `event_quota_consumed_at` 和 `event_quota_released_at` 必须保证重复确认、重复取消不重复变更余额。
- 报名和取消使用唯一约束避免重复记录。
- 前台重复报名必须返回已有有效报名；未确认取消可重新提交，已确认后取消不可由用户自行重报。
- 阶段八确认报名时必须锁定活动和报名记录，防止并发确认造成超卖。
- 活动过期状态优先由日期和正式状态规则判定，不由前端决定。

### 验收矩阵

- 目录过滤、分页、本地化和状态展示正确。
- guest、free、member 对 member-only event 的结果正确。
- 重复报名不会重复计数。
- 前台申请统一进入 `requested`；满员后的 waitlist / declined 分配由阶段八报名审核完成。
- 取消后计数和用户 account events 同步。
- 已消耗活动额度的报名取消后返还；重复取消保持幂等。
- 阶段八实现确认动作时，必须补充确认扣减、余额不足和并发容量验收。
- 不消耗会员额度的活动不受活动余额限制。
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

阶段八涉及独立的 `cupid-match-admin`、RuoYi 后台接口、权限菜单、后台账号和审计，详细实施与验收要求迁移至：

- `doc/cm-admin-implementation-plan.md`

本阶段保持以下总边界：

- 正式运营能力在 `cupid-match-admin` 和 `controller/cupid/admin` 中实现。
- 后台沿用 RuoYi 登录态、角色、菜单、权限和操作日志。
- Cupid 后台岗位使用 RuoYi 专用角色和精确权限表达，不维护 `cm_staff_members` 映射。
- Java 产品后端不开放 `/api/debug/*`。
- `cupid-match-app` Debug 页面继续保留用于 Mock 和开发回归，生产环境通过 `VITE_ENABLE_DEBUG=false` 禁止访问。
- RuoYi 生成器只生成机械骨架，不负责审核状态机、跨表事务、并发锁、权益扣减或审计。

## 13. 阶段九：支付、审计与生产化

内容：

- `cm_audit_logs` 完整写入策略。
- Email/SMS 验证码真实通道。
- 本地上传迁移至对象存储。
- Stripe 或人工确认支付流程。
- 数据库迁移工具和版本管理。
- 数据备份、恢复演练和敏感配置管理。
- 性能索引、慢查询和批量查询复核。
- 基于最终 mapper 审计 `cm_schema.sql` 的组合索引和约束；外键是否落库单独评估，不在前期阶段打断接口实现。
- HTTPS、CORS、限流、验证码频率和登录防爆破。
- 自动化集成测试与部署健康检查。

生产化完成前，不把测试验证码、人工支付捷径或本地文件路径暴露给生产前端。

## 14. 当前禁止事项

- 不全量生成所有 `cm_` 表 CRUD。
- 不复刻 mock-server debug routes。
- 不合并前台用户和 RuoYi 后台用户。
- 不重写 RuoYi 原生用户、角色和菜单体系。
- 不把 Cupid 业务改造成独立的 DDD、Clean Architecture 或 `dto/query/projection/support` 分层。
- 不因为契约存在 TypeScript interface，就在 Java 中机械创建一一对应的类。
- 不提前创建尚未被 service 使用的 domain、返回模型、接口或通用工具。
- 不因现有 service 文件较长就先行拆分；拆分必须由后续功能中的实际复用点或明确职责边界触发。
- 不为单条 mapper SQL 创建专用 row/projection 类；确需非表结果时，优先确认能否由已有 domain 字段、关联 domain 或 `Map` 承载。
- 不把筛选解析、跨表聚合、多语言回退、权限判断和响应拼装放进 controller、query 对象或 mapper。
- 不为 seed UUID 或旧 `u-001` ID 增加兼容代码。
- 不在 controller 中写 SQL 聚合、权限规则或事务流程。
- 不在业务代码中硬编码 `plan-free` UUID 等数据库主键。
- 不在未进入支付阶段时伪造正式支付成功。

## 15. 下一执行入口

下一任务是阶段八的 Phase 8.1：后台基础接入。

具体执行顺序、生成器规则、三工程边界和验收矩阵以 `doc/cm-admin-implementation-plan.md` 为准。
