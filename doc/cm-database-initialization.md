# Cupid Match 数据库初始化与增量脚本

## 1. 文档定位

本文记录 RuoYi、Quartz、Cupid 业务表和 Cupid 后台配置脚本的职责、执行顺序与环境限制。

数据库结构设计仍以 `doc/cm-schema-structure-notes.md` 和 `sql/cm_schema.sql` 为准；Phase 8 后台菜单与权限以 `doc/cm-admin-implementation-plan.md` 和 `sql/cm_admin_menu.sql` 为准。

## 2. SQL 文件职责

| 文件 | 来源 | 职责 | 是否可修改 |
| --- | --- | --- | --- |
| `sql/ry_20260417.sql` | RuoYi 原始脚本 | 创建并初始化 `sys_*`、生成器等 RuoYi 表 | 保持原样 |
| `sql/quartz.sql` | RuoYi 原始脚本 | 创建 Quartz 调度表 | 保持原样 |
| `sql/cm_schema.sql` | Cupid 项目 | 删除并重建全部 `cm_*` 业务表 | 按业务 schema 维护 |
| `sql/cm_seed.sql` | Cupid 项目 | 注入开发和测试样例数据 | 由 seed 脚本生成 |
| `sql/cm_admin_menu.sql` | Cupid 项目 | 清理 RuoYi 演示数据，维护 Cupid 后台角色、菜单和权限 | 按 Phase 8 增量维护 |

不复制并修改 `ry_20260417.sql` 或 `quartz.sql`。上游基线由原文件和 Git 历史保留，Cupid 差异全部写入项目自有增量脚本。

## 3. 完整开发环境重建

完整重建会删除 RuoYi、Quartz 和 Cupid 的现有表及数据，只能用于本地开发、测试环境或明确允许清空的数据库。

在目标数据库依次执行：

```text
1. sql/ry_20260417.sql
2. sql/quartz.sql
3. sql/cm_schema.sql
4. sql/cm_seed.sql
5. sql/cm_admin_menu.sql
```

说明：

- 第 1 步创建 RuoYi 后台账号、角色、菜单、字典、参数和演示数据。
- 第 2 步创建 Quartz 表。
- 第 3 步创建 Cupid 业务表。
- 第 4 步注入 Cupid 样例数据。
- 第 5 步清理 RuoYi 演示入口并建立 Cupid 后台角色、菜单和权限。
- 第 5 步完成后需要重新登录后台，使前端重新拉取角色、权限和动态路由。

## 4. 仅重建 Cupid 业务数据

当 `cm_schema.sql`、mock 样例数据或 UUID 映射规则变化时，先重新生成 seed：

```powershell
node .\scripts\generate-cm-seed.js
```

然后依次执行：

```text
1. sql/cm_schema.sql
2. sql/cm_seed.sql
```

该流程不会修改 RuoYi 系统表、Quartz 表或后台菜单。

`cm_schema.sql` 包含 `drop table if exists`，不得在已有正式业务数据的环境直接执行。

## 5. 仅更新后台角色、菜单和权限

只执行：

```text
sql/cm_admin_menu.sql
```

当前脚本负责：

- 删除“若依官网”的角色关联和菜单。
- 删除 RuoYi 原始三条演示公告及其已读记录。
- 按 `role_key` 幂等创建 Cupid 后台角色。
- 随 Phase 8 实现逐步维护 Cupid `M/C/F` 菜单和角色菜单关系。

规则：

- 业务页面文件不存在时，不创建对应 `C` 菜单。
- 新增页面时同时提交 Vue 页面、后端权限、`C/F` 菜单和角色授权。
- `role_id` 使用数据库自增值；脚本通过 `role_key` 查询角色，不硬编码角色主键。
- Cupid 菜单使用 `2000-2199` 预留区间，执行前检查是否有冲突。
- 清理菜单时先删除 `sys_role_menu` 关联，再删除 `sys_menu`。
- 不覆盖管理员对既有 Cupid 角色名称、状态、数据范围或用户角色关系的人工调整。

## 6. 执行前检查

首次在现有数据库执行 `cm_admin_menu.sql` 前，备份以下 RuoYi 表：

```text
sys_role
sys_user_role
sys_menu
sys_role_menu
sys_notice
sys_notice_read
```

备份用于恢复现有后台授权和公告数据，不通过复制并长期维护另一份 RuoYi 初始化 SQL 代替数据库备份。

执行完整重建或后台增量脚本前检查：

```sql
select database();
select @@character_set_database, @@collation_database;
select max(menu_id) from sys_menu;
select menu_id, menu_name, path, perms
from sys_menu
where menu_id between 2000 and 2199
   or perms like 'cupid:%';
select role_id, role_name, role_key, status, del_flag
from sys_role
where role_key like 'cupid_%';
```

如果 `2000-2199` 已被非 Cupid 菜单占用，先调整 `doc/cm-admin-implementation-plan.md` 与 `cm_admin_menu.sql` 的预留区间，不能直接覆盖。

## 7. 环境限制

| 操作 | 本地开发 | 测试环境 | 生产环境 |
| --- | --- | --- | --- |
| 完整执行五个 SQL | 允许 | 仅允许明确重建时执行 | 禁止 |
| 执行 `cm_schema.sql` | 允许清空时执行 | 仅允许明确重建时执行 | 禁止 |
| 执行 `cm_seed.sql` | 允许 | 按测试需要 | 禁止 |
| 执行 `cm_admin_menu.sql` | 允许 | 允许，执行前备份 | 当前重构期不直接执行 |

生产环境进入正式部署前，必须改用版本化数据库迁移，而不是依靠全量初始化脚本更新已有数据库。

## 8. Phase 8 SQL 维护规则

每个 Phase 完成页面和接口时，同步更新 `cm_admin_menu.sql`：

1. 页面真实存在后创建对应 `M/C` 菜单。
2. Controller 权限确定后创建对应 `F` 权限。
3. `C/F.perms` 与 `@PreAuthorize`、`v-hasPermi` 完全一致。
4. 通过 `role_key` 建立默认角色授权。
5. 重新执行脚本并重新登录后台。
6. 验证 `/getRouters`、侧边栏、直接 URL 和无权限请求。

不要把 Phase 8 菜单重新写回 RuoYi 原始 SQL。
