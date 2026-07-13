# Cupid Match 本地调试简明说明

本文用于本地把后端、后台管理端和 C 端 H5 跑起来。更完整的账号清单见 `doc/cm-seed-accounts.md`，数据库初始化说明见 `doc/cm-database-initialization.md`。

## 1. 本地依赖

需要先准备：

- JDK 21
- MySQL
- Redis
- Node.js / npm
- 后端 `.env` 文件：从 `cupid-match-server/.env.example` 复制，并按本机配置填写数据库、Redis、邮件、短信、Stripe 等变量

纯页面联调时，邮件、短信、Stripe 可以先保持关闭；验证码发送和真实支付联调时再补外部服务配置。

## 2. 初始化数据库

在本地开发库中按顺序执行：

```text
cupid-match-server/sql/cm_schema.sql
cupid-match-server/sql/cm_required_seed.sql
cupid-match-server/sql/cm_demo_seed.sql
```

执行完成后，重启后端并重新登录后台。

## 3. 启动后端

用 IDEA 启动：

```text
cupid-match-server/ruoyi-admin/src/main/java/com/ruoyi/RuoYiApplication.java
```

默认接口地址：

```text
http://127.0.0.1:8080
```

如果 8080 被占用，先释放端口或临时修改后端端口。后台管理端代理默认指向 `http://localhost:8080`。

## 4. 启动后台管理端

```text
cd cupid-match-admin
npm.cmd run dev
```

默认地址：

```text
http://127.0.0.1:8081
```

后台登录账号见 `doc/cm-seed-accounts.md`。常用主账号：

```text
admin / admin123
cupid_admin / admin123
```

## 5. 启动 C 端 H5

```text
cd cupid-match-app
npm.cmd run dev:h5
```

默认会启动 Vite H5 开发服务，通常地址为：

```text
http://localhost:5173
```

C 端接口配置来自 `cupid-match-app/.env.development`：

```text
VITE_API_BASE_URL=http://127.0.0.1:8080/api
VITE_ASSET_BASE_URL=http://127.0.0.1:8080
```

C 端登录账号见 `doc/cm-seed-accounts.md`。常用主账号：

```text
lin.yuanhang@rencontreaparis.test / password123
13333333333 / password123
```

## 6. 外部服务联调

### 邮件 / 短信验证码

后端启动配置提供 SMTP、SMS 服务商密钥；后台热开关控制是否真实发送验证码。

常见策略：

- 本地只测注册登录流程：关闭真实发送，查看日志或使用测试配置。
- 测真实邮件：填写 SMTP 配置，并打开邮箱验证码热开关。
- 测真实短信：填写 SMS provider 配置，并打开短信验证码热开关。

### Stripe Checkout

本地支付联调需要：

- 后端 `.env` 填写 Stripe Secret Key、Webhook Secret、Success URL、Cancel URL。
- `sql/cm_required_seed.sql` 中的测试 `prod_xxx` / `price_xxx` 与 Stripe 测试环境保持一致。
- 本地启动 Stripe CLI 转发 webhook：

```text
stripe listen --forward-to http://127.0.0.1:8080/api/payment/stripe/webhook
```

Stripe CLI 输出的 `whsec_...` 要填入后端 `.env` 的 `CUPID_STRIPE_WEBHOOK_SECRET`，然后重启后端。

## 7. 常用验收入口

- 后台首页：确认菜单、角色权限、账号信息正常。
- 后台用户服务：检查 App 用户、会员管理、支付订阅、联系咨询、通知发布。
- 后台审核中心：检查资料、照片、认证、私人介绍审核。
- 后台活动运营：检查活动创建、报名审核、生命周期状态。
- C 端：检查登录、资料页、会员页、消息中心、活动报名、支付升级、取消自动续费。

如果菜单权限或动态路由看起来不对，先退出后台重新登录；如果仍不对，再检查 `cm_required_seed.sql` 是否已重新执行。
