# Render 部署

本文说明如何将 Java 后端部署到 Render，并与 Cloudflare Pages 上的 C 端和管理后台联调。

## 运行方式

仓库根目录提供多阶段 `Dockerfile`：第一阶段用 Maven + Java 17 构建 `ruoyi-admin.jar`，第二阶段用 Java 17 JRE 运行。应用从 Render 的 `PORT` 环境变量读取端口。

Render Web Service 配置：

| 配置项 | 值 |
| --- | --- |
| Runtime | `Docker` |
| Repository | `waltonR1/cupid-match-server` |
| Branch | `master` |
| Root Directory | 留空 |
| Dockerfile Path | `./Dockerfile` |
| Health Check Path | `/` |
| Auto-Deploy | `On Commit` |

## 必需环境变量

下列值只在 Render Dashboard 中设置，不要写入 Git：

```env
CUPID_DB_URL=jdbc:mysql://<host>:<port>/<database>?useUnicode=true&characterEncoding=utf8&useSSL=true&serverTimezone=GMT%2B8
CUPID_DB_USERNAME=
CUPID_DB_PASSWORD=

CUPID_REDIS_HOST=
CUPID_REDIS_PORT=6379
CUPID_REDIS_DATABASE=0
CUPID_REDIS_USERNAME=
CUPID_REDIS_PASSWORD=

CUPID_TOKEN_SECRET=
CUPID_CORS_ALLOWED_ORIGIN_PATTERNS=https://cupid-match.pages.dev,https://cupid-match-admin.pages.dev
```

`CUPID_TOKEN_SECRET` 必须使用长随机值。正式域名上线后，将它们追加到 `CUPID_CORS_ALLOWED_ORIGIN_PATTERNS`，多个来源用英文逗号分隔。

## R2 对象存储

Render 的本地文件系统不适合持久保存上传文件。生产环境使用 Cloudflare R2 的 S3 兼容接口：

```env
CUPID_STORAGE_TYPE=s3
CUPID_STORAGE_S3_BUCKET=cupid-match-public
CUPID_STORAGE_S3_PRIVATE_BUCKET=cupid-match-private
CUPID_STORAGE_S3_REGION=auto
CUPID_STORAGE_S3_ENDPOINT=https://<ACCOUNT_ID>.r2.cloudflarestorage.com
CUPID_STORAGE_S3_ACCESS_KEY=
CUPID_STORAGE_S3_SECRET_KEY=
CUPID_STORAGE_S3_PATH_STYLE_ACCESS=false
CUPID_STORAGE_PUBLIC_BASE_URL=
```

- `cupid-match-public` 存放头像和资料照片。初始可保持私有，由后端代理读取。
- `cupid-match-private` 存放实名、学历、收入、婚姻等认证材料，必须保持私有。
- 后续给公开桶绑定 CDN/自定义域名时，再将 `CUPID_STORAGE_PUBLIC_BASE_URL` 设为该域名；私有材料仍由鉴权后端转发。

## 外部服务

根据启用的功能在 Render 设置 SMTP、Twilio 和 Stripe 变量，变量名以仓库根目录 `.env.example` 为准。

Stripe 正式联调要点：

- `CUPID_STRIPE_SUCCESS_URL` 和 `CUPID_STRIPE_CANCEL_URL` 指向 C 端 Pages 域名。
- Stripe Webhook Endpoint 设为 `https://<render-service>/api/payment/stripe/webhook`。
- 测试和正式环境的 Secret Key、Webhook Secret、Price ID 和 Customer ID 不能混用。

## 数据库初始化

首次部署前，在生产 MySQL 按顺序执行：

```text
sql/cm_schema.sql
sql/cm_required_seed.sql
```

不要在生产环境执行 `sql/cm_demo_seed.sql`。首次登录后立即更换初始后台密码。

## 验证

1. Render 日志中出现 Spring Boot 启动成功，服务状态为 `Live`。
2. `GET https://<render-service>/` 可访问。
3. C 端可登录、读取资料、上传公开图片。
4. 管理后台可登录并读取菜单。
5. 认证材料不能通过 R2 公开 URL 访问，只能由有权后台账号读取。
