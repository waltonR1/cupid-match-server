-- ----------------------------
-- Cupid Match 后台基础配置
-- ----------------------------
-- 本脚本在 RuoYi 原始初始化脚本执行后运行，只维护 Cupid 后台增量配置。
-- 不修改 RuoYi 表结构，不创建尚无 Vue 页面对应的业务菜单。
-- 后续每个 Phase 在真实页面存在后，将对应 M/C/F 菜单和角色授权追加到本文件。

start transaction;

-- ----------------------------
-- 1. 清理 RuoYi 演示入口
-- ----------------------------

-- 先删除角色菜单关系，再删除“若依官网”菜单。
delete rm
from sys_role_menu rm
inner join sys_menu m on m.menu_id = rm.menu_id
where m.menu_id = 4
  and m.menu_name = '若依官网'
  and m.path = 'http://ruoyi.vip';

delete from sys_menu
where menu_id = 4
  and menu_name = '若依官网'
  and path = 'http://ruoyi.vip';

-- 先删除演示公告的已读记录，再删除 RuoYi 原始演示公告。
delete nr
from sys_notice_read nr
inner join sys_notice n on n.notice_id = nr.notice_id
where (n.notice_id = 1 and n.notice_title = '温馨提醒：2018-07-01 若依新版本发布啦')
   or (n.notice_id = 2 and n.notice_title = '维护通知：2018-07-01 若依系统凌晨维护')
   or (n.notice_id = 3 and n.notice_title = '若依开源框架介绍');

delete from sys_notice
where (notice_id = 1 and notice_title = '温馨提醒：2018-07-01 若依新版本发布啦')
   or (notice_id = 2 and notice_title = '维护通知：2018-07-01 若依系统凌晨维护')
   or (notice_id = 3 and notice_title = '若依开源框架介绍');

-- ----------------------------
-- 2. 创建 Cupid 后台角色
-- ----------------------------
-- role_id 使用 sys_role 自增值，不在业务脚本中硬编码。
-- 已存在相同 role_key 时不覆盖管理员后续维护的角色名称、状态或数据范围。

insert into sys_role (
    role_name, role_key, role_sort, data_scope,
    menu_check_strictly, dept_check_strictly,
    status, del_flag, create_by, create_time, remark
)
select
    'Cupid 平台管理员', 'cupid_admin', 10, '1',
    1, 1, '0', '0', 'admin', sysdate(), '全部 Cupid 运营能力，不默认授予 RuoYi 系统菜单'
where not exists (
    select 1 from sys_role where role_key = 'cupid_admin' and del_flag = '0'
);

insert into sys_role (
    role_name, role_key, role_sort, data_scope,
    menu_check_strictly, dept_check_strictly,
    status, del_flag, create_by, create_time, remark
)
select
    'Cupid 审核员', 'cupid_reviewer', 11, '1',
    1, 1, '0', '0', 'admin', sysdate(), 'Profile、Photo、Verification 和 Introduction 审核'
where not exists (
    select 1 from sys_role where role_key = 'cupid_reviewer' and del_flag = '0'
);

insert into sys_role (
    role_name, role_key, role_sort, data_scope,
    menu_check_strictly, dept_check_strictly,
    status, del_flag, create_by, create_time, remark
)
select
    'Cupid 活动管理员', 'cupid_event_manager', 12, '1',
    1, 1, '0', '0', 'admin', sysdate(), 'Event 和 Event Registration 运营'
where not exists (
    select 1 from sys_role where role_key = 'cupid_event_manager' and del_flag = '0'
);

insert into sys_role (
    role_name, role_key, role_sort, data_scope,
    menu_check_strictly, dept_check_strictly,
    status, del_flag, create_by, create_time, remark
)
select
    'Cupid 用户支持', 'cupid_support', 13, '1',
    1, 1, '0', '0', 'admin', sysdate(), 'App User、Inbox 和 Staff Task 运营'
where not exists (
    select 1 from sys_role where role_key = 'cupid_support' and del_flag = '0'
);

insert into sys_role (
    role_name, role_key, role_sort, data_scope,
    menu_check_strictly, dept_check_strictly,
    status, del_flag, create_by, create_time, remark
)
select
    'Cupid 审计员', 'cupid_auditor', 14, '1',
    1, 1, '0', '0', 'admin', sysdate(), 'Cupid 业务审计只读'
where not exists (
    select 1 from sys_role where role_key = 'cupid_auditor' and del_flag = '0'
);

-- ----------------------------
-- 3. Cupid 菜单和角色授权
-- ----------------------------
-- Phase 8.1 不创建空业务菜单。
-- 后续模块必须在对应 src/views/cupid/**/index.vue 存在后，才追加：
-- 1. 一级 M 目录；
-- 2. 对应 C 页面菜单；
-- 3. 对应 F 按钮权限；
-- 4. 通过 role_key 查询 role_id 后写入 sys_role_menu。

commit;
