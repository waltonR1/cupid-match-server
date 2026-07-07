# Phase 9B Stripe Checkout Subscription Plan

本文记录 Cupid Match 使用 Stripe Checkout 完成会员订阅闭环的实施计划。目标不是重新设计会员体系，而是在现有会员、权益、订单和后台运营基础上接入正式订阅支付。

## 1. 当前基础评估

项目已经具备以下可复用基础：

- 会员套餐表：`cm_membership_plans`
  - 已包含 `tier`、价格、币种、`billing_type`、`billing_period`、`validity_months`、私人介绍额度、活动额度、客服等级等字段。
  - 当前 seed 中付费档位仍是 `one_time`，但 schema 已预留 `recurring` 与 `billing_period`。
- 用户会员表：`cm_user_memberships`
  - 已保存用户当前等级、状态、开始时间和到期时间。
  - C 端、权限判断、活动额度、私人介绍额度都已经读取这张表。
- 用户权益余额表：`cm_user_entitlement_balances`
  - 已保存会员周期内的权益额度、已用额度和剩余额度。
  - 活动报名和私人介绍已经会消费或读取这些余额。
- 订单与支付表：`cm_orders`、`cm_payments`
  - schema 和 seed 中已经存在，但当前业务代码尚未写入订单或支付。
  - 字段适合一次性支付记录，但不足以完整承载订阅生命周期。
- C 端会员页
  - 已有 `GET /api/account/membership`、`POST /api/account/membership/upgrade`。
  - 页面已经展示当前会员、权益余额、可升级套餐和升级按钮。
  - 当前升级接口只返回 `pending_external_flow`。
- 后台会员管理
  - 已有会员列表、详情、状态变更、等级和时间编辑。
  - 可作为订阅上线后的人工兜底入口。
- 定时任务
  - 已有会员过期自动任务。
  - 订阅接入后仍可保留，用于本地状态兜底修正。

因此，Stripe 订阅不是从零开始。主要缺口集中在：

- Stripe Price / Product 与本地会员套餐的映射。
- Stripe Customer / Subscription / Checkout Session / Invoice / PaymentIntent 外部 ID 的持久化。
- webhook 签名校验与幂等处理。
- 支付成功后创建或续期本地会员，并生成权益周期余额。
- 订阅失败、取消、过期、退款时的本地状态同步。
- C 端跳转 Checkout、支付结果页和订阅管理入口。
- 后台订单、支付、订阅可见性。

## 2. 最终目标

最终目标是完成订阅制会员闭环：

1. 用户在 C 端选择会员套餐。
2. 后端创建本地订单和 Stripe Checkout Session。
3. C 端跳转 Stripe 托管 Checkout 页面。
4. 用户完成订阅支付。
5. Stripe 通过 webhook 通知后端。
6. 后端校验签名、幂等处理事件。
7. 后端根据订阅和发票状态激活或续期本地会员。
8. 后端生成当前周期权益余额。
9. 用户返回 C 端后看到最新会员与权益。
10. 后台可以查看订单、支付、订阅和 webhook 处理记录。
11. 续费、支付失败、取消、退款等生命周期事件都能同步到本地状态。

履约原则：

- 不信任前端 success URL 来开通会员。
- 只在 Stripe webhook 确认支付成功或发票支付成功后开通或续期权益。
- 本地权限判断只读本地会员和权益表，不实时依赖 Stripe API。
- webhook 必须幂等。
- 敏感密钥只通过环境变量读取，不写入数据库或源码。

## 3. Stripe 集成方式

采用 Stripe Checkout 的订阅模式：

- Checkout `mode=subscription`。
- 使用 Stripe Dashboard 或 Stripe API 创建 Product 与 recurring Price。
- 本地保存 Stripe Price ID 与会员套餐的映射。
- C 端只提交本地 `tier` 或 `planId`，不提交金额、币种或 Stripe Price ID。
- 后端根据本地套餐查询 Stripe Price ID 并创建 Checkout Session。

第一版不做自定义卡输入，不做 Elements，不在 C 端收集银行卡信息。

## 4. 数据模型计划

### 4.1 会员套餐与 Stripe Price 映射

建议新增表 `cm_membership_plan_payment_prices`，不要直接把 Stripe 字段塞进 `cm_membership_plans`。

原因：

- test / live 环境的 Stripe Price ID 不同。
- 后续可能保留人工确认或其他支付渠道。
- 同一套餐可能存在不同币种、不同计费周期、促销价或迁移价。

建议字段：

- `id`
- `plan_id`
- `provider`：`stripe`
- `environment`：`test` / `live`
- `mode`：`subscription`
- `provider_product_id`
- `provider_price_id`
- `currency`
- `billing_period`
- `status`：`active` / `inactive`
- `created_at`
- `updated_at`

唯一约束：

- `(plan_id, provider, environment, mode, currency, billing_period)`
- `(provider, environment, provider_price_id)`

### 4.2 Stripe Customer 映射

建议新增表 `cm_payment_customers`。

建议字段：

- `id`
- `user_id`
- `provider`：`stripe`
- `environment`：`test` / `live`
- `provider_customer_id`
- `created_at`
- `updated_at`

唯一约束：

- `(user_id, provider, environment)`
- `(provider, environment, provider_customer_id)`

### 4.3 订阅表

建议新增表 `cm_subscriptions`。

建议字段：

- `id`
- `user_id`
- `plan_id`
- `membership_id`
- `provider`：`stripe`
- `environment`：`test` / `live`
- `provider_customer_id`
- `provider_subscription_id`
- `provider_price_id`
- `status`
  - 本地可用值：`incomplete`、`trialing`、`active`、`past_due`、`cancelled`、`unpaid`、`paused`、`incomplete_expired`
- `current_period_started_at`
- `current_period_ends_at`
- `cancel_at_period_end`
- `cancelled_at`
- `created_at`
- `updated_at`

唯一约束：

- `(provider, environment, provider_subscription_id)`

### 4.4 扩展订单表

现有 `cm_orders` 需要补充订阅上下文。

建议新增字段：

- `order_type`：`membership_subscription`
- `provider`：`stripe`
- `environment`：`test` / `live`
- `provider_checkout_session_id`
- `provider_subscription_id`
- `provider_customer_id`
- `expires_at`
- `paid_at`
- `cancelled_at`
- `failure_reason`

订单状态建议扩展为：

- `pending`
- `checkout_created`
- `paid`
- `cancelled`
- `expired`
- `failed`
- `refunded`

### 4.5 扩展支付表

现有 `cm_payments` 可继续作为每次发票支付或退款记录。

建议新增字段：

- `provider_invoice_id`
- `provider_subscription_id`
- `provider_charge_id`
- `provider_checkout_session_id`
- `failure_reason`
- `raw_status`

`provider_payment_id` 对 Stripe 可保存 PaymentIntent ID 或 Charge ID。建议第一版保存 PaymentIntent ID，并额外保存 Invoice ID。

### 4.6 webhook 事件表

必须新增 `cm_payment_webhook_events`，用于幂等和排障。

建议字段：

- `id`
- `provider`：`stripe`
- `environment`：`test` / `live`
- `event_id`
- `event_type`
- `payload_json`
- `process_status`：`received`、`processed`、`failed`、`ignored`
- `process_message`
- `received_at`
- `processed_at`
- `created_at`
- `updated_at`

唯一约束：

- `(provider, environment, event_id)`

## 5. 配置计划

`application.yml` 增加 Stripe 配置占位：

```yaml
cupid:
  payment:
    stripe:
      enabled: ${CUPID_STRIPE_ENABLED:false}
      environment: ${CUPID_STRIPE_ENVIRONMENT:test}
      secret-key: ${CUPID_STRIPE_SECRET_KEY:}
      webhook-secret: ${CUPID_STRIPE_WEBHOOK_SECRET:}
      success-url: ${CUPID_STRIPE_SUCCESS_URL:}
      cancel-url: ${CUPID_STRIPE_CANCEL_URL:}
```

说明：

- `secret-key` 和 `webhook-secret` 只来自环境变量。
- `enabled` 作为启动级开关。
- 后续如需要运营热开关，可增加 `cupid.payment.stripe.enabled` 到 `sys_config`，但不能把密钥放进数据库。

## 6. 后端接口计划

### 6.1 发起订阅 Checkout

复用现有接口：

```text
POST /api/account/membership/upgrade
```

请求：

```json
{
  "tier": "gold"
}
```

响应改为：

```json
{
  "status": "checkout_required",
  "requestedTier": "gold",
  "orderId": "...",
  "checkoutUrl": "https://checkout.stripe.com/..."
}
```

后端流程：

1. 校验用户存在且状态 active。
2. 校验目标套餐存在、启用、非 free、`billing_type=recurring`。
3. 校验目标套餐高于当前套餐，或明确允许续订同档。
4. 查询当前环境的 active Stripe Price 映射。
5. 查找或创建 Stripe Customer，并写入 `cm_payment_customers`。
6. 创建本地 `cm_orders`，状态为 `pending`。
7. 创建 Stripe Checkout Session：
   - `mode=subscription`
   - `customer=<stripe customer id>`
   - `line_items[0].price=<stripe price id>`
   - `line_items[0].quantity=1`
   - metadata 写入 `orderId`、`userId`、`planId`、`tier`
   - success URL 包含 `{CHECKOUT_SESSION_ID}`
   - cancel URL 包含本地 `orderId`
8. 更新订单状态为 `checkout_created`，写入 `provider_checkout_session_id`。
9. 返回 `checkoutUrl`。

### 6.2 支付结果查询

新增：

```text
GET /api/account/membership/orders/{orderId}
```

用途：

- C 端 success 页轮询或刷新。
- 告知用户“支付处理中 / 已开通 / 已取消 / 失败”。

响应：

```json
{
  "orderId": "...",
  "status": "paid",
  "membershipStatus": "active"
}
```

### 6.3 Stripe webhook

新增公开但验签接口：

```text
POST /api/payment/stripe/webhook
```

注意：

- 该接口不走登录态。
- 必须读取原始请求 body 校验 Stripe 签名。
- 验签失败直接返回 400。
- 事件 ID 已处理过时直接返回 200。

第一版必处理事件：

- `checkout.session.completed`
- `checkout.session.expired`
- `invoice.paid`
- `invoice.payment_failed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`

后续增强事件：

- `charge.refunded`
- `invoice.finalization_failed`
- `invoice.payment_action_required`

## 7. 本地会员与权益开通规则

### 7.1 首次支付成功

触发来源：

- 主要使用 `invoice.paid`。
- `checkout.session.completed` 用于补齐 order / subscription 映射，但不单独作为最终履约依据，除非确认 payment_status 为 paid 且 subscription 可用。

本地操作：

1. 根据 Stripe Subscription 找到本地 `cm_subscriptions`。
2. 获取 plan。
3. 关闭或标记旧 active paid membership：
   - 如果当前是 free，可保留 free 但权限以 paid active 为准。
   - 如果当前已有 paid active，按业务策略处理升级或续期。
4. 创建或更新 `cm_user_memberships`：
   - `status=active`
   - `started_at=current_period_start`
   - `expires_at=current_period_end`
5. 更新 `cm_subscriptions.membership_id`。
6. 生成本周期 `cm_user_entitlement_balances`。
7. 更新订单 `paid`。
8. 写入 `cm_payments`。
9. 写入业务审计日志。
10. 可选：发送站内通知。

### 7.2 续费成功

触发来源：

- `invoice.paid`

本地操作：

1. 找到 subscription。
2. 更新 `current_period_started_at` / `current_period_ends_at`。
3. 更新本地会员 `expires_at`。
4. 为新周期生成权益余额。
5. 写入支付记录。
6. 通知用户续费成功。

### 7.3 支付失败

触发来源：

- `invoice.payment_failed`
- `customer.subscription.updated` 中状态变为 `past_due` / `unpaid`

本地操作：

- 更新 subscription 状态。
- 不立即删除已付周期内权益。
- 若 Stripe 状态进入 `unpaid` 或 `canceled`，再暂停或取消本地会员。
- 发送站内通知或跟进事项。

### 7.4 用户取消订阅

触发来源：

- `customer.subscription.updated`
- `customer.subscription.deleted`

规则：

- `cancel_at_period_end=true`：本地会员保持 active 到当前周期结束，展示“到期后取消”。
- `deleted` 或 status `canceled`：本地会员改为 `cancelled` 或等周期结束后改为 `expired`，具体取决于 Stripe 返回的周期和取消时间。

### 7.5 退款

第一版建议只做记录和人工处理提示，不自动倒扣已使用权益。

后续可根据退款策略处理：

- 全额退款且会员未使用：取消会员并回收权益。
- 已使用权益：进入人工跟进事项。

## 8. C 端改造计划

### 8.1 类型和 API

修改：

- `AccountMembershipUpgradeResultDTO`

新增状态：

- `checkout_required`
- `pending_external_flow` 可保留兼容，但 Stripe 启用后不再作为正常路径。

新增字段：

- `orderId`
- `checkoutUrl`

### 8.2 会员页

修改 `pages/account/membership.vue`：

- 点击升级后，如果返回 `checkout_required`：
  - H5 使用 `window.location.href = checkoutUrl`。
  - 其他端如暂不支持 Stripe Checkout，可提示“请在浏览器中完成支付”。
- 保留当前 toast 逻辑作为 fallback。
- 按钮 loading 防重复点击。

### 8.3 支付结果页

新增页面：

```text
/pages/account/membership-payment-result
```

用途：

- 处理 Stripe success / cancel 回跳。
- 根据 `orderId` 或 `session_id` 查询本地订单状态。
- 显示：
  - 支付处理中
  - 会员已开通
  - 支付取消
  - 支付失败
- 支持返回会员页刷新。

## 9. 后台改造计划

第一版后台最少补：

1. 会员详情展示：
   - provider
   - subscription ID
   - 当前周期
   - 是否到期取消
2. 新增订单/支付查询页，或先并入会员详情：
   - 订单 ID
   - Stripe Checkout Session ID
   - Stripe Subscription ID
   - Invoice / PaymentIntent
   - 金额、币种、状态、支付时间
3. webhook 事件查询页：
   - event id
   - event type
   - 处理状态
   - 错误信息
   - 创建和处理时间

后台操作第一版不建议直接调用 Stripe 取消或退款。取消、退款可以先在 Stripe Dashboard 操作，系统通过 webhook 同步；后台只做查看和人工备注。

## 10. SQL 与 seed 计划

### 10.1 schema

更新：

- `cm_schema.sql`
- `cm_seed.sql`

新增：

- `cm_membership_plan_payment_prices`
- `cm_payment_customers`
- `cm_subscriptions`
- `cm_payment_webhook_events`

扩展：

- `cm_orders`
- `cm_payments`
- 必要时扩展 `cm_user_memberships`：
  - `subscription_id` 或 `source`
  - 如果已通过 `cm_subscriptions.membership_id` 反查，则可以不加。

### 10.2 seed

seed 不写真实 Stripe 密钥。

可以写测试映射占位：

- provider：`stripe`
- environment：`test`
- provider_price_id：`price_replace_me_silver`

实际本地联调前由开发者替换为 Stripe Dashboard 中创建的 test Price ID。

## 11. 实施顺序

### Step 1：订阅计划与 SQL 落地

- 增加 Stripe 订阅相关表。
- 扩展订单和支付表。
- seed 增加测试 Price 映射占位。
- 补文档说明配置项和联调步骤。

验收：

- 全量重建数据库成功。
- 现有会员页、后台会员列表不受影响。

### Step 2：后端 Stripe 配置和客户端封装

- 增加 Stripe Java SDK。
- 增加 Stripe properties。
- 增加 `CupidStripeClient` 或 `CupidPaymentProvider` 抽象。
- 实现创建 Customer、Checkout Session、校验 webhook 签名。

验收：

- 配置缺失时启动不暴露密钥。
- Stripe disabled 时升级接口返回明确错误或保留外部流程。

### Step 3：升级接口创建 Checkout Session

- 改造 `requestUpgrade`。
- 写入本地 order。
- 创建 Stripe Checkout Session。
- 返回 checkout URL。

验收：

- 使用 Stripe test Price 能跳转 Checkout。
- 重复点击不会生成异常订单。
- 金额和 Price ID 不由前端控制。

### Step 4：webhook 幂等与基础履约

- 新增 webhook controller。
- 实现签名校验。
- 写入 webhook event。
- 处理 `checkout.session.completed`。
- 处理 `invoice.paid`，创建或续期会员和权益。

验收：

- Stripe test card 支付成功后，本地会员变 active。
- `GET /api/account/membership` 返回新会员和权益。
- 重放同一个 webhook 不重复开通、不重复发权益。

### Step 5：C 端 Checkout 跳转和结果页

- DTO 增加 `checkoutUrl`。
- 升级按钮跳转 Stripe Checkout。
- 新增 success / cancel 页面。
- 结果页查询本地订单状态。

验收：

- 支付成功返回后能看到已开通或处理中。
- 取消返回后订单不被误标为 paid。

### Step 6：订阅生命周期事件

- 处理 `customer.subscription.updated`。
- 处理 `customer.subscription.deleted`。
- 处理 `invoice.payment_failed`。
- 同步 past_due、cancel_at_period_end、cancelled、unpaid。
- 生成站内通知或跟进事项。

验收：

- Stripe Dashboard 取消订阅后，本地能同步。
- 续费成功能生成新周期权益。
- 支付失败不会误开通新周期权益。

### Step 7：后台可见性

- 增加订单/支付/订阅查询。
- 增加 webhook 事件查询。
- 会员详情展示订阅信息。

验收：

- 后台能定位某个用户的订阅、订单、支付和 webhook 处理状态。
- 失败事件可见，便于排障。

### Step 8：回归和生产前检查

- 测试卡：
  - 支付成功
  - 3DS
  - 支付失败
  - 用户取消
  - webhook 重放
  - 订阅取消
  - 续费成功
- 检查：
  - 密钥不入库、不入 Git。
  - webhook 失败可重试。
  - 权益不重复生成。
  - 本地过期任务不误伤 Stripe active 订阅。

## 12. 工程量重新评估

因为已有会员、权益、套餐、订单雏形和 C 端会员页，工程量不是从零的一到两周。

更准确估计：

- 最小订阅 Checkout 闭环：3～5 天。
  - 创建 Checkout Session。
  - webhook 支付成功开通会员。
  - C 端跳转和结果页。
- 可运营订阅闭环：6～9 天。
  - 增加订阅状态同步、支付失败、取消、续费、后台查询和 webhook 排障。
- 更完整生产级：10～14 天。
  - 包含退款策略、客户自助管理订阅、Billing Portal、税务、发票展示、多环境迁移和更完整自动化测试。

建议目标：

第一轮做到“可运营订阅闭环”，不要只做最小闭环。也就是直接覆盖：

- Checkout 创建。
- webhook 幂等。
- 首次支付开通。
- 续费续期。
- 取消同步。
- 支付失败标记。
- 后台可查。

退款、Billing Portal、自助换档、税务自动化可以作为第二轮。

## 13. 需要确认的业务决策

正式编码前需要确认：

1. 是否把现有 silver / gold / diamond 都改为 `recurring`？
2. 订阅周期是否统一为 monthly，还是 silver / gold / diamond 各自不同？
3. 当前 `price_cents` 是月费，还是原先一次性价格？
4. 用户升级高档时是否立即生效，还是当前周期结束后生效？
5. 取消订阅后是否保留权益到已付周期结束？
6. 退款是否自动取消会员，还是进入人工处理？
7. 是否第一版接 Stripe Customer Portal 让用户自助取消和改卡？

默认建议：

- 付费档位统一改为 `recurring`。
- 第一版统一 monthly。
- 用户升级高档立即生效。
- 取消订阅后保留权益到当前周期结束。
- 退款第一版进入人工处理，不自动扣回。
- Customer Portal 第二轮做。
