# 验证码 Email 与 SMS 接入配置

本文说明 Cupid Match 验证码投递服务的部署配置、运行开关和验证方式。敏感凭据仅通过环境变量提供，不写入源码、YAML 实际值或数据库。

## 1. 投递模式

验证码生成后按请求中的 `provider` 投递：

- `email`：使用 Spring Mail 通过 SMTP 发送。
- `phone`：调用 `CupidSmsGateway` 短信网关实现。

`cupid.auth.verification-code-log-enabled` 的优先级最高：

- `true`：仅在服务端日志输出验证码，不调用 Email 或 SMS。
- `false`：根据 `provider` 调用对应投递渠道。

开发环境可以使用日志模式。联调和生产环境必须关闭日志模式。

## 2. Email 配置

### 2.1 环境变量

`application.yml` 通过以下环境变量读取 SMTP 配置：

| 环境变量 | 必填 | 说明 |
| --- | --- | --- |
| `CUPID_SMTP_HOST` | 是 | SMTP 服务地址 |
| `CUPID_SMTP_PORT` | 是 | SMTP 服务端口，默认 `587` |
| `CUPID_SMTP_USERNAME` | 是 | SMTP 用户名 |
| `CUPID_SMTP_PASSWORD` | 是 | SMTP 密码或供应商 API Key |
| `CUPID_MAIL_FROM` | 是 | 发件人邮箱，必须符合供应商的域名规则 |

敏感值不得直接写入 `application.yml`。在本地开发时，应在 IDE 启动配置或启动进程的环境变量中提供。

### 2.2 Resend 示例

Resend 的 API Key 可以作为 SMTP 密码使用：

```text
CUPID_SMTP_HOST=smtp.resend.com
CUPID_SMTP_PORT=587
CUPID_SMTP_USERNAME=resend
CUPID_SMTP_PASSWORD=<Resend API Key>
CUPID_MAIL_FROM=onboarding@resend.dev
```

使用 `onboarding@resend.dev` 测试时，只能发送到 Resend 账号绑定的邮箱。向其他用户发送前，需要在 Resend 验证自有域名，并将 `CUPID_MAIL_FROM` 改为该域名下的地址，例如：

```text
CUPID_MAIL_FROM=no-reply@mail.example.com
```

### 2.3 Email 开关

数据库运行时参数：

```text
cupid.verification.email.enabled
```

- `true`：允许发送 Email 验证码。
- `false`：禁用 Email 验证码。

该参数可在若依后台的“系统管理 → 参数设置”中修改并立即生效。数据库不存在该参数时，使用以下 YAML 值兜底：

```yaml
cupid:
  auth:
    verification-delivery:
      email:
        enabled: false
```

## 3. SMS 配置

### 3.1 当前接入状态

系统已经提供统一短信扩展接口：

```text
com.ruoyi.framework.web.service.CupidSmsGateway
```

短信供应商确定后，需要：

1. 引入供应商 SDK 或 HTTP 客户端。
2. 实现 `CupidSmsGateway`。
3. 将实现类注册为 Spring Bean。
4. 根据 `purpose` 选择注册、重置密码或通用模板。
5. 将供应商异常转换为项目统一的投递失败。

在没有 `CupidSmsGateway` Bean 时，即使打开 SMS 热开关，短信也不会发送，接口将返回 `verification_delivery_unavailable`。

### 3.2 预留环境变量

`application.yml` 已预留以下短信参数：

| 环境变量 | 说明 |
| --- | --- |
| `CUPID_SMS_PROVIDER` | 短信供应商标识 |
| `CUPID_SMS_ACCESS_KEY` | 供应商访问凭据 |
| `CUPID_SMS_SECRET_KEY` | 供应商密钥 |
| `CUPID_SMS_SIGN_NAME` | 短信签名 |
| `CUPID_SMS_REGISTRATION_TEMPLATE_ID` | 注册验证码模板 ID |
| `CUPID_SMS_PASSWORD_RESET_TEMPLATE_ID` | 密码重置验证码模板 ID |
| `CUPID_SMS_GENERAL_TEMPLATE_ID` | 通用验证码模板 ID |

这些变量是供应商适配器的配置入口。当前未接入具体供应商时，配置这些变量不会单独产生发送能力。

### 3.3 SMS 开关

数据库运行时参数：

```text
cupid.verification.sms.enabled
```

- `true`：允许调用已注册的 SMS 网关。
- `false`：禁用 SMS 验证码。

数据库不存在该参数时，使用以下 YAML 值兜底：

```yaml
cupid:
  auth:
    verification-delivery:
      sms:
        enabled: false
```

## 4. 开关优先级

投递判定顺序如下：

1. `verification-code-log-enabled=true`：仅输出日志，立即结束。
2. 根据请求的 `provider` 选择 Email 或 SMS。
3. 读取对应的数据库热开关。
4. 数据库不存在对应参数时，读取 YAML 的 `enabled` 兜底值。
5. 检查 SMTP 配置或 SMS 网关 Bean。
6. 执行发送。

建议环境配置：

| 环境 | 日志模式 | Email 热开关 | SMS 热开关 |
| --- | --- | --- | --- |
| 本地纯开发 | 开启 | 关闭 | 关闭 |
| Email 联调 | 关闭 | 开启 | 关闭 |
| SMS 联调 | 关闭 | 关闭 | 开启 |
| 生产环境 | 关闭 | 按业务启用 | 按业务启用 |

## 5. 失败与回滚

验证码会先写入 Redis，再执行外部投递。如果投递失败，系统会删除：

- 本次生成的验证码；
- 本次请求产生的发送冷却记录。

因此用户可以在外部服务恢复后重新请求，不会因为失败投递而持有一个无法收到的有效验证码，也不会被错误冷却。

日志仅在必要位置记录脱敏后的邮箱或手机号。不得记录 SMTP 密码、API Key、短信密钥等敏感信息。

## 6. Email 联调清单

1. 配置全部 SMTP 环境变量。
2. 将 `verification-code-log-enabled` 设置为 `false`。
3. 将 `cupid.verification.email.enabled` 设置为 `true`。
4. 保持 `cupid.verification.sms.enabled` 为 `false`。
5. 重启后端，使启动环境变量生效。
6. 使用允许接收测试邮件的邮箱请求验证码。
7. 检查收件箱、垃圾邮件目录和供应商发送记录。
8. 使用邮件中的验证码完成验证。
9. 故意配置错误密码，确认投递失败后可以立即重新请求。

## 7. SMS 联调清单

1. 完成并注册 `CupidSmsGateway` 供应商实现。
2. 配置供应商凭据、签名和模板环境变量。
3. 将 `verification-code-log-enabled` 设置为 `false`。
4. 将 `cupid.verification.sms.enabled` 设置为 `true`。
5. 使用有效手机号请求验证码。
6. 检查供应商发送记录和手机收件情况。
7. 分别验证注册、密码重置和通用场景的模板映射。
8. 模拟供应商失败，确认验证码和冷却记录正确回滚。

