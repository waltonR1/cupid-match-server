# Cupid Match 后台运营实施计划

## 1. 文档定位

本文是 Cupid Match 阶段八的独立实施与验收基线，覆盖：

- `cupid-match-server`：RuoYi 后台接口、权限、业务事务和审计。
- `cupid-match-admin`：RuoYi Vue3 + TypeScript 后台页面。
- `cupid-match-app`：保留开发环境 Debug 页面，不新增正式后台能力。

产品前台 API、数据库结构和阶段一至阶段七的实现仍分别以以下文件为准：

1. `doc/cm-backend-implementation-plan.md`
2. `doc/cm-api-status.md`
3. `doc/reference-from-app/final-api-contract.md`
4. `doc/reference-from-app/final-data-flow-contract.md`
5. `sql/cm_schema.sql`

## 2. 当前基线

- `cupid-match-server` 已完成阶段一至阶段七的前台产品能力。
- `cupid-match-admin` 是 RuoYi 3.9.2 官方 Vue3 + TypeScript 前端，目前尚未添加 Cupid 业务页面。
- 后台账号继续使用 RuoYi `sys_user`、角色、菜单、权限和登录态。
- `cm_staff_members.sys_user_id` 用于将 RuoYi 用户映射为 Cupid 业务 staff。
- `cm_staff_tasks` 和 `cm_audit_logs` 已在 schema 中预留。
- Java 产品后端不开放 `/api/debug/*`。

阶段八不是把 Mock Debug API 原样搬进 Java，而是将其中真实的运营能力改造成有权限、有审计、有状态约束的正式后台功能。

## 3. 三个工程的职责

### 3.1 cupid-match-server

负责：

- `controller/cupid/admin` 下的 RuoYi 后台接口。
- 后台查询、筛选、分页和详情聚合。
- 状态流转、事务、数据库锁和并发保护。
- RuoYi 权限注解和操作日志。
- `cm_staff_members` 业务 staff 校验。
- 需要业务快照时写入 `cm_audit_logs`。
- 复用阶段一至阶段七已有 service、mapper 和业务规则。

禁止：

- 在 `controller/cupid/app` 中加入后台操作。
- 新增 `/api/debug/*`。
- 让 Controller 直接操作 Mapper 或编排跨表事务。
- 为后台重新复制一套前台 Profile、Event 或 Membership 聚合逻辑。

### 3.2 cupid-match-admin

负责：

- Cupid 后台菜单、路由、API、TypeScript 类型和页面。
- 列表筛选、分页、详情抽屉或对话框。
- 审核操作、原因输入、二次确认和结果反馈。
- 使用 RuoYi `v-hasPermi` 控制按钮显示。
- 沿用 RuoYi 的请求封装、布局、表格、分页和字典组件。

禁止：

- 在页面中复制后端状态机。
- 用前端隐藏按钮代替后端权限校验。
- 直接调用 Cupid 前台 `/api/...` 接口执行运营操作。
- 把 `cupid-match-app` 的 Debug 页面复制到后台。

### 3.3 cupid-match-app

- Debug 页面和 `src/api/debug` 可以继续保留，供 Mock Server 和本地回归使用。
- 生产环境继续设置 `VITE_ENABLE_DEBUG=false`，通过路由守卫和页面守卫禁止访问。
- 当前 Debug 页面仍会进入生产构建产物，只是运行时不可访问；不得将其描述为“生产环境不编译”。
- Staging 当前允许 Debug 页面，连接 Java 后端时 `/api/debug/*` 返回不存在属于预期行为。
- 阶段八不以删除 Debug 页面为验收项。

## 4. 后台接口约定

### 4.1 路径和响应

- 后台 Controller 放在 `com.ruoyi.web.controller.cupid.admin`。
- 后台路径使用 `/cupid/...`，不使用 `/api/...` 或 `/api/debug/...`。
- 列表接口使用 RuoYi `startPage()` 和 `TableDataInfo`。
- 查询详情和动作结果沿用 RuoYi `AjaxResult`。
- `startPage()` 后必须紧跟目标 MyBatis 查询，避免 PageHelper 分页上下文污染。

### 4.2 权限

所有后台接口必须同时具备：

1. RuoYi 登录态。
2. `@PreAuthorize("@ss.hasPermi('cupid:模块:动作')")`。
3. 涉及业务状态修改时校验当前 `sys_user` 在 `cm_staff_members` 中处于 `active` 状态。

建议权限标识：

| 模块 | 权限 |
| --- | --- |
| Profile | `cupid:profile:list`, `cupid:profile:query`, `cupid:profile:review` |
| Photo | `cupid:photo:list`, `cupid:photo:review` |
| Verification | `cupid:verification:list`, `cupid:verification:review` |
| Introduction | `cupid:introduction:list`, `cupid:introduction:review` |
| Event | `cupid:event:list`, `cupid:event:query`, `cupid:event:edit` |
| Event Registration | `cupid:eventRegistration:list`, `cupid:eventRegistration:review` |
| Inbox | `cupid:inbox:list`, `cupid:inbox:notify` |
| User | `cupid:user:list`, `cupid:user:query`, `cupid:user:status` |
| Staff Task | `cupid:staffTask:list`, `cupid:staffTask:edit` |
| Audit | `cupid:audit:list`, `cupid:audit:query` |

菜单和按钮权限 SQL 应随各子任务提交，不等到阶段末一次补齐。

### 4.3 日志和审计

- 普通后台操作使用 RuoYi `@Log` 记录操作日志。
- 影响 Cupid 核心业务状态的操作，同时写入 `cm_audit_logs`。
- 审计记录至少包含：
  - `actor_type = staff`
  - 当前 `sys_user.user_id`
  - `subject_type`
  - `subject_id`
  - 稳定的 `action` code
  - `before_data`
  - `after_data`
  - 操作原因
- 列表查询不写业务审计。
- 审计日志后台只读，不提供通用修改或删除功能。

## 5. 数据表与 Domain 建模规则

当前 `cm_schema.sql` 包含 42 张 `cm_` 表，阶段一至阶段七已建立 20 个 Domain。表数量与 Domain 数量不需要一一对应：

- 独立业务实体、独立状态机和后台主要查询对象应建立 Domain。
- 纯关联表、本地化值表和只被父实体批量读写的附属表不必机械建立 Domain。
- 单次聚合查询可以使用已有 Domain 的关联字段或 `Map`。
- 当一张表开始承担独立列表、详情、锁定、状态修改或跨方法传递时，应从 `Map` 提升为明确 Domain。
- 不得仅因为 RuoYi 生成器能够导入一张表，就保留其全部 Domain 和通用 CRUD。

### 5.1 Phase 8 必须建立

| 表 | Domain | 建立时机 | 原因 |
| --- | --- | --- | --- |
| `cm_staff_members` | `CupidStaffMember` | Phase 8.1 | staff 身份、角色和 active 状态校验 |
| `cm_event_registrations` | `CupidEventRegistration` | Phase 8.4 | 独立审核状态机、行锁、容量和权益事务 |
| `cm_inbox_threads` | `CupidInboxThread` | Phase 8.5 前 | 后台线程查询和系统通知创建 |
| `cm_inbox_messages` | `CupidInboxMessage` | Phase 8.5 前 | sender、模板和消息类型需要明确建模 |
| `cm_staff_tasks` | `CupidStaffTask` | Phase 8.7 | 独立后台管理实体 |
| `cm_audit_logs` | `CupidAuditLog` | 第一个业务审计写入前 | 统一审计写入、列表和详情 |

`CupidEventRegistration` 是当前最优先从 `Map<String, Object>` 提升的实体。前台只读聚合继续使用 `CupidEvent` 没有问题，但后台审核不能依赖字符串 key 完成锁定、状态流转和权益扣减。

### 5.2 按实际后台功能建立

| 表 | 建议 |
| --- | --- |
| `cm_profile_internal_records` | 后台开始管理 featured、source 或内部字段时建立 `CupidProfileInternalRecord` |
| `cm_event_agenda_items` | 后台开始编辑活动议程时建立 `CupidEventAgendaItem` |
| `cm_staff_task_localized_fields` | 使用主子表生成器时可建立附属 Domain；仅维护 note 时也可由 `CupidStaffTask` 聚合 |
| `cm_user_preferences` | 后台独立编辑用户偏好时再建立；只读摘要继续使用 Map |
| `cm_user_security_settings` | 后台独立管理安全设置时再建立；只读聚合继续使用 Map |

### 5.3 默认不建立独立 Domain

以下表目前是关联、本地化或流程附属数据，可继续由父 Domain、Mapper 参数、批量 SQL 或 Map 承载：

- `cm_user_security_challenges`
- `cm_user_agreement_acceptances`
- `cm_profile_internal_localized_fields`
- `cm_membership_plan_localized_fields`
- `cm_event_localized_fields`
- `cm_event_relationship_focuses`
- `cm_event_language_codes`
- `cm_event_agenda_item_localized_fields`
- `cm_inbox_reads`

如果后续需求使其中某张表成为独立后台列表或状态实体，再按真实调用点建立 Domain，不提前创建。

### 5.4 Phase 9 再建立

- `cm_orders` -> `CupidOrder`
- `cm_payments` -> `CupidPayment`

正式支付尚未进入实现阶段，不在 Phase 8 提前生成。

### 5.5 已有 Domain 保持不变

阶段一至阶段七已有 Domain 不因后台开发整体重建。后台应优先复用 `CupidUser`、`CupidProfile`、`CupidProfilePhoto`、`CupidProfileVerification`、`CupidPrivateIntroductionRequest`、`CupidEvent`、`CupidUserMembership` 和 `CupidUserEntitlementBalance`。

只有后台出现新的真实字段需求时才补充字段或建立独立 Domain，不为生成器模板调整现有分层。

## 6. RuoYi 代码生成器使用规则

RuoYi 官方生成器支持导入数据库表、单表/树表/主子表模板、预览、编辑、同步，以及生成 Java、Mapper XML、Vue3 TypeScript 页面、API 和菜单 SQL。

本项目允许使用生成器减轻机械工作，但生成结果只能作为骨架。

### 6.1 推荐生成

适合生成并保留较多基础结构：

- `cm_staff_members`
- `cm_staff_tasks`
- `cm_staff_task_localized_fields`
- `cm_audit_logs` 的只读列表和详情
- Event 基础列表或编辑表单骨架

可复用的生成内容：

- Domain 字段骨架
- 基础 Mapper 和 XML
- 分页列表 Controller 结构
- 后台 API 文件和 TypeScript 类型骨架
- Vue3 TS 查询表单、表格、分页和基础对话框
- 菜单与权限 SQL

### 6.2 仅可参考，不得直接采用通用 CRUD

以下功能必须按业务动作手写：

- Profile、Photo、Verification 审核
- Private Introduction 接受或拒绝
- Event Registration 确认、候补或拒绝
- 权益原子扣减和返还
- 容量并发控制
- Inbox 系统通知
- User 停用、恢复及会话失效
- Staff 身份校验
- 审计快照

生成器不得为这些业务暴露通用 `add/edit/remove` 来绕过状态机。

### 6.3 生成工作流

1. 在 RuoYi 后台“系统工具 -> 代码生成”中导入目标表。
2. 配置包名、模块名、业务名、菜单和 TypeScript 前端模板。
3. 先预览全部文件，不直接覆盖现有代码。
4. 在独立临时目录或独立提交中解压生成结果。
5. 只挑选与本项目职责一致的骨架。
6. 删除不需要的通用新增、修改、删除和导入导出。
7. 将状态修改改成明确的业务命令。
8. 补充权限、staff 校验、事务、锁、通知和审计。
9. 编译前后端并执行真实接口冒烟。

若生成结果与当前 Vue3 TypeScript 目录或类型规范不一致，以 `cupid-match-admin` 现有源码风格为准，不修改项目去迁就模板。

## 7. Debug 能力处置

### 7.1 转化为正式后台能力

| Mock Debug 能力 | 正式后台模块 |
| --- | --- |
| Private Introduction 列表、接受、拒绝 | 私人介绍处理 |
| Event Registration 列表、确认、候补、拒绝 | 活动报名审核 |
| Event 列表和状态修改 | 活动管理 |
| Profile Photo 列表和审核 | 照片审核 |
| Profile Verification 列表和审核 | 认证审核 |
| Inbox Thread 列表和发送系统通知 | 消息支持工具 |

这些能力应重新设计后台接口和页面，不保留 Debug 路径或 Debug DTO 名称。

### 7.2 只保留在 Mock 或开发工具

- Profile guest/free/member/backend 访问预览。
- Event guest/free/member 详情预览。
- Event 虚拟身份报名和取消。
- 本地验证码查看。

这些能力用于前台权限和状态回归，不属于运营后台。

### 7.3 不进入 Java

- `POST /debug/identities/:id/verify`

这是 Mock 中绕过验证码直接验证身份的遗留捷径，前端也没有使用。不得迁移到 Java 或后台。

## 8. 实施子阶段

### 8.1 Phase 8.1：后台基础接入

目标：

- 建立 Cupid 后台一级菜单。
- 创建权限标识和角色授权方案。
- 实现 `cm_staff_members` 管理或最小查询能力。
- 建立 `CupidStaffMember` Domain；只生成 staff 模块需要的最小骨架。
- 建立统一的 active staff 校验方法。
- 确认 `cupid-match-admin` 可登录并访问空的 Cupid 菜单。

验收：

- 未授权 RuoYi 用户看不到菜单且接口返回无权限。
- 有菜单权限但没有 active staff 映射的用户不能执行 Cupid 状态修改。
- active staff 可以访问被授权模块。

### 8.2 Phase 8.2：Profile、Photo、Verification 审核

后台页面：

- Profile 审核队列和详情。
- Photo 审核队列及图片预览。
- Verification 审核队列及材料字段。

核心动作：

- 审核 Profile。
- 将照片设置为 `approved` 或 `hidden`。
- 分字段更新 verification 状态。
- 更新 `verified_at` 和审核 staff。
- 必要时创建 Inbox 通知。

强制规则：

- 不直接复用 Mock 的任意字段状态写入。
- 校验合法状态流转。
- Profile、Photo 和 Verification 的联动在同一业务事务中完成。
- 审核理由进入审计日志。

### 8.3 Phase 8.3：Private Introduction 处理

后台页面：

- 按状态、申请时间、申请人和目标 Profile 查询。
- 查看申请人、目标资料和历史申请。

核心动作：

- 接受 `requested` 申请。
- 拒绝 `requested` 申请并设置 cooldown。
- 创建对应 Inbox 通知。

强制规则：

- 使用数据库锁防止重复处理。
- 非 `requested` 状态不可再次处理。
- 状态、响应时间、cooldown、通知和审计保持事务一致。

### 8.4 Phase 8.4：Event 管理和报名审核

后台页面：

- Event 列表、详情和状态管理。
- Event Registration 审核列表。

建模要求：

- 建立 `CupidEventRegistration`，后台审核、锁定和状态更新不再使用 `Map<String, Object>`。
- Event 基础管理继续复用 `CupidEvent`。
- 只有本阶段确实支持议程编辑时才建立 `CupidEventAgendaItem`。

核心动作：

- 管理 Event 基础字段和状态。
- 将 `requested` 报名设置为 `confirmed`、`waitlist` 或 `declined`。
- 确认时原子扣减活动权益。
- 取消或状态回滚时按既有规则返还权益。
- 创建报名结果通知。

强制规则：

- 确认报名时锁定 Event 和 Registration。
- 同一事务内检查容量和扣减权益。
- 禁止超卖和重复扣减。
- 余额不足时确认失败，不部分更新。

### 8.5 Phase 8.5：Inbox 通知工具

后台页面：

- 查询用户系统通知线程。
- 选择模板、语言和目标用户。
- 预览并发送系统通知。

建模要求：

- 建立 `CupidInboxThread` 和 `CupidInboxMessage`。
- 前台 Inbox 返回结构可以继续由 service 聚合，后台写入和查询使用明确 Domain。

强制规则：

- 不允许任意伪造用户聊天消息。
- 模板 code 和 locale 必须校验。
- 自定义正文权限应与模板发送权限分离。
- 发送结果写操作日志；重要人工通知可写业务审计。

### 8.6 Phase 8.6：User 状态管理

后台页面：

- 用户列表和详情。
- 状态、身份、会员、Profile 和近期活动摘要。

核心动作：

- 按明确业务规则停用或恢复用户。
- 停用用户时注销其全部 Cupid Redis 会话。

强制规则：

- 不修改 RuoYi `sys_user` 代替 `cm_users`。
- 不提供删除用户数据的通用按钮。
- 敏感身份信息按后台权限分级显示。

### 8.7 Phase 8.7：Staff Tasks 和审计查询

后台页面：

- Staff Task 列表、分配、状态和优先级。
- Cupid Audit Log 只读列表和详情。

建模要求：

- 建立 `CupidStaffTask` 和 `CupidAuditLog`。
- `cm_staff_task_localized_fields` 是否独立建模取决于最终页面是否将多语言 note 作为子表维护。

强制规则：

- Task assignee 必须是有效 RuoYi 用户。
- 业务动作不因 Task 状态失败而丢失核心事务。
- Audit Log 不提供修改和删除。

## 9. 后台 API 建议

最终路径可随 RuoYi 模块命名微调，但职责应保持稳定：

| 模块 | 建议接口 |
| --- | --- |
| Profile | `GET /cupid/profile/list`, `GET /cupid/profile/{id}`, `POST /cupid/profile/{id}/review` |
| Photo | `GET /cupid/photo/list`, `POST /cupid/photo/{id}/review` |
| Verification | `GET /cupid/verification/list`, `POST /cupid/verification/{profileId}/review` |
| Introduction | `GET /cupid/introduction/list`, `POST /cupid/introduction/{id}/accept`, `POST /cupid/introduction/{id}/decline` |
| Event | `GET /cupid/event/list`, `GET /cupid/event/{id}`, `POST /cupid/event/{id}/status` |
| Event Registration | `GET /cupid/eventRegistration/list`, `POST /cupid/eventRegistration/{id}/review` |
| Inbox | `GET /cupid/inbox/list`, `POST /cupid/inbox/notify` |
| User | `GET /cupid/user/list`, `GET /cupid/user/{id}`, `POST /cupid/user/{id}/status` |
| Staff Task | RuoYi 生成器产生的基础路径可保留，动作按业务收敛 |
| Audit | `GET /cupid/audit/list`, `GET /cupid/audit/{id}` |

审核请求体应显式包含目标状态和 `reason`，不要把任意状态值直接放在 URL 中。

## 10. 每个子阶段的执行要求

开始前：

1. 阅读本阶段对应章节。
2. 检查阶段一至阶段七已有 service 和 mapper 是否可复用。
3. 按本文 Domain 建模规则判断目标表是否需要独立 Domain。
4. 明确哪些文件来自生成器，哪些是业务手写。
5. 先确定权限标识、状态流转和审计 action code。

提交前：

1. 后端编译通过。
2. `cupid-match-admin` TypeScript 检查和生产构建通过。
3. 使用真实 RuoYi 登录态验证接口。
4. 验证无权限、无 staff 映射、非法状态和重复操作。
5. 验证审计和通知副作用。
6. 检查生成器是否留下绕过业务规则的通用 CRUD。
7. 检查是否为关联表或本地化表机械创建了无调用点的 Domain。

建议将后端、菜单 SQL和 `cupid-match-admin` 页面按同一业务模块提交，不将整个阶段压成一个巨大提交。

## 11. 阶段八完成标准

必须同时满足：

- 正式后台能力不依赖 `/api/debug/*`。
- 所有后台写操作均有 RuoYi 权限校验。
- 核心状态修改要求 active staff。
- 关键操作具有事务、并发保护和审计。
- Profile、Photo、Verification、Introduction、Event Registration 的状态机通过验收。
- Event 确认不超卖、不重复扣减权益。
- User 停用会注销全部 Cupid 会话。
- `cupid-match-admin` 菜单、列表、详情和动作页面可用。
- 产品前端原有接口和 Debug 页面行为未被破坏。
- Debug 页面继续只在允许的环境中访问。
- 独立状态实体使用明确 Domain，关联表和本地化表没有被机械一表一 Domain 化。

## 12. 当前执行入口

下一任务是 Phase 8.1：

1. 用 RuoYi 菜单和权限体系建立 Cupid 后台一级菜单。
2. 建立 `CupidStaffMember`，确定 `cm_staff_members` 的管理方式和 active staff 校验入口。
3. 只为 `cm_staff_members` 生成或手写最小骨架，不提前生成其他 `cm_` 表 CRUD 或 Domain。
4. 在第一个需要审计的写操作前建立 `CupidAuditLog`，不要求 Phase 8.1 提前完成审计页面。
5. 完成权限矩阵和基础登录冒烟后，再进入 Profile 审核模块。
