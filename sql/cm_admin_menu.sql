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
-- Phase 8.2：审核中心菜单与资料中心菜单。
-- 对应页面已存在：
-- - cupid-match-admin/src/views/cupid/profile/index.vue
-- - cupid-match-admin/src/views/cupid/photo/index.vue
-- - cupid-match-admin/src/views/cupid/verification/identity/index.vue
-- - cupid-match-admin/src/views/cupid/verification/education/index.vue
-- - cupid-match-admin/src/views/cupid/verification/income/index.vue
-- - cupid-match-admin/src/views/cupid/verification/marital/index.vue
-- - cupid-match-admin/src/views/cupid/profile-library/index.vue
-- - cupid-match-admin/src/views/cupid/profile-manage/index.vue

delete from sys_role_menu where menu_id between 2000 and 2049;
delete from sys_menu where menu_id between 2000 and 2049;

insert into sys_menu values
('2000', '审核中心', '0', '10', 'cupid', null, '', 'Cupid', 1, 0, 'M', '0', '0', '', 'clipboard', 'admin', sysdate(), '', null, 'Cupid 审核中心目录'),
('2010', '资料审核', '2000', '1', 'profile', 'cupid/profile/index', '', 'CupidProfile', 1, 0, 'C', '0', '0', 'cupid:profile:list', 'user', 'admin', sysdate(), '', null, 'Cupid 资料审核页面'),
('2011', '资料查询', '2010', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profile:query', '#', 'admin', sysdate(), '', null, ''),
('2012', '资料审核', '2010', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profile:review', '#', 'admin', sysdate(), '', null, ''),
('2020', '照片审核', '2000', '2', 'photo', 'cupid/photo/index', '', 'CupidPhoto', 1, 0, 'C', '0', '0', 'cupid:photo:list', 'eye', 'admin', sysdate(), '', null, 'Cupid 照片审核页面'),
('2021', '照片查询', '2020', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:photo:query', '#', 'admin', sysdate(), '', null, ''),
('2022', '照片审核', '2020', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:photo:review', '#', 'admin', sysdate(), '', null, ''),
('2030', '认证审核', '2000', '3', 'verification', null, '', 'CupidVerificationRoot', 1, 0, 'M', '0', '0', '', 'education', 'admin', sysdate(), '', null, 'Cupid 四类认证材料审核目录'),
('2031', '身份认证审核', '2030', '1', 'identity', 'cupid/verification/identity/index', '', 'CupidIdentityVerification', 1, 0, 'C', '0', '0', 'cupid:verification:identity:list', 'peoples', 'admin', sysdate(), '', null, 'Cupid 身份认证材料审核页面'),
('2032', '学历认证审核', '2030', '2', 'education', 'cupid/verification/education/index', '', 'CupidEducationVerification', 1, 0, 'C', '0', '0', 'cupid:verification:education:list', 'education', 'admin', sysdate(), '', null, 'Cupid 学历认证材料审核页面'),
('2033', '收入认证审核', '2030', '3', 'income', 'cupid/verification/income/index', '', 'CupidIncomeVerification', 1, 0, 'C', '0', '0', 'cupid:verification:income:list', 'money', 'admin', sysdate(), '', null, 'Cupid 收入认证材料审核页面'),
('2034', '婚姻认证审核', '2030', '4', 'marital', 'cupid/verification/marital/index', '', 'CupidMaritalVerification', 1, 0, 'C', '0', '0', 'cupid:verification:marital:list', 'people', 'admin', sysdate(), '', null, 'Cupid 婚姻认证材料审核页面'),
('2035', '认证列表', '2030', '5', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:verification:list', '#', 'admin', sysdate(), '', null, ''),
('2036', '认证查询', '2030', '6', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:verification:query', '#', 'admin', sysdate(), '', null, ''),
('2037', '认证审核', '2030', '7', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:verification:review', '#', 'admin', sysdate(), '', null, ''),
('2040', '资料中心', '0', '11', 'profile-center', null, '', 'CupidProfileCenterRoot', 1, 0, 'M', '0', '0', '', 'user', 'admin', sysdate(), '', null, 'Cupid 资料中心目录'),
('2041', '资料库', '2040', '1', 'library', 'cupid/profile-library/index', '', 'CupidProfileLibrary', 1, 0, 'C', '0', '0', 'cupid:profileLibrary:list', 'list', 'admin', sysdate(), '', null, 'Cupid 资料库只读页面'),
('2042', '资料库查询', '2041', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profileLibrary:query', '#', 'admin', sysdate(), '', null, ''),
('2043', '资料运营', '2040', '2', 'manage', 'cupid/profile-manage/index', '', 'CupidProfileManage', 1, 0, 'C', '0', '0', 'cupid:profileManage:list', 'edit', 'admin', sysdate(), '', null, 'Cupid 资料运营管理页面'),
('2044', '资料运营查询', '2043', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profileManage:query', '#', 'admin', sysdate(), '', null, ''),
('2045', '运营字段编辑', '2043', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profileManage:edit', '#', 'admin', sysdate(), '', null, ''),
('2046', '内部备注查看', '2043', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profileManage:notes', '#', 'admin', sysdate(), '', null, ''),
('2047', '内部备注编辑', '2043', '4', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profileManage:editNotes', '#', 'admin', sysdate(), '', null, '');

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id
from sys_role r
join sys_menu m on m.menu_id between 2000 and 2049
where r.role_key = 'cupid_admin'
  and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id
from sys_role r
join sys_menu m on m.menu_id between 2000 and 2039
where r.role_key = 'cupid_reviewer'
  and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id
from sys_role r
join sys_menu m on m.menu_id in (2000, 2010, 2011, 2020, 2021, 2030, 2031, 2032, 2033, 2034, 2035, 2036)
where r.role_key = 'cupid_auditor'
  and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id
from sys_role r
join sys_menu m on m.menu_id in (2040, 2041, 2042)
where r.role_key = 'cupid_support'
  and r.del_flag = '0';

commit;
