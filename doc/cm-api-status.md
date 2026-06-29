# Cupid Match API 实现与使用状态

## 1. 文档用途

本文记录 Cupid Match 当前 API 的后端实现状态和前端使用状态，作为后续人工验收、后台运营开发和生产化工作的检查清单。

状态定义：

- `完成`：Java 后端已有 Controller 和业务实现。
- `契约占位`：接口已实现，但按当前契约只返回占位结果，不执行最终外部流程。
- `未实现（计划内）`：Java 后端当前没有对应接口，后续由后台运营或生产化阶段替代。
- `已使用`：前端产品页面通过 hook 或 API 模块实际调用。
- `仅封装`：前端已有 API 函数，但当前没有页面或 hook 调用。
- `未接入`：前端没有对应产品 API 函数或 UI。

## 2. 产品 API 汇总

- 产品 API：55 个。
- 后端完成：54 个。
- 按契约占位：1 个，会员升级只进入外部流程。
- 前端已使用：53 个。
- 前端仅封装：1 个，`GET /api/account/me`。
- 前端未接入：1 个，Inbox 发送消息。

`GET /api/membership/catalog` 已在最终契约正文、Java Controller 和前端中存在，但遗漏于 `final-api-contract.md` 顶部 API 汇总表。本文按实际产品接口将其计入。

## 3. Auth

| API | 用途 | 后端状态 | 前端状态 | 前端入口 |
| --- | --- | --- | --- | --- |
| `POST /api/auth/register` | 注册并创建登录会话 | 完成 | 已使用 | `use-register.ts` |
| `POST /api/auth/verification-code` | 获取注册验证码元数据 | 完成 | 已使用 | `use-register.ts` |
| `POST /api/auth/password-reset-code` | 获取密码重置验证码元数据 | 完成 | 已使用 | `use-forgot-password.ts` |
| `POST /api/auth/password/reset` | 验证并重置密码 | 完成 | 已使用 | `use-forgot-password.ts` |
| `POST /api/auth/login` | 登录并创建 Redis 会话 | 完成 | 已使用 | `use-login.ts` |
| `POST /api/auth/logout` | 注销当前 Redis 会话 | 完成 | 已使用 | `AppHeader.vue` |

## 4. Legal

| API | 用途 | 后端状态 | 前端状态 | 前端入口 |
| --- | --- | --- | --- | --- |
| `GET /api/legal/documents/:type` | 获取服务条款或隐私说明 | 完成 | 已使用 | `use-agreement-dialog.ts` |

## 5. Profiles

| API | 用途 | 后端状态 | 前端状态 | 前端入口 |
| --- | --- | --- | --- | --- |
| `GET /api/profiles/featured` | 首页精选 self profiles | 完成 | 已使用 | `use-home-self-profiles.ts` |
| `GET /api/profiles/self` | self 资料目录 | 完成 | 已使用 | `use-self-profile-directory.ts` |
| `GET /api/profiles/family` | family 资料目录 | 完成 | 已使用 | `use-family-profile-directory.ts` |
| `GET /api/profiles/self/:id` | self 资料详情 | 完成 | 已使用 | `use-self-profile-detail.ts` |
| `GET /api/profiles/family/:id` | family 资料详情 | 完成 | 已使用 | `use-family-profile-detail.ts` |

## 6. Favorites

| API | 用途 | 后端状态 | 前端状态 | 前端入口 |
| --- | --- | --- | --- | --- |
| `POST /api/favorites/:profileId` | 收藏 profile | 完成 | 已使用 | self/family detail hooks |
| `DELETE /api/favorites/:profileId` | 取消收藏 | 完成 | 已使用 | self/family detail hooks |

## 7. Private Introductions

| API | 用途 | 后端状态 | 前端状态 | 前端入口 |
| --- | --- | --- | --- | --- |
| `POST /api/profiles/self/:id/private-introduction` | 申请 self 私人介绍 | 完成 | 已使用 | `use-self-profile-detail.ts` |
| `POST /api/profiles/family/:id/private-introduction` | 申请 family 私人介绍 | 完成 | 已使用 | `use-family-profile-detail.ts` |

申请的后台接受、拒绝和正式处理不属于上述前台接口，计划在 RuoYi 后台运营阶段实现。

## 8. Inbox

| API | 用途 | 后端状态 | 前端状态 | 前端入口 |
| --- | --- | --- | --- | --- |
| `GET /api/inbox/threads` | 查询消息线程 | 完成 | 已使用 | `use-messages-inbox.ts` |
| `GET /api/inbox/threads/:id/messages` | 分页查询线程消息 | 完成 | 已使用 | `use-messages-inbox.ts` |
| `POST /api/inbox/threads/:id/read` | 标记线程已读 | 完成 | 已使用 | `use-messages-inbox.ts` |
| `POST /api/inbox/threads/:id/messages` | 在允许的线程中发送消息 | 完成 | 未接入 | 产品 UI 尚未开放发送功能 |

### 8.1 后台通知发布

| API | 用途 | 后端状态 | 后台状态 | 后台入口 |
| --- | --- | --- | --- | --- |
| `GET /cupid/inbox/users` | 搜索通知目标用户 | 完成 | 已使用 | 通知发布 |
| `GET /cupid/inbox/subjects` | 搜索与目标用户关联的业务对象 | 完成 | 已使用 | 通知发布 |
| `GET /cupid/inbox/templates` | 查询启用模板 | 完成 | 已使用 | 通知发布 |
| `POST /cupid/inbox/preview` | 单发内容预览 | 完成 | 已使用 | 通知发布 |
| `POST /cupid/inbox/notify` | 单用户通知 | 完成 | 已使用 | 通知发布 |
| `POST /cupid/inbox/broadcast/preview` | 群发范围和内容预览 | 完成 | 已使用 | 通知发布 |
| `POST /cupid/inbox/broadcast` | 简易群发 | 完成 | 已使用 | 通知发布 |
| `GET /cupid/inboxTemplate/list` | 模板列表 | 完成 | 已使用 | 通知模板 |
| `GET /cupid/inboxTemplate/:id` | 模板详情 | 完成 | 已使用 | 通知模板 |
| `POST /cupid/inboxTemplate` | 新增三语模板 | 完成 | 已使用 | 通知模板 |
| `PUT /cupid/inboxTemplate/:id` | 编辑模板 | 完成 | 已使用 | 通知模板 |
| `POST /cupid/inboxTemplate/:id/status` | 模板启停 | 完成 | 已使用 | 通知模板 |

后台不提供查看全部 C 端线程或历史消息的接口。资料、照片、认证、活动报名和私人介绍状态变更通过事务提交后的领域事件自动通知。

## 9. Events

| API | 用途 | 后端状态 | 前端状态 | 前端入口 |
| --- | --- | --- | --- | --- |
| `GET /api/events` | 活动目录 | 完成 | 已使用 | home/events directory hooks |
| `GET /api/events/:id` | 活动详情 | 完成 | 已使用 | `use-event-detail.ts` |
| `POST /api/events/:id/register` | 申请活动报名 | 完成 | 已使用 | `use-event-detail.ts` |
| `POST /api/events/:id/cancel` | 取消活动报名 | 完成 | 已使用 | `use-event-detail.ts` |

报名确认、候补和拒绝属于后台审核动作，计划在 RuoYi 后台运营阶段实现。

## 10. Account Overview And Profiles

| API | 用途 | 后端状态 | 前端状态 | 前端入口 |
| --- | --- | --- | --- | --- |
| `GET /api/account/me` | 查询当前账户身份 | 完成 | 仅封装 | `account.ts` 中存在 `getAccountMe`，当前无调用方 |
| `POST /api/account/me` | 更新账户基础信息 | 完成 | 已使用 | `use-account-settings.ts` |
| `GET /api/account/dashboard` | 查询账户首页聚合 | 完成 | 已使用 | `use-account-dashboard.ts` |
| `GET /api/account/profiles` | 查询当前用户管理的 profiles | 完成 | 已使用 | `use-account-profiles.ts` |
| `GET /api/account/profiles/:profileId` | 查询可管理 profile 详情 | 完成 | 已使用 | `use-account-profile-detail.ts` |
| `POST /api/account/profiles/save` | 创建或保存 profile 草稿 | 完成 | 已使用 | `use-account-profile-detail.ts` |
| `POST /api/account/profiles/:profileId/archive` | 归档 profile | 完成 | 已使用 | `use-account-profile-detail.ts` |
| `POST /api/account/profiles/:profileId/privacy-preferences` | 更新 profile 隐私偏好 | 完成 | 已使用 | `use-account-profile-detail.ts` |

## 11. Account Relationships And Membership

| API | 用途 | 后端状态 | 前端状态 | 前端入口 |
| --- | --- | --- | --- | --- |
| `GET /api/account/membership` | 查询当前会员和权益 | 完成 | 已使用 | `use-account-membership.ts` |
| `GET /api/account/favorites` | 查询收藏列表 | 完成 | 已使用 | `use-account-relationship.ts` |
| `GET /api/account/events` | 查询账户活动报名 | 完成 | 已使用 | `use-account-events.ts` |
| `GET /api/account/private-introductions` | 查询私人介绍申请 | 完成 | 已使用 | `use-account-relationship.ts` |
| `GET /api/account/private-introductions/:requestId/contact` | 获取已接受介绍的联系方式 | 完成 | 已使用 | `use-account-relationship.ts` |
| `POST /api/account/membership/upgrade` | 发起会员升级 | 契约占位 | 已使用 | `use-account-membership.ts` |

会员升级当前只返回 `pending_external_flow` 和 `requestedTier`，不创建订单、不支付、不修改会员或权益。正式流程属于支付与生产化阶段。

## 12. Account Settings And Security

| API | 用途 | 后端状态 | 前端状态 | 前端入口 |
| --- | --- | --- | --- | --- |
| `GET /api/account/settings` | 查询账户设置聚合 | 完成 | 已使用 | `use-account-settings.ts` |
| `POST /api/account/settings/preferences` | 更新账户偏好 | 完成 | 已使用 | `use-account-settings.ts` |
| `POST /api/account/identities/verification-code` | 获取身份绑定验证码 | 完成 | 已使用 | `use-account-settings.ts` |
| `POST /api/account/identities` | 绑定 email 或 phone 身份 | 完成 | 已使用 | `use-account-settings.ts` |
| `DELETE /api/account/identities/:id` | 解绑身份 | 完成 | 已使用 | `use-account-settings.ts` |
| `GET /api/account/mfa/status` | 查询 MFA 状态 | 完成 | 已使用 | `use-account-settings.ts` |
| `POST /api/account/mfa/verification-code` | 获取 MFA 验证码 | 完成 | 已使用 | `use-account-settings.ts` |
| `POST /api/account/mfa/enable` | 开启 MFA | 完成 | 已使用 | `use-account-settings.ts` |
| `POST /api/account/mfa/disable` | 关闭 MFA | 完成 | 已使用 | `use-account-settings.ts` |
| `POST /api/account/security/challenge-code` | 获取敏感操作验证码 | 完成 | 已使用 | `use-account-settings.ts` |
| `POST /api/account/security/challenge` | 验证敏感操作并获取 challenge token | 完成 | 已使用 | `use-account-settings.ts` |
| `POST /api/account/password/change` | 修改密码并注销全部旧会话 | 完成 | 已使用 | `use-account-settings.ts` |
| `POST /api/account/export` | 创建账户数据导出 | 完成 | 已使用 | `use-account-settings.ts` |
| `GET /api/account/export/download` | 下载账户数据导出 | 完成 | 已使用 | `use-account-settings.ts` |
| `POST /api/account/deactivate` | 停用当前账户 | 完成 | 已使用 | `use-account-settings.ts` |

当前验证码由开发实现生成并写入日志；真实 Email/SMS 发送通道属于生产化阶段。

## 13. Membership Catalog And Upload

| API | 用途 | 后端状态 | 前端状态 | 前端入口 |
| --- | --- | --- | --- | --- |
| `GET /api/membership/catalog` | 查询公开会员套餐 | 完成 | 已使用 | `use-membership-catalog.ts` |
| `POST /api/upload` | multipart 图片上传 | 完成 | 已使用 | account profile/settings hooks |

上传当前使用本地文件存储；迁移对象存储属于生产化阶段。

## 14. Debug API

Java 后端按实施计划不开放 `/api/debug/*`。以下接口仍存在于前端 Debug API 和 Debug 页面中，仅用于 Mock Server 或开发调试，不属于当前 Java 产品 API。Debug 页面继续保留；生产环境通过 `VITE_ENABLE_DEBUG=false` 禁止访问，但当前仍会进入构建产物。

| API | 前端状态 | Java 后端状态 | 后续去向 |
| --- | --- | --- | --- |
| `GET /api/debug/private-introductions` | Debug 页面使用 | 未实现（计划内） | 后台私人介绍处理 |
| `POST /api/debug/private-introductions/:id/accept` | Debug 页面使用 | 未实现（计划内） | 后台接受操作 |
| `POST /api/debug/private-introductions/:id/decline` | Debug 页面使用 | 未实现（计划内） | 后台拒绝操作 |
| `GET /api/debug/event-registrations` | Debug 页面使用 | 未实现（计划内） | 后台报名审核 |
| `POST /api/debug/event-registrations/:id/review/:status` | Debug 页面使用 | 未实现（计划内） | 后台报名状态操作 |
| `GET /api/debug/events` | Debug 页面使用 | 未实现（计划内） | 后台活动管理 |
| `POST /api/debug/events/:eventId/status` | Debug 页面使用 | 未实现（计划内） | 后台活动状态操作 |
| `GET /api/debug/events-preview/:eventId` | Debug 页面使用 | 未实现（计划内） | 不进入产品 API |
| `POST /api/debug/events-preview/:eventId/register` | Debug 页面使用 | 未实现（计划内） | 不进入产品 API |
| `POST /api/debug/events-preview/:eventId/cancel` | Debug 页面使用 | 未实现（计划内） | 不进入产品 API |
| `GET /api/debug/inbox/threads` | Debug 页面使用 | 未实现（计划内） | 后台通知工具 |
| `POST /api/debug/inbox/notify` | Debug 页面使用 | 未实现（计划内） | 后台通知操作 |
| `GET /api/debug/profile-access-preview/:profileType/:profileId` | Debug 页面使用 | 未实现（计划内） | 保留为开发预览工具 |
| `GET /api/debug/profile-photos` | Debug 页面使用 | 未实现（计划内） | 后台照片审核 |
| `POST /api/debug/profile-photos/:id/review/:status` | Debug 页面使用 | 未实现（计划内） | 后台照片审核操作 |
| `GET /api/debug/profile-verifications` | Debug 页面使用 | 未实现（计划内） | 后台身份审核 |
| `POST /api/debug/profile-verifications/:profileId/:field/:status` | Debug 页面使用 | 未实现（计划内） | 后台身份审核操作 |
| `GET /api/debug/verification-codes` | Debug 页面使用 | 未实现（计划内） | 仅保留本地开发工具 |

Mock Server 还存在 `POST /api/debug/identities/:id/verify`。前端没有封装或使用该接口，它会绕过验证码直接验证身份，属于遗留测试捷径，不迁移到 Java 或正式后台。

## 15. 尚未由产品 API 覆盖的后续能力

以下能力不应被误判为当前 API 缺失，它们属于后续阶段的新后台接口或基础设施：

- Profile、Photo、Verification 后台审核。
- Private Introduction 后台接受和拒绝。
- Event 管理以及报名确认、候补和拒绝。
- Inbox 后台通知工具。
- User 状态管理和 Staff tasks。
- 正式支付、订单和会员确认。
- 完整业务审计日志。
- Email/SMS 真实验证码通道。
- 对象存储、限流、防爆破、部署健康检查和自动化集成测试。
