# Cupid Match 初始化账号说明

本文记录 `sql/cm_required_seed.sql` 和 `sql/cm_demo_seed.sql` 写入的本地开发账号。账号只用于本地开发、联调和验收，不得作为生产环境账号或生产密码策略。

## 后台账号

后台账号来自 `sql/cm_required_seed.sql`，用于登录 Cupid Match 后台管理端。

默认密码：`admin123`

| 用户名 | 昵称 | 部门 | 角色 | 主要用途 |
| --- | --- | --- | --- | --- |
| `admin` | 平台管理员 | 管理与财务 | 超级管理员 | RuoYi 与 Cupid 全局管理，适合初始化、兜底排查和权限配置。 |
| `cupid_admin` | Cupid 运营管理员 | 运营增长 | Cupid 平台管理员 | Cupid 全量运营权限，用于日常运营主账号验收。 |
| `cupid_reviewer` | 审核专员 | 审核风控 | Cupid 审核员 | 资料、照片、认证材料、私人介绍审核。 |
| `cupid_profile_ops` | 资料运营专员 | 运营增长 | Cupid 资料运营 | 资料库查看、资料运营字段维护、内部备注维护。 |
| `cupid_event` | 活动运营 | 运营增长 | Cupid 活动管理员 | 活动创建、状态调整、报名审核和活动运营验收。 |
| `cupid_support` | 用户支持 | 用户支持 | Cupid 用户支持 | App 用户查询、通知发布、联系咨询、跟进事项处理。 |
| `cupid_content` | 内容配置专员 | 产品技术 | Cupid 内容配置 | 通用选项、通知模板、服务条款与隐私政策维护。 |
| `cupid_payment` | 支付财务专员 | 管理与财务 | Cupid 支付财务 | 会员、支付订单、Stripe 回调日志、取消续费和退款处理。 |
| `cupid_auditor` | 业务审计 | 管理与财务 | Cupid 审计员 | 业务审计、安全事件和核心业务只读检查。 |
| `cupid_monitor` | 运营监控观察员 | 运营增长 | Cupid 运营监控 | 业务监控、审计和安全事件只读观察。 |

建议验收权限时优先使用岗位账号，不要长期使用 `admin` 作为唯一测试账号。

## C 端演示账号

C 端账号来自 `sql/cm_demo_seed.sql`，用于登录 C 端 H5。

默认密码：`password123`

邮箱使用保留测试域 `rencontreaparis.test`，用于表达业务语义，不用于真实邮件投递。

| 登录标识 | 用户 | 账号状态 | 会员状态 | 主要用途 |
| --- | --- | --- | --- | --- |
| `lin.yuanhang@rencontreaparis.test` | 林远航 | 正常 | 黄金会员，生效中 | 主验收账号：C 端登录、会员状态、消息中心、活动报名、私人介绍、支付订单、安全挑战。 |
| `13333333333` | 林远航 | 正常 | 黄金会员，生效中 | 同一用户的手机号身份，用于验证多登录身份绑定。 |
| `aline.moreau@rencontreaparis.test` | Aline Moreau | 正常 | 免费会员，生效中 | 免费会员与公开资料展示样例。 |
| `sophie.laurent@rencontreaparis.test` | Sophie Laurent | 正常 | 白银会员，生效中 | 白银会员、资料待审核样例。 |
| `martin.keller@rencontreaparis.test` | Martin Keller | 正常 | 钻石会员，生效中 | 钻石会员、权益余额、群发失败重试样例。 |
| `iris.vandijk@rencontreaparis.test` | Iris Van Dijk | 正常 | 免费会员，生效中 | 免费会员、普通公开资料样例。 |
| `aline.durand@rencontreaparis.test` | Aline Durand | 正常 | 免费会员，生效中 | 后台资料与认证审核待处理样例。 |
| `julien.chen@rencontreaparis.test` | Julien Chen | 正常 | 免费会员，生效中 | 家庭资料与审核完成样例。 |
| `elise.bernard@rencontreaparis.test` | Élise Bernard | 正常 | 免费会员，生效中 | 认证材料驳回与补充审核样例。 |
| `marc.lefevre@rencontreaparis.test` | Marc Lefèvre | 已停用 | 白银会员，已过期 | App 用户停用、会员过期、退款订单样例；登录应被拦截。 |
| `nina.roche@rencontreaparis.test` | Nina Roche | 已封禁 | 黄金会员，已取消续费 | App 用户封禁、跟进事项和审计样例；登录应被拦截。 |
| `hugo.lambert@rencontreaparis.test` | Hugo Lambert | 正常 | 免费会员，生效中 | 新注册用户、隐藏资料、基础账号状态样例。 |

## 数据覆盖边界

- `cm_required_seed.sql` 只放后台运行必须数据：公司部门、岗位、后台账号、角色权限、菜单、字典、系统配置、定时任务、会员套餐、选项、通知模板和法律条款。
- `cm_demo_seed.sql` 放 C 端和后台验收样例：用户、登录身份、资料、认证、会员、权益、活动、报名、消息、群发记录、失败重试、联系咨询、支付、Webhook、安全事件、翻译重试、跟进事项和审计日志。
- demo 中每个 `cm_profiles` 资料都有 active owner，每个 active `cm_users` 用户都有 active membership。
- demo 密码和邮箱都不是生产数据；生产环境必须重新创建后台账号，并使用真实密钥、SMTP、SMS、Stripe 配置。
