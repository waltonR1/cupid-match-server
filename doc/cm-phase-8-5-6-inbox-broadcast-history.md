# Phase 8.5.6：Inbox 后台发送记录

## 1. 目标

- 为后台通知补齐“发送后可回看”的运营能力。
- 让后台能够查看群发历史、发送批次结果和目标用户明细。
- 保持当前 C 端收件箱模型不变，不重做线程归档方式。

## 2. 非目标

- 不调整 C 端消息中心展示结构。
- 不修改现有通知模板、多语言和投递逻辑。
- 不在本阶段实现撤回、重发、导出和完整单发审计中心。
- 不改变“同业务对象复用同一系统线程”的当前收件箱模型。

## 3. 范围

本阶段只补“后台群发记录可追溯性”，不扩展到完整消息运营中心。

## 4. 数据结构

新增 `cm_inbox_broadcasts`，用于记录每次群发任务的主信息：

- `id`
- `staff_user_id`
- `scope`
- `tier`
- `mode`
- `template_code`
- `locale`
- `subject_type`
- `payload_json`
- `target_count`
- `success_count`
- `failure_count`
- `created_at`
- `updated_at`

新增 `cm_inbox_broadcast_targets`，用于记录每次群发下的目标投递结果：

- `id`
- `broadcast_id`
- `user_id`
- `message_id`
- `status`
- `error_message`
- `created_at`

## 5. 后端改动

- 后台群发执行时，先创建 `cm_inbox_broadcasts` 主记录，再逐个用户写入目标记录。
- 投递成功时记录 `message_id` 和 `status=success`。
- 投递失败时记录 `status=failure` 和 `error_message`。
- 群发结束后回写 `target_count`、`success_count`、`failure_count`。
- 新增后台查询接口：
  - `GET /cupid/inbox/broadcast/list`
  - `GET /cupid/inbox/broadcast/{id}`

## 6. 后台页面改动

- 在现有通知发送页下方补充“最近群发记录”区域。
- 列表展示发送时间、发送人、发送模式、模板或摘要、目标人数、成功数、失败数。
- 支持查看详情；详情使用抽屉或弹窗展示目标用户列表和失败原因。
- 当前发送表单、模板选择、预览和发送流程保持不变。

## 7. 验收标准

1. 后台执行一次群发后，可在记录列表中看到该批次。
2. 列表能正确展示目标人数、成功数、失败数。
3. 点开详情后，可查看目标用户及失败原因。
4. 不影响当前单发、群发、模板预览和 C 端消息展示。
5. 后台重启后历史记录仍可查询。

## 8. 阶段结论

`8.5` 完成 Inbox 通知发送与 C 端承接。  
`8.5.6` 用于补齐后台发送记录与群发可追溯性，使通知能力具备基本运营闭环。
