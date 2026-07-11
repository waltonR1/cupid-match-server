# Cupid Match 数据库初始化说明

本文说明当前仓库内 SQL 文件的用途、执行顺序和环境限制。

## SQL 文件职责

| 文件 | 来源 | 用途 |
| --- | --- | --- |
| `sql/ry_20260417.sql` | RuoYi 原始脚本 | 创建并初始化 RuoYi `sys_*`、代码生成器等基础表。 |
| `sql/quartz.sql` | RuoYi 原始脚本 | 创建 Quartz 调度表。 |
| `sql/cm_schema.sql` | Cupid Match | 重建 Cupid Match `cm_*` 业务表。 |
| `sql/cm_seed.sql` | Cupid Match | 注入 Cupid Match 初始菜单、字典、业务样例、套餐、定时任务等数据。 |

数据库结构以 `sql/cm_schema.sql` 为准；当前业务结构说明可参考 `doc/cm-schema-structure-notes.md`。

## 本地完整重建

完整重建会清空已有 RuoYi、Quartz 和 Cupid Match 业务数据，只能用于本地开发库或明确允许重建的测试库。

按顺序执行：

```text
1. sql/ry_20260417.sql
2. sql/quartz.sql
3. sql/cm_schema.sql
4. sql/cm_seed.sql
```

执行后重新启动后端，并重新登录后台，让菜单、权限和动态路由刷新。

## 仅重建 Cupid Match 业务表

仅在本地开发库中执行：

```text
1. sql/cm_schema.sql
2. sql/cm_seed.sql
```

注意：`cm_schema.sql` 包含 `drop table if exists`，不要在已有正式业务数据的环境直接执行。

## 仅更新初始数据

如果只调整菜单、字典、套餐价格映射、定时任务或测试样例，可以只执行：

```text
sql/cm_seed.sql
```

执行前建议确认脚本中的数据符合当前环境：

- Stripe 测试环境可以保留 `prod_xxx` 和 `price_xxx`；
- 生产环境不要直接执行测试 seed；
- 敏感配置不写入 seed，应放在 `.env` 或部署平台环境变量。

## 环境限制

| 操作 | 本地开发 | 测试环境 | 生产环境 |
| --- | --- | --- | --- |
| 完整执行四个 SQL | 允许 | 仅明确重建时允许 | 禁止 |
| 执行 `cm_schema.sql` | 允许清空时执行 | 仅明确重建时允许 | 禁止 |
| 执行 `cm_seed.sql` | 允许 | 按测试需要执行 | 不建议直接执行 |

生产环境上线前应改用版本化数据库迁移，而不是依赖全量初始化脚本覆盖已有数据。
