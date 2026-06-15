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
| Verification 审核 | 审核中心 | `verification` | `cupid/verification/index` | `cupid:verification:list` |
| 私人介绍处理 | 关系服务 | `introduction` | `cupid/introduction/index` | `cupid:introduction:list` |
| 活动管理 | 活动运营 | `event` | `cupid/event/index` | `cupid:event:list` |
| 报名审核 | 活动运营 | `registration` | `cupid/event-registration/index` | `cupid:eventRegistration:list` |
| App 用户管理 | 用户服务 | `user` | `cupid/user/index` | `cupid:user:list` |
| 系统通知 | 用户服务 | `inbox` | `cupid/inbox/index` | `cupid:inbox:list` |
| Staff Task | 运营协作 | `task` | `cupid/staff-task/index` | `cupid:staffTask:list` |
| 业务审计 | 运营协作 | `audit` | `cupid/audit/index` | `cupid:audit:list` |

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
- `CupidVerification`
- `CupidIntroduction`
- `CupidEvent`
- `CupidEventRegistration`
- `CupidUser`
- `CupidInbox`
- `CupidStaffTask`
- `CupidAudit`

### 6.3 按钮权限

| 页面 | 权限 |
| --- | --- |
| Profile | `cupid:profile:query`、`cupid:profile:review` |
| Photo | `cupid:photo:query`、`cupid:photo:review` |
| Verification | `cupid:verification:query`、`cupid:verification:review` |
| Introduction | `cupid:introduction:query`、`cupid:introduction:accept`、`cupid:introduction:decline` |
| Event | `cupid:event:query`、`cupid:event:edit`、`cupid:event:changeStatus` |
| Event Registration | `cupid:eventRegistration:query`、`cupid:eventRegistration:review` |
| User | `cupid:user:query`、`cupid:user:changeStatus` |
| Inbox | `cupid:inbox:query`、`cupid:inbox:notify` |
| Staff Task | `cupid:staffTask:query`、`cupid:staffTask:add`、`cupid:staffTask:edit` |
| Audit | `cupid:audit:query` |

规则：

- 每个动作权限建立 `F` 菜单并挂在对应 `C` 菜单下。
- 前端按钮使用相同权限执行 `v-hasPermi`。
- Controller 使用完全一致的 `@PreAuthorize` 字符串。
- 页面权限和接口权限必须同时存在，不能只实现其中一层。
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
| `cupid_support` | App User、Inbox 和 Staff Task |
| `cupid_auditor` | 业务审计只读 |

不创建含义重叠的 `cupid_operator`。新增角色前必须先证明现有角色无法准确表达职责。

### 7.2 默认授权

| 角色 | 首页 | 审核中心 | 关系服务 | 活动运营 | 用户服务 | 运营协作 |
| --- | --- | --- | --- | --- | --- | --- |
| `cupid_admin` | 固定路由 | 全部 | 全部 | 全部 | 全部 | 全部 |
| `cupid_reviewer` | 固定路由 | 全部 | 全部 | 否 | 否 | 否 |
| `cupid_event_manager` | 固定路由 | 否 | 否 | 全部 | 否 | 否 |
| `cupid_support` | 固定路由 | 否 | 否 | 否 | 全部 | Staff Task |
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

- `cm_profile_internal_records`：后台开始管理 featured、source 或内部字段时建立。
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

### 11.2 Phase 8.2：Profile、Photo、Verification 审核

页面：

- `src/views/cupid/profile/index.vue`
- `src/views/cupid/photo/index.vue`
- `src/views/cupid/verification/index.vue`

API：

| 模块 | 接口 |
| --- | --- |
| Profile | `GET /cupid/profile/list`、`GET /cupid/profile/{id}`、`POST /cupid/profile/{id}/review` |
| Photo | `GET /cupid/photo/list`、`GET /cupid/photo/{id}`、`POST /cupid/photo/{id}/review` |
| Verification | `GET /cupid/verification/list`、`GET /cupid/verification/{profileId}`、`POST /cupid/verification/{profileId}/review` |

要求：

- 列表支持审核状态、用户、时间等必要筛选。
- Photo 页面提供真实图片预览。
- Verification 页面按字段展示材料和状态。
- 审核请求显式包含目标状态与 reason。
- Profile、Photo、Verification 联动处于同一事务。
- 写入审核人、审核时间和业务审计。
- 后台审核写操作同时使用 RuoYi `@Log`。
- 页面确实需要可维护的展示枚举时才新增 `cupid_*` 字典，状态机值仍由 Java 和数据库约束。
- 同步加入对应 `M/C/F` 菜单和角色授权。

### 11.3 Phase 8.3：Private Introduction

页面：

- `src/views/cupid/introduction/index.vue`

API：

- `GET /cupid/introduction/list`
- `GET /cupid/introduction/{id}`
- `POST /cupid/introduction/{id}/accept`
- `POST /cupid/introduction/{id}/decline`

要求：

- 可按状态、申请时间、申请人和目标 Profile 筛选。
- 只允许处理 `requested`。
- 使用数据库锁防止重复处理。
- 拒绝时按现有规则设置 cooldown。
- 状态、时间、cooldown、Inbox 通知和审计保持事务一致。

### 11.4 Phase 8.4：Event 与 Registration

页面：

- `src/views/cupid/event/index.vue`
- `src/views/cupid/event-registration/index.vue`

API：

| 模块 | 接口 |
| --- | --- |
| Event | `GET /cupid/event/list`、`GET /cupid/event/{id}`、`POST /cupid/event/{id}/status` |
| Registration | `GET /cupid/eventRegistration/list`、`GET /cupid/eventRegistration/{id}`、`POST /cupid/eventRegistration/{id}/review` |

要求：

- 建立 `CupidEventRegistration`，不再用 `Map<String, Object>` 承担后台状态实体。
- Registration 可处理 `confirmed`、`waitlist` 和 `declined`。
- 确认时锁定 Event 与 Registration。
- 同一事务内检查容量并原子扣减活动权益。
- 余额不足或容量不足时整体失败。
- 禁止超卖和重复扣减。
- 状态回滚按现有规则返还权益。

### 11.5 Phase 8.5：Inbox 通知

页面：

- `src/views/cupid/inbox/index.vue`

API：

- `GET /cupid/inbox/list`
- `GET /cupid/inbox/{threadId}`
- `POST /cupid/inbox/notify`

要求：

- 建立 `CupidInboxThread` 和 `CupidInboxMessage`。
- 不修改或复用 `sys_notice`、`sys_notice_read` 承载 C 端通知。
- RuoYi“通知公告”继续只面向 `sys_user` 后台员工。
- 支持查询系统通知线程、模板、语言和目标用户。
- 提供发送前预览。
- 不允许伪造用户聊天消息。
- 模板 code、locale、用户和消息类型必须校验。
- 自定义正文权限与模板发送权限需要分开时，再增加更细权限，不提前拆分。

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
- Profile、Photo、Verification、Introduction、Event Registration 状态机通过验收。
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

Phase 8.1 已完成。下一任务是 Phase 8.2，严格按以下顺序执行：

1. 审计现有 Profile、Photo、Verification Domain、Mapper、Service 和数据库字段。
2. 明确审核状态流转、权限字符、审计 action code 和事务边界。
3. 仅为真实后台查询和审核动作补充接口，不复用 C 端接口执行后台操作。
4. 实现 `src/views/cupid/profile/`、`photo/`、`verification/` 及对应 `src/api/cupid/` 文件。
5. 页面真实存在后，再向 `sql/cm_admin_menu.sql` 追加审核中心的 `M/C/F` 菜单和角色授权。
6. 完成构建、权限、状态机、审计和重复操作验收。
