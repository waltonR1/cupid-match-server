# Cupid Match 数据库初始化说明

本文说明当前仓库内 SQL 文件的用途、执行顺序和环境限制。

## SQL 文件职责

| 文件 | 用途 |
| --- | --- |
| `sql/cm_schema.sql` | 创建 Cupid Match 业务表，并包含项目当前需要的 RuoYi / Quartz 基础表结构。 |
| `sql/cm_required_seed.sql` | 插入后台运行必须数据，包括 Cupid 公司部门、岗位、后台账号、角色权限、菜单、字典、系统配置、定时任务、会员套餐、选项、通知模板和法律条款。 |
| `sql/cm_demo_seed.sql` | 插入 C 端、本地联调和后台验收样例数据。此文件会清理并重建 demo 业务数据，不要在生产环境执行。 |

## 本地完整重建

完整重建会清空并重建当前库内相关表，只能用于本地开发库或明确允许重建的测试库。

按顺序执行：

```text
1. sql/cm_schema.sql
2. sql/cm_required_seed.sql
3. sql/cm_demo_seed.sql
```

执行后重启后端，并重新登录后台，让菜单、权限和动态路由刷新。

初始化账号清单见 `doc/cm-seed-accounts.md`。

本地启动与联调步骤见 `doc/cm-local-debugging.md`。

## 只更新后台运行必须数据

如果只调整后台账号、角色、菜单、字典、系统配置、定时任务、会员套餐、选项、通知模板或法律条款，可以只执行：

```text
sql/cm_required_seed.sql
```

注意：该文件会按本项目维护范围重建相关后台基础数据和必要业务配置。执行前应确认目标环境允许覆盖这些初始化数据。

## 只更新 C 端样例数据

如果只需要刷新本地演示用户、资料、活动、消息、支付样例等数据，可以只执行：

```text
sql/cm_demo_seed.sql
```

注意：该文件会清理 demo 业务表中的样例数据，不要在已有真实用户或真实业务数据的环境中执行。

## 环境限制

| 操作 | 本地开发 | 测试环境 | 生产环境 |
| --- | --- | --- | --- |
| 执行 `cm_schema.sql` | 允许 | 仅明确重建时允许 | 禁止 |
| 执行 `cm_required_seed.sql` | 允许 | 按发布需要执行 | 需改为受控迁移或人工复核 |
| 执行 `cm_demo_seed.sql` | 允许 | 仅演示库允许 | 禁止 |

生产环境上线前应使用版本化数据库迁移和受控配置，不应依赖全量初始化脚本覆盖已有数据。

## 外部配置说明

- Stripe 测试环境可以在 required seed 中保留测试 `prod_xxx` 和 `price_xxx`。这些 ID 不是密钥，但生产 live 映射仍建议单独管理和复核。
- SMTP、SMS、Stripe Secret Key、Webhook Secret 等敏感值不写入 SQL，应放在 `.env` 或部署平台环境变量中。
