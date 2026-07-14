# Cupid Match 三仓生产部署

本文是 Cupid Match 生产部署的统一入口，覆盖 Java 后端、C 端 H5、运营后台、MySQL、Redis、Cloudflare R2、Stripe 和三仓发布顺序。各前端仓库只保留本项目的构建补充说明；域名、环境变量和联调关系以本文为准。

## 仓库与线上服务

| 单元 | 仓库 | 平台 | 当前服务 |
| --- | --- | --- | --- |
| Java 后端 | [cupid-match-server](https://github.com/waltonR1/cupid-match-server) | Render Web Service | `https://cupid-match-server.onrender.com` |
| C 端 H5 | [cupid-match](https://github.com/waltonR1/cupid-match) | Cloudflare Pages | `https://cupid-match.pages.dev` |
| 运营后台 | [cupid-match-admin](https://github.com/waltonR1/cupid-match-admin) | Cloudflare Pages | `https://cupid-match-admin.pages.dev` |

线上调用关系：

```text
cupid-match.pages.dev -----------\
                                    -> cupid-match-server.onrender.com -> MySQL / Redis
cupid-match-admin.pages.dev -----/                    |
                                                       +-> Cloudflare R2
                                                       +-> SMTP / Twilio / Stripe
```

## 发布顺序

首次部署或基础设施变更时按以下顺序操作：

1. 准备生产 MySQL 和 Redis，初始化数据库。
2. 创建 R2 公开、私有桶和最小权限 API Token。
3. 部署 Render 后端并写入环境变量。
4. 部署 C 端 Cloudflare Pages，并指向 Render API。
5. 部署运营后台 Cloudflare Pages，并指向 Render API。
6. 配置 Stripe Webhook，更新 Render 中的 Webhook Secret。
7. 完成 API、CORS、登录、上传和私有材料读取冒烟测试。

日常发布时，只有接口兼容的前端改动可以单独发布；接口契约变更应先发布兼容版后端，再发布两个前端。

## 1. 数据库与 Redis

生产 MySQL 首次初始化只执行：

```text
sql/cm_schema.sql
sql/cm_required_seed.sql
```

不要在生产环境执行 `sql/cm_demo_seed.sql`。首次登录后台后立即修改初始化密码。

数据库和 Redis 连接信息只写入 Render 环境变量：

```env
CUPID_DB_URL=jdbc:mysql://<host>:<port>/<database>?useUnicode=true&characterEncoding=utf8&useSSL=true&serverTimezone=GMT%2B8
CUPID_DB_USERNAME=
CUPID_DB_PASSWORD=

CUPID_REDIS_HOST=
CUPID_REDIS_PORT=6379
CUPID_REDIS_DATABASE=0
CUPID_REDIS_USERNAME=
CUPID_REDIS_PASSWORD=
```

## 2. Cloudflare R2

创建两个私有桶：

| Bucket | 用途 | 访问策略 |
| --- | --- | --- |
| `cupid-match-public` | 头像、资料照片等公开业务图片 | 初始保持私有，由后端代理读取；以后可单独接 CDN |
| `cupid-match-private` | 实名、学历、收入、婚姻等认证材料 | 始终保持私有，只能通过鉴权后端读取 |

创建只对这两个桶具有 Object Read & Write 权限的 R2 API Token，然后在 Render 设置：

```env
CUPID_STORAGE_TYPE=s3
CUPID_STORAGE_S3_BUCKET=cupid-match-public
CUPID_STORAGE_S3_PRIVATE_BUCKET=cupid-match-private
CUPID_STORAGE_S3_REGION=auto
CUPID_STORAGE_S3_ENDPOINT=https://<CLOUDFLARE_ACCOUNT_ID>.r2.cloudflarestorage.com
CUPID_STORAGE_S3_ACCESS_KEY=
CUPID_STORAGE_S3_SECRET_KEY=
CUPID_STORAGE_S3_PATH_STYLE_ACCESS=false
CUPID_STORAGE_PUBLIC_BASE_URL=
```

暂不接 CDN 时保持 `CUPID_STORAGE_PUBLIC_BASE_URL` 为空。以后给公开桶绑定自定义域名时，只修改公开资源域名；不要给私有桶开启公共访问。

## 3. Render 后端

创建 Free Web Service：

| 配置项 | 值 |
| --- | --- |
| Name | `cupid-match-server` |
| Repository | `waltonR1/cupid-match-server` |
| Branch | `master` |
| Runtime | `Docker` |
| Root Directory | 留空 |
| Dockerfile Path | `./Dockerfile` |
| Health Check Path | `/api/membership/catalog` |
| Auto-Deploy | `On Commit` |

除数据库、Redis 和 R2 变量外，至少设置：

```env
CUPID_TOKEN_SECRET=<long-random-secret>
CUPID_CORS_ALLOWED_ORIGIN_PATTERNS=https://cupid-match.pages.dev,https://cupid-match-admin.pages.dev
JAVA_OPTS=-XX:MaxRAMPercentage=70.0 -XX:MaxMetaspaceSize=128m
```

SMTP、Twilio、Stripe 等变量以仓库根目录 `.env.example` 为准。Render Free 实例空闲后会休眠，首次请求可能需要等待约一分钟。

## 4. C 端 Cloudflare Pages

Pages 项目配置：

| 配置项 | 值 |
| --- | --- |
| Project name | `cupid-match-app` |
| Repository | `waltonR1/cupid-match` |
| Production branch | `master` |
| Build command | `npm run build:h5:production` |
| Build output directory | `dist/build/h5` |
| Root directory | 留空 |

Production 环境变量：

```env
VITE_APP_ENV=production
VITE_API_BASE_URL=https://cupid-match-server.onrender.com/api
VITE_ASSET_BASE_URL=https://cupid-match-server.onrender.com
VITE_API_ENABLE_LOGGING=false
VITE_ENABLE_DEBUG=false
```

C 端使用 hash router，不需要 Pages SPA rewrite。修改 `VITE_*` 后必须重新部署，因为这些值在构建时写入静态产物。

## 5. 运营后台 Cloudflare Pages

Pages 项目配置：

| 配置项 | 值 |
| --- | --- |
| Project name | `cupid-match-admin` |
| Repository | `waltonR1/cupid-match-admin` |
| Production branch | `master` |
| Build command | `npm run build:prod` |
| Build output directory | `dist` |
| Root directory | 留空 |

Production 环境变量：

```env
VITE_APP_BASE_API=https://cupid-match-server.onrender.com
VITE_APP_ENV=production
VITE_APP_TITLE=Cupid Match 后台
VITE_BUILD_COMPRESS=gzip
```

不要添加 `/* /index.html 200` 的 `_redirects`。没有顶层 `404.html` 时，Cloudflare Pages 会自动提供 SPA fallback；手写该规则会被判定为循环。

## 6. Stripe

Render 中的测试或正式 Stripe Key 必须属于同一环境。回跳地址设置为：

```env
CUPID_STRIPE_SUCCESS_URL=https://cupid-match.pages.dev/#/pages/account/membership
CUPID_STRIPE_CANCEL_URL=https://cupid-match.pages.dev/#/pages/account/membership
```

在 Stripe 对应环境创建 Webhook Endpoint：

```text
https://cupid-match-server.onrender.com/api/payment/stripe/webhook
```

订阅以下事件：

```text
checkout.session.completed
checkout.session.expired
invoice.paid
invoice.payment_succeeded
invoice.payment_failed
charge.refunded
customer.subscription.created
customer.subscription.updated
customer.subscription.deleted
```

把该线上 Endpoint 新生成的 Signing Secret 写入 Render 的 `CUPID_STRIPE_WEBHOOK_SECRET`。本机 `stripe listen` 生成的 `whsec_...` 不能用于线上 Endpoint。

## 7. 上线验证

至少完成以下检查：

1. Render 状态为 `Live`，`GET /api/membership/catalog` 返回业务 `code: 200`。
2. 使用两个 Pages 域名作为 `Origin` 请求后端时，响应包含对应的 `Access-Control-Allow-Origin`。
3. C 端和后台构建产物中的 API 地址均为 Render HTTPS 域名，不包含 `127.0.0.1`。
4. C 端登录、会员目录、资料读取和公开图片上传正常。
5. 后台登录、菜单、照片审核和认证材料审核正常，内页直接刷新不返回 404。
6. 公开图片可以通过后端读取；私有认证材料没有公共 R2 URL，未授权请求被拒绝。
7. Stripe 测试 Checkout 完成后，Webhook 投递成功且本地订单、订阅状态正确更新。

## 8. 日常发布

三个仓库都从 `master` 自动部署：

- 推送 `cupid-match-server/master` 会触发 Render Docker 构建和健康检查。
- 推送 `cupid-match/master` 会触发 C 端 Pages 生产构建。
- 推送 `cupid-match-admin/master` 会触发后台 Pages 生产构建。

发布后查看对应平台日志并重复最小冒烟路径。不要把 `.env`、数据库密码、R2 Secret Key、Stripe Secret Key 或 Webhook Secret 提交到任何仓库。

## 相关文档

- [Render 后端细节](./cm-render-deployment.md)
- [数据库初始化](./cm-database-initialization.md)
- [图片上传与存储](./cm-upload-storage-configuration.md)
- [Stripe 配置](./cm-payment-stripe-configuration.md)
- [本地联调](./cm-local-debugging.md)
