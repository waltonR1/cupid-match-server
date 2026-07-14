# Cupid Match Server

Cupid Match Server 是 Cupid Match 的 Java 后端服务，基于 RuoYi / Spring Boot 改造，负责 C 端 API、后台 API、认证、验证码、会员订阅、支付回调、图片上传、定时任务、消息、审核和运营数据。

## 关联仓库

| 仓库 | 职责 | 生产平台 |
| --- | --- | --- |
| [cupid-match-server](https://github.com/waltonR1/cupid-match-server) | 当前仓库，Java API 与后端任务 | Render |
| [cupid-match](https://github.com/waltonR1/cupid-match) | C 端 uni-app / Vue H5 | Cloudflare Pages |
| [cupid-match-admin](https://github.com/waltonR1/cupid-match-admin) | Vue 3 运营后台 | Cloudflare Pages |

三仓的完整生产部署、环境变量、R2 和 Stripe 联调统一见 [三仓生产部署](./doc/cm-production-deployment.md)。

## 技术栈

- Java 17
- Spring Boot 4
- Spring Security
- MyBatis
- MySQL
- Redis
- Quartz
- RuoYi 后台基础能力

## 目录概览

```text
ruoyi-admin       应用入口、Controller、配置文件
ruoyi-common      通用工具、常量、异常、基础模型
ruoyi-framework   安全、Web、Redis、验证码和框架服务
ruoyi-system      RuoYi 系统管理模块
ruoyi-quartz      定时任务模块
ruoyi-generator   RuoYi 代码生成模块
sql               Cupid Match 建表与初始化数据
doc               Cupid Match 后端文档
scripts           辅助脚本
```

## 数据库初始化

本地或演示库按以下顺序执行：

```text
sql/cm_schema.sql
sql/cm_required_seed.sql
sql/cm_demo_seed.sql
```

说明：

- `cm_schema.sql`：创建 Cupid Match 业务表。
- `cm_required_seed.sql`：后台运行必须数据，包括部门、岗位、后台账号、角色权限、菜单、字典、系统配置、定时任务、会员套餐、通知模板和条款。
- `cm_demo_seed.sql`：本地联调和验收演示数据，会清理并重建 demo 业务数据；不要在生产环境执行。

详细说明见 [doc/cm-database-initialization.md](./doc/cm-database-initialization.md)。

## 本地配置

复制环境变量模板：

```bash
copy .env.example .env
```

`.env` 已被 Git 忽略，只用于本机填写外部服务密钥。

常见配置范围：

- SMTP 邮件验证码
- Twilio 短信验证码
- Stripe Checkout / Webhook

详细说明：

- [doc/cm-verification-delivery-configuration.md](./doc/cm-verification-delivery-configuration.md)
- [doc/cm-payment-stripe-configuration.md](./doc/cm-payment-stripe-configuration.md)

## 本地启动

启动后端入口：

```text
com.ruoyi.RuoYiApplication
```

默认端口：

```text
http://127.0.0.1:8080
```

后台开发代理和 C 端 H5 都默认连接该后端。

更完整的联调步骤见 [doc/cm-local-debugging.md](./doc/cm-local-debugging.md)。

## 常用账号

完整账号列表见 [doc/cm-seed-accounts.md](./doc/cm-seed-accounts.md)。

| 端 | 账号 | 密码 | 用途 |
| --- | --- | --- | --- |
| 后台 | `admin` | `admin123` | 超级管理员 |
| 后台 | `cupid_admin` | `admin123` | Cupid 运营管理员 |
| 后台 | `cupid_reviewer` | `admin123` | 审核专员 |
| C 端 | `lin.yuanhang@rencontreaparis.test` | `password123` | 主验收账号 |
| C 端 | `13333333333` | `password123` | 同一用户手机号登录身份 |

## 关键文档

- [数据库初始化](./doc/cm-database-initialization.md)
- [本地联调](./doc/cm-local-debugging.md)
- [初始化账号](./doc/cm-seed-accounts.md)
- [Stripe 支付配置](./doc/cm-payment-stripe-configuration.md)
- [验证码投递配置](./doc/cm-verification-delivery-configuration.md)
- [图片上传与 CDN](./doc/cm-upload-storage-configuration.md)
- [三仓生产部署](./doc/cm-production-deployment.md)
- [Render 后端部署](./doc/cm-render-deployment.md)
- [数据库结构说明](./doc/cm-schema-structure-notes.md)
- [API 状态说明](./doc/cm-api-status.md)

## 敏感信息

不要提交以下内容：

- `.env`
- SMTP 密码
- Twilio Token / API Secret
- Stripe Secret Key
- Stripe Webhook Secret
- 生产环境数据库、Redis、对象存储或 CDN 密钥

SQL 中可以保留测试环境的 Stripe `prod_xxx` / `price_xxx`，这些不是密钥；生产 `live` 价格映射仍建议单独管理和复核。
