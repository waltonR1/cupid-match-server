# Cupid Match 后台运营实施计划

## 1. 文档定位

本文是 Cupid Match 阶段八的实施与验收基线，覆盖：

- `cupid-match-server`：RuoYi 后台接口、权限、事务、审计和菜单 SQL。
- `cupid-match-admin`：RuoYi Vue3 + TypeScript 后台页面。
- `cupid-match-app`：保留现有开发环境 Debug 页面，不继续承担正式后台职责。

本文必须与以下文件保持一致：

1. `doc/cm-backend-implementation-plan.md`
2. `doc/cm-api-status.md`
3. `doc/cm-schema-structure-notes.md`
4. `doc/cm-database-initialization.md`
5. `doc/reference-from-app/final-api-contract.md`
6. `doc/reference-from-app/final-data-flow-contract.md`
7. `sql/cm_schema.sql`

发生冲突时：

- 前台产品契约以 final contract 为准。
- 数据库结构以 `cm_schema.sql` 为准。
- RuoYi 登录、菜单、权限和动态路由行为以当前项目源码为准。
- 阶段八的执行顺序、后台页面和后台接口以本文为准。

## 2. 当前基线与阶段目标

### 2.1 当前基线

- 阶段一至阶段七的前台产品接口已经完成。
- `cupid-match-admin` 是 RuoYi 3.9.2 官方 Vue3 + TypeScript 前端，尚未建立 Cupid 业务页面。
- RuoYi `sys_user`、`sys_role`、`sys_user_role`、`sys_menu` 和 `sys_role_menu` 继续作为后台账号与授权的唯一来源。
- `cm_staff_members` 已从 schema 移除，不重新建立第二套后台员工身份。
- Java 产品后端不提供 `/api/debug/*`。
- `cupid-match-app` 的 Debug 页面只服务于 Mock 和开发回归，不迁移为正式运营后台。

### 2.2 阶段八目标

阶段八不是把 Mock Debug API 原样迁入 Java，而是建立：

- 独立的 Cupid Match 运营后台信息架构。
- 基于 RuoYi 的登录、角色、菜单、按钮权限和操作日志。
- 受状态机、事务、并发和审计约束的正式业务操作。
- 可查询、可筛选、可分页、可查看详情的后台页面。
- Profile、Photo、Verification、Introduction、Event、Registration、Inbox、User、Task 和 Audit 的运营能力。

### 2.3 不在阶段八范围内

- 不重写 RuoYi 登录认证和动态路由框架。
- 不把 `cm_users` 与 `sys_user` 合并。
- 不创建 `cm_staff_members`、`CupidStaffMember` 或 staff 登录体系。
- 不把 Debug DTO、Debug 路径和任意字段修改能力迁入正式后台。
- 不提前实现支付、退款和财务对账；这些属于阶段九。

## 3. RuoYi 原生动态路由与权限机制

本节是后台菜单和页面接入必须遵循的源码事实。

### 3.1 登录后的实际调用链

1. 前端路由守卫检测到已有 token 且尚未加载角色。
2. 前端调用 `getInfo()`，取得当前 `sys_user` 的角色和权限字符。
3. 前端调用 `GET /getRouters`。
4. 后端读取当前用户 ID：
   - 超级管理员调用 `selectMenuTreeAll()`。
   - 普通用户通过 `sys_user_role -> sys_role_menu -> sys_menu` 查询菜单。
5. 后端只将正常状态的 `M` 和 `C` 菜单构造成 `RouterVo`。
6. 前端将 `Layout`、`ParentView`、`InnerLink` 或组件路径字符串转换成 Vue 组件。
7. 前端通过 `router.addRoute()` 注册后端下发的业务路由。

对应源码：

- `ruoyi-admin/.../SysLoginController#getRouters`
- `ruoyi-system/.../SysMenuServiceImpl#selectMenuTreeByUserId`
- `ruoyi-system/.../SysMenuServiceImpl#buildMenus`
- `ruoyi-system/.../SysMenuMapper.xml`
- `cupid-match-admin/src/permission.ts`
- `cupid-match-admin/src/store/modules/permission.ts`

### 3.2 `sys_menu` 三种类型

| 类型 | 含义 | 是否生成路由 | 主要字段 |
| --- | --- | --- | --- |
| `M` | 目录 | 是 | `parent_id`、`path`、`icon`、`order_num` |
| `C` | 页面菜单 | 是 | `path`、`component`、`perms`、`is_cache` |
| `F` | 按钮或动作权限 | 否 | `parent_id`、`perms`、`order_num` |

约束：

- `M` 只组织菜单树，不对应业务 CRUD 页面。
- `C` 对应一个真实存在的 Vue 页面。
- `F` 用于按钮显示和后端动作权限，不参与路由构造。
- 列表页的 `C.perms` 使用 `cupid:<module>:list`。
- 详情、审核、状态修改等权限使用该页面下的 `F` 行表达。

### 3.3 菜单字段的准确语义

| 字段 | 本项目取值规则 |
| --- | --- |
| `menu_type` | `M` 目录、`C` 页面、`F` 按钮 |
| `is_frame` | `0` 是外链，`1` 不是外链；Cupid 菜单统一使用 `1` |
| `is_cache` | `0` 缓存，`1` 不缓存 |
| `visible` | `0` 显示，`1` 隐藏；隐藏路由仍可访问 |
| `status` | `0` 正常，`1` 停用；停用菜单不会下发 |
| `path` | 目录或页面的路由片段，不填写 `views/` |
| `component` | 相对 `src/views/` 的组件路径，不带 `.vue` |
| `route_name` | Vue Router 路由名称；必须唯一 |
| `perms` | 后端和前端共同使用的权限字符 |
| `query` | 固定路由参数；普通列表页面留空 |

示例：

```text
component = cupid/profile/index
```

必须对应：

```text
cupid-match-admin/src/views/cupid/profile/index.vue
```

`permission.ts` 使用 `import.meta.glob('./../../views/**/*.vue')` 精确匹配组件路径。页面文件不存在或路径大小写不一致时，动态路由无法正确加载。

### 3.4 固定路由与动态路由的边界

`cupid-match-admin/src/router/index.ts` 中的 `constantRoutes` 包含：

- `/login`
- `/401`
- `/404`
- `/index`
- `/user/profile`

其中 `/index` 是所有已登录后台用户都能进入的固定首页，不由 `sys_menu` 下发，也不能依靠 `sys_role_menu` 隐藏。

Cupid 业务列表页面使用 `sys_menu` 动态下发。只有详情页、编辑页等不应出现在侧边栏的特殊页面，才考虑：

- 建立 `visible=1` 的隐藏 `C` 菜单；或
- 在前端 `dynamicRoutes` 中声明并用 `permissions` 限制。

默认优先使用隐藏 `C` 菜单，使路由、角色和权限继续由后端统一管理。不要把普通业务菜单硬编码到前端 `dynamicRoutes`。

### 3.5 超级管理员的特殊行为

RuoYi 的 `SecurityUtils.isAdmin(userId)` 对用户 ID 1 生效。超级管理员：

- 不依赖 `sys_role_menu` 查询菜单。
- 可以看到全部 `status=0` 的 `M` 和 `C` 菜单。
- 权限判断拥有全权限通配能力。

因此：

- “不给 admin 角色分配某菜单”不能隐藏该菜单。
- “若依官网”必须删除其菜单和角色关联，不能只依靠不给普通角色授权。
- 普通 Cupid 运营角色是否看到系统管理、系统监控和系统工具，由 `sys_role_menu` 控制。
- 日常运营不应使用超级管理员账号。

## 4. 三个工程的职责

### 4.1 `cupid-match-server`

负责：

- 在 `com.ruoyi.web.controller.cupid.admin` 下提供后台 Controller。
- 后台列表、筛选、分页、详情聚合和业务动作。
- 复用已有 Cupid Domain、Mapper 和 Service。
- 状态机、事务、数据库锁、并发保护和幂等。
- `@PreAuthorize` 权限校验和 RuoYi `@Log` 操作日志。
- 核心业务动作写入 `cm_audit_logs`。
- 维护 `sql/cm_admin_menu.sql`。

禁止：

- 在 `controller/cupid/app` 中加入后台操作。
- 新增 `/api/debug/*`。
- Controller 直接操作 Mapper 或编排跨表事务。
- 为后台复制一套前台聚合 Service。
- 仅依靠前端隐藏按钮保护写接口。

### 4.2 `cupid-match-admin`

负责：

- 修改后台品牌、首页、导航和默认文案。
- 在 `src/views/cupid/` 下建立业务页面。
- 在 `src/api/cupid/` 下建立后台 API 与 TypeScript 类型。
- 复用 RuoYi 表格、分页、字典、弹窗、抽屉和请求封装。
- 使用 `v-hasPermi` 控制按钮显示。
- 对危险操作提供原因输入和二次确认。
- 正确处理 loading、空状态、错误状态和重复提交。

禁止：

- 在页面中复制后端状态机。
- 调用前台 `/api/...` 接口执行后台操作。
- 复制 `cupid-match-app` Debug 页面。
- 用用户名或角色名硬编码页面权限。
- 绕过动态菜单，在前端硬编码普通业务路由。

### 4.3 `cupid-match-app`

- 保留现有 Debug 页面与 `src/api/debug`。
- 生产环境继续设置 `VITE_ENABLE_DEBUG=false`。
- Debug 页面当前仍进入构建产物，只是运行时不可访问。
- Java 后端没有 `/api/debug/*` 属于预期行为。
- 阶段八不以删除 Debug 页面为验收项。

## 5. 后台品牌、首页与导航

### 5.1 品牌清理

Phase 8.1 必须完成：

- 所有环境的 `VITE_APP_TITLE` 改为 Cupid Match 后台名称。
- 替换侧边栏 Logo、favicon 和登录页品牌信息。
- 修改 `settings.ts` 中面向用户的版权文案。
- 删除 Navbar 中指向 RuoYi 源码和文档的入口及无用组件引用。
- 删除“若依官网”菜单及其 `sys_role_menu` 关联。
- 删除 RuoYi 演示公告。

不得：

- 删除 RuoYi 源码版权、许可证或依赖声明。
- 为了品牌修改通用工具类和框架注释。

### 5.2 首页

保留：

```text
route: /index
file:  src/views/index.vue
```

首页重做为 Cupid Match 运营工作台，不承载完整 CRUD。

首页分两步实现：

1. Phase 8.1：完成页面布局、欢迎信息、空状态和按权限显示的快捷入口。
2. 各业务模块完成后：接入待审核数量、活动异常和当前用户任务。

若建立 `GET /cupid/dashboard`：

- 不新增独立的 Dashboard 菜单权限。
- 接口依赖 RuoYi 登录态，并按当前用户已有的模块 `list` 权限返回对应统计卡片。
- 不把无权限模块的统计数据返回给前端后再隐藏。
- 不为尚未实现的模块伪造数量。

### 5.3 系统菜单

继续保留：

- 系统管理
- 系统监控
- 系统工具

授权规则：

- 超级管理员始终可见。
- 普通 `cupid_admin` 默认不授予系统菜单。
- 只有平台管理员或明确需要的技术人员才分配系统菜单。
- 权限差异通过 `sys_role_menu` 配置，不修改系统菜单源码。

### 5.4 RuoYi 原生功能与 C 端边界

RuoYi 原生系统功能默认只管理后台账号和后台基础设施。不能因为 Cupid 代码位于同一个工程，就认为这些页面已经覆盖 `cm_users`、Cupid JWT 或 Cupid Inbox。

| 原生功能 | 当前数据源或对象 | 是否已经覆盖 C 端 | 处理方式与时机 |
| --- | --- | --- | --- |
| 用户管理 | `sys_user` | 否 | 原样保留管理后台账号；Phase 8.6 独立实现 App User 管理 |
| 角色管理 | `sys_role`、`sys_user_role` | 间接涉及 | Phase 8.1 直接复用，建立 Cupid 后台角色 |
| 菜单管理 | `sys_menu`、`sys_role_menu` | 只涉及后台 | Phase 8.1 直接复用，管理 Cupid 后台动态路由和按钮权限 |
| 部门管理 | `sys_dept` | 否 | 保留给后台组织管理；阶段八不要求改造 |
| 岗位管理 | `sys_post` | 否 | 保留给后台员工岗位；不得表达 App 会员、身份或业务角色 |
| 字典管理 | `sys_dict_type`、`sys_dict_data` | 当前未接入 | 有真实后台表单需求时按模块接入，不迁移状态机和程序常量 |
| 参数设置 | `sys_config` | 当前未接入 | 有真实热更新需求时接入，不迁移基础设施和安全配置 |
| 通知公告 | `sys_notice`、`sys_notice_read`，关联 `sys_user` | 否 | 保留给后台员工；Phase 8.5 使用 Cupid Inbox 独立实现 C 端通知 |
| 操作日志 | `sys_oper_log`、RuoYi `@Log` | 尚未覆盖 Cupid 后台接口 | Phase 8.2 起所有后台写操作按需接入 |
| 登录日志 | `sys_logininfor`、RuoYi 后台认证 | 否 | 继续只记录后台登录；C 端安全事件推迟到生产化阶段 |
| 在线用户 | `login_tokens:*`、`LoginUser` | 否 | 保留后台在线用户；Phase 8.6 独立实现 Cupid 会话查询和强退 |
| 定时任务 | Quartz、`sys_job` | 当前未接入 | 保留框架；出现真实补偿或清理任务时再接入 |
| 数据监控 | Druid 数据源统计 | 是，自动覆盖 | 直接保留，Cupid SQL 已包含在同一数据源统计中 |
| 服务监控 | 当前 Java 进程 | 是，自动覆盖 | 直接保留，Cupid 服务运行在同一进程中 |
| 缓存监控 | Redis 实例整体统计 | 是，自动计入 | 直接保留，只授权技术管理员 |
| 缓存列表 | RuoYi 预设 key 前缀 | 否 | 阶段八不改造成 C 端会话管理工具 |

上述功能必须遵守以下边界：

- 原生用户、在线用户、登录日志和通知公告不得通过兼容分支同时承载 `sys_user` 与 `cm_users`。
- C 端需要同类能力时，可以复用 RuoYi 页面组件、分页模式和权限模式，但必须使用独立 Cupid Controller、Service、数据表或 Redis key。
- 系统管理、系统监控和系统工具默认只授予平台管理员和技术人员。
- 普通 Cupid 运营角色不得获得缓存清理、后台在线用户强退、参数修改、字典修改或定时任务管理权限。
- 原缓存列表中的全量清理能力可能同时删除后台登录、Cupid 会话、验证码和其他缓存，只能由受控技术账号使用。

### 5.5 字典与参数接入规则

字典适合表达后台显示和选择项，例如：

- 审核原因类别。
- Staff Task 优先级。
- 后台筛选标签。
- 不参与状态机判断的展示枚举。

字典不得取代：

- Profile、Verification、Introduction 或 Registration 的合法状态流转。
- 权益类型和扣减规则。
- 隐私受限字段集合。
- `CupidProfileConstants` 中影响程序分支的字段集合。
- C 端多语言产品文案。

使用 Cupid 字典时，业务代码必须显式读取 RuoYi 字典服务；仅在后台创建 `cupid_*` 字典不会让现有 Java 或 App 自动使用它。

参数设置适合少量需要运行时调整的非安全运营参数，例如推荐数量或运营功能开关。以下配置继续保留在 YAML、环境变量或专用配置类中：

- 数据库、Redis 和翻译服务连接信息。
- JWT secret 和令牌基础安全配置。
- 连接超时、启动失败策略等基础设施配置。
- 状态机、权限和事务规则。

不得为了使用参数管理而让每次业务调用动态读取大量 `sys_config`。只有运营人员确实需要在线修改且修改后可安全立即生效的值才接入。

### 5.6 日志、审计和会话分层

后台与 C 端的观测能力分为：

1. `sys_logininfor`：RuoYi 后台账号登录、退出和失败记录。
2. `sys_oper_log`：后台 Controller 操作记录，由 RuoYi `@Log` 产生。
3. `cm_audit_logs`：Cupid 核心业务状态变更的 before、after、reason 和后台操作人。
4. Cupid 会话：`cupid:session:*` 保存单会话，`cupid:user-sessions:*` 保存用户全部会话 ID。

阶段八不把 C 端登录写入 `sys_logininfor`。若生产化阶段需要记录登录失败、密码重置、身份解绑和异常设备等安全事件，应设计独立的 Cupid 安全事件模型，不复用后台登录日志表。

原缓存监控会统计整个 Redis 实例，因此已经包含 Cupid key 对 Redis 容量和命令量的影响；原缓存列表没有注册 Cupid key，也不得替代业务会话管理。Cupid 会话强退必须调用 `CupidTokenService`，不能由运营页面直接删除 Redis key。

## 6. Cupid 菜单与页面结构

### 6.1 一级目录

| 一级目录 | `path` | 建议图标 | 子页面 |
| --- | --- | --- | --- |
| 审核中心 | `cupid-review` | `audit` | Profile、Photo、Verification |
| 关系服务 | `cupid-relationship` | `peoples` | Private Introduction |
| 活动运营 | `cupid-event` | `date` | Event、Event Registration |
| 用户服务 | `cupid-user` | `user` | App User、Inbox |
| 运营协作 | `cupid-operations` | `clipboard` | Staff Task、Audit Log |
| 配置中心 | `cupid-config` | `dict` | Common Options |

一级目录统一配置：

```text
menu_type = M
parent_id = 0
is_frame = 1
visible = 0
status = 0
component = ''
perms = ''
```

不得仅为了占位插入没有任何可用子页面的目录。每个一级目录随第一个真实子页面一起加入 SQL。

### 6.2 页面菜单

| 页面 | 父目录 | `path` | `component` | 页面权限 |
| --- | --- | --- | --- | --- |
| Profile 审核 | 审核中心 | `profile` | `cupid/profile/index` | `cupid:profile:list` |
| Photo 审核 | 审核中心 | `photo` | `cupid/photo/index` | `cupid:photo:list` |
| 身份认证审核 | 审核中心 / 认证审核 | `identity` | `cupid/verification/identity/index` | `cupid:verification:identity:list` |
| 学历认证审核 | 审核中心 / 认证审核 | `education` | `cupid/verification/education/index` | `cupid:verification:education:list` |
| 收入认证审核 | 审核中心 / 认证审核 | `income` | `cupid/verification/income/index` | `cupid:verification:income:list` |
| 婚姻认证审核 | 审核中心 / 认证审核 | `marital` | `cupid/verification/marital/index` | `cupid:verification:marital:list` |
| 私人介绍处理 | 关系服务 | `introduction` | `cupid/introduction/index` | `cupid:introduction:list` |
| 活动管理 | 活动运营 | `event` | `cupid/event/index` | `cupid:event:list` |
| 报名审核 | 活动运营 | `registration` | `cupid/event-registration/index` | `cupid:eventRegistration:list` |
| App 用户管理 | 用户服务 | `user` | `cupid/user/index` | `cupid:user:list` |
| 通知发布 | 用户服务 | `inbox` | `cupid/inbox/index` | `cupid:inbox:send` |
| 通知模板 | 用户服务 | `inbox-template` | `cupid/inbox-template/index` | `cupid:inboxTemplate:list` |
| Staff Task | 运营协作 | `task` | `cupid/staff-task/index` | `cupid:staffTask:list` |
| 业务审计 | 运营协作 | `audit` | `cupid/audit/index` | `cupid:audit:list` |
| 通用选项 | 配置中心 | `options` | `cupid/options/index` | `cupid:options:list` |

页面菜单统一配置：

```text
menu_type = C
is_frame = 1
is_cache = 0
visible = 0
status = 0
query = ''
```

每一个 `route_name` 必须显式设置并全局唯一，建议：

- `CupidProfile`
- `CupidPhoto`
- `CupidIdentityVerification`
- `CupidEducationVerification`
- `CupidIncomeVerification`
- `CupidMaritalVerification`
- `CupidIntroduction`
- `CupidEvent`
- `CupidEventRegistration`
- `CupidUser`
- `CupidInboxPublisher`
- `CupidInboxTemplate`
- `CupidStaffTask`
- `CupidAudit`
- `CupidOptions`

### 6.3 按钮权限

| 页面 | 权限 |
| --- | --- |
| Profile | `cupid:profile:query`、`cupid:profile:review` |
| Photo | `cupid:photo:query`、`cupid:photo:review` |
| Verification | `cupid:verification:list`、`cupid:verification:query`、`cupid:verification:review` |
| Introduction | `cupid:introduction:query`、`cupid:introduction:accept`、`cupid:introduction:decline` |
| Event | `cupid:event:query`、`cupid:event:edit`、`cupid:event:changeStatus` |
| Event Registration | `cupid:eventRegistration:query`、`cupid:eventRegistration:review` |
| User | `cupid:user:query`、`cupid:user:changeStatus` |
| Inbox 发布 | `cupid:inbox:preview`、`cupid:inbox:send`、`cupid:inbox:broadcast` |
| Inbox 模板 | `cupid:inboxTemplate:query`、`cupid:inboxTemplate:add`、`cupid:inboxTemplate:edit`、`cupid:inboxTemplate:changeStatus` |
| Staff Task | `cupid:staffTask:query`、`cupid:staffTask:add`、`cupid:staffTask:edit` |
| Audit | `cupid:audit:query` |
| Options | `cupid:options:query`、`cupid:options:edit` |

规则：

- 每个动作权限建立 `F` 菜单并挂在对应 `C` 菜单下。
- 前端按钮使用相同权限执行 `v-hasPermi`。
- Controller 使用完全一致的 `@PreAuthorize` 字符串。
- 页面权限和接口权限必须同时存在，不能只实现其中一层。
- Verification 四个页面可以使用分项页面权限控制菜单可见性；底层列表、详情和审核接口仍使用通用 `cupid:verification:*` 权限。
- Audit 不提供修改和删除权限。
- User 不提供通用删除权限。
- 审核模块不暴露通用 `add/edit/remove`。

## 7. 角色与授权矩阵

### 7.1 角色

| 角色键 | 用途 |
| --- | --- |
| `cupid_admin` | 全部 Cupid 运营能力，不默认拥有 RuoYi 系统菜单 |
| `cupid_reviewer` | Profile、Photo、Verification 和 Introduction 审核 |
| `cupid_event_manager` | Event 和 Event Registration |
| `cupid_support` | App User、Inbox 单发和 Staff Task |
| `cupid_auditor` | 业务审计只读 |

不创建含义重叠的 `cupid_operator`。新增角色前必须先证明现有角色无法准确表达职责。

### 7.2 默认授权

| 角色 | 首页 | 审核中心 | 关系服务 | 活动运营 | 用户服务 | 运营协作 |
| --- | --- | --- | --- | --- | --- | --- |
| `cupid_admin` | 固定路由 | 全部 | 全部 | 全部 | 全部 | 全部 |
| `cupid_reviewer` | 固定路由 | 全部 | 全部 | 否 | 否 | 否 |
| `cupid_event_manager` | 固定路由 | 否 | 否 | 全部 | 否 | 否 |
| `cupid_support` | 固定路由 | 否 | 否 | 否 | App User + Inbox 单发 | Staff Task |
| `cupid_auditor` | 固定路由 | 否 | 否 | 否 | 否 | Audit 只读 |

“全部”表示同时授予：

- 父级 `M` 目录。
- 对应 `C` 页面。
- 该岗位需要的全部 `F` 动作。

RuoYi 的菜单树依赖父级节点。不能只分配按钮权限而遗漏父目录和页面菜单。

### 7.3 后台账号

- 后台账号通过 RuoYi 用户管理创建。
- 通过 RuoYi 角色分配功能关联 Cupid 角色。
- 不把后台员工写入 `cm_users`。
- `cm_staff_tasks.assignee_sys_user_id` 引用 RuoYi `sys_user.user_id`。
- 停用后台账号继续使用 RuoYi 原生用户状态。
- 生产环境日常运营账号不得使用用户 ID 1。

## 8. 菜单与角色 SQL

新增：

```text
sql/cm_admin_menu.sql
```

完整数据库初始化顺序、环境限制和只执行后台增量脚本的方式见 `doc/cm-database-initialization.md`。RuoYi 原始 `ry_20260417.sql` 和 `quartz.sql` 保持不变，不复制修改。

### 8.1 SQL 职责

该文件只维护：

- Cupid 一级目录。
- Cupid 页面菜单。
- Cupid 按钮权限。
- Cupid 专用角色。
- Cupid 角色与菜单关系。
- “若依官网”菜单及其角色关联删除。
- 必要的演示公告清理。

不修改：

- RuoYi 原生系统菜单定义。
- 超级管理员逻辑。
- RuoYi 登录和权限表结构。
- `cm_` 业务表结构。

### 8.2 ID 分配

实施前先检查现有最大 ID 和冲突：

```sql
select max(menu_id) from sys_menu;
select menu_id, menu_name from sys_menu where menu_id between 2000 and 2199;
select role_id, role_key from sys_role where role_key like 'cupid_%';
```

若无冲突，预留：

- `2000-2004`：Cupid 一级目录。
- `2010-2049`：Cupid 页面菜单。
- `2100-2199`：Cupid 按钮权限。

角色不依赖硬编码 `role_id` 建立关联。`sys_role_menu` 插入时通过 `role_key` 查询实际 `role_id`。

### 8.3 可重复执行原则

- 菜单使用固定 `menu_id`，插入前按该 ID 或明确权限标识清理本项目自己的旧数据。
- 清理顺序必须先删 `sys_role_menu` 中的 Cupid 关联，再删 Cupid `sys_menu`。
- 只删除 `menu_id` 位于预留区间或 `perms like 'cupid:%'` 的记录。
- 不使用无范围的 `delete from sys_role_menu`。
- 角色按 `role_key` 判断是否存在，不覆盖人工修改的用户角色关系。
- 每次新增业务模块时同步新增该模块的 `C/F` 行和角色授权，不等阶段末补齐。
- SQL 执行后重新登录，确保前端重新拉取角色、权限和路由。

## 9. 后台接口约定

### 9.1 路径与响应

- Controller 放在 `com.ruoyi.web.controller.cupid.admin`。
- 路径统一使用 `/cupid/...`，不使用 `/api/...`。
- 列表使用 `startPage()` 和 `TableDataInfo`。
- 详情和动作结果使用 `AjaxResult`。
- `startPage()` 后必须紧跟目标 MyBatis 查询。
- 后台查询对象沿用 RuoYi 项目风格，不创建独立 `query` 包。
- 简单筛选字段放在 Domain 或明确的参数对象中；只有跨实体复杂请求才建立专用请求对象。

### 9.2 权限

所有后台接口必须具备：

1. RuoYi 登录态。
2. 对应的 `@PreAuthorize("@ss.hasPermi('cupid:module:action')")`。
3. 正常状态的 `sys_user`。
4. 写操作的参数校验和业务状态校验。

`v-hasPermi` 只控制前端显示，后端注解才是安全边界。

### 9.3 日志与审计

- 查询操作不写业务审计。
- 后台写操作使用 RuoYi `@Log`。
- 影响 Cupid 核心状态的操作同时写入 `cm_audit_logs`。
- `cm_audit_logs.actor_type = staff`。
- `actor_user_id` 写当前 `sys_user.user_id` 的字符串形式。
- 审计包含 `subject_type`、`subject_id`、稳定 action code、before、after 和 reason。
- 审计与业务状态修改处于同一事务。
- Audit 页面只读，不提供通用修改和删除。

## 10. Domain 与生成器规则

### 10.1 必须建立的 Domain

| 表 | Domain | 阶段 | 原因 |
| --- | --- | --- | --- |
| `cm_event_registrations` | `CupidEventRegistration` | 8.4 | 独立审核状态机、锁和权益事务 |
| `cm_inbox_threads` | `CupidInboxThread` | 8.5 前 | 后台线程查询 |
| `cm_inbox_messages` | `CupidInboxMessage` | 8.5 前 | 明确 sender、模板和消息类型 |
| `cm_staff_tasks` | `CupidStaffTask` | 8.7 | 独立管理实体 |
| `cm_audit_logs` | `CupidAuditLog` | 首个业务写操作前 | 统一审计写入和查询 |

### 10.2 按真实需要建立

- `cm_profile_internal_records`：后台开始管理 featured 或内部字段时建立；`source` 仅作为内部流程归因预留字段。
- `cm_event_agenda_items`：后台开始编辑议程时建立。
- `cm_staff_task_localized_fields`：页面确实维护多语言 note 时建立。
- `cm_user_preferences`：后台独立编辑偏好时建立。
- `cm_user_security_settings`：后台独立管理安全设置时建立。

关联表、本地化表和只被父实体批量读取的附属表，不因生成器可导入就机械建立 Domain。

### 10.3 生成器可以承担

- Domain 字段骨架。
- 基础 Mapper 和 XML。
- 简单分页列表 Controller 骨架。
- Vue3 TS 查询表单、表格、分页和基础弹窗。
- API 文件和类型骨架。
- 菜单与权限 SQL 草稿。

### 10.4 生成器不能直接决定

- 审核状态机。
- Introduction 接受与拒绝。
- Registration 确认、候补与拒绝。
- 权益扣减和返还。
- 活动容量并发控制。
- Inbox 系统通知。
- User 停用和全部会话失效。
- 审计快照。

生成器产物必须先预览，解压到临时目录，挑选可复用部分。不得直接覆盖现有 Cupid Service、Mapper 或前端目录。

## 11. 分阶段实施

### 11.1 Phase 8.1：后台基础接入

完成状态（2026-06-15）：

- `sql/cm_admin_menu.sql` 已执行，Cupid 初始角色、官网菜单清理和演示公告清理已落库。
- `cupid-match-admin` 已完成环境标题、登录页、侧边栏、Navbar 和版权文案的品牌清理；全局主题色继续沿用 RuoYi 原生配置。
- 固定路由 `/index` 已改为运营首页，仅展示真实账号、角色、权限和导航信息；尚未实现的业务模块使用未启用状态，不伪造业务统计。
- 生产构建已通过，登录页已完成浏览器检查。
- 后端重新构建后已通过 Redis 初始化并正常启动，超级管理员登录、首页、角色列表、动态路由加载和刷新恢复均已通过浏览器检查。
- 5 个 Cupid 角色均已创建且未提前授予任何空业务菜单；官网菜单和 3 条演示公告已清理。
- 普通 Cupid 角色的系统菜单隔离、角色变更重新登录生效、停用账号禁止登录和账号恢复均已通过人工验收。
- 超级管理员显示名称已由演示昵称改为正式名称“管理员”。
- Phase 8.1 已全部完成。

后端与 SQL：

- 创建 `sql/cm_admin_menu.sql`。
- 建立 Cupid 角色和初始授权规则。
- 删除“若依官网”菜单及其角色关联。
- 清理演示公告。
- 不创建尚无页面文件的 `C` 菜单。
- 不改造原生用户、通知公告、在线用户、登录日志和缓存列表去兼容 C 端。
- 普通 Cupid 角色不授予字典、参数、定时任务、缓存清理和后台在线用户强退权限。

前端：

- 完成品牌清理。
- 重做 `src/views/index.vue`。
- 建立 `src/views/cupid/` 和 `src/api/cupid/` 目录约定。
- 首页先提供有权限的模块快捷入口和真实空状态。
- 不提前生成空 CRUD 页面。

验收：

- 登录页、标题、Logo、favicon、首页和 Navbar 不再展示 RuoYi 演示品牌。
- `/index` 对所有正常登录用户可访问。
- 普通 Cupid 角色看不到系统管理、系统监控和系统工具。
- 超级管理员仍可使用系统菜单。
- 停用账号无法登录。
- 重新登录后菜单和权限变化生效。
- 原生系统页面仍只管理 RuoYi 后台账号和后台基础设施。

### 11.2 Phase 8.2：Profile 与 Photo 审核

状态：

- 后端审核接口、Service、Mapper XML 已实现。
- 前端 `cupid-match-admin` 审核页面和 `src/api/cupid/review.ts` 已实现。
- `sql/cm_admin_menu.sql` 已追加审核中心动态菜单、按钮权限和角色授权。
- 已通过 `ruoyi-admin` Maven 编译和 `cupid-match-admin` 生产构建。
- 已执行 `sql/cm_admin_menu.sql` 后，通过 `/getRouters` 验证审核中心动态路由已返回。
- 已验证 Profile、Photo、Verification 列表和详情接口返回 200。
- 已用浏览器验证三张审核页面可打开，无登录跳转和前端运行错误。
- 已补充审核页可读摘要、短 ID 展示、字段中文标签和重复审核保护。
- Phase 8.2 的正式验收范围收敛为 Profile 发布审核与 Photo 内容审核；Verification 已在 Phase 8.2.2 单独改造为材料审核闭环。
- Verification 已从 `cm_profile_verifications` 汇总状态入口改为 `cm_profile_verification_materials` 材料队列入口，并拆为身份、学历、收入、婚姻四个后台页面。
- Verification 后台接口仍保留 `/cupid/verification/...` 路径，但 `{id}` 语义已从 `profileId` 改为 `materialId`。
- 多语言资料文案需要后续拆成独立审核队列，审核单元应为 `profile_id + field_name + locale`，例如 `summary/zh`、`summary/fr`、`summary/en` 各自成条。当前 `cm_profile_localized_fields.status` 表达的是生成/翻译可用状态，不应直接复用为审核结论。
- 已手工执行 Profile 与 Photo 审核写操作，确认状态流转、重复审核保护、`cm_audit_logs` 和 RuoYi `sys_oper_log` 写入。

页面：

- `src/views/cupid/profile/index.vue`
- `src/views/cupid/photo/index.vue`
- `src/views/cupid/verification/identity/index.vue`
- `src/views/cupid/verification/education/index.vue`
- `src/views/cupid/verification/income/index.vue`
- `src/views/cupid/verification/marital/index.vue`

API：

| 模块 | 接口 |
| --- | --- |
| Profile | `GET /cupid/profile/list`、`GET /cupid/profile/{id}`、`POST /cupid/profile/{id}/review` |
| Photo | `GET /cupid/photo/list`、`GET /cupid/photo/{id}`、`POST /cupid/photo/{id}/review` |
| Verification | `GET /cupid/verification/list`、`GET /cupid/verification/{materialId}`、`POST /cupid/verification/{materialId}/review`，按认证材料审核 |

要求：

- 列表支持审核状态、用户、时间等必要筛选。
- Photo 页面提供真实图片预览。
- 审核请求显式包含目标状态与 reason。
- Profile 和 Photo 各自的状态流转处于明确事务内。
- 写入审核人、审核时间和业务审计。
- 后台审核写操作同时使用 RuoYi `@Log`。
- 页面确实需要可维护的展示枚举时才新增 `cupid_*` 字典，状态机值仍由 Java 和数据库约束。
- 同步加入对应 `M/C/F` 菜单和角色授权。

### 11.2.1 Phase 8.2.1：Profile 内部运营字段与后台内部资料

定位：

- Phase 8.2.1 专门处理已开放 Profile 的运营控制和内部备注，不并入当前 Profile 发布审核页。
- 当前 Profile 发布审核页只审核面向 C 端展示的资料内容，不增加独立“展示控制”区。`familyVisible`、隐私偏好和联系方式可见范围保留为资料中心能力，后续如需展示应进入资料库或资料运营页，而不是塞入发布审核详情。
- 内部字段默认不面向 C 端展示，必须先确认字段用途、可见边界和权限后再做后台页面。

目标：

- 建立面向运营人员的 Profile 管理入口，用于维护已开放资料的精选状态和内部备注。
- 明确区分“C 端展示资料”“C 端展示控制”“后台内部资料”和“后台备注”。
- 后台内部资料字段必须有权限控制和审计记录，不能绕过现有 App API 字段白名单。

数据边界：

| 数据 | 当前表 | 用途 | C 端可见性 |
| --- | --- | --- | --- |
| 精选状态 | `cm_profile_internal_records.is_featured` | 推荐、首页精选、运营排序判断 | 可间接影响推荐，不直接作为详情字段展示 |
| 内部记录来源 | `cm_profile_internal_records.source` | 预留给资料采集、自动精选等内部流程归因 | 不在 8.2.1 资料运营页展示或编辑 |
| 更新人 | `cm_profile_internal_records.updated_by_user_id` | 记录后台或用户操作来源 | 不展示 |
| 雇主信息 | `cm_profile_internal_localized_fields.employer` | 后台维护的职业背景参考 | 8.2.1 只读；后续进入 8.2.2 认证审核 |
| 收入范围 | `cm_profile_internal_localized_fields.income_range` | 后台维护的收入/认证参考 | 8.2.1 只读；后续进入 8.2.2 收入认证 |
| 内部备注 | `cm_profile_internal_localized_fields.staff_notes` | 运营备注、服务记录摘要 | 永不进入 App profile detail |

页面规划：

- 一级菜单使用“资料中心”，下挂两个页面：
  - `cupid/profile-library/index`：资料库，只读查看 C 端资料本体、已通过照片和后台内部资料。
  - `cupid/profile-manage/index`：资料运营，仅展示已开放资料，维护精选和内部备注。
- 两个页面都不要塞进 `cupid/profile/index` 发布审核页。
- 资料库列表可复用 Profile 审核页的查询条件：资料 ID、资料名称、用户 ID、用户名称、类型、状态、更新时间。
- 资料库详情展示完整只读档案：基础资料、婚恋与偏好、生活方式、已通过照片、精选状态、雇主信息、收入范围和内部备注；不提供运营编辑动作。
- 资料运营列表只进入 `profile_status = open` 的资料，额外显示是否精选、最近内部更新时间、内部备注状态，并可只读显示雇主信息和收入范围作为认证参考。
- 资料运营详情页分区：
  - 基础资料只读摘要：资料名称、用户、资料类型、资料状态、基本信息。
  - 运营字段：`is_featured`。
  - 认证参考：`employer`、`income_range` 只读展示，不在资料运营页编辑。
  - 内部备注：`staff_notes`，仅授权角色可见。
  - 审计信息：最近更新人、更新时间。

权限规划：

| 能力 | 权限 |
| --- | --- |
| 资料库列表 | `cupid:profileLibrary:list` |
| 资料库详情 | `cupid:profileLibrary:query` |
| 资料运营列表 | `cupid:profileManage:list` |
| 资料运营详情 | `cupid:profileManage:query` |
| 编辑运营字段 | `cupid:profileManage:edit` |
| 查看内部备注 | `cupid:profileManage:notes` |
| 编辑内部备注 | `cupid:profileManage:editNotes` |

实现顺序：

1. 先确认是否沿用 `cm_profile_internal_records` 和 `cm_profile_internal_localized_fields`，若字段足够则不新增表。
2. 在后端新增独立 Controller/Service 方法，不复用发布审核的 `reviewProfile` 写操作。
3. Mapper 查询 Profile 基础摘要时只挑选后台需要字段，不把 domain 整体序列化。
4. 资料运营写操作只更新 `cm_profile_internal_records.is_featured` 或 `staff_notes`。
5. 写操作必须写入 `cm_audit_logs`，action 建议使用：
   - `cupid.profile.internal.update`
   - `cupid.profile.internal.notes.update`
6. Controller 写操作接入 RuoYi `@Log`。
7. `sql/cm_admin_menu.sql` 新增菜单和按钮权限，并授权给需要的运营角色。
8. 前端新增页面，列表和详情沿用 RuoYi 表格、抽屉或弹窗模式。

重新审核规则：

- 修改 `is_featured`、`staff_notes` 不触发资料重新进入 `review`。
- `employer`、`income_range` 不在 8.2.1 编辑；收入范围归入 8.2.2 收入认证，雇主信息随认证资料一起评估。
- 若未来某个后台内部资料字段进入 C 端 profile detail，必须先把该字段迁移到正式展示契约，并定义是否触发发布审核。

验收：

- 资料运营只展示已开放资料。
- 资料库可只读查看后台内部字段。
- 后台可编辑精选状态，资料运营页采用开关切换即保存，不额外放保存按钮。
- 内部备注只对具备备注权限的角色可见。
- 资料运营不能编辑雇主信息和收入范围。
- 修改精选或内部备注后，App profile detail 响应不新增内部字段。
- 修改写入 `cm_audit_logs` 和 `sys_oper_log`。
- 发布审核页不出现内部字段。
- `cupid_auditor` 仍只读业务审计，不具备编辑能力。

当前实现状态：

- 已新增资料库后台接口 `GET /cupid/profile-library/list`、`GET /cupid/profile-library/{id}`。
- 已新增资料运营后台接口 `GET /cupid/profile-manage/list`、`GET /cupid/profile-manage/{id}`、`GET /cupid/profile-manage/{id}/notes`、`POST /cupid/profile-manage/{id}/internal`、`POST /cupid/profile-manage/{id}/notes`。
- 已新增前端页面 `cupid/profile-library/index` 和 `cupid/profile-manage/index`，分别作为只读“资料库”和可操作“资料运营”，不混入 Profile 发布审核页。
- 资料库详情已只读展示 `cm_profile_internal_records` 和 `cm_profile_internal_localized_fields` 的内部字段，不提供编辑入口。
- 资料审核、资料库和资料运营详情已只读展示归属关系、联系方式、联系方式开放策略、隐私偏好、家庭可见和最后活跃时间；资料运营仍不提供联系方式或隐私偏好编辑入口。
- 已接入 `cm_profile_internal_records` 的 `is_featured`、`updated_by_user_id`，以及 `cm_profile_internal_localized_fields` 的 `staff_notes`；`employer`、`income_range` 仅作为只读认证参考展示，`cm_profile_internal_records.source` 仅保留为内部流程预留字段，当前页面不展示、不筛选、不编辑。
- 内部备注通过独立 notes 接口读取和保存，权限与普通运营字段分离。
- 写操作已写入 `cm_audit_logs`，操作动作为 `cupid.profile.internal.update` 和 `cupid.profile.internal.notes.update`，同时由 RuoYi `@Log` 写入 `sys_oper_log`。
- `sql/cm_admin_menu.sql` 已新增独立一级菜单 `资料中心`，下挂二级 `资料库` 与 `资料运营`；`cupid_admin` 默认拥有完整资料中心权限，`cupid_support` 默认只拥有资料库只读权限。

8.2.1 完成后仍需遵守：

- 不把内部字段塞入当前 Profile 发布审核页。
- 资料库可以只读查看 `staff_notes`、收入、雇主等内部/敏感字段；发布审核页不展示这些字段。
- 不让内部字段绕过 C 端资料展示边界直接进入 App profile detail。
- 后台若未来需要编辑面向 C 端展示的资料字段，必须从资料库或独立资料编辑能力进入，不混入审核按钮或资料运营内部字段接口。
- 面向 C 端展示字段的后台编辑必须使用独立权限、写入 `cm_audit_logs` 的 before/after/operator/reason，并明确编辑后是直接生效还是重新进入发布审核。

### 11.2.2 Phase 8.2.2：Verification 认证审核闭环

定位：

- Phase 8.2.2 专门处理身份、学历、收入、婚姻四类认证材料审核，不并入当前 Profile 发布审核。
- 平台审核归属于 Profile 发布审核，对应 `cm_profiles.profile_status`，不再归属于 Verification。
- 当前 `cm_profile_verifications.review_status` 只能作为历史兼容或派生汇总字段，不能继续伪装成独立“平台审核”。
- 认证审核必须形成“C 端提交材料、后台分项审核、拒绝原因回传、C 端重新提交”的闭环。

目标：

- 支持身份、学历、收入、婚姻四类认证材料的提交、查看、通过、拒绝和重新提交。
- 后台审核以材料和认证类型为单位，不再把一条 `cm_profile_verifications` 记录伪装成完整审核材料。
- 认证通过后稳定影响 C 端 `isVerified`、账号中心认证状态和后续业务权限。
- 拒绝后 C 端能看到拒绝原因文本，并可重新提交对应类型材料。
- C 端账号中心继续展示五个状态，但“平台审核”直接读取 Profile 发布审核状态。

当前实现状态（2026-06-23）：

- 已新增 `cm_profile_verification_materials`，用于保存每次认证材料提交和审核结果。
- 已新增增量迁移脚本 `sql/cm_phase_8_2_2_verification_materials.sql`，用于现有数据库创建材料表并回填旧汇总认证状态。
- 已保留 `cm_profile_verifications` 作为四类认证的汇总状态表。
- C 端资料详情页已从“保存资料顺带提交身份认证”改为独立提交认证材料：
  - 保存资料只保存草稿或资料内容，不自动进入平台发布审核。
  - 已保存资料可调用 `POST /account/profiles/{profileId}/submit-review`，将 `draft` 或被拒后的 `hidden` 资料提交为 `review`。
  - 身份认证提交 `legalName`、`dateOfBirth`、`materialUrl`、补充说明。
  - 学历、收入、婚姻提交 `materialName`、`materialUrl`、补充说明。
  - `materialUrl` 当前作为私有对象 Key 保存；C 端选择文件时只保留本地文件信息，提交认证材料时先上传取得私有 Key，再提交材料记录。
  - 上传端和服务端都限制为 PDF/JPG/JPEG/PNG/WEBP，服务端单文件上限为 10MB。
  - 提交成功后刷新资料详情，状态进入 `pending`。
- Admin 已将认证材料队列拆为四个页面，共用同一个材料审核组件：
  - `cupid/verification/identity/index`：身份认证材料。
  - `cupid/verification/education/index`：学历认证材料。
  - `cupid/verification/income/index`：收入认证材料。
  - `cupid/verification/marital/index`：婚姻认证材料。
  - 每个页面固定提交对应 `materialType` 查询，不再依赖人工筛选认证类型。
  - 详情按 `materialId` 查看。
  - 审核只影响该材料对应的一个认证类型。
- 后端接口已按材料语义实现：
  - `GET /account/profiles/{profileId}/verification`
  - `POST /account/profiles/{profileId}/verification/materials/upload`
  - `POST /account/profiles/{profileId}/verification/materials`
  - `GET /cupid/verification/list`
  - `GET /cupid/verification/{materialId}`
  - `GET /cupid/verification/{materialId}/material/preview`
  - `GET /cupid/verification/{materialId}/material/download`
  - `POST /cupid/verification/{materialId}/review`
- 材料附件保存为 `private://verification/...` 私有 Key；Admin 不直接打开裸链，只能通过鉴权预览/下载接口由后端流式返回。
- 当前拒绝原因保存为 `rejection_reason` 文本；Admin 提供快捷拒绝原因和补充备注，不规划结构化 reason code。

推荐数据模型：

保留 `cm_profile_verifications` 作为 Profile 的认证汇总表：

- `identity_status`
- `education_status`
- `income_status`
- `marital_status`
- `review_status`：兼容字段或派生汇总字段，不能作为平台审核来源
- `verified_at`
- `verified_by_user_id`

已新增认证材料表 `cm_profile_verification_materials`：

| 字段 | 用途 |
| --- | --- |
| `id` | 材料 ID |
| `profile_id` | 关联 Profile |
| `material_type` | `identity`、`education`、`income`、`marital` |
| `status` | `pending`、`approved`、`rejected` |
| `legal_name`、`date_of_birth` | 身份认证提交字段 |
| `material_name` | 材料名称 |
| `material_url` | 材料私有地址或对象 Key，不存长期公开裸链 |
| `scan_status` | 安全检查状态；当前上传入口写入 `passed` |
| `scan_message` | 安全检查说明 |
| `scanned_at` | 安全检查时间 |
| `review_note` | 用户提交说明 |
| `submitted_by_user_id` | 提交人 |
| `submitted_at` | 提交时间 |
| `reviewed_by_user_id` | 审核人 |
| `reviewed_at` | 审核时间 |
| `rejection_reason` | 拒绝原因文本 |
| `created_at`、`updated_at` | 时间戳 |

如需要保留多条审核动作流水，可新增 `cm_profile_verification_audit_logs`；否则先复用 `cm_audit_logs` 记录 before/after/reason。

状态职责：

- 材料表 `status` 表达单份材料的审核结果。
- `cm_profile_verifications.*_status` 表达该认证类型的当前汇总结果。
- `cm_profile_verifications.review_status` 只表达四类认证材料的整体汇总状态，或后续考虑废弃；它不表达平台审核：
  - 全部关键认证未提交：`unreviewed`
  - 任一材料待审：`pending`
  - 必要认证全部通过：`approved`
  - 任一必要认证被拒且无新待审材料：`rejected`
- `cm_profiles.profile_status` 表达平台审核：
  - `review`：平台审核中
  - `open`：平台审核通过，资料可进入 C 端公开展示范围
  - `hidden`：平台审核未通过或资料被隐藏
  - 其他状态按 Profile 生命周期语义展示，不挪到 Verification 解释
- C 端公开资料 `isVerified` 只在身份认证通过且整体规则满足时为 true，具体规则由后端统一计算。

C 端账号中心：

- 账号中心资料认证卡片继续展示身份、学历、收入、婚姻和平台审核五个状态。
- 身份、学历、收入、婚姻四项来自 Verification 四个认证汇总字段。
- 平台审核来自 Profile 发布审核状态，不读取 `cm_profile_verifications.review_status`。
- 平台审核点击后只展示资料发布审核说明和当前状态，不提交认证材料；资料内容修改和重新提交仍走 Profile 资料编辑/发布审核链路。
- 身份、学历、收入、婚姻四类认证无论当前状态是 `unverified`、`pending`、`verified` 还是 `rejected`，点击后都打开详情弹窗或内联面板，不再只有未认证时可展开。
- 已认证状态复用现有只读展示组件：
  - 身份认证展示脱敏真实姓名、出生日期等可展示摘要。
  - 学历、收入、婚姻若没有可公开给用户复核的字段，则展示“该认证由平台工作人员审核与维护”。
  - 已认证内容默认只读，不允许直接改资料字段。
- 未认证状态展示提交表单：
  - 身份认证表单至少包含真实姓名、出生日期和材料上传入口。
  - 学历、收入、婚姻表单按认证类型展示材料上传入口和必要说明。
  - 保存后进入 `pending`，前端按钮文案改为待审核。
- 待审核状态展示已提交材料摘要、提交时间和“审核中”提示；C 端默认不支持撤回或替换 pending 材料。
- 已拒绝状态展示拒绝原因文本、补充说明和重新提交入口。
- 重新提交同类型材料时，旧的 rejected 材料保留，新材料进入 `pending`；当前不允许同类型存在未处理 pending 重复提交。
- 新增或扩展 API 传输认证材料，不复用资料编辑保存接口：
  - `GET /account/profiles/{profileId}/verification` 返回四类认证状态、材料摘要、拒绝原因和可操作状态。
  - `POST /account/profiles/{profileId}/verification/materials/upload` 上传认证材料文件，返回私有 `materialUrl`、原文件名、Content-Type 和大小。
  - `POST /account/profiles/{profileId}/verification/materials` 新增认证材料提交。
  - Profile 详情或账号概览接口需要返回平台审核状态，供账号中心“平台审核”使用。
  - 提交接口只传材料 URL、文件元信息和认证类型，不接收裸露公网附件地址。
- 认证材料提交不应触发 Profile 发布审核状态变化。
- Verification 接口不再返回一个可被前端解释为“平台审核”的 `reviewStatus`；如保留该字段，只能命名或注释为认证汇总状态。

后台页面：

- 后台不再保留一个混合“认证审核”总页面；`认证审核` 作为目录，下面拆为身份、学历、收入、婚姻四个材料审核页面。
- 四个页面共用一套审核组件和 `/cupid/verification/...` 接口，只通过固定 `materialType` 区分业务队列。
- 页面只处理身份、学历、收入、婚姻四类材料。
- 平台审核继续由 `cupid/profile/index` 资料审核页承担。
- 发布审核页默认只显示 `profile_status = review` 的待审核资料；草稿资料不进入审核队列，手动筛出时也不可执行审核。
- 列表筛选：
  - 资料 ID、资料名称、用户 ID、用户名称
  - 材料状态
  - 提交时间、审核时间
  - 排序：待审优先、提交时间最新、审核时间最新
- 列表列：
  - 资料摘要
  - 用户
  - 当前材料状态
  - 拒绝原因摘要
  - 提交时间
  - 审核时间
- 详情页：
  - 资料和用户摘要
  - 当前认证类型的材料预览
  - 历史提交批次
  - 已有拒绝原因
  - 审核操作区：通过、拒绝、拒绝原因快捷选项、补充说明
- 当前粗粒度 `POST /cupid/verification/{profileId}/review` 已改为 `POST /cupid/verification/{materialId}/review` 语义，不能再一次性修改四类认证状态。

权限规划：

| 能力 | 权限 |
| --- | --- |
| 身份认证页面 | `cupid:verification:identity:list` |
| 学历认证页面 | `cupid:verification:education:list` |
| 收入认证页面 | `cupid:verification:income:list` |
| 婚姻认证页面 | `cupid:verification:marital:list` |
| 接口列表 | `cupid:verification:list` |
| 详情 | `cupid:verification:query` |
| 审核 | `cupid:verification:review` |
| 预览材料附件 | `cupid:verification:material:preview` |
| 下载材料附件 | `cupid:verification:material:download` |
| 后台补录材料 | `cupid:verification:material:create` |
| 重置认证状态 | `cupid:verification:reset` |

接口规划：

| 端 | 接口 | 用途 |
| --- | --- | --- |
| App | `GET /account/profiles/{profileId}/verification` | 查看四类认证状态、材料摘要、拒绝原因和是否可提交 |
| App | `POST /account/profiles/{profileId}/verification/materials/upload` | 上传认证材料文件，返回后端私有文件 Key |
| App | `POST /account/profiles/{profileId}/verification/materials` | 提交认证材料；payload 包含 `materialType`、材料 URL、文件元信息和身份认证补充字段 |
| App | 账号概览或 Profile 详情接口 | 返回 `profileStatus` 或派生的 `platformReviewStatus`，用于展示平台审核 |
| Admin | `GET /cupid/verification/list` | 查询材料审核队列 |
| Admin | `GET /cupid/verification/{materialId}` | 查看材料详情 |
| Admin | `GET /cupid/verification/{materialId}/material/preview` | 点击材料凭证后弹窗预览，由后端流式返回，受 `cupid:verification:material:preview` 控制 |
| Admin | `GET /cupid/verification/{materialId}/material/download` | 鉴权下载材料文件，由后端流式返回，受 `cupid:verification:material:download` 控制 |
| Admin | `POST /cupid/verification/material/create` | 后台手工补录新的待审材料，受 `cupid:verification:material:create` 控制 |
| Admin | `POST /cupid/verification/reset` | 后台重置某个资料的某类认证状态，受 `cupid:verification:reset` 控制 |
| Admin | `POST /cupid/verification/{materialId}/review` | 审核材料 |

审计与通知：

- 后台审核写操作必须写入 `cm_audit_logs`，action 建议使用：
  - 当前实现：`cupid.verification.review`
  - 后续可细化为 `cupid.verification.material.approve`、`cupid.verification.material.reject`
- Controller 写操作接入 RuoYi `@Log`。
- 审核通知不在 Phase 8.2.2 实现；等 Phase 8.5 Cupid Inbox 完成后，再统一接入认证、资料和照片审核结果通知。
- 通过后是否通知用户可配置，默认可以先不发，账号中心状态即时更新即可。

迁移与兼容：

- 现有 `cm_profile_verifications` 数据保留为汇总状态。
- 若没有历史材料，不伪造材料记录。
- 当前基础 Verification 页面已拆为四个真实材料审核队列。
- `sql/cm_admin_menu.sql` 使用一个 `认证审核` 目录承载四个分项页面；接口权限继续保留通用 `cupid:verification:list/query/review`，减少后端鉴权和接口复制成本。
- C 端账号中心平台审核已从 Profile 的 `profileStatus` 派生；不能再从 Verification 的 `reviewStatus` 读取。
- 后端需要检查所有 `reviewStatus` 命名，避免前端继续把认证汇总状态误解为平台审核。

验收：

- C 端可提交四类认证材料。
- C 端五个状态来源清晰：四类认证来自 Verification，平台审核来自 Profile。
- 后台四个认证页面分别固定身份、学历、收入、婚姻材料队列。
- 后台可按状态、资料、用户和时间筛选待审材料。
- 后台可查看材料凭证并通过或拒绝；真实材料内容通过点击材料凭证弹窗预览，下载由独立权限控制。
- 拒绝原因能回到 C 端账号中心。
- 重新提交后新材料进入待审，旧材料不丢失。
- 汇总状态与材料状态一致，不出现材料已拒绝但汇总仍 pending 的不一致状态。
- 公开资料 `isVerified` 与后端认证规则一致。
- 资料审核通过或拒绝只影响平台审核展示，不会批量修改四类认证状态。
- 审核写入 `cm_audit_logs` 和 `sys_oper_log`。
- Verification 认证审核业务闭环已完成；真实上传、材料预览和材料下载已接入。
- C 端认证材料使用提交时上传，避免用户选择文件后取消提交产生新的私有孤儿文件。

### 11.2.3 Phase 8.2.3：Verification 安全与 Profile 编辑边界补强

Phase 8.2.3 位于 Phase 8.2.2 和 Phase 8.2.4 之间。它不阻塞认证审核闭环完成，只承接认证材料安全治理、后台材料补录、认证重置和 Profile 后台编辑边界，不再扩展成完整认证重构。

- 为认证材料补充病毒/内容扫描。
- 如后续迁移对象存储，可将当前后端流式响应替换为短期签名地址，但仍不能裸露直连敏感材料。
- C 端平台审核状态需要继续从 `profileStatus` 派生，不再使用 `cm_profile_verifications.review_status`。
- C 端不提供替换待审材料能力；同类型存在 `pending` 材料时继续禁止重复提交，被拒绝后再提交新材料。
- 如确有运营协助需求，仅在后台提供受独立权限控制的材料补录能力；补录新增一条 pending 材料，不覆盖历史材料。
- 如已通过认证需要撤销或重新认证，后台使用“重置认证状态”，将该类型汇总状态改回 `unverified`，历史材料和审核记录保留。
- 后台可继续完善 Profile 内部字段、精选和备注；面向 C 端展示的资料字段如需后台编辑，必须进入独立资料编辑能力，不混入审核中心。
- 拒绝原因继续使用快捷文本和备注，不引入结构化 reason code。
- 审核通知等待 Phase 8.5 Cupid Inbox 完成后统一接入，不在 8.2.3 提前实现。

验收口径：

- 认证材料上传、预览和下载仍必须走后端鉴权接口，不得回退为公开 URL。
- 扫描失败、扫描中和扫描通过的状态处理必须明确，不得让未扫描材料直接进入通过流程。
- 后台补录材料必须具备独立权限、补录说明和审计日志；不得允许 C 端替换 pending 材料。
- 重置认证状态必须具备独立权限、重置原因和审计日志；不得删除历史材料。
- 后台编辑面向 C 端展示字段时，必须记录 before/after/operator/reason，并明确是否触发发布审核。
- 通知能力只在 Phase 8.5 之后作为业务消息进入 Cupid Inbox，不复用 RuoYi 后台通知公告。

当前实现状态：

- 已新增认证材料安全检查字段：`scan_status`、`scan_message`、`scanned_at`。
- C 端认证材料上传和后台材料补录都会在保存前做基础文件签名检查，当前支持 PDF/JPG/JPEG/PNG/WEBP。
- 审核通过前要求材料 `scan_status = passed`；未通过安全检查的材料不能被审核通过。
- 后台页面可补录新的待审材料，使用 `cupid:verification:material:create`，并写入 `cm_audit_logs` 与 RuoYi 操作日志。
- 后台页面可重置某个资料的某类认证状态，使用 `cupid:verification:reset`，重置后 C 端可重新提交。
- C 端仍不支持替换 pending 材料；被拒绝后重新提交新材料。
- 当前安全检查是基础签名检查，不等同于完整外部杀毒引擎；如上线需要更强扫描，可在此阶段继续接入外部扫描服务。

### 11.2.4 Phase 8.2.4：后端统一枚举语义

> 最新执行计划见 [cm-phase-8-2-4-enum-plan.md](cm-phase-8-2-4-enum-plan.md)。本节只保留 Phase 8.2.4 的入口，实际执行以专属文档为准。

### 11.3 Phase 8.3：Private Introduction

定位：

- 后台不代表用户确认关系，只处理平台是否受理私人介绍服务。
- `requested` 表示用户已申请、等待平台受理。
- `accepted` 表示平台已受理，服务开始；不是双方确认。
- `declined` 表示平台暂不受理，可按规则进入 cooldown。
- 后续如改为用户确认、staff 确认或自动化受理，可在 `requested -> accepted/declined` 之间扩展，不推翻现有表结构。

页面：

- `src/views/cupid/introduction/index.vue`

API：

- `GET /cupid/introduction/list`
- `GET /cupid/introduction/{id}`
- `POST /cupid/introduction/{id}/accept`
- `POST /cupid/introduction/{id}/decline`
- `POST /cupid/introduction/{id}/note`

要求：

- 可按状态、申请时间、申请人、目标 Profile 和负责人员筛选。
- accept/decline 只允许处理 `requested`，语义为平台受理/暂不受理。
- 使用数据库锁防止重复处理。
- 拒绝时按现有规则设置 cooldown，并记录原因。
- 状态、时间、cooldown、Inbox 通知和审计保持事务一致。
- 后台支持只读观察和内部跟进备注；备注不改变申请状态。
- 后续可接自动化任务：规则检查通过自动受理，异常进入人工处理。

当前实现：

- 已实现后台列表、详情、平台受理、平台暂不受理、内部备注。
- 暂不受理会写入 `declined`、`responded_at`、`cooldown_until`，并退回本次申请预留的私人介绍额度。
- 处理记录和内部备注写入 `cm_audit_logs`，不新增独立备注表。
- 自动化受理暂不实现。

### 11.4 Phase 8.4：Event 与 Registration

#### Domain

建立 `CupidEventRegistration`，不再用 `Map<String, Object>` 承担后台状态实体。

`CupidEventRegistration` 字段（映射 `cm_event_registrations`）：

| Java 字段 | 列 | 说明 |
| --- | --- | --- |
| `id` | `id` | UUID |
| `userId` | `user_id` | 用户ID |
| `eventId` | `event_id` | 活动ID |
| `entitlementBalanceId` | `entitlement_balance_id` | 实际消费的活动权益余额ID |
| `status` | `status` | requested / confirmed / declined / waitlist / cancelled / attended |
| `requestedAt` | `requested_at` | 申请时间 |
| `confirmedAt` | `confirmed_at` | 确认时间 |
| `declinedAt` | `declined_at` | 拒绝时间 |
| `waitlistedAt` | `waitlisted_at` | 候补时间 |
| `cancelledAt` | `cancelled_at` | 取消时间 |
| `attendedAt` | `attended_at` | 参加时间 |
| `eventQuotaConsumedAt` | `event_quota_consumed_at` | 权益扣减时间 |
| `eventQuotaReleasedAt` | `event_quota_released_at` | 权益释放时间 |
| `createdAt` | `created_at` | 创建时间 |
| `updatedAt` | `updated_at` | 更新时间 |

#### 状态机

Event：

```
draft → open → waitlist → closed → completed
        ↘ closed
        ↘ completed

open / waitlist / closed / completed ↔ hidden
```

- Event 状态只使用 `draft`、`open`、`waitlist`、`closed`、`completed`、`hidden`。
- `member` 不是 Event 状态，会员专属来自 `visibility = member`。
- Admin 可以新增活动，并且仅允许编辑 `draft` 活动的内容。
- 新建和编辑时只允许保存为 `draft` 或 `open`；发布为 `open` 前必须补齐全部必填内容。
- 独立状态变更只允许 `draft` 切 `open`，不能绕过发布字段校验。
- `open` 可切 `waitlist`（转入候补）、`closed`（停止报名）或 `completed`（活动结束）。
- `waitlist` 可切 `closed` 或 `completed`。
- `closed` 可切 `open`（重新开放）或 `completed`。
- `open`、`waitlist`、`closed`、`completed` 均可切为 `hidden`，从 C 端公开活动目录下架。
- `hidden` 可由 Admin 手工恢复为 `open`、`waitlist`、`closed` 或 `completed`，不记录隐藏前状态。
- 隐藏不修改已有报名、名额、额度和活动内容；直链详情及“我的活动”保持可用。
- `completed` 不允许恢复为其他生命周期状态，但允许切为 `hidden`。

Registration：

- Admin 可以将任意持久化报名状态纠正为另一个状态，但目标状态不能与当前状态相同。
- `confirmed` 和 `attended` 占用名额；其他状态不占用名额。
- 进入占位状态时检查容量，并按活动规则扣减额度。
- 离开占位状态时返还 `entitlement_balance_id` 指向的原额度记录。
- 所有状态纠正必须填写原因并写入 `cm_audit_logs`。

#### 页面

- `src/views/cupid/event/index.vue`
- `src/views/cupid/event-registration/index.vue`

#### Event 管理页

列表筛选：活动标题、状态、城市、活动日期范围、排序（日期/创建时间）。

列表列：

| 列 | 说明 |
| --- | --- |
| 活动 | 标题 |
| 状态 | `labelOf(eventStatuses, ...)` |
| 可见范围 | `labelOf(eventVisibilityOptions, ...)` |
| 城市 | `optionLabel('profile.city', ...)` |
| 日期 | eventDate |
| 时段 | startTime – endTime |
| 容量 | occupiedCount / capacity（confirmed + attended） |
| 操作 | 详情、编辑、报名管理、状态变更 |

详情抽屉：活动基本信息（标题、状态、可见范围、日期、时间、城市、容量）、活动说明、note items、agenda items 和报名统计。

新增/编辑弹窗：维护标题、可见范围、城市、语言、地址可见性、日期时间、名额、额度规则、封面、说明、场地、地址、形式、人群、关系主题、note items 和 agenda items。只有草稿可再次编辑；保存为报名中时，每条 note/agenda 均必须完整。

状态变更弹窗：选择目标状态并填写必填原因。发布为 `open` 时后端重新校验完整活动内容；变更及完整活动内容快照写入 `cm_audit_logs`。

#### Registration 管理页

列表筛选：活动标题、用户名称/ID、状态、申请时间范围。

列表列：

| 列 | 说明 |
| --- | --- |
| 活动 | 活动标题 |
| 用户 | 账户名称 + userId |
| 状态 | `labelOf(eventRegStatuses, ...)` |
| 申请时间 | requestedAt |
| 处理时间 | confirmedAt / declinedAt / waitlistedAt |
| 操作 | 详情 + 状态纠正按钮 |

详情抽屉：报名信息（活动、用户、状态、时间戳）、用户简要资料。默认不展示联系方式。

状态纠正弹窗：从完整报名状态列表选择目标状态（排除当前状态），并填写必填原因。

#### API

| 模块 | 方法 | 路径 | 权限 | 说明 |
| --- | --- | --- | --- | --- |
| Event | `GET` | `/cupid/event/list` | `cupid:event:list` | 列表，可按 keyword/status/city/dateRange 筛选 |
| Event | `GET` | `/cupid/event/{id}` | `cupid:event:query` | 详情，含多语言字段和报名统计 |
| Event | `POST` | `/cupid/event` | `cupid:event:add` | 新增活动 |
| Event | `PUT` | `/cupid/event/{id}` | `cupid:event:edit` | 编辑草稿活动 |
| Event | `POST` | `/cupid/event/{id}/status` | `cupid:event:changeStatus` | 变更活动状态，body: `{ status, reason }`，reason 必填 |
| Registration | `GET` | `/cupid/eventRegistration/list` | `cupid:eventRegistration:list` | 列表，可按 eventTitle/userKeyword/status/dateRange/sortBy 筛选 |
| Registration | `GET` | `/cupid/eventRegistration/{id}` | `cupid:eventRegistration:query` | 详情，含活动摘要和用户信息 |
| Registration | `POST` | `/cupid/eventRegistration/{id}/review` | `cupid:eventRegistration:review` | 纠正报名状态，body: `{ status, reason }` |

8.4 不新增联系方式查看接口。若后续需要在报名详情查看用户联系方式，必须单独增加权限字符，例如 `cupid:eventRegistration:contact`。

#### 通用选项

- `event.status` 必须包含 `draft`、`open`、`waitlist`、`closed`、`completed`、`hidden`。
- 新增 `event.visibility`，包含 `public`、`registered`、`member`。
- `event.registrationStatus` 使用 `requested`、`confirmed`、`waitlist`、`declined`、`cancelled`、`attended`。
- Admin 前端不得维护本地状态文案，全部通过 common options 渲染。

#### 业务规则

**报名状态纠正**：

1. 按 Event、Registration 顺序执行 `SELECT ... FOR UPDATE`。
2. 目标为 `confirmed` 或 `attended` 且当前不占位时，检查 `occupiedCount < capacity`。
3. 活动需要额度且进入占位状态时，锁定并扣减当前有效的活动权益余额，同时记录 `entitlement_balance_id`。
4. 离开占位状态时，按 `entitlement_balance_id` 返还原额度记录，不按当前会员周期猜测。
5. 写入目标状态的时间戳，同时保留此前已经发生过的生命周期时间戳。
6. 写入包含纠正原因、前后快照的 `cm_audit_logs`。

**禁止超卖**：所有容量检查必须在同一事务内、`FOR UPDATE` 锁保护下完成。容量统计口径统一为 `confirmed + attended` 占用名额，`waitlist` 不占用名额。

**Event 状态变更**：

- 只允许按本节状态机变更状态。
- `draft` 发布为 `open` 时必须再次执行完整字段校验。
- `closed` 不影响已确认的报名。
- `completed` 不允许直接切回 `open`、`waitlist` 或 `closed`，但可因下架切为 `hidden`。
- `hidden` 仅控制公开目录展示，不改变 Registration 和权益数据。
- 所有状态变更必须填写原因并写入 `cm_audit_logs`。

#### 权限字符

- `cupid:event:list` / `cupid:event:query` / `cupid:event:add` / `cupid:event:edit` / `cupid:event:changeStatus`
- `cupid:eventRegistration:list` / `cupid:eventRegistration:query` / `cupid:eventRegistration:review`
- `cupid:eventRegistration:contact`：8.4 预留，不实现；后续若需要查看联系方式再启用。

角色授权：`cupid_event_manager` 拥有全部 event 和 registration 权限；`cupid_admin` 默认全有。

### 11.5 Phase 8.5：Inbox 通知

#### 终态定义

Phase 8.5 将 Cupid Inbox 的“站内通知”能力推进到终态，不宣告未来受控沟通能力完成：

- 后台不提供“查看全部 C 端线程和消息”的能力。
- 后台只提供模板管理、预览、单用户通知和群发通知。
- 人工单发和群发统一显示为“平台管理员”，写入 `category = system` 线程，C 端不可回复。
- 自动业务通知显示为“系统通知”，同样写入 `system` 线程。
- 继续复用现有 `cm_inbox_threads`、`cm_inbox_messages`、`cm_inbox_reads` 和 `/api/inbox/**`。
- 现有 C 端仅允许向 `chat + open` 线程发送文本，因此无需新增禁止回复分支；8.5 不创建后台 chat 线程。
- 保留现有 `POST /api/inbox/threads/{id}/messages`、`ICupidInboxService.sendMessage` 和 `chat` category，作为未来受控沟通预留；8.5 不删除、不扩展，也不在 C 端 API/hook/page 接入。
- 不复用 `sys_notice`、`sys_notice_read`，不将 `cm_users` 写入 `sys_user`。

Phase 8.5 分为：

1. 8.5.1：通知模板与模板管理。
2. 8.5.2：单用户预览和发送。
3. 8.5.3：简易群发。
4. 8.5.4：业务状态自动通知。
5. 8.5.5：完整验收。

#### 8.5.1：模板结构与管理

新增 `cm_inbox_templates`：

| 字段 | 说明 |
| --- | --- |
| `id` | UUID |
| `template_code` | 稳定 code，唯一；创建后不可修改 |
| `message_type` | `text / system_notice / status_update / action_prompt` |
| `subject_type` | 可空；限定模板对应业务对象 |
| `action_type` | 可空；由模板定义，发送请求不能覆盖 |
| `status` | `enabled / disabled` |
| `created_at / updated_at` | 时间戳 |

新增 `cm_inbox_template_localized_fields`：

| 字段 | 说明 |
| --- | --- |
| `id` | UUID |
| `template_id` | 模板 ID |
| `locale` | `zh / fr / en` |
| `name` | 后台展示名称 |
| `body` | 纯文本模板正文 |
| `created_at / updated_at` | 时间戳 |

约束：

- `uk_cm_inbox_template_code(template_code)`。
- `uk_cm_inbox_template_locale(template_id, locale)`。
- 模板正文使用受控 `{{variableName}}`；禁止执行 SpEL、FreeMarker 或任意表达式。
- Java 集中声明每个 template code 允许的变量；未知、缺失或未替换变量均拒绝保存预览或发送。
- `cm_inbox_messages` 增加可空 `dedupe_key varchar(160)` 和唯一索引；自动通知和群发使用，普通单发可为空。
- 同步更新 `cm_schema.sql`、`cm_seed.sql`，并提供现有数据库可手工执行的 Phase 8.5 增量 SQL。

初始模板至少包含：

- `welcome_message`
- `profile_review_approved / profile_review_rejected`
- `photo_review_approved / photo_review_rejected`
- `verification_approved / verification_rejected`
- `event_registration_status_changed`
- `private_introduction_status_changed`

模板管理页面：`src/views/cupid/inbox-template/index.vue`

- 列表展示 code、message type、subject type、三语完整度、状态和更新时间。
- 支持新增模板、编辑三语 name/body、启用和停用。
- 编辑时不可修改 template code。
- message type、subject type、action type 使用后端 common options。
- 保存前校验三语正文、占位符和允许变量。
- 已被历史消息使用的模板允许停用，不允许删除；8.5 不提供模板删除接口。

模板 API：

| 方法 | 路径 | 权限 |
| --- | --- | --- |
| `GET` | `/cupid/inboxTemplate/list` | `cupid:inboxTemplate:list` |
| `GET` | `/cupid/inboxTemplate/{id}` | `cupid:inboxTemplate:query` |
| `POST` | `/cupid/inboxTemplate` | `cupid:inboxTemplate:add` |
| `PUT` | `/cupid/inboxTemplate/{id}` | `cupid:inboxTemplate:edit` |
| `POST` | `/cupid/inboxTemplate/{id}/status` | `cupid:inboxTemplate:changeStatus` |

Common Options 增加并递增静态版本：

- `inbox.messageType`
- `inbox.templateStatus`
- `inbox.senderType`
- `inbox.category`
- `inbox.threadStatus`

`message.subjectType` 继续复用。Admin 不保留本地 label 兼容。

#### 8.5.2：单用户通知

页面：`src/views/cupid/inbox/index.vue`

该页面是“通知发布”工作台，不展示线程列表或历史消息。包含：

- 目标用户搜索与选择。
- 模板/自定义正文模式。
- 语言选择；默认目标用户 `preferred_locale`。
- subject type 和 subject 搜索。
- 预览区。
- 确认发送。

API：

| 方法 | 路径 | 权限 | 说明 |
| --- | --- | --- | --- |
| `GET` | `/cupid/inbox/templates` | `cupid:inbox:preview` | 已启用模板 |
| `POST` | `/cupid/inbox/preview` | `cupid:inbox:preview` | 只渲染，不写库 |
| `POST` | `/cupid/inbox/notify` | `cupid:inbox:send` | 单用户发送 |

规则：

- userId 必须存在于 `cm_users`。
- 模板必须 enabled；locale 只接受 `zh/fr/en`。
- subject 必须与目标用户存在真实业务关联，避免泄露其他用户资料、活动报名、介绍或会员信息。
- 模板定义 message type、subject type 和 action type，前端不能覆盖。
- 自定义正文 trim 后 1–4000 字，不允许 action payload。
- 预览结果不能直接作为发送正文；发送事务必须重新加载模板和渲染。
- 人工模板和自定义通知均写 `sender_type = staff`，`sender_user_id = 当前 sys_user.user_id`；C 端统一显示“平台管理员”。
- 线程始终为 `category = system`，所以 C 端不能回复。
- 人工单发属于工作人员联系，目标用户 `staff_contact_enabled = false` 时拒绝发送；业务必达的自动通知不走人工单发接口。
- 有 subject 时复用同一用户、同一 subject 的 open system 线程；无 subject 时复用该用户的通用 open system 线程。
- 插入消息、touch thread 和写 `cm_audit_logs` 在同一事务完成。
- C 端消息展示根据 sender type 显示三语“平台管理员/系统通知”标签；不暴露真实 sys_user 用户名或 ID，不给 system 线程渲染回复输入框。

#### 8.5.3：简易群发

不新增 broadcast/broadcast_recipient 表，不实现批次历史和失败恢复。

支持接收范围：

- 全部有效 C 端用户。
- 指定会员等级。
- 手工选择多个用户。

API：

| 方法 | 路径 | 权限 | 说明 |
| --- | --- | --- | --- |
| `POST` | `/cupid/inbox/broadcast/preview` | `cupid:inbox:broadcast` | 返回预计人数、少量用户样例和最终文案 |
| `POST` | `/cupid/inbox/broadcast` | `cupid:inbox:broadcast` | 分批群发 |

规则：

- 前端只能提交固定 scope 和参数，不能提交 SQL、字段名或表达式。
- HTTP 请求内按固定批大小处理，例如每批 100 人；每个用户使用独立事务，单个失败不回滚其他用户。
- 每用户写入必须调用独立 Bean 的 `REQUIRES_NEW` 方法，不能在同类循环中依赖 self-invocation。
- 每个用户复用自己的通用 system 线程，写入独立消息，不共享 thread/message。
- 群发生成 `broadcastId`；每条消息使用 `broadcast:{broadcastId}:{userId}` 作为 dedupe key。
- sender type 为 staff，C 端显示“平台管理员”，用户不可回复。
- 模板群发按每个用户 preferred locale 分别渲染；自定义正文使用发送者选择的单一语言。
- 普通公告尊重 `service_announcements_enabled`；业务必达通知不通过群发接口发送。
- 响应返回 broadcastId、目标数、成功数、失败数和最多 20 条失败摘要。
- `cm_audit_logs` 记录 scope、模板、语言、目标数、成功数和失败数，不记录完整用户 ID 数组。
- 不支持失败重试；再次群发必须创建新的 broadcastId 并重新确认。

#### 8.5.4：业务自动通知

接入：

- 资料审核通过/拒绝。
- 照片审核通过/拒绝。
- 身份、学历、收入、婚姻认证通过/拒绝。
- Event Registration 状态纠正。
- 私人介绍受理/暂不受理。

规则：

- 业务 Service 发布结构化领域事件，不拼模板正文、不直接操作 Inbox Mapper。
- 使用 `@TransactionalEventListener(AFTER_COMMIT)`，监听器调用独立 Bean 上 `REQUIRES_NEW` 的通知方法。
- 通知失败只记录错误日志，不回滚核心业务。
- 自动消息使用 `sender_type = system`，并提供稳定 dedupe key。
- family profile 根据 active ownership 找到接收用户。
- 拒绝原因可以作为模板变量，但内部备注不得发送。
- 自动消息也写入 system 线程，C 端不可回复。
- 不在 8.5 实现 Event Reminder、会员到期调度、失败重试队列或外部推送。

后端职责：

- `CupidInboxServiceImpl`：保持现有 C 端读取、已读和 chat 用户消息能力。
- `CupidInboxNotificationService`：模板渲染、subject 校验、线程复用和消息写入。
- `CupidAdminInboxServiceImpl`：单发、群发和预览。
- `CupidInboxTemplateServiceImpl`：模板 CRUD 和占位符校验。
- `CupidInboxAdminController`、`CupidInboxTemplateAdminController`：权限和请求边界。
- 业务 Service、Controller 不得复制通知 SQL。

#### 菜单与权限

“用户服务”下新增：

- “通知发布”：`cupid/inbox/index`，菜单权限 `cupid:inbox:send`。
- “通知模板”：`cupid/inbox-template/index`，菜单权限 `cupid:inboxTemplate:list`。

功能权限：

- `cupid:inbox:preview`
- `cupid:inbox:send`
- `cupid:inbox:broadcast`
- `cupid:inboxTemplate:list/query/add/edit/changeStatus`

角色：

- `cupid_admin`：全部权限。
- `cupid_support`：preview/send，可单发；默认无 broadcast 和模板编辑权限。
- `cupid_auditor`：不进入 Inbox 后台；发送历史通过 Phase 8.7 业务审计查看。

菜单和授权写入 `cm_seed.sql` 与 Phase 8.5 增量 SQL，不修改 RuoYi 原始 SQL。

#### 8.5.5：验收

1. 后台不存在查看全部 C 端线程或历史消息的页面/API。
2. 模板可新增、编辑三语文案、启停；code 不可修改且不能删除。
3. 模板未知变量、缺失变量、非法 message/subject/action 类型均被拒绝。
4. preview 不写数据库，send 必须重新渲染。
5. 单发和群发写入 staff 消息，保存真实 sys_user ID，C 端显示“平台管理员”且不能回复。
6. 自动业务通知写入 system 消息，失败不回滚业务。
7. 全部用户、会员等级、手工用户三种群发范围正确，禁用公告用户被排除。
8. 群发每位用户具有独立消息，失败不影响其他用户，响应统计准确。
9. dedupe key 阻止自动通知和同一 broadcastId 重复写入。
10. C 端线程、消息、未读、已读和游标分页保持正常。
11. 人工单发、群发、模板变更和自动通知均写入 `cm_audit_logs`。
12. `sys_notice`、`sys_notice_read` 和 `sys_user` 没有 Cupid 兼容分支。
13. Maven package、Admin build、C 端 type-check/check:i18n、XML 解析和 diff check 全部通过。

#### 明确不做

- 不查看全部 C 端线程和消息。
- 不创建后台 chat，不允许 C 端回复管理员通知。
- 不实现未来受控沟通；保留现有 chat 发送后端预留，但不创建 chat 线程或开放发送入口。
- 不编辑、撤回或删除历史消息。
- 不建立群发批次表，不做批次历史、失败恢复或定时群发。
- 不做复杂用户画像、营销编排、短信、邮件、WebSocket 或 Push。
- 不开放任意 action payload。

### 11.6 Phase 8.6：App User 管理

页面：

- `src/views/cupid/user/index.vue`

API：

- `GET /cupid/user/list`
- `GET /cupid/user/{id}`
- `POST /cupid/user/{id}/status`
- `GET /cupid/user/{id}/sessions`
- `DELETE /cupid/user/{id}/sessions/{sessionId}`
- `DELETE /cupid/user/{id}/sessions`

要求：

- 详情聚合身份、会员、Profile 和近期活动摘要。
- 只提供明确的停用和恢复动作。
- 停用时注销该用户全部 Cupid Redis 会话。
- 会话页面读取 `cupid:session:*` 和 `cupid:user-sessions:*` 对应的结构化会话信息。
- 单会话强退和全部会话强退必须通过 `CupidTokenService` 完成，不能由 Controller 直接删除 Redis key。
- 单会话强退前必须验证目标 session 属于 URL 中的用户，不能仅凭任意 session ID 删除会话。
- 原“在线用户”页面继续只扫描 `login_tokens:*` 和 `LoginUser`，不加入 Cupid 兼容分支。
- 当前 `CupidLoginUser` 只包含会话、身份、用户和时间信息；只有页面确认需要 IP、设备或 User-Agent 时才扩展模型。
- 不修改 `sys_user` 代替 `cm_users`。
- 不提供通用删除按钮。
- 敏感身份信息按权限分级返回。

### 11.7 Phase 8.7：Staff Task 与 Audit

页面：

- `src/views/cupid/staff-task/index.vue`
- `src/views/cupid/audit/index.vue`

API：

- Staff Task 使用明确的任务新增、分配、状态和优先级接口。
- Audit 使用 `GET /cupid/audit/list`、`GET /cupid/audit/{id}`。

要求：

- 建立 `CupidStaffTask` 和 `CupidAuditLog`。
- assignee 必须是有效的 RuoYi `sys_user`。
- Task 失败不能回滚已经完成的核心业务动作。
- Audit 列表和详情只读。
- before/after JSON 使用结构化展示，不允许后台修改。
- `sys_oper_log` 用于查询后台接口调用，`cm_audit_logs` 用于查询 Cupid 业务状态变化，两者不合并。

### 11.8 阶段八后与生产化任务

以下能力不阻塞阶段八后台交付，进入生产化阶段后按实际需求实施：

- C 端登录成功、登录失败、密码重置、身份解绑和异常设备等安全事件日志。
- Cupid Redis key 数量、会话数量和验证码数量的专用只读监控。
- 翻译失败补偿、过期业务数据清理等 Quartz 定时任务。
- 将经过验证、确实需要热更新的运营参数接入 `sys_config`。
- 更完整的会话设备识别、IP、User-Agent 和异常登录检测。
- 收紧或移除生产环境“清空全部缓存”等高风险运维能力。

这些任务不得通过修改 RuoYi 原生用户模型来缩短实现路径。

## 12. 每个子阶段的执行顺序

开始前：

1. 阅读本文对应章节。
2. 检查现有 Domain、Service、Mapper 和 XML 是否可复用。
3. 对照 Mock 理解业务行为，但以 final contract 和已确认规则为准。
4. 确认状态流转、权限字符、审计 action code 和事务边界。
5. 决定生成器仅生成哪些骨架。

实施顺序：

1. 补充必要 Domain 与 Mapper。
2. 实现 Service 业务动作和事务。
3. 实现 Controller、权限和日志。
4. 新增前端 API 与类型。
5. 新增真实 Vue 页面。
6. 页面文件存在后再加入对应 `C/F` 菜单 SQL。
7. 更新角色授权。
8. 执行编译、构建和真实接口验证。

提交前：

1. 后端编译通过。
2. `cupid-match-admin` TypeScript 检查和生产构建通过。
3. 使用真实 RuoYi 登录态验证接口。
4. 验证无权限、停用账号、非法状态和重复操作。
5. 验证数据库事务、并发保护、审计和通知。
6. 验证菜单路由、刷新、标签页和 keep-alive。
7. 验证生成器没有留下绕过状态机的通用 CRUD。
8. 同步本文和 `doc/cm-api-status.md` 的完成状态。

## 13. 人工验收矩阵

### 13.1 动态路由

- 登录后 `/getRouters` 返回当前角色拥有的 Cupid `M/C` 菜单。
- 返回的 `component` 都能在 `src/views` 中找到精确文件。
- 普通运营角色无法通过直接输入 URL 访问未授权动态页面。
- `visible=1` 的隐藏页面不显示在侧边栏，但有权限时可访问。
- `status=1` 的菜单不会下发，也不能访问。
- 修改菜单或角色后重新登录可以看到变化。

### 13.2 按钮与接口权限

- 没有 `F` 权限时按钮不显示。
- 即使手工发请求，没有对应权限也会返回无权限。
- `C` 页面权限、`F` 按钮权限与 Controller 注解完全一致。
- `cupid_auditor` 只能查看审计，不能执行任何修改动作。

### 13.3 账号隔离

- RuoYi 后台账号只存在于 `sys_user`。
- App 用户只存在于 `cm_users`。
- 停用后台账号不影响 App 用户。
- 停用 App 用户不修改 RuoYi 后台账号。
- 原通知公告、在线用户和登录日志只识别 RuoYi 后台账号。

### 13.4 业务安全

- 非法状态不能流转。
- 重复审核不会产生第二次副作用。
- Registration 并发确认不会超卖。
- 权益不会重复扣减或重复返还。
- User 停用后旧 Cupid token 失效。
- 单个 Cupid 会话可强退且不影响该用户其他会话。
- 全部会话强退后该用户所有旧 token 均失效。
- 会话操作通过 `CupidTokenService` 完成。
- 核心动作均有操作日志和业务审计。

## 14. 阶段八完成标准

必须同时满足：

- 正式后台不依赖 `/api/debug/*`。
- 首页、品牌和导航完成 Cupid Match 化。
- 业务页面使用 RuoYi 动态菜单加载。
- 菜单、按钮与 Controller 权限一致。
- 普通 Cupid 角色与系统管理权限隔离。
- Profile、Photo、Introduction、Event Registration 状态机通过验收；Verification 认证审核闭环按 Phase 8.2.2 独立验收。
- Event Registration 不超卖且不重复扣减权益。
- Inbox 通知不能伪造用户聊天。
- C 端通知不依赖 `sys_notice` 和 `sys_notice_read`。
- User 停用会注销全部 Cupid 会话。
- App User 页面可以查询和受控强退 Cupid 会话，原在线用户页面仍只管理后台登录。
- Staff Task 使用 RuoYi 用户作为 assignee。
- Audit Log 只读且记录关键业务动作。
- RuoYi 字典和参数仅在真实调用点接入，没有取代业务常量、状态机或基础设施配置。
- `cupid-match-admin` 构建通过。
- 阶段一至阶段七的前台接口未被破坏。

## 15. 当前执行入口

Phase 8.2 已完成 Profile 与 Photo 审核的代码、菜单、列表、详情、页面挂载和写操作验收。
Phase 8.2.1 已完成资料库与资料运营的拆分、内部字段展示和精选/备注运营。
Phase 8.2.2 已完成 Verification 认证审核业务闭环，并已接入真实文件上传、鉴权预览和鉴权下载；拒绝原因继续使用快捷文本和备注，不规划结构化 reason code。
Phase 8.2.3 已完成认证材料安全、后台补录材料、认证重置和 Profile 后台编辑边界补强。
Phase 8.2.4 最新计划已迁移到 [cm-phase-8-2-4-enum-plan.md](cm-phase-8-2-4-enum-plan.md)。执行顺序调整为：先做可写字段枚举边界与数据库评估，再按 API 分区把前端枚举翻译前移到后端，最后评估枚举值动态管理。

已确认：

1. 资料审核和照片审核可执行通过或拒绝。
2. 审核写操作会写入 `cm_audit_logs`，同时被 RuoYi `sys_oper_log` 记录。
3. 重复审核会被阻止，并提示已处理。
4. Verification 已按身份、学历、收入、婚姻拆分为四个材料审核队列。
5. `cupid_auditor` 只读权限作为角色矩阵复验项保留，不阻塞 Phase 8.2 完成。
6. Phase 8.2.4 完成后，再进入 Phase 8.3：Private Introduction。
