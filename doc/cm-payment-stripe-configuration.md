# Cupid Match Stripe 支付配置

本文说明会员订阅接入 Stripe Checkout 时需要配置的本地环境变量、Stripe 后台资源、数据库价格映射和本地联调步骤。

## 配置文件

后端启动时会读取 `cupid-match-server/.env`。该文件只用于本地和部署环境，不提交到 Git。

可从仓库内模板复制：

```bash
copy .env.example .env
```

真实密钥只写入 `.env` 或部署平台的环境变量。不要把 `sk_*`、`whsec_*`、Twilio token、SMTP password 等敏感值写入 SQL、文档或可提交配置。

## 必填环境变量

| 变量 | 示例 | 说明 |
| --- | --- | --- |
| `CUPID_STRIPE_ENABLED` | `true` | Stripe 支付总开关；为 `false` 时不会创建 Checkout Session。 |
| `CUPID_STRIPE_ENVIRONMENT` | `test` | 当前支付环境；本地和沙盒使用 `test`，生产使用 `live`。 |
| `CUPID_STRIPE_SECRET_KEY` | `sk_test_...` | Stripe Secret Key，用于后端创建 Checkout、取消续费、退款和查询支付对象。 |
| `CUPID_STRIPE_WEBHOOK_SECRET` | `whsec_...` | Stripe Webhook 签名密钥，用于校验回调真实性。 |
| `CUPID_STRIPE_SUCCESS_URL` | `http://localhost:5173/#/pages/account/membership` | Checkout 支付成功后的跳转地址。 |
| `CUPID_STRIPE_CANCEL_URL` | `http://localhost:5173/#/pages/account/membership` | Checkout 取消后的跳转地址。 |

`SUCCESS_URL` 支持包含 `{CHECKOUT_SESSION_ID}` 和 `{ORDER_ID}` 占位符；`CANCEL_URL` 支持包含 `{ORDER_ID}` 占位符。当前 C 端会员页可在跳回后重新拉取会员状态。

## Stripe 后台资源

### Secret Key

位置：Stripe Dashboard → Developers → API keys。

本地联调用测试环境密钥，格式为 `sk_test_...`。生产环境使用 `sk_live_...`，必须单独配置，不能复用测试环境。

### Product 与 Price

位置：Stripe Dashboard → Product catalog。

每个付费会员套餐需要一个 Stripe Product 和一个订阅 Price：

- 白银会员：月订阅 Price。
- 黄金会员：月订阅 Price。
- 钻石会员：月订阅 Price。

系统真正创建 Checkout 时使用的是 `price_xxx`，不是 `prod_xxx`。`prod_xxx` 只用于人工识别和后台对照。

### Webhook endpoint

本地联调用 Stripe CLI：

```bash
stripe listen --forward-to http://127.0.0.1:8080/api/payment/stripe/webhook
```

命令启动后会输出 `whsec_...`，将该值写入 `CUPID_STRIPE_WEBHOOK_SECRET`。

生产环境需要在 Stripe Dashboard → Developers → Webhooks 新建 endpoint：

```text
https://你的后端域名/api/payment/stripe/webhook
```

生产 endpoint 生成的 `whsec_...` 与本地 CLI 的 `whsec_...` 不同，不能混用。

## 数据库价格映射

会员套餐与 Stripe Price 的映射保存在：

```text
cm_membership_plan_payment_prices
```

关键字段：

| 字段 | 说明 |
| --- | --- |
| `plan_id` | 关联 `cm_membership_plans.id`。 |
| `provider` | 当前为 `stripe`。 |
| `environment` | `test` 或 `live`，必须与 `CUPID_STRIPE_ENVIRONMENT` 一致。 |
| `mode` | 当前为 `subscription`。 |
| `currency` | 当前使用 `EUR`。 |
| `billing_period` | 当前使用 `month`。 |
| `provider_product_id` | Stripe Product ID，格式 `prod_xxx`。 |
| `provider_price_id` | Stripe Price ID，格式 `price_xxx`。 |
| `is_active` | 只有启用的映射才会被用于创建 Checkout。 |

本地测试环境可以在 `sql/cm_seed.sql` 中保留测试用 `prod_xxx` 和 `price_xxx`。这些 ID 不是密钥，但生产环境的 live 映射仍建议单独管理和复核。

## 本地联调步骤

1. 启动 C 端前端，确认会员页可访问。
2. 启动后端，确认 `.env` 已被读取。
3. 启动 Stripe CLI webhook 转发：

   ```bash
   stripe listen --forward-to http://127.0.0.1:8080/api/payment/stripe/webhook
   ```

4. 使用 Stripe CLI 输出的 `whsec_...` 更新 `.env` 中的 `CUPID_STRIPE_WEBHOOK_SECRET`。
5. 重启后端。
6. 在 C 端会员页点击付费套餐，跳转 Stripe Checkout。
7. 使用 Stripe 测试卡完成支付。
8. 回到 C 端会员页，确认会员等级、权益和续费状态刷新。
9. 在后台「用户服务 / 支付订阅」确认：
   - 订单状态变为已支付；
   - 支付流水存在；
   - Webhook 回调日志成功；
   - Subscription、Price、Customer 等 Stripe ID 已回填。

## 常见问题

### 返回 `No such price`

通常是数据库里的 `provider_price_id` 写成了 `prod_xxx`，或 Price 属于另一个 Stripe 环境。

处理方式：

- `provider_price_id` 必须是 `price_xxx`；
- `CUPID_STRIPE_ENVIRONMENT` 必须与数据库 `environment` 一致；
- `CUPID_STRIPE_SECRET_KEY` 必须与该 Price 所属的 Stripe test/live 环境一致；
- `is_active` 必须为启用状态。

### Stripe CLI 显示 webhook 200，但会员没升级

优先检查：

- `.env` 中的 `CUPID_STRIPE_WEBHOOK_SECRET` 是否是当前 `stripe listen` 输出的值；
- 后端是否在更新 `.env` 后重启；
- 后台 Webhook 回调日志是否有失败原因；
- 支付订单详情中是否回填了 Checkout Session、Subscription、Price、Payment、Charge。

### 退款按钮不可用或退款失败

退款依赖 Stripe 支付对象回填。若历史订单缺少本地支付流水，后台订单详情会尝试从 Stripe 实时补齐 Checkout Session、Invoice、PaymentIntent 和 Charge。

若 Stripe 返回已经退款，系统会按幂等成功处理并同步本地退款状态。

### 取消自动续费后会员是否立即失效

不会。取消自动续费只把 Stripe Subscription 设置为当前周期结束后不再续费。会员权益保留到当前周期结束，后续由会员生命周期任务处理到期状态。

### 退款后是否需要取消自动续费

需要。平台后台退款流程会同时尝试取消该订阅的后续自动续费，避免退款后下个周期继续扣款。

