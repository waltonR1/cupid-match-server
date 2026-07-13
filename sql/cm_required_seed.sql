-- Cupid Match required seed data (DML only)
-- Run after sql/cm_schema.sql.
-- Contains only backend runtime data: framework system basics, Cupid organization/accounts/permissions,
-- platform dictionaries/configs/jobs, options, membership plans, legal documents and message templates.

start transaction;

-- Clean runtime seed rows managed by this file.
delete from sys_user_role where user_id in (1, 10, 11, 12, 13, 14, 15, 16, 17, 18) or role_id in (
  select role_id from sys_role where role_id in (1, 2) or role_key in ('cupid_admin', 'cupid_reviewer', 'cupid_event_manager', 'cupid_support', 'cupid_auditor', 'cupid_profile_operator', 'cupid_content_operator', 'cupid_payment_operator', 'cupid_monitor_reader')
);
delete from sys_user_post where user_id in (1, 10, 11, 12, 13, 14, 15, 16, 17, 18);
delete from sys_role_menu where menu_id in (
  select menu_id from sys_menu where (menu_id between 1 and 117) or (menu_id between 500 and 501) or (menu_id between 1000 and 1061) or (menu_id between 2000 and 2120)
) or role_id in (
  select role_id from sys_role where role_id in (1, 2) or role_key in ('cupid_admin', 'cupid_reviewer', 'cupid_event_manager', 'cupid_support', 'cupid_auditor', 'cupid_profile_operator', 'cupid_content_operator', 'cupid_payment_operator', 'cupid_monitor_reader')
);
delete from sys_role_dept where dept_id between 100 and 199 or role_id in (
  select role_id from sys_role where role_id in (1, 2) or role_key in ('cupid_admin', 'cupid_reviewer', 'cupid_event_manager', 'cupid_support', 'cupid_auditor', 'cupid_profile_operator', 'cupid_content_operator', 'cupid_payment_operator', 'cupid_monitor_reader')
);
delete from sys_user where user_id in (1, 10, 11, 12, 13, 14, 15, 16, 17, 18);
delete from sys_role where role_id in (1, 2) or role_key in ('cupid_admin', 'cupid_reviewer', 'cupid_event_manager', 'cupid_support', 'cupid_auditor', 'cupid_profile_operator', 'cupid_content_operator', 'cupid_payment_operator', 'cupid_monitor_reader');
delete from sys_post where post_id in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
delete from sys_dept where dept_id between 100 and 199;
delete from sys_menu where (menu_id between 1 and 117) or (menu_id between 500 and 501) or (menu_id between 1000 and 1061) or (menu_id between 2000 and 2120);
delete from sys_dict_data where dict_code between 1 and 30;
delete from sys_dict_type where dict_id between 1 and 10;
delete from sys_config where config_id between 1 and 17;
delete from sys_job where job_id between 1 and 12;
delete from cm_option_values;
delete from cm_option_groups;
delete from cm_inbox_template_localized_fields;
delete from cm_inbox_templates;
delete from cm_membership_plan_payment_prices;
delete from cm_membership_plan_localized_fields;
delete from cm_membership_plans;
delete from cm_legal_document_contents;
delete from cm_legal_documents;

-- Cupid company structure: compact small-company distribution.
insert into sys_dept (dept_id, parent_id, ancestors, dept_name, order_num, leader, phone, email, status, del_flag, create_by, create_time, update_by, update_time) values
(100, 0, '0', 'Cupid Match', 0, '平台管理员', '', 'ops@cupid-match.local', '0', '0', 'admin', sysdate(), '', null),
(101, 100, '0,100', '管理与财务', 1, '平台管理员', '', 'admin@cupid-match.local', '0', '0', 'admin', sysdate(), '', null),
(102, 100, '0,100', '产品技术', 2, '产品负责人', '', 'product@cupid-match.local', '0', '0', 'admin', sysdate(), '', null),
(103, 100, '0,100', '运营增长', 3, '运营负责人', '', 'ops@cupid-match.local', '0', '0', 'admin', sysdate(), '', null),
(104, 100, '0,100', '审核风控', 4, '审核负责人', '', 'review@cupid-match.local', '0', '0', 'admin', sysdate(), '', null),
(105, 100, '0,100', '用户支持', 5, '支持负责人', '', 'support@cupid-match.local', '0', '0', 'admin', sysdate(), '', null);

insert into sys_post (post_id, post_code, post_name, post_sort, status, create_by, create_time, update_by, update_time, remark) values
(1, 'founder_admin', '平台管理员', 1, '0', 'admin', sysdate(), '', null, '全局管理'),
(2, 'ops_admin', '运营管理员', 2, '0', 'admin', sysdate(), '', null, '运营统筹'),
(3, 'reviewer', '审核专员', 3, '0', 'admin', sysdate(), '', null, '资料与材料审核'),
(4, 'event_ops', '活动运营', 4, '0', 'admin', sysdate(), '', null, '活动与报名运营'),
(5, 'support', '用户支持', 5, '0', 'admin', sysdate(), '', null, '用户服务与跟进'),
(6, 'auditor', '业务审计', 6, '0', 'admin', sysdate(), '', null, '业务审计与安全事件'),
(7, 'profile_ops', '资料运营', 7, '0', 'admin', sysdate(), '', null, '资料库与资料运营'),
(8, 'content_ops', '内容配置', 8, '0', 'admin', sysdate(), '', null, '选项、条款和通知模板配置'),
(9, 'payment_ops', '支付财务', 9, '0', 'admin', sysdate(), '', null, '会员和支付订阅处理'),
(10, 'monitor_reader', '运营监控', 10, '0', 'admin', sysdate(), '', null, '业务监控与审计查看');

insert into sys_role (role_id, role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, update_by, update_time, remark) values
(1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', sysdate(), '', null, '超级管理员'),
(2, '基础角色', 'common', 99, '2', 1, 1, '0', '0', 'admin', sysdate(), '', null, '保留给后台基础功能的普通角色');

insert into sys_user (user_id, dept_id, user_name, nick_name, user_type, email, phonenumber, sex, avatar, password, status, del_flag, login_ip, login_date, pwd_update_date, create_by, create_time, update_by, update_time, remark) values
(1, 101, 'admin', '平台管理员', '00', 'admin@cupid-match.local', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '全局超级管理员'),
(10, 103, 'cupid_admin', 'Cupid 运营管理员', '00', 'ops.admin@cupid-match.local', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, 'Cupid 全量运营权限'),
(11, 104, 'cupid_reviewer', '审核专员', '00', 'reviewer@cupid-match.local', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '资料、照片、认证、私人介绍审核'),
(12, 103, 'cupid_event', '活动运营', '00', 'event@cupid-match.local', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '活动与报名运营'),
(13, 105, 'cupid_support', '用户支持', '00', 'support@cupid-match.local', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '用户、通知、联系咨询、跟进事项'),
(14, 101, 'cupid_auditor', '业务审计', '00', 'auditor@cupid-match.local', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '审计与安全事件只读'),
(15, 103, 'cupid_profile_ops', '资料运营专员', '00', 'profile.ops@cupid-match.local', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '资料库查看、资料运营字段与内部备注维护'),
(16, 102, 'cupid_content', '内容配置专员', '00', 'content.ops@cupid-match.local', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '通用选项、通知模板、服务条款与隐私政策维护'),
(17, 101, 'cupid_payment', '支付财务专员', '00', 'payment.ops@cupid-match.local', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '会员、支付订单、取消续费与退款处理'),
(18, 103, 'cupid_monitor', '运营监控观察员', '00', 'monitor@cupid-match.local', '', '2', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '业务监控、审计与安全事件只读查看');

insert into sys_user_role values (1, 1);
insert into sys_user_post values (1, 1), (10, 2), (11, 3), (12, 4), (13, 5), (14, 6), (15, 7), (16, 8), (17, 9), (18, 10);

-- Framework base menus used by system management/monitoring/tool pages.
insert into sys_menu values('1', '系统管理', '0', '1', 'system',           null, '', '', 1, 0, 'M', '0', '0', '', 'system',   'admin', sysdate(), '', null, '系统管理目录');
insert into sys_menu values('2', '系统监控', '0', '2', 'monitor',          null, '', '', 1, 0, 'M', '0', '0', '', 'monitor',  'admin', sysdate(), '', null, '系统监控目录');
insert into sys_menu values('3', '系统工具', '0', '3', 'tool',             null, '', '', 1, 0, 'M', '0', '0', '', 'tool',     'admin', sysdate(), '', null, '系统工具目录');
insert into sys_menu values('100',  '用户管理', '1',   '1', 'user',       'system/user/index',        '', '', 1, 0, 'C', '0', '0', 'system:user:list',        'user',          'admin', sysdate(), '', null, '用户管理菜单');
insert into sys_menu values('101',  '角色管理', '1',   '2', 'role',       'system/role/index',        '', '', 1, 0, 'C', '0', '0', 'system:role:list',        'peoples',       'admin', sysdate(), '', null, '角色管理菜单');
insert into sys_menu values('102',  '菜单管理', '1',   '3', 'menu',       'system/menu/index',        '', '', 1, 0, 'C', '0', '0', 'system:menu:list',        'tree-table',    'admin', sysdate(), '', null, '菜单管理菜单');
insert into sys_menu values('103',  '部门管理', '1',   '4', 'dept',       'system/dept/index',        '', '', 1, 0, 'C', '0', '0', 'system:dept:list',        'tree',          'admin', sysdate(), '', null, '部门管理菜单');
insert into sys_menu values('104',  '岗位管理', '1',   '5', 'post',       'system/post/index',        '', '', 1, 0, 'C', '0', '0', 'system:post:list',        'post',          'admin', sysdate(), '', null, '岗位管理菜单');
insert into sys_menu values('105',  '字典管理', '1',   '6', 'dict',       'system/dict/index',        '', '', 1, 0, 'C', '0', '0', 'system:dict:list',        'dict',          'admin', sysdate(), '', null, '字典管理菜单');
insert into sys_menu values('106',  '参数设置', '1',   '7', 'config',     'system/config/index',      '', '', 1, 0, 'C', '0', '0', 'system:config:list',      'edit',          'admin', sysdate(), '', null, '参数设置菜单');
insert into sys_menu values('107',  '通知公告', '1',   '8', 'notice',     'system/notice/index',      '', '', 1, 0, 'C', '0', '0', 'system:notice:list',      'message',       'admin', sysdate(), '', null, '通知公告菜单');
insert into sys_menu values('108',  '日志管理', '1',   '9', 'log',        '',                         '', '', 1, 0, 'M', '0', '0', '',                        'log',           'admin', sysdate(), '', null, '日志管理菜单');
insert into sys_menu values('109',  '在线用户', '2',   '1', 'online',     'monitor/online/index',     '', '', 1, 0, 'C', '0', '0', 'monitor:online:list',     'online',        'admin', sysdate(), '', null, '在线用户菜单');
insert into sys_menu values('110',  '定时任务', '2',   '2', 'job',        'monitor/job/index',        '', '', 1, 0, 'C', '0', '0', 'monitor:job:list',        'job',           'admin', sysdate(), '', null, '定时任务菜单');
insert into sys_menu values('111',  '数据监控', '2',   '3', 'druid',      'monitor/druid/index',      '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list',      'druid',         'admin', sysdate(), '', null, '数据监控菜单');
insert into sys_menu values('112',  '服务监控', '2',   '4', 'server',     'monitor/server/index',     '', '', 1, 0, 'C', '0', '0', 'monitor:server:list',     'server',        'admin', sysdate(), '', null, '服务监控菜单');
insert into sys_menu values('113',  '缓存监控', '2',   '5', 'cache',      'monitor/cache/index',      '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list',      'redis',         'admin', sysdate(), '', null, '缓存监控菜单');
insert into sys_menu values('114',  '缓存列表', '2',   '6', 'cacheList',  'monitor/cache/list',       '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list',      'redis-list',    'admin', sysdate(), '', null, '缓存列表菜单');
insert into sys_menu values('115',  '表单构建', '3',   '1', 'build',      'tool/build/index',         '', '', 1, 0, 'C', '0', '0', 'tool:build:list',         'build',         'admin', sysdate(), '', null, '表单构建菜单');
insert into sys_menu values('116',  '代码生成', '3',   '2', 'gen',        'tool/gen/index',           '', '', 1, 0, 'C', '0', '0', 'tool:gen:list',           'code',          'admin', sysdate(), '', null, '代码生成菜单');
insert into sys_menu values('117',  '系统接口', '3',   '3', 'swagger',    'tool/swagger/index',       '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list',       'swagger',       'admin', sysdate(), '', null, '系统接口菜单');
insert into sys_menu values('500',  '操作日志', '108', '1', 'operlog',    'monitor/operlog/index',    '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list',    'form',          'admin', sysdate(), '', null, '操作日志菜单');
insert into sys_menu values('501',  '登录日志', '108', '2', 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor',    'admin', sysdate(), '', null, '登录日志菜单');
insert into sys_menu values('1000', '用户查询', '100', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1001', '用户新增', '100', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1002', '用户修改', '100', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1003', '用户删除', '100', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1004', '用户导出', '100', '5',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1005', '用户导入', '100', '6',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1006', '重置密码', '100', '7',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd',       '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1007', '角色查询', '101', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1008', '角色新增', '101', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1009', '角色修改', '101', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1010', '角色删除', '101', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1011', '角色导出', '101', '5',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1012', '菜单查询', '102', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1013', '菜单新增', '102', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1014', '菜单修改', '102', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1015', '菜单删除', '102', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1016', '部门查询', '103', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1017', '部门新增', '103', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1018', '部门修改', '103', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1019', '部门删除', '103', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1020', '岗位查询', '104', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1021', '岗位新增', '104', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1022', '岗位修改', '104', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1023', '岗位删除', '104', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1024', '岗位导出', '104', '5',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1025', '字典查询', '105', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1026', '字典新增', '105', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1027', '字典修改', '105', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1028', '字典删除', '105', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1029', '字典导出', '105', '5', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1030', '参数查询', '106', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1031', '参数新增', '106', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1032', '参数修改', '106', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1033', '参数删除', '106', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove',       '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1034', '参数导出', '106', '5', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export',       '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1035', '公告查询', '107', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1036', '公告新增', '107', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1037', '公告修改', '107', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1038', '公告删除', '107', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove',       '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1039', '操作查询', '500', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1040', '操作删除', '500', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove',     '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1041', '日志导出', '500', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export',     '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1042', '登录查询', '501', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query',   '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1043', '登录删除', '501', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove',  '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1044', '日志导出', '501', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export',  '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1045', '账户解锁', '501', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock',  '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1046', '在线查询', '109', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query',       '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1047', '批量强退', '109', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1048', '单条强退', '109', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1049', '任务查询', '110', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query',          '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1050', '任务新增', '110', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1051', '任务修改', '110', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1052', '任务删除', '110', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1053', '状态修改', '110', '5', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus',   '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1054', '任务导出', '110', '6', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1055', '生成查询', '116', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query',             '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1056', '生成修改', '116', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit',              '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1057', '生成删除', '116', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1058', '导入代码', '116', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import',            '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1059', '预览代码', '116', '5', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview',           '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1060', '生成代码', '116', '6', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code',              '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1061', '缓存清理', '114', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:cache:clear',        '#', 'admin', sysdate(), '', null, '缓存清理操作');

-- Framework dictionaries and Cupid runtime configs.
insert into sys_dict_type values(1,  '用户性别', 'sys_user_sex',        '0', 'admin', sysdate(), '', null, '用户性别列表');
insert into sys_dict_type values(2,  '菜单状态', 'sys_show_hide',       '0', 'admin', sysdate(), '', null, '菜单状态列表');
insert into sys_dict_type values(3,  '系统开关', 'sys_normal_disable',  '0', 'admin', sysdate(), '', null, '系统开关列表');
insert into sys_dict_type values(4,  '任务状态', 'sys_job_status',      '0', 'admin', sysdate(), '', null, '任务状态列表');
insert into sys_dict_type values(5,  '任务分组', 'sys_job_group',       '0', 'admin', sysdate(), '', null, '任务分组列表');
insert into sys_dict_type values(6,  '系统是否', 'sys_yes_no',          '0', 'admin', sysdate(), '', null, '系统是否列表');
insert into sys_dict_type values(7,  '通知类型', 'sys_notice_type',     '0', 'admin', sysdate(), '', null, '通知类型列表');
insert into sys_dict_type values(8,  '通知状态', 'sys_notice_status',   '0', 'admin', sysdate(), '', null, '通知状态列表');
insert into sys_dict_type values(9,  '操作类型', 'sys_oper_type',       '0', 'admin', sysdate(), '', null, '操作类型列表');
insert into sys_dict_type values(10, '系统状态', 'sys_common_status',   '0', 'admin', sysdate(), '', null, '登录状态列表');

-- 12
insert into sys_dict_data values(1,  1,  '男',       '0',       'sys_user_sex',        '',   '',        'Y', '0', 'admin', sysdate(), '', null, '性别男');
insert into sys_dict_data values(2,  2,  '女',       '1',       'sys_user_sex',        '',   '',        'N', '0', 'admin', sysdate(), '', null, '性别女');
insert into sys_dict_data values(3,  3,  '未知',     '2',       'sys_user_sex',        '',   '',        'N', '0', 'admin', sysdate(), '', null, '性别未知');
insert into sys_dict_data values(4,  1,  '显示',     '0',       'sys_show_hide',       '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '显示菜单');
insert into sys_dict_data values(5,  2,  '隐藏',     '1',       'sys_show_hide',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '隐藏菜单');
insert into sys_dict_data values(6,  1,  '正常',     '0',       'sys_normal_disable',  '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(7,  2,  '停用',     '1',       'sys_normal_disable',  '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '停用状态');
insert into sys_dict_data values(8,  1,  '正常',     '0',       'sys_job_status',      '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(9,  2,  '暂停',     '1',       'sys_job_status',      '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '停用状态');
insert into sys_dict_data values(10, 1,  '默认',     'DEFAULT', 'sys_job_group',       '',   '',        'Y', '0', 'admin', sysdate(), '', null, '默认分组');
insert into sys_dict_data values(11, 2,  '系统',     'SYSTEM',  'sys_job_group',       '',   '',        'N', '0', 'admin', sysdate(), '', null, '系统分组');
insert into sys_dict_data values(12, 1,  '是',       'Y',       'sys_yes_no',          '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '系统默认是');
insert into sys_dict_data values(13, 2,  '否',       'N',       'sys_yes_no',          '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '系统默认否');
insert into sys_dict_data values(14, 1,  '通知',     '1',       'sys_notice_type',     '',   'warning', 'Y', '0', 'admin', sysdate(), '', null, '通知');
insert into sys_dict_data values(15, 2,  '公告',     '2',       'sys_notice_type',     '',   'success', 'N', '0', 'admin', sysdate(), '', null, '公告');
insert into sys_dict_data values(16, 1,  '正常',     '0',       'sys_notice_status',   '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(17, 2,  '关闭',     '1',       'sys_notice_status',   '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '关闭状态');
insert into sys_dict_data values(18, 99, '其他',     '0',       'sys_oper_type',       '',   'info',    'N', '0', 'admin', sysdate(), '', null, '其他操作');
insert into sys_dict_data values(19, 1,  '新增',     '1',       'sys_oper_type',       '',   'info',    'N', '0', 'admin', sysdate(), '', null, '新增操作');
insert into sys_dict_data values(20, 2,  '修改',     '2',       'sys_oper_type',       '',   'info',    'N', '0', 'admin', sysdate(), '', null, '修改操作');
insert into sys_dict_data values(21, 3,  '删除',     '3',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '删除操作');
insert into sys_dict_data values(22, 4,  '授权',     '4',       'sys_oper_type',       '',   'primary', 'N', '0', 'admin', sysdate(), '', null, '授权操作');
insert into sys_dict_data values(23, 5,  '导出',     '5',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', sysdate(), '', null, '导出操作');
insert into sys_dict_data values(24, 6,  '导入',     '6',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', sysdate(), '', null, '导入操作');
insert into sys_dict_data values(25, 7,  '强退',     '7',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '强退操作');
insert into sys_dict_data values(26, 8,  '生成代码', '8',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', sysdate(), '', null, '生成操作');
insert into sys_dict_data values(27, 9,  '清空数据', '9',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '清空操作');
insert into sys_dict_data values(28, 1,  '成功',     '0',       'sys_common_status',   '',   'primary', 'N', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(29, 2,  '失败',     '1',       'sys_common_status',   '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '停用状态');
insert into sys_dict_data values(30, 3,  'Cupid业务', 'CUPID',   'sys_job_group',       '',   'primary', 'N', '0', 'admin', sysdate(), '', null, 'Cupid业务任务分组');

-- 13
insert into sys_config values(1, '主框架页-默认皮肤样式名称',     'sys.index.skinName',               'skin-blue',     'Y', 'admin', sysdate(), '', null, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow' );
insert into sys_config values(2, '用户管理-账号初始密码',         'sys.user.initPassword',            '123456',        'Y', 'admin', sysdate(), '', null, '初始化密码 123456' );
insert into sys_config values(3, '主框架页-侧边栏主题',           'sys.index.sideTheme',              'theme-dark',    'Y', 'admin', sysdate(), '', null, '深色主题theme-dark，浅色主题theme-light' );
insert into sys_config values(4, '账号自助-验证码开关',           'sys.account.captchaEnabled',       'true',          'Y', 'admin', sysdate(), '', null, '是否开启验证码功能（true开启，false关闭）');
insert into sys_config values(5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser',         'false',         'Y', 'admin', sysdate(), '', null, '是否开启注册用户功能（true开启，false关闭）');
insert into sys_config values(6, '用户登录-黑名单列表',           'sys.login.blackIPList',            '',              'Y', 'admin', sysdate(), '', null, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
insert into sys_config values(7, '用户管理-初始密码修改策略',     'sys.account.initPasswordModify',   '1',             'Y', 'admin', sysdate(), '', null, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
insert into sys_config values(8, '用户管理-账号密码更新周期',     'sys.account.passwordValidateDays', '0',             'Y', 'admin', sysdate(), '', null, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');
insert into sys_config values(9, '用户管理-密码字符范围',         'sys.account.chrtype',              '0',             'Y', 'admin', sysdate(), '', null, '默认任意字符范围，0任意（密码可以输入任意字符），1数字（密码只能为0-9数字），2英文字母（密码只能为a-z和A-Z字母），3字母和数字（密码必须包含字母，数字）,4字母数字和特殊字符（目前支持的特殊字符包括：~!@#$%^&*()-=_+）');
insert into sys_config values(10, 'Cupid-验证码有效期（分钟）',    'cupid.auth.verification.codeTtlMinutes',       '5',  'Y', 'admin', sysdate(), '', null, '允许范围1-15，非法值自动回退为5');
insert into sys_config values(11, 'Cupid-验证码重发间隔（秒）',    'cupid.auth.verification.resendIntervalSeconds', '60', 'Y', 'admin', sysdate(), '', null, '允许范围30-300，非法值自动回退为60');
insert into sys_config values(12, 'Cupid-私人介绍有效期（天）',    'cupid.introduction.expiryDays',                  '7',  'Y', 'admin', sysdate(), '', null, '允许范围1-30，仅影响新申请，非法值自动回退为7');
insert into sys_config values(13, 'Cupid-私人介绍冷却期（天）',    'cupid.introduction.cooldownDays',                '90', 'Y', 'admin', sysdate(), '', null, '允许范围7-365，仅影响新冷却记录，非法值自动回退为90');
insert into sys_config values(14, 'Cupid-定时维护批量大小',        'cupid.scheduler.batchSize',                      '500', 'Y', 'admin', sysdate(), '', null, '允许范围50-2000，非法值自动回退为500');
insert into sys_config values(15, 'Cupid-机器翻译开关', 'cupid.translation.enabled', 'false', 'Y', 'admin', sysdate(), '', null, '修改后立即生效');
insert into sys_config values(16, 'Cupid-邮箱验证码发送开关', 'cupid.verification.email.enabled', 'false', 'Y', 'admin', sysdate(), '', null, '修改后立即生效；SMTP 参数仍由启动配置提供');
insert into sys_config values(17, 'Cupid-短信验证码发送开关', 'cupid.verification.sms.enabled', 'false', 'Y', 'admin', sysdate(), '', null, '修改后立即生效；短信服务商参数仍由启动配置提供');

-- Cupid common options (dynamic groups)
insert into cm_option_groups (id, group_key, group_name, group_scope, manage_status, sort_order, status) values
('00000000-0000-0000-8243-000000000001', 'profile.city', '资料城市', 'profile', 'dynamic', 10, 'enabled'),
('00000000-0000-0000-8243-000000000002', 'profile.country', '国家', 'profile', 'dynamic', 20, 'enabled'),
('00000000-0000-0000-8243-000000000003', 'profile.nationality', '国籍', 'profile', 'dynamic', 30, 'enabled'),
('00000000-0000-0000-8243-000000000004', 'profile.languages', '语言', 'profile', 'dynamic', 40, 'enabled'),
('00000000-0000-0000-8243-000000000005', 'profile.education', '教育背景', 'profile', 'dynamic', 50, 'enabled'),
('00000000-0000-0000-8243-000000000006', 'profile.industry', '行业', 'profile', 'dynamic', 60, 'enabled'),
('00000000-0000-0000-8243-000000000007', 'profile.relationshipGoal', '关系目标', 'profile', 'dynamic', 70, 'enabled'),
('00000000-0000-0000-8243-000000000008', 'profile.residencePlan', '居住计划', 'profile', 'dynamic', 80, 'enabled'),
('00000000-0000-0000-8243-000000000009', 'profile.preferredEducation', '期望学历', 'profile', 'dynamic', 90, 'enabled'),
('00000000-0000-0000-8243-000000000010', 'profile.familyLife', '家庭生活', 'profile', 'dynamic', 100, 'enabled'),
('00000000-0000-0000-8243-000000000011', 'profile.exercise', '运动习惯', 'profile', 'dynamic', 110, 'enabled'),
('00000000-0000-0000-8243-000000000012', 'profile.degreeLevel', '最高学历', 'profile', 'dynamic', 120, 'enabled'),
('00000000-0000-0000-8243-000000000013', 'profile.maritalStatus', '婚姻状态', 'profile', 'dynamic', 130, 'enabled'),
('00000000-0000-0000-8243-000000000014', 'profile.childrenPlan', '子女计划', 'profile', 'dynamic', 140, 'enabled'),
('00000000-0000-0000-8243-000000000015', 'profile.datingIntentionCode', '交友意向', 'profile', 'dynamic', 150, 'enabled'),
('00000000-0000-0000-8243-000000000016', 'profile.relocation', '迁居意愿', 'profile', 'dynamic', 160, 'enabled'),
('00000000-0000-0000-8243-000000000017', 'profile.relationshipValues', '关系价值观', 'profile', 'dynamic', 170, 'enabled'),
('00000000-0000-0000-8243-000000000018', 'profile.preferredLocation', '地域偏好', 'profile', 'dynamic', 180, 'enabled'),
('00000000-0000-0000-8243-000000000019', 'profile.smoking', '吸烟', 'profile', 'dynamic', 190, 'enabled'),
('00000000-0000-0000-8243-000000000020', 'profile.drinking', '饮酒', 'profile', 'dynamic', 200, 'enabled'),
('00000000-0000-0000-8243-000000000021', 'profile.activityLevel', '活跃程度', 'profile', 'dynamic', 210, 'enabled'),
('00000000-0000-0000-8243-000000000022', 'profile.weekendStyle', '周末节奏', 'profile', 'dynamic', 220, 'enabled'),
('00000000-0000-0000-8243-000000000023', 'profile.pets', '宠物', 'profile', 'dynamic', 230, 'enabled'),
('00000000-0000-0000-8243-000000000024', 'profile.communicationStyle', '沟通方式', 'profile', 'dynamic', 240, 'enabled');

insert into cm_option_values (id, group_id, option_value, label_zh, label_fr, label_en, sort_order, requires_extra_text, status) values
('00000000-0000-8243-0001-000000000001', '00000000-0000-0000-8243-000000000001', 'FR:paris', '巴黎', 'Paris', 'Paris', 10, 0, 'enabled'),
('00000000-0000-8243-0001-000000000002', '00000000-0000-0000-8243-000000000001', 'FR:lyon', '里昂', 'Lyon', 'Lyon', 20, 0, 'enabled'),
('00000000-0000-8243-0001-000000000003', '00000000-0000-0000-8243-000000000001', 'FR:nice', '尼斯', 'Nice', 'Nice', 30, 0, 'enabled'),
('00000000-0000-8243-0001-000000000004', '00000000-0000-0000-8243-000000000001', 'FR:marseille', '马赛', 'Marseille', 'Marseille', 40, 0, 'enabled'),
('00000000-0000-8243-0001-000000000005', '00000000-0000-0000-8243-000000000001', 'CN:shanghai', '上海', 'Shanghai', 'Shanghai', 50, 0, 'enabled'),
('00000000-0000-8243-0001-000000000006', '00000000-0000-0000-8243-000000000001', 'CN:beijing', '北京', 'Beijing', 'Beijing', 60, 0, 'enabled'),
('00000000-0000-8243-0001-000000000007', '00000000-0000-0000-8243-000000000001', 'CH:geneva', '日内瓦', 'Geneve', 'Geneva', 70, 0, 'enabled'),
('00000000-0000-8243-0001-000000000008', '00000000-0000-0000-8243-000000000001', 'BE:brussels', '布鲁塞尔', 'Bruxelles', 'Brussels', 80, 0, 'enabled'),
('00000000-0000-8243-0001-000000000009', '00000000-0000-0000-8243-000000000001', 'NL:amsterdam', '阿姆斯特丹', 'Amsterdam', 'Amsterdam', 90, 0, 'enabled'),
('00000000-0000-8243-0001-000000000010', '00000000-0000-0000-8243-000000000001', 'FR:bordeaux', '波尔多', 'Bordeaux', 'Bordeaux', 100, 0, 'enabled'),
('00000000-0000-8243-0001-000000000011', '00000000-0000-0000-8243-000000000001', 'FR:toulouse', '图卢兹', 'Toulouse', 'Toulouse', 110, 0, 'enabled'),
('00000000-0000-8243-0001-000000000012', '00000000-0000-0000-8243-000000000001', 'FR:lille', '里尔', 'Lille', 'Lille', 120, 0, 'enabled'),
('00000000-0000-8243-0001-000000000013', '00000000-0000-0000-8243-000000000001', 'FR:strasbourg', '斯特拉斯堡', 'Strasbourg', 'Strasbourg', 130, 0, 'enabled'),
('00000000-0000-8243-0001-000000000014', '00000000-0000-0000-8243-000000000001', 'FR:nantes', '南特', 'Nantes', 'Nantes', 140, 0, 'enabled'),
('00000000-0000-8243-0001-000000000015', '00000000-0000-0000-8243-000000000001', 'FR:montpellier', '蒙彼利埃', 'Montpellier', 'Montpellier', 150, 0, 'enabled'),
('00000000-0000-8243-0001-000000000016', '00000000-0000-0000-8243-000000000001', 'FR:rennes', '雷恩', 'Rennes', 'Rennes', 160, 0, 'enabled'),
('00000000-0000-8243-0001-000000000017', '00000000-0000-0000-8243-000000000001', 'FR:grenoble', '格勒诺布尔', 'Grenoble', 'Grenoble', 170, 0, 'enabled'),
('00000000-0000-8243-0001-000000000018', '00000000-0000-0000-8243-000000000001', 'CH:zurich', '苏黎世', 'Zurich', 'Zurich', 180, 0, 'enabled'),
('00000000-0000-8243-0001-000000000019', '00000000-0000-0000-8243-000000000001', 'CH:lausanne', '洛桑', 'Lausanne', 'Lausanne', 190, 0, 'enabled'),
('00000000-0000-8243-0001-000000000020', '00000000-0000-0000-8243-000000000001', 'BE:antwerp', '安特卫普', 'Anvers', 'Antwerp', 200, 0, 'enabled'),
('00000000-0000-8243-0001-000000000021', '00000000-0000-0000-8243-000000000001', 'NL:rotterdam', '鹿特丹', 'Rotterdam', 'Rotterdam', 210, 0, 'enabled'),
('00000000-0000-8243-0001-000000000022', '00000000-0000-0000-8243-000000000001', 'NL:the-hague', '海牙', 'La Haye', 'The Hague', 220, 0, 'enabled'),
('00000000-0000-8243-0001-000000000023', '00000000-0000-0000-8243-000000000001', 'GB:london', '伦敦', 'Londres', 'London', 230, 0, 'enabled'),
('00000000-0000-8243-0001-000000000024', '00000000-0000-0000-8243-000000000001', 'DE:berlin', '柏林', 'Berlin', 'Berlin', 240, 0, 'enabled'),
('00000000-0000-8243-0001-000000000025', '00000000-0000-0000-8243-000000000001', 'DE:munich', '慕尼黑', 'Munich', 'Munich', 250, 0, 'enabled'),
('00000000-0000-8243-0001-000000000026', '00000000-0000-0000-8243-000000000001', 'DE:frankfurt', '法兰克福', 'Francfort', 'Frankfurt', 260, 0, 'enabled'),
('00000000-0000-8243-0001-000000000027', '00000000-0000-0000-8243-000000000001', 'IT:milan', '米兰', 'Milan', 'Milan', 270, 0, 'enabled'),
('00000000-0000-8243-0001-000000000028', '00000000-0000-0000-8243-000000000001', 'IT:rome', '罗马', 'Rome', 'Rome', 280, 0, 'enabled'),
('00000000-0000-8243-0001-000000000029', '00000000-0000-0000-8243-000000000001', 'ES:barcelona', '巴塞罗那', 'Barcelone', 'Barcelona', 290, 0, 'enabled'),
('00000000-0000-8243-0001-000000000030', '00000000-0000-0000-8243-000000000001', 'ES:madrid', '马德里', 'Madrid', 'Madrid', 300, 0, 'enabled'),
('00000000-0000-8243-0001-000000000031', '00000000-0000-0000-8243-000000000001', 'LU:luxembourg', '卢森堡', 'Luxembourg', 'Luxembourg', 310, 0, 'enabled'),
('00000000-0000-8243-0001-000000000032', '00000000-0000-0000-8243-000000000001', 'CN:shenzhen', '深圳', 'Shenzhen', 'Shenzhen', 320, 0, 'enabled'),
('00000000-0000-8243-0001-000000000033', '00000000-0000-0000-8243-000000000001', 'CN:guangzhou', '广州', 'Guangzhou', 'Guangzhou', 330, 0, 'enabled'),
('00000000-0000-8243-0002-000000000001', '00000000-0000-0000-8243-000000000002', 'FR', '法国', 'France', 'France', 10, 0, 'enabled'),
('00000000-0000-8243-0002-000000000002', '00000000-0000-0000-8243-000000000002', 'CN', '中国', 'Chine', 'China', 20, 0, 'enabled'),
('00000000-0000-8243-0002-000000000003', '00000000-0000-0000-8243-000000000002', 'US', '美国', 'Etats-Unis', 'United States', 30, 0, 'enabled'),
('00000000-0000-8243-0002-000000000004', '00000000-0000-0000-8243-000000000002', 'CH', '瑞士', 'Suisse', 'Switzerland', 40, 0, 'enabled'),
('00000000-0000-8243-0002-000000000005', '00000000-0000-0000-8243-000000000002', 'NL', '荷兰', 'Pays-Bas', 'Netherlands', 50, 0, 'enabled'),
('00000000-0000-8243-0002-000000000006', '00000000-0000-0000-8243-000000000002', 'GB', '英国', 'Royaume-Uni', 'United Kingdom', 60, 0, 'enabled'),
('00000000-0000-8243-0002-000000000007', '00000000-0000-0000-8243-000000000002', 'BE', '比利时', 'Belgique', 'Belgium', 70, 0, 'enabled'),
('00000000-0000-8243-0002-000000000008', '00000000-0000-0000-8243-000000000002', 'DE', '德国', 'Allemagne', 'Germany', 80, 0, 'enabled'),
('00000000-0000-8243-0002-000000000009', '00000000-0000-0000-8243-000000000002', 'IT', '意大利', 'Italie', 'Italy', 90, 0, 'enabled'),
('00000000-0000-8243-0002-000000000010', '00000000-0000-0000-8243-000000000002', 'ES', '西班牙', 'Espagne', 'Spain', 100, 0, 'enabled'),
('00000000-0000-8243-0002-000000000011', '00000000-0000-0000-8243-000000000002', 'PT', '葡萄牙', 'Portugal', 'Portugal', 110, 0, 'enabled'),
('00000000-0000-8243-0002-000000000012', '00000000-0000-0000-8243-000000000002', 'LU', '卢森堡', 'Luxembourg', 'Luxembourg', 120, 0, 'enabled'),
('00000000-0000-8243-0002-000000000013', '00000000-0000-0000-8243-000000000002', 'SE', '瑞典', 'Suede', 'Sweden', 130, 0, 'enabled'),
('00000000-0000-8243-0002-000000000014', '00000000-0000-0000-8243-000000000002', 'DK', '丹麦', 'Danemark', 'Denmark', 140, 0, 'enabled'),
('00000000-0000-8243-0002-000000000015', '00000000-0000-0000-8243-000000000002', 'IE', '爱尔兰', 'Irlande', 'Ireland', 150, 0, 'enabled'),
('00000000-0000-8243-0002-000000000016', '00000000-0000-0000-8243-000000000002', 'JP', '日本', 'Japon', 'Japan', 160, 0, 'enabled'),
('00000000-0000-8243-0002-000000000017', '00000000-0000-0000-8243-000000000002', 'KR', '韩国', 'Coree du Sud', 'South Korea', 170, 0, 'enabled'),
('00000000-0000-8243-0002-000000000018', '00000000-0000-0000-8243-000000000002', 'CA', '加拿大', 'Canada', 'Canada', 180, 0, 'enabled'),
('00000000-0000-8243-0002-000000000019', '00000000-0000-0000-8243-000000000002', 'AU', '澳大利亚', 'Australie', 'Australia', 190, 0, 'enabled'),
('00000000-0000-8243-0002-000000000020', '00000000-0000-0000-8243-000000000002', 'SG', '新加坡', 'Singapour', 'Singapore', 200, 0, 'enabled'),
('00000000-0000-8243-0003-000000000001', '00000000-0000-0000-8243-000000000003', 'FR', '法国', 'France', 'France', 10, 0, 'enabled'),
('00000000-0000-8243-0003-000000000002', '00000000-0000-0000-8243-000000000003', 'CN', '中国', 'Chine', 'China', 20, 0, 'enabled'),
('00000000-0000-8243-0003-000000000003', '00000000-0000-0000-8243-000000000003', 'US', '美国', 'Etats-Unis', 'United States', 30, 0, 'enabled'),
('00000000-0000-8243-0003-000000000004', '00000000-0000-0000-8243-000000000003', 'CH', '瑞士', 'Suisse', 'Switzerland', 40, 0, 'enabled'),
('00000000-0000-8243-0003-000000000005', '00000000-0000-0000-8243-000000000003', 'NL', '荷兰', 'Pays-Bas', 'Netherlands', 50, 0, 'enabled'),
('00000000-0000-8243-0003-000000000006', '00000000-0000-0000-8243-000000000003', 'GB', '英国', 'Royaume-Uni', 'United Kingdom', 60, 0, 'enabled'),
('00000000-0000-8243-0003-000000000007', '00000000-0000-0000-8243-000000000003', 'BE', '比利时', 'Belgique', 'Belgium', 70, 0, 'enabled'),
('00000000-0000-8243-0003-000000000008', '00000000-0000-0000-8243-000000000003', 'DE', '德国', 'Allemagne', 'Germany', 80, 0, 'enabled'),
('00000000-0000-8243-0003-000000000009', '00000000-0000-0000-8243-000000000003', 'IT', '意大利', 'Italie', 'Italy', 90, 0, 'enabled'),
('00000000-0000-8243-0003-000000000010', '00000000-0000-0000-8243-000000000003', 'ES', '西班牙', 'Espagne', 'Spain', 100, 0, 'enabled'),
('00000000-0000-8243-0003-000000000011', '00000000-0000-0000-8243-000000000003', 'PT', '葡萄牙', 'Portugal', 'Portugal', 110, 0, 'enabled'),
('00000000-0000-8243-0003-000000000012', '00000000-0000-0000-8243-000000000003', 'LU', '卢森堡', 'Luxembourg', 'Luxembourg', 120, 0, 'enabled'),
('00000000-0000-8243-0003-000000000013', '00000000-0000-0000-8243-000000000003', 'SE', '瑞典', 'Suede', 'Sweden', 130, 0, 'enabled'),
('00000000-0000-8243-0003-000000000014', '00000000-0000-0000-8243-000000000003', 'DK', '丹麦', 'Danemark', 'Denmark', 140, 0, 'enabled'),
('00000000-0000-8243-0003-000000000015', '00000000-0000-0000-8243-000000000003', 'IE', '爱尔兰', 'Irlande', 'Ireland', 150, 0, 'enabled'),
('00000000-0000-8243-0003-000000000016', '00000000-0000-0000-8243-000000000003', 'JP', '日本', 'Japon', 'Japan', 160, 0, 'enabled'),
('00000000-0000-8243-0003-000000000017', '00000000-0000-0000-8243-000000000003', 'KR', '韩国', 'Coree du Sud', 'South Korea', 170, 0, 'enabled'),
('00000000-0000-8243-0003-000000000018', '00000000-0000-0000-8243-000000000003', 'CA', '加拿大', 'Canada', 'Canada', 180, 0, 'enabled'),
('00000000-0000-8243-0003-000000000019', '00000000-0000-0000-8243-000000000003', 'AU', '澳大利亚', 'Australie', 'Australia', 190, 0, 'enabled'),
('00000000-0000-8243-0003-000000000020', '00000000-0000-0000-8243-000000000003', 'SG', '新加坡', 'Singapour', 'Singapore', 200, 0, 'enabled'),
('00000000-0000-8243-0004-000000000001', '00000000-0000-0000-8243-000000000004', 'ZH', '中文', 'Chinois', 'Chinese', 10, 0, 'enabled'),
('00000000-0000-8243-0004-000000000002', '00000000-0000-0000-8243-000000000004', 'EN', '英语', 'Anglais', 'English', 20, 0, 'enabled'),
('00000000-0000-8243-0004-000000000003', '00000000-0000-0000-8243-000000000004', 'FR', '法语', 'Francais', 'French', 30, 0, 'enabled'),
('00000000-0000-8243-0004-000000000004', '00000000-0000-0000-8243-000000000004', 'ES', '西班牙语', 'Espagnol', 'Spanish', 40, 0, 'enabled'),
('00000000-0000-8243-0004-000000000005', '00000000-0000-0000-8243-000000000004', 'AR', '阿拉伯语', 'Arabe', 'Arabic', 50, 0, 'enabled'),
('00000000-0000-8243-0004-000000000006', '00000000-0000-0000-8243-000000000004', 'PT', '葡萄牙语', 'Portugais', 'Portuguese', 60, 0, 'enabled'),
('00000000-0000-8243-0004-000000000007', '00000000-0000-0000-8243-000000000004', 'RU', '俄语', 'Russe', 'Russian', 70, 0, 'enabled'),
('00000000-0000-8243-0004-000000000008', '00000000-0000-0000-8243-000000000004', 'DE', '德语', 'Allemand', 'German', 80, 0, 'enabled'),
('00000000-0000-8243-0004-000000000009', '00000000-0000-0000-8243-000000000004', 'JA', '日语', 'Japonais', 'Japanese', 90, 0, 'enabled'),
('00000000-0000-8243-0004-000000000010', '00000000-0000-0000-8243-000000000004', 'KO', '韩语', 'Coreen', 'Korean', 100, 0, 'enabled'),
('00000000-0000-8243-0004-000000000011', '00000000-0000-0000-8243-000000000004', 'HI', '印地语', 'Hindi', 'Hindi', 110, 0, 'enabled'),
('00000000-0000-8243-0004-000000000012', '00000000-0000-0000-8243-000000000004', 'IT', '意大利语', 'Italien', 'Italian', 120, 0, 'enabled'),
('00000000-0000-8243-0004-000000000013', '00000000-0000-0000-8243-000000000004', 'NL', '荷兰语', 'Neerlandais', 'Dutch', 130, 0, 'enabled'),
('00000000-0000-8243-0004-000000000014', '00000000-0000-0000-8243-000000000004', 'TR', '土耳其语', 'Turc', 'Turkish', 140, 0, 'enabled'),
('00000000-0000-8243-0004-000000000015', '00000000-0000-0000-8243-000000000004', 'VI', '越南语', 'Vietnamien', 'Vietnamese', 150, 0, 'enabled'),
('00000000-0000-8243-0004-000000000016', '00000000-0000-0000-8243-000000000004', 'TH', '泰语', 'Thai', 'Thai', 160, 0, 'enabled'),
('00000000-0000-8243-0004-000000000017', '00000000-0000-0000-8243-000000000004', 'PL', '波兰语', 'Polonais', 'Polish', 170, 0, 'enabled'),
('00000000-0000-8243-0004-000000000018', '00000000-0000-0000-8243-000000000004', 'SV', '瑞典语', 'Suedois', 'Swedish', 180, 0, 'enabled'),
('00000000-0000-8243-0004-000000000019', '00000000-0000-0000-8243-000000000004', 'EL', '希腊语', 'Grec', 'Greek', 190, 0, 'enabled'),
('00000000-0000-8243-0004-000000000020', '00000000-0000-0000-8243-000000000004', 'HE', '希伯来语', 'Hebreu', 'Hebrew', 200, 0, 'enabled'),
('00000000-0000-8243-0004-000000000021', '00000000-0000-0000-8243-000000000004', 'ID', '印尼语', 'Indonesien', 'Indonesian', 210, 0, 'enabled'),
('00000000-0000-8243-0004-000000000022', '00000000-0000-0000-8243-000000000004', 'MS', '马来语', 'Malais', 'Malay', 220, 0, 'enabled'),
('00000000-0000-8243-0004-000000000023', '00000000-0000-0000-8243-000000000004', 'BN', '孟加拉语', 'Bengali', 'Bengali', 230, 0, 'enabled'),
('00000000-0000-8243-0004-000000000024', '00000000-0000-0000-8243-000000000004', 'FA', '波斯语', 'Persan', 'Persian', 240, 0, 'enabled'),
('00000000-0000-8243-0004-000000000025', '00000000-0000-0000-8243-000000000004', 'UR', '乌尔都语', 'Ourdou', 'Urdu', 250, 0, 'enabled'),
('00000000-0000-8243-0004-000000000026', '00000000-0000-0000-8243-000000000004', 'YUE', '粤语', 'Cantonais', 'Cantonese', 260, 0, 'enabled'),
('00000000-0000-8243-0004-000000000027', '00000000-0000-0000-8243-000000000004', 'TA', '泰米尔语', 'Tamoul', 'Tamil', 270, 0, 'enabled'),
('00000000-0000-8243-0004-000000000028', '00000000-0000-0000-8243-000000000004', 'TE', '泰卢固语', 'Telougou', 'Telugu', 280, 0, 'enabled'),
('00000000-0000-8243-0004-000000000029', '00000000-0000-0000-8243-000000000004', 'MR', '马拉地语', 'Marathi', 'Marathi', 290, 0, 'enabled'),
('00000000-0000-8243-0004-000000000030', '00000000-0000-0000-8243-000000000004', 'GU', '古吉拉特语', 'Gujarati', 'Gujarati', 300, 0, 'enabled'),
('00000000-0000-8243-0004-000000000031', '00000000-0000-0000-8243-000000000004', 'PA', '旁遮普语', 'Pendjabi', 'Punjabi', 310, 0, 'enabled'),
('00000000-0000-8243-0004-000000000032', '00000000-0000-0000-8243-000000000004', 'TL', '他加禄语', 'Tagalog', 'Tagalog', 320, 0, 'enabled'),
('00000000-0000-8243-0004-000000000033', '00000000-0000-0000-8243-000000000004', 'KM', '高棉语', 'Khmer', 'Khmer', 330, 0, 'enabled'),
('00000000-0000-8243-0004-000000000034', '00000000-0000-0000-8243-000000000004', 'MY', '缅甸语', 'Birman', 'Burmese', 340, 0, 'enabled'),
('00000000-0000-8243-0004-000000000035', '00000000-0000-0000-8243-000000000004', 'LO', '老挝语', 'Lao', 'Lao', 350, 0, 'enabled'),
('00000000-0000-8243-0004-000000000036', '00000000-0000-0000-8243-000000000004', 'MN', '蒙古语', 'Mongol', 'Mongolian', 360, 0, 'enabled'),
('00000000-0000-8243-0004-000000000037', '00000000-0000-0000-8243-000000000004', 'NE', '尼泊尔语', 'Nepalais', 'Nepali', 370, 0, 'enabled'),
('00000000-0000-8243-0004-000000000038', '00000000-0000-0000-8243-000000000004', 'SI', '僧伽罗语', 'Cinghalais', 'Sinhala', 380, 0, 'enabled'),
('00000000-0000-8243-0004-000000000039', '00000000-0000-0000-8243-000000000004', 'AM', '阿姆哈拉语', 'Amharique', 'Amharic', 390, 0, 'enabled'),
('00000000-0000-8243-0004-000000000040', '00000000-0000-0000-8243-000000000004', 'SW', '斯瓦希里语', 'Swahili', 'Swahili', 400, 0, 'enabled'),
('00000000-0000-8243-0004-000000000041', '00000000-0000-0000-8243-000000000004', 'RO', '罗马尼亚语', 'Roumain', 'Romanian', 410, 0, 'enabled'),
('00000000-0000-8243-0004-000000000042', '00000000-0000-0000-8243-000000000004', 'HU', '匈牙利语', 'Hongrois', 'Hungarian', 420, 0, 'enabled'),
('00000000-0000-8243-0004-000000000043', '00000000-0000-0000-8243-000000000004', 'CS', '捷克语', 'Tcheque', 'Czech', 430, 0, 'enabled'),
('00000000-0000-8243-0004-000000000044', '00000000-0000-0000-8243-000000000004', 'SK', '斯洛伐克语', 'Slovaque', 'Slovak', 440, 0, 'enabled'),
('00000000-0000-8243-0004-000000000045', '00000000-0000-0000-8243-000000000004', 'BG', '保加利亚语', 'Bulgare', 'Bulgarian', 450, 0, 'enabled'),
('00000000-0000-8243-0004-000000000046', '00000000-0000-0000-8243-000000000004', 'SR', '塞尔维亚语', 'Serbe', 'Serbian', 460, 0, 'enabled'),
('00000000-0000-8243-0004-000000000047', '00000000-0000-0000-8243-000000000004', 'HR', '克罗地亚语', 'Croate', 'Croatian', 470, 0, 'enabled'),
('00000000-0000-8243-0004-000000000048', '00000000-0000-0000-8243-000000000004', 'UK', '乌克兰语', 'Ukrainien', 'Ukrainian', 480, 0, 'enabled'),
('00000000-0000-8243-0004-000000000049', '00000000-0000-0000-8243-000000000004', 'NO', '挪威语', 'Norvegien', 'Norwegian', 490, 0, 'enabled'),
('00000000-0000-8243-0004-000000000050', '00000000-0000-0000-8243-000000000004', 'DA', '丹麦语', 'Danois', 'Danish', 500, 0, 'enabled'),
('00000000-0000-8243-0004-000000000051', '00000000-0000-0000-8243-000000000004', 'FI', '芬兰语', 'Finnois', 'Finnish', 510, 0, 'enabled'),
('00000000-0000-8243-0004-000000000052', '00000000-0000-0000-8243-000000000004', 'LT', '立陶宛语', 'Lituanien', 'Lithuanian', 520, 0, 'enabled'),
('00000000-0000-8243-0004-000000000053', '00000000-0000-0000-8243-000000000004', 'LV', '拉脱维亚语', 'Letton', 'Latvian', 530, 0, 'enabled'),
('00000000-0000-8243-0004-000000000054', '00000000-0000-0000-8243-000000000004', 'ET', '爱沙尼亚语', 'Estonien', 'Estonian', 540, 0, 'enabled'),
('00000000-0000-8243-0004-000000000055', '00000000-0000-0000-8243-000000000004', 'SL', '斯洛文尼亚语', 'Slovene', 'Slovenian', 550, 0, 'enabled'),
('00000000-0000-8243-0004-000000000056', '00000000-0000-0000-8243-000000000004', 'IS', '冰岛语', 'Islandais', 'Icelandic', 560, 0, 'enabled'),
('00000000-0000-8243-0004-000000000057', '00000000-0000-0000-8243-000000000004', 'CA', '加泰罗尼亚语', 'Catalan', 'Catalan', 570, 0, 'enabled'),
('00000000-0000-8243-0004-000000000058', '00000000-0000-0000-8243-000000000004', 'HY', '亚美尼亚语', 'Armenien', 'Armenian', 580, 0, 'enabled'),
('00000000-0000-8243-0004-000000000059', '00000000-0000-0000-8243-000000000004', 'KA', '格鲁吉亚语', 'Georgien', 'Georgian', 590, 0, 'enabled'),
('00000000-0000-8243-0004-000000000060', '00000000-0000-0000-8243-000000000004', 'AZ', '阿塞拜疆语', 'Azerbaidjanais', 'Azerbaijani', 600, 0, 'enabled'),
('00000000-0000-8243-0004-000000000061', '00000000-0000-0000-8243-000000000004', 'KK', '哈萨克语', 'Kazakh', 'Kazakh', 610, 0, 'enabled'),
('00000000-0000-8243-0004-000000000062', '00000000-0000-0000-8243-000000000004', 'UZ', '乌兹别克语', 'Ouzbek', 'Uzbek', 620, 0, 'enabled'),
('00000000-0000-8243-0004-000000000063', '00000000-0000-0000-8243-000000000004', 'KY', '吉尔吉斯语', 'Kirghize', 'Kyrgyz', 630, 0, 'enabled'),
('00000000-0000-8243-0004-000000000064', '00000000-0000-0000-8243-000000000004', 'PS', '普什图语', 'Pachto', 'Pashto', 640, 0, 'enabled'),
('00000000-0000-8243-0004-000000000065', '00000000-0000-0000-8243-000000000004', 'KU', '库尔德语', 'Kurde', 'Kurdish', 650, 0, 'enabled'),
('00000000-0000-8243-0004-000000000066', '00000000-0000-0000-8243-000000000004', 'HT', '海地克里奥尔语', 'Creole haitien', 'Haitian Creole', 660, 0, 'enabled'),
('00000000-0000-8243-0004-000000000067', '00000000-0000-0000-8243-000000000004', 'MT', '马耳他语', 'Maltais', 'Maltese', 670, 0, 'enabled'),
('00000000-0000-8243-0004-000000000068', '00000000-0000-0000-8243-000000000004', 'GA', '爱尔兰语', 'Irlandais', 'Irish', 680, 0, 'enabled'),
('00000000-0000-8243-0004-000000000069', '00000000-0000-0000-8243-000000000004', 'CY', '威尔士语', 'Gallois', 'Welsh', 690, 0, 'enabled'),
('00000000-0000-8243-0004-000000000070', '00000000-0000-0000-8243-000000000004', 'ML', '马拉雅拉姆语', 'Malayalam', 'Malayalam', 700, 0, 'enabled'),
('00000000-0000-8243-0004-000000000071', '00000000-0000-0000-8243-000000000004', 'KN', '卡纳达语', 'Kannada', 'Kannada', 710, 0, 'enabled'),
('00000000-0000-8243-0004-000000000072', '00000000-0000-0000-8243-000000000004', 'OR', '奥里亚语', 'Odia', 'Odia', 720, 0, 'enabled'),
('00000000-0000-8243-0004-000000000073', '00000000-0000-0000-8243-000000000004', 'FIL', '菲律宾语', 'Philippin', 'Filipino', 730, 0, 'enabled'),
('00000000-0000-8243-0004-000000000074', '00000000-0000-0000-8243-000000000004', 'AF', '南非荷兰语', 'Afrikaans', 'Afrikaans', 740, 0, 'enabled'),
('00000000-0000-8243-0004-000000000075', '00000000-0000-0000-8243-000000000004', 'MI', '毛利语', 'Maori', 'Maori', 750, 0, 'enabled'),
('00000000-0000-8243-0004-000000000076', '00000000-0000-0000-8243-000000000004', 'MG', '马达加斯加语', 'Malgache', 'Malagasy', 760, 0, 'enabled'),
('00000000-0000-8243-0004-000000000077', '00000000-0000-0000-8243-000000000004', 'SO', '索马里语', 'Somali', 'Somali', 770, 0, 'enabled'),
('00000000-0000-8243-0004-000000000078', '00000000-0000-0000-8243-000000000004', 'SM', '萨摩亚语', 'Samoan', 'Samoan', 780, 0, 'enabled'),
('00000000-0000-8243-0004-000000000079', '00000000-0000-0000-8243-000000000004', 'SD', '信德语', 'Sindhi', 'Sindhi', 790, 0, 'enabled'),
('00000000-0000-8243-0004-000000000080', '00000000-0000-0000-8243-000000000004', 'TK', '土库曼语', 'Turkmene', 'Turkmen', 800, 0, 'enabled'),
('00000000-0000-8243-0005-000000000001', '00000000-0000-0000-8243-000000000005', 'bachelor', '学士', 'Licence', 'Bachelor', 10, 0, 'enabled'),
('00000000-0000-8243-0005-000000000002', '00000000-0000-0000-8243-000000000005', 'bachelor_arts', '文学学士', 'Licence de lettres', 'BA', 20, 0, 'enabled'),
('00000000-0000-8243-0005-000000000003', '00000000-0000-0000-8243-000000000005', 'bachelor_science', '理学学士', 'Licence de sciences', 'BSc', 30, 0, 'enabled'),
('00000000-0000-8243-0005-000000000004', '00000000-0000-0000-8243-000000000005', 'bachelor_engineering', '工科学士', 'Licence d''ingenierie', 'BEng', 40, 0, 'enabled'),
('00000000-0000-8243-0005-000000000005', '00000000-0000-0000-8243-000000000005', 'bachelor_business', '商科学士', 'Licence de commerce', 'BBA', 50, 0, 'enabled'),
('00000000-0000-8243-0005-000000000006', '00000000-0000-0000-8243-000000000005', 'bachelor_law', '法学学士', 'Licence de droit', 'LLB', 60, 0, 'enabled'),
('00000000-0000-8243-0005-000000000007', '00000000-0000-0000-8243-000000000005', 'bachelor_medicine', '医学学士', 'Licence de medecine', 'MBBS', 70, 0, 'enabled'),
('00000000-0000-8243-0005-000000000008', '00000000-0000-0000-8243-000000000005', 'master', '硕士', 'Master', 'Master', 80, 0, 'enabled'),
('00000000-0000-8243-0005-000000000009', '00000000-0000-0000-8243-000000000005', 'master_arts', '文学硕士', 'Master de lettres', 'MA', 90, 0, 'enabled'),
('00000000-0000-8243-0005-000000000010', '00000000-0000-0000-8243-000000000005', 'master_science', '理学硕士', 'Master de sciences', 'MSc', 100, 0, 'enabled'),
('00000000-0000-8243-0005-000000000011', '00000000-0000-0000-8243-000000000005', 'master_engineering', '工科硕士', 'Master d''ingenierie', 'MEng', 110, 0, 'enabled'),
('00000000-0000-8243-0005-000000000012', '00000000-0000-0000-8243-000000000005', 'master_business', '商科硕士', 'Master de commerce', 'MBA', 120, 0, 'enabled'),
('00000000-0000-8243-0005-000000000013', '00000000-0000-0000-8243-000000000005', 'master_finance', '金融硕士', 'Master de finance', 'MFin', 130, 0, 'enabled'),
('00000000-0000-8243-0005-000000000014', '00000000-0000-0000-8243-000000000005', 'master_law', '法学硕士', 'Master de droit', 'LLM', 140, 0, 'enabled'),
('00000000-0000-8243-0005-000000000015', '00000000-0000-0000-8243-000000000005', 'master_medicine', '医学硕士', 'Master de medecine', 'MMed', 150, 0, 'enabled'),
('00000000-0000-8243-0005-000000000016', '00000000-0000-0000-8243-000000000005', 'phd', '博士', 'Doctorat', 'PhD', 160, 0, 'enabled'),
('00000000-0000-8243-0005-000000000017', '00000000-0000-0000-8243-000000000005', 'phd_medicine', '医学博士', 'Doctorat de medecine', 'MD', 170, 0, 'enabled'),
('00000000-0000-8243-0005-000000000018', '00000000-0000-0000-8243-000000000005', 'phd_law', '法学博士', 'Doctorat de droit', 'JD', 180, 0, 'enabled'),
('00000000-0000-8243-0005-000000000019', '00000000-0000-0000-8243-000000000005', 'postdoc', '博士后', 'Post-doctorat', 'Postdoc', 190, 0, 'enabled'),
('00000000-0000-8243-0005-000000000022', '00000000-0000-0000-8243-000000000005', 'other', '其他', 'Autre', 'Other', 220, 1, 'enabled'),
('00000000-0000-8243-0006-000000000001', '00000000-0000-0000-8243-000000000006', 'finance', '金融', 'Finance', 'Finance', 10, 0, 'enabled'),
('00000000-0000-8243-0006-000000000002', '00000000-0000-0000-8243-000000000006', 'technology', '科技', 'Technologie', 'Technology', 20, 0, 'enabled'),
('00000000-0000-8243-0006-000000000003', '00000000-0000-0000-8243-000000000006', 'education', '教育', 'Education', 'Education', 30, 0, 'enabled'),
('00000000-0000-8243-0006-000000000004', '00000000-0000-0000-8243-000000000006', 'other', '其他', 'Autre', 'Other', 40, 1, 'enabled'),
('00000000-0000-8243-0006-000000000005', '00000000-0000-0000-8243-000000000006', 'healthcare', '医疗健康', 'Sante', 'Healthcare', 50, 0, 'enabled'),
('00000000-0000-8243-0006-000000000006', '00000000-0000-0000-8243-000000000006', 'law', '法律', 'Droit', 'Law', 60, 0, 'enabled'),
('00000000-0000-8243-0006-000000000007', '00000000-0000-0000-8243-000000000006', 'arts_design', '艺术设计', 'Arts et design', 'Arts & Design', 70, 0, 'enabled'),
('00000000-0000-8243-0006-000000000008', '00000000-0000-0000-8243-000000000006', 'consulting', '咨询', 'Conseil', 'Consulting', 80, 0, 'enabled'),
('00000000-0000-8243-0006-000000000009', '00000000-0000-0000-8243-000000000006', 'real_estate', '房地产', 'Immobilier', 'Real Estate', 90, 0, 'enabled'),
('00000000-0000-8243-0006-000000000010', '00000000-0000-0000-8243-000000000006', 'media', '传媒', 'Medias', 'Media', 100, 0, 'enabled'),
('00000000-0000-8243-0006-000000000011', '00000000-0000-0000-8243-000000000006', 'public_service', '公共服务', 'Service public', 'Public Service', 110, 0, 'enabled'),
('00000000-0000-8243-0006-000000000012', '00000000-0000-0000-8243-000000000006', 'retail', '零售贸易', 'Commerce', 'Retail', 120, 0, 'enabled'),
('00000000-0000-8243-0007-000000000001', '00000000-0000-0000-8243-000000000007', 'long_term', '长期关系', 'Relation durable', 'Long-term relationship', 10, 0, 'enabled'),
('00000000-0000-8243-0007-000000000002', '00000000-0000-0000-8243-000000000007', 'marriage_oriented', '以婚姻为目标', 'Projet de mariage', 'Marriage oriented', 20, 0, 'enabled'),
('00000000-0000-8243-0007-000000000003', '00000000-0000-0000-8243-000000000007', 'other', '其他', 'Autre', 'Other', 30, 1, 'enabled'),
('00000000-0000-8243-0008-000000000001', '00000000-0000-0000-8243-000000000008', 'current_city', '留在当前城市', 'Rester dans la ville actuelle', 'Stay in current city', 10, 0, 'enabled'),
('00000000-0000-8243-0008-000000000002', '00000000-0000-0000-8243-000000000008', 'open_to_move', '愿意共同规划城市', 'Ouvert a definir une ville commune', 'Open to planning a shared city', 20, 0, 'enabled'),
('00000000-0000-8243-0008-000000000003', '00000000-0000-0000-8243-000000000008', 'other', '其他', 'Autre', 'Other', 30, 1, 'enabled'),
('00000000-0000-8243-0009-000000000001', '00000000-0000-0000-8243-000000000009', 'bachelor_or_above', '本科及以上', 'Licence ou plus', 'Bachelor or above', 10, 0, 'enabled'),
('00000000-0000-8243-0009-000000000002', '00000000-0000-0000-8243-000000000009', 'master_or_above', '硕士及以上', 'Master ou plus', 'Master or above', 20, 0, 'enabled'),
('00000000-0000-8243-0009-000000000003', '00000000-0000-0000-8243-000000000009', 'other', '其他', 'Autre', 'Other', 30, 1, 'enabled'),
('00000000-0000-8243-0010-000000000001', '00000000-0000-0000-8243-000000000010', 'open_to_discuss', '愿意沟通家庭规划', 'Ouvert a discuter', 'Open to discuss', 10, 0, 'enabled'),
('00000000-0000-8243-0010-000000000002', '00000000-0000-0000-8243-000000000010', 'clear_plan', '有明确家庭规划', 'Projet familial clair', 'Clear family plan', 20, 0, 'enabled'),
('00000000-0000-8243-0010-000000000003', '00000000-0000-0000-8243-000000000010', 'other', '其他', 'Autre', 'Other', 30, 1, 'enabled'),
('00000000-0000-8243-0011-000000000001', '00000000-0000-0000-8243-000000000011', 'regular', '规律运动', 'Activite reguliere', 'Regular exercise', 10, 0, 'enabled'),
('00000000-0000-8243-0011-000000000002', '00000000-0000-0000-8243-000000000011', 'occasional', '偶尔运动', 'Activite occasionnelle', 'Occasional exercise', 20, 0, 'enabled'),
('00000000-0000-8243-0011-000000000003', '00000000-0000-0000-8243-000000000011', 'other', '其他', 'Autre', 'Other', 30, 1, 'enabled'),
('00000000-0000-8243-0012-000000000001', '00000000-0000-0000-8243-000000000012', 'bachelor', '本科', 'Licence', 'Bachelor', 10, 0, 'enabled'),
('00000000-0000-8243-0012-000000000002', '00000000-0000-0000-8243-000000000012', 'master', '硕士', 'Master', 'Master', 20, 0, 'enabled'),
('00000000-0000-8243-0012-000000000003', '00000000-0000-0000-8243-000000000012', 'phd', '博士', 'Doctorat', 'PhD', 30, 0, 'enabled'),
('00000000-0000-8243-0013-000000000001', '00000000-0000-0000-8243-000000000013', 'never_married', '未婚', 'Jamais marie', 'Never married', 10, 0, 'enabled'),
('00000000-0000-8243-0013-000000000002', '00000000-0000-0000-8243-000000000013', 'divorced', '离异', 'Divorce', 'Divorced', 20, 0, 'enabled'),
('00000000-0000-8243-0013-000000000003', '00000000-0000-0000-8243-000000000013', 'widowed', '丧偶', 'Veuf/veuve', 'Widowed', 30, 0, 'enabled'),
('00000000-0000-8243-0014-000000000001', '00000000-0000-0000-8243-000000000014', 'wants', '希望有孩子', 'Souhaite des enfants', 'Wants children', 10, 0, 'enabled'),
('00000000-0000-8243-0014-000000000002', '00000000-0000-0000-8243-000000000014', 'open_to_discuss', '愿意沟通', 'Ouvert a discuter', 'Open to discuss', 20, 0, 'enabled'),
('00000000-0000-8243-0014-000000000003', '00000000-0000-0000-8243-000000000014', 'does_not_want', '不计划要孩子', 'Ne souhaite pas d''enfants', 'Does not want children', 30, 0, 'enabled'),
('00000000-0000-8243-0015-000000000001', '00000000-0000-0000-8243-000000000015', 'serious', '认真交往', 'Relation serieuse', 'Serious relationship', 10, 0, 'enabled'),
('00000000-0000-8243-0015-000000000002', '00000000-0000-0000-8243-000000000015', 'marriage', '以婚姻为目标', 'Projet de mariage', 'Marriage minded', 20, 0, 'enabled'),
('00000000-0000-8243-0015-000000000003', '00000000-0000-0000-8243-000000000015', 'exclusive', '稳定专一关系', 'Relation exclusive', 'Exclusive relationship', 30, 0, 'enabled'),
('00000000-0000-8243-0015-000000000004', '00000000-0000-0000-8243-000000000015', 'cross_border', '接受跨境发展', 'Ouvert a l''international', 'Open to cross-border', 40, 0, 'enabled'),
('00000000-0000-8243-0016-000000000001', '00000000-0000-0000-8243-000000000016', 'willing', '愿意', 'Oui', 'Willing', 10, 0, 'enabled'),
('00000000-0000-8243-0016-000000000002', '00000000-0000-0000-8243-000000000016', 'unwilling', '不愿意', 'Non', 'Unwilling', 20, 0, 'enabled'),
('00000000-0000-8243-0016-000000000003', '00000000-0000-0000-8243-000000000016', 'open_to_discuss', '可以讨论', 'A discuter', 'Open to discuss', 30, 0, 'enabled'),
('00000000-0000-8243-0017-000000000001', '00000000-0000-0000-8243-000000000017', 'honesty', '诚实', 'Honnetete', 'Honesty', 10, 0, 'enabled'),
('00000000-0000-8243-0017-000000000002', '00000000-0000-0000-8243-000000000017', 'trust', '信任', 'Confiance', 'Trust', 20, 0, 'enabled'),
('00000000-0000-8243-0017-000000000003', '00000000-0000-0000-8243-000000000017', 'communication', '沟通', 'Communication', 'Communication', 30, 0, 'enabled'),
('00000000-0000-8243-0017-000000000004', '00000000-0000-0000-8243-000000000017', 'respect', '尊重', 'Respect', 'Respect', 40, 0, 'enabled'),
('00000000-0000-8243-0017-000000000005', '00000000-0000-0000-8243-000000000017', 'loyalty', '忠诚', 'Loyaute', 'Loyalty', 50, 0, 'enabled'),
('00000000-0000-8243-0017-000000000006', '00000000-0000-0000-8243-000000000017', 'family', '家庭', 'Famille', 'Family', 60, 0, 'enabled'),
('00000000-0000-8243-0017-000000000007', '00000000-0000-0000-8243-000000000017', 'growth', '共同成长', 'Croissance commune', 'Growth', 70, 0, 'enabled'),
('00000000-0000-8243-0017-000000000008', '00000000-0000-0000-8243-000000000017', 'support', '相互支持', 'Soutien mutuel', 'Support', 80, 0, 'enabled'),
('00000000-0000-8243-0017-000000000009', '00000000-0000-0000-8243-000000000017', 'humor', '幽默', 'Humour', 'Humor', 90, 0, 'enabled'),
('00000000-0000-8243-0017-000000000010', '00000000-0000-0000-8243-000000000017', 'ambition', '事业心', 'Ambition', 'Ambition', 100, 0, 'enabled'),
('00000000-0000-8243-0017-000000000011', '00000000-0000-0000-8243-000000000017', 'kindness', '善良', 'Bienveillance', 'Kindness', 110, 0, 'enabled'),
('00000000-0000-8243-0017-000000000012', '00000000-0000-0000-8243-000000000017', 'independence', '独立', 'Independance', 'Independence', 120, 0, 'enabled'),
('00000000-0000-8243-0017-000000000013', '00000000-0000-0000-8243-000000000017', 'romance', '浪漫', 'Romance', 'Romance', 130, 0, 'enabled'),
('00000000-0000-8243-0017-000000000014', '00000000-0000-0000-8243-000000000017', 'stability', '稳定', 'Stabilite', 'Stability', 140, 0, 'enabled'),
('00000000-0000-8243-0018-000000000001', '00000000-0000-0000-8243-000000000018', 'local', '同城', 'Meme ville', 'Local', 10, 0, 'enabled'),
('00000000-0000-8243-0018-000000000002', '00000000-0000-0000-8243-000000000018', 'regional', '同区域', 'Region', 'Regional', 20, 0, 'enabled'),
('00000000-0000-8243-0018-000000000003', '00000000-0000-0000-8243-000000000018', 'national', '全国', 'National', 'National', 30, 0, 'enabled'),
('00000000-0000-8243-0018-000000000004', '00000000-0000-0000-8243-000000000018', 'international', '不限', 'International', 'International', 40, 0, 'enabled'),
('00000000-0000-8243-0019-000000000001', '00000000-0000-0000-8243-000000000019', 'never', '从不', 'Jamais', 'Never', 10, 0, 'enabled'),
('00000000-0000-8243-0019-000000000002', '00000000-0000-0000-8243-000000000019', 'social', '社交场合', 'Occasionnel', 'Socially', 20, 0, 'enabled'),
('00000000-0000-8243-0019-000000000003', '00000000-0000-0000-8243-000000000019', 'often', '经常', 'Souvent', 'Often', 30, 0, 'enabled'),
('00000000-0000-8243-0020-000000000001', '00000000-0000-0000-8243-000000000020', 'never', '从不', 'Jamais', 'Never', 10, 0, 'enabled'),
('00000000-0000-8243-0020-000000000002', '00000000-0000-0000-8243-000000000020', 'social', '社交场合', 'Occasionnel', 'Socially', 20, 0, 'enabled'),
('00000000-0000-8243-0020-000000000003', '00000000-0000-0000-8243-000000000020', 'often', '经常', 'Souvent', 'Often', 30, 0, 'enabled'),
('00000000-0000-8243-0021-000000000001', '00000000-0000-0000-8243-000000000021', 'low', '低', 'Faible', 'Low', 10, 0, 'enabled'),
('00000000-0000-8243-0021-000000000002', '00000000-0000-0000-8243-000000000021', 'moderate', '中等', 'Modere', 'Moderate', 20, 0, 'enabled'),
('00000000-0000-8243-0021-000000000003', '00000000-0000-0000-8243-000000000021', 'high', '高', 'Eleve', 'High', 30, 0, 'enabled'),
('00000000-0000-8243-0022-000000000001', '00000000-0000-0000-8243-000000000022', 'outdoors', '户外', 'Exterieur', 'Outdoors', 10, 0, 'enabled'),
('00000000-0000-8243-0022-000000000002', '00000000-0000-0000-8243-000000000022', 'indoors', '宅家', 'Interieur', 'Indoors', 20, 0, 'enabled'),
('00000000-0000-8243-0022-000000000003', '00000000-0000-0000-8243-000000000022', 'social', '社交聚会', 'Social', 'Social', 30, 0, 'enabled'),
('00000000-0000-8243-0022-000000000004', '00000000-0000-0000-8243-000000000022', 'flexible', '看心情', 'Flexible', 'Flexible', 40, 0, 'enabled'),
('00000000-0000-8243-0023-000000000001', '00000000-0000-0000-8243-000000000023', 'has', '有宠物', 'A des animaux', 'Has pets', 10, 0, 'enabled'),
('00000000-0000-8243-0023-000000000002', '00000000-0000-0000-8243-000000000023', 'none', '不养', 'Pas d''animaux', 'No pets', 20, 0, 'enabled'),
('00000000-0000-8243-0023-000000000003', '00000000-0000-0000-8243-000000000023', 'likes', '喜欢但不养', 'Aime sans en avoir', 'Likes pets', 30, 0, 'enabled'),
('00000000-0000-8243-0024-000000000001', '00000000-0000-0000-8243-000000000024', 'direct', '直接', 'Direct', 'Direct', 10, 0, 'enabled'),
('00000000-0000-8243-0024-000000000002', '00000000-0000-0000-8243-000000000024', 'indirect', '委婉', 'Indirect', 'Indirect', 20, 0, 'enabled'),
('00000000-0000-8243-0024-000000000003', '00000000-0000-0000-8243-000000000024', 'balanced', '看情况', 'Equilibre', 'Balanced', 30, 0, 'enabled');


-- Cupid scheduled jobs.
insert into sys_job values(4, '私人介绍过期补偿', 'CUPID', 'cupidTask.expireIntroductionRequests', '0 */10 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '处理过期私人介绍申请并返还权益');
insert into sys_job values(5, '安全挑战过期清理', 'CUPID', 'cupidTask.expireSecurityChallenges', '30 */10 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '标记已过期的安全挑战');
insert into sys_job values(6, '会员状态归一化', 'CUPID', 'cupidTask.expireMemberships', '0 5 0 * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '过期失效会员、清理多条当前会员，并为无当前会员用户恢复免费会员');
insert into sys_job values(7, '活动站内提醒', 'CUPID', 'cupidTask.sendEventReminders', '0 */10 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '向24小时内开始的活动确认用户发送站内提醒');
insert into sys_job values(8, '跟进事项逾期提醒', 'CUPID', 'cupidTask.sendOverdueStaffTaskReminders', '30 */10 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '向逾期跟进事项负责人发送后台通知');
insert into sys_job values(9, '翻译失败重试', 'CUPID', 'cupidTask.retryFailedTranslations', '0 */5 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '按指数退避重试机器翻译失败任务');
insert into sys_job values(10, '消息失败重试', 'CUPID', 'cupidTask.retryFailedMessages', '30 */5 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '重试瞬时基础设施异常导致的站内消息失败');
insert into sys_job values(11, '运营数据定期清理', 'CUPID', 'cupidTask.cleanupOperationalData', '0 20 3 * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '按保留策略分批清理技术日志及过期运行数据');
insert into sys_job values(12, '活动生命周期同步', 'CUPID', 'cupidTask.synchronizeEventLifecycle', '0 */5 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '自动确认报名、递补候补并归档已结束活动');

insert into sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
select 'Cupid 平台管理员', 'cupid_admin', 10, '1', 1, 1, '0', '0', 'admin', sysdate(), '全部 Cupid 运营能力'
where not exists (select 1 from sys_role where role_key = 'cupid_admin' and del_flag = '0');

insert into sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
select 'Cupid 审核员', 'cupid_reviewer', 11, '1', 1, 1, '0', '0', 'admin', sysdate(), 'Profile/Photo/Verification/Introduction 审核'
where not exists (select 1 from sys_role where role_key = 'cupid_reviewer' and del_flag = '0');

insert into sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
select 'Cupid 活动管理员', 'cupid_event_manager', 12, '1', 1, 1, '0', '0', 'admin', sysdate(), 'Event/Registration 运营'
where not exists (select 1 from sys_role where role_key = 'cupid_event_manager' and del_flag = '0');

insert into sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
select 'Cupid 用户支持', 'cupid_support', 13, '1', 1, 1, '0', '0', 'admin', sysdate(), 'App User/Inbox/Staff Task 运营'
where not exists (select 1 from sys_role where role_key = 'cupid_support' and del_flag = '0');

insert into sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
select 'Cupid 审计员', 'cupid_auditor', 14, '1', 1, 1, '0', '0', 'admin', sysdate(), 'Cupid 业务审计只读'
where not exists (select 1 from sys_role where role_key = 'cupid_auditor' and del_flag = '0');

insert into sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
select 'Cupid 资料运营', 'cupid_profile_operator', 15, '1', 1, 1, '0', '0', 'admin', sysdate(), 'Profile Library/Profile Manage 运营'
where not exists (select 1 from sys_role where role_key = 'cupid_profile_operator' and del_flag = '0');

insert into sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
select 'Cupid 内容配置', 'cupid_content_operator', 16, '1', 1, 1, '0', '0', 'admin', sysdate(), 'Options/Legal/Inbox Template 配置'
where not exists (select 1 from sys_role where role_key = 'cupid_content_operator' and del_flag = '0');

insert into sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
select 'Cupid 支付财务', 'cupid_payment_operator', 17, '1', 1, 1, '0', '0', 'admin', sysdate(), 'Membership/Payment 运营'
where not exists (select 1 from sys_role where role_key = 'cupid_payment_operator' and del_flag = '0');

insert into sys_role (role_name, role_key, role_sort, data_scope, menu_check_strictly, dept_check_strictly, status, del_flag, create_by, create_time, remark)
select 'Cupid 运营监控', 'cupid_monitor_reader', 18, '1', 1, 1, '0', '0', 'admin', sysdate(), 'Monitor/Audit/Security 只读'
where not exists (select 1 from sys_role where role_key = 'cupid_monitor_reader' and del_flag = '0');

insert into sys_user_role (user_id, role_id) select 10, role_id from sys_role where role_key = 'cupid_admin' and del_flag = '0';
insert into sys_user_role (user_id, role_id) select 11, role_id from sys_role where role_key = 'cupid_reviewer' and del_flag = '0';
insert into sys_user_role (user_id, role_id) select 12, role_id from sys_role where role_key = 'cupid_event_manager' and del_flag = '0';
insert into sys_user_role (user_id, role_id) select 13, role_id from sys_role where role_key = 'cupid_support' and del_flag = '0';
insert into sys_user_role (user_id, role_id) select 14, role_id from sys_role where role_key = 'cupid_auditor' and del_flag = '0';
insert into sys_user_role (user_id, role_id) select 15, role_id from sys_role where role_key = 'cupid_profile_operator' and del_flag = '0';
insert into sys_user_role (user_id, role_id) select 16, role_id from sys_role where role_key = 'cupid_content_operator' and del_flag = '0';
insert into sys_user_role (user_id, role_id) select 17, role_id from sys_role where role_key = 'cupid_payment_operator' and del_flag = '0';
insert into sys_user_role (user_id, role_id) select 18, role_id from sys_role where role_key = 'cupid_monitor_reader' and del_flag = '0';

delete from sys_role_menu where menu_id between 2000 and 2120;
delete from sys_menu where menu_id between 2000 and 2120;

insert into sys_menu values
('2000', '审核中心', '0', '10', 'cupid', null, '', 'Cupid', 1, 0, 'M', '0', '0', '', 'clipboard', 'admin', sysdate(), '', null, 'Cupid 审核中心目录'),
('2010', '资料审核', '2000', '1', 'profile', 'cupid/profile/index', '', 'CupidProfile', 1, 0, 'C', '0', '0', 'cupid:profile:list', 'user', 'admin', sysdate(), '', null, 'Cupid 资料审核页面'),
('2011', '资料查询', '2010', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profile:query', '#', 'admin', sysdate(), '', null, ''),
('2012', '资料审核', '2010', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profile:review', '#', 'admin', sysdate(), '', null, ''),
('2020', '照片审核', '2000', '2', 'photo', 'cupid/photo/index', '', 'CupidPhoto', 1, 0, 'C', '0', '0', 'cupid:photo:list', 'eye', 'admin', sysdate(), '', null, 'Cupid 照片审核页面'),
('2021', '照片查询', '2020', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:photo:query', '#', 'admin', sysdate(), '', null, ''),
('2022', '照片审核', '2020', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:photo:review', '#', 'admin', sysdate(), '', null, ''),
('2030', '认证审核', '2000', '3', 'verification', null, '', 'CupidVerificationRoot', 1, 0, 'M', '0', '0', '', 'education', 'admin', sysdate(), '', null, 'Cupid 认证材料审核目录'),
('2031', '身份认证审核', '2030', '1', 'identity', 'cupid/verification/identity/index', '', 'CupidIdentityVerification', 1, 0, 'C', '0', '0', 'cupid:verification:identity:list', 'peoples', 'admin', sysdate(), '', null, 'Cupid 身份认证审核'),
('2032', '学历认证审核', '2030', '2', 'education', 'cupid/verification/education/index', '', 'CupidEducationVerification', 1, 0, 'C', '0', '0', 'cupid:verification:education:list', 'education', 'admin', sysdate(), '', null, 'Cupid 学历认证审核'),
('2033', '收入认证审核', '2030', '3', 'income', 'cupid/verification/income/index', '', 'CupidIncomeVerification', 1, 0, 'C', '0', '0', 'cupid:verification:income:list', 'money', 'admin', sysdate(), '', null, 'Cupid 收入认证审核'),
('2034', '婚姻认证审核', '2030', '4', 'marital', 'cupid/verification/marital/index', '', 'CupidMaritalVerification', 1, 0, 'C', '0', '0', 'cupid:verification:marital:list', 'people', 'admin', sysdate(), '', null, 'Cupid 婚姻认证审核'),
('2035', '认证列表', '2030', '5', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:verification:list', '#', 'admin', sysdate(), '', null, ''),
('2036', '认证查询', '2030', '6', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:verification:query', '#', 'admin', sysdate(), '', null, ''),
('2037', '认证审核', '2030', '7', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:verification:review', '#', 'admin', sysdate(), '', null, ''),
('2038', '材料预览', '2030', '8', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:verification:material:preview', '#', 'admin', sysdate(), '', null, ''),
('2039', '材料下载', '2030', '9', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:verification:material:download', '#', 'admin', sysdate(), '', null, ''),
('2048', '材料补录', '2030', '10', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:verification:material:create', '#', 'admin', sysdate(), '', null, ''),
('2049', '认证重置', '2030', '11', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:verification:reset', '#', 'admin', sysdate(), '', null, ''),
('2040', '资料中心', '0', '11', 'profile-center', null, '', 'CupidProfileCenterRoot', 1, 0, 'M', '0', '0', '', 'user', 'admin', sysdate(), '', null, 'Cupid 资料中心目录'),
('2041', '资料库', '2040', '1', 'library', 'cupid/profile-library/index', '', 'CupidProfileLibrary', 1, 0, 'C', '0', '0', 'cupid:profileLibrary:list', 'list', 'admin', sysdate(), '', null, 'Cupid 资料库'),
('2042', '资料库查询', '2041', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profileLibrary:query', '#', 'admin', sysdate(), '', null, ''),
('2043', '资料运营', '2040', '2', 'manage', 'cupid/profile-manage/index', '', 'CupidProfileManage', 1, 0, 'C', '0', '0', 'cupid:profileManage:list', 'edit', 'admin', sysdate(), '', null, 'Cupid 资料运营管理'),
('2044', '资料运营查询', '2043', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profileManage:query', '#', 'admin', sysdate(), '', null, ''),
('2045', '运营字段编辑', '2043', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profileManage:edit', '#', 'admin', sysdate(), '', null, ''),
('2046', '内部备注查看', '2043', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profileManage:notes', '#', 'admin', sysdate(), '', null, ''),
('2047', '内部备注编辑', '2043', '4', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:profileManage:editNotes', '#', 'admin', sysdate(), '', null, ''),
('2050', '配置中心', '0', '12', 'cupid-config', null, '', 'CupidConfigRoot', 1, 0, 'M', '0', '0', '', 'dict', 'admin', sysdate(), '', null, 'Cupid 配置中心目录'),
('2051', '通用选项', '2050', '1', 'options', 'cupid/options/index', '', 'CupidOptions', 1, 0, 'C', '0', '0', 'cupid:options:list', 'dict', 'admin', sysdate(), '', null, 'Cupid 通用选项管理'),
('2052', '选项查询', '2051', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:options:query', '#', 'admin', sysdate(), '', null, ''),
('2053', '选项编辑', '2051', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:options:edit', '#', 'admin', sysdate(), '', null, ''),
('2060', '关系服务', '0', '13', 'relationship-service', null, '', 'CupidRelationshipRoot', 1, 0, 'M', '0', '0', '', 'peoples', 'admin', sysdate(), '', null, 'Cupid 关系服务目录'),
('2061', '私人介绍', '2060', '1', 'introduction', 'cupid/introduction/index', '', 'CupidIntroduction', 1, 0, 'C', '0', '0', 'cupid:introduction:list', 'peoples', 'admin', sysdate(), '', null, 'Cupid 私人介绍受理页面'),
('2062', '私人介绍查询', '2061', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:introduction:query', '#', 'admin', sysdate(), '', null, ''),
('2063', '私人介绍受理', '2061', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:introduction:accept', '#', 'admin', sysdate(), '', null, ''),
('2064', '私人介绍暂不受理', '2061', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:introduction:decline', '#', 'admin', sysdate(), '', null, ''),
('2065', '私人介绍备注', '2061', '4', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:introduction:note', '#', 'admin', sysdate(), '', null, ''),
('2070', '活动运营', '0', '14', 'cupid-event', null, '', 'CupidEventRoot', 1, 0, 'M', '0', '0', '', 'date', 'admin', sysdate(), '', null, 'Cupid 活动运营目录'),
('2071', '活动管理', '2070', '1', 'event', 'cupid/event/index', '', 'CupidEvent', 1, 0, 'C', '0', '0', 'cupid:event:list', 'date', 'admin', sysdate(), '', null, 'Cupid 活动管理页面'),
('2072', '活动查询', '2071', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:event:query', '#', 'admin', sysdate(), '', null, ''),
('2073', '活动状态变更', '2071', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:event:changeStatus', '#', 'admin', sysdate(), '', null, ''),
('2074', '报名审核', '2070', '2', 'registration', 'cupid/event-registration/index', '', 'CupidEventRegistration', 1, 0, 'C', '0', '0', 'cupid:eventRegistration:list', 'list', 'admin', sysdate(), '', null, 'Cupid 活动报名审核页面'),
('2075', '报名查询', '2074', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:eventRegistration:query', '#', 'admin', sysdate(), '', null, ''),
('2076', '报名处理', '2074', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:eventRegistration:review', '#', 'admin', sysdate(), '', null, ''),
('2077', '活动新增', '2071', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:event:add', '#', 'admin', sysdate(), '', null, ''),
('2078', '活动编辑', '2071', '4', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:event:edit', '#', 'admin', sysdate(), '', null, ''),
('2080', '用户服务', '0', '15', 'cupid-service', null, '', 'CupidUserServiceRoot', 1, 0, 'M', '0', '0', '', 'message', 'admin', sysdate(), '', null, 'Cupid 用户服务目录'),
('2081', '通知发布', '2080', '1', 'inbox', 'cupid/inbox/index', '', 'CupidInbox', 1, 0, 'C', '0', '0', 'cupid:inbox:send', 'message', 'admin', sysdate(), '', null, 'Cupid C端通知发布'),
('2082', '通知预览', '2081', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:inbox:preview', '#', 'admin', sysdate(), '', null, ''),
('2083', '通知群发', '2081', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:inbox:broadcast', '#', 'admin', sysdate(), '', null, ''),
('2084', '通知模板', '2080', '2', 'inbox-template', 'cupid/inbox-template/index', '', 'CupidInboxTemplate', 1, 0, 'C', '0', '0', 'cupid:inboxTemplate:list', 'edit', 'admin', sysdate(), '', null, 'Cupid 通知模板管理'),
('2085', '模板查询', '2084', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:inboxTemplate:query', '#', 'admin', sysdate(), '', null, ''),
('2086', '模板新增', '2084', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:inboxTemplate:add', '#', 'admin', sysdate(), '', null, ''),
('2087', '模板编辑', '2084', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:inboxTemplate:edit', '#', 'admin', sysdate(), '', null, ''),
('2088', '模板启停', '2084', '4', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:inboxTemplate:changeStatus', '#', 'admin', sysdate(), '', null, '');

insert into sys_menu values('2089', 'App 用户管理', '2080', '3', 'user', 'cupid/user/index', '', 'CupidUser', 1, 0, 'C', '0', '0', 'cupid:user:list', 'user', 'admin', sysdate(), '', null, 'Cupid App 用户管理');
insert into sys_menu values('2090', '用户查询', '2089', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:user:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2091', '用户状态变更', '2089', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:user:status', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2092', '用户会话查询', '2089', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:user:session:list', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2093', '用户会话强退', '2089', '4', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:user:session:kick', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2094', '查看完整敏感信息', '2089', '5', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:user:sensitive', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2095', '会员管理', '2080', '4', 'membership', 'cupid/membership/index', '', 'CupidMembership', 1, 0, 'C', '0', '0', 'cupid:membership:list', 'money', 'admin', sysdate(), '', null, 'Cupid 会员管理');
insert into sys_menu values('2096', '会员查询', '2095', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:membership:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2097', '会员状态变更', '2095', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:membership:status', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2098', '会员资料编辑', '2095', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:membership:edit', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2099', '运营协作', '0', '16', 'cupid-operation', null, '', 'CupidOperationRoot', 1, 0, 'M', '0', '0', '', 'clipboard', 'admin', sysdate(), '', null, 'Cupid 运营协作目录');
insert into sys_menu values('2100', '跟进事项', '2099', '1', 'task', 'cupid/staff-task/index', '', 'CupidStaffTask', 1, 0, 'C', '0', '0', 'cupid:staffTask:list', 'list', 'admin', sysdate(), '', null, 'Cupid 跟进事项');
insert into sys_menu values('2101', '任务查询', '2100', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:staffTask:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2102', '任务新增', '2100', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:staffTask:add', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2103', '任务编辑', '2100', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:staffTask:edit', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2104', '业务审计', '2099', '2', 'audit', 'cupid/audit/index', '', 'CupidAudit', 1, 0, 'C', '0', '0', 'cupid:audit:list', 'eye', 'admin', sysdate(), '', null, 'Cupid 业务审计');
insert into sys_menu values('2105', '审计查询', '2104', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:audit:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2106', '安全事件', '2099', '3', 'security-event', 'cupid/security-event/index', '', 'CupidSecurityEvent', 1, 0, 'C', '0', '0', 'cupid:security:event:list', 'lock', 'admin', sysdate(), '', null, 'Cupid C端安全事件中心');
insert into sys_menu values('2107', '安全事件查询', '2106', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:security:event:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2108', '安全事件导出', '2106', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:security:event:export', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2109', '业务监控', '2099', '4', 'monitor', 'cupid/monitor/index', '', 'CupidBusinessMonitor', 1, 0, 'C', '0', '0', 'cupid:monitor:list', 'monitor', 'admin', sysdate(), '', null, 'Cupid 业务专项只读监控');
insert into sys_menu values('2110', '支付订阅', '2080', '5', 'payment', 'cupid/payment/index', '', 'CupidPayment', 1, 0, 'C', '0', '0', 'cupid:payment:list', 'money', 'admin', sysdate(), '', null, 'Cupid 支付订阅与支付回调日志查询');
insert into sys_menu values('2111', '支付订单查询', '2110', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:payment:list', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2112', '回调日志查询', '2110', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:payment:webhook:list', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2113', '取消订阅续费', '2110', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:payment:subscription:cancel', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2114', '支付订单退款', '2110', '4', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:payment:refund', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2115', '联系咨询', '2080', '6', 'contact-lead', 'cupid/contact-lead/index', '', 'CupidContactLead', 1, 0, 'C', '0', '0', 'cupid:contactLead:list', 'message', 'admin', sysdate(), '', null, 'Cupid 联系咨询线索');
insert into sys_menu values('2116', '联系咨询查询', '2115', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:contactLead:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2117', '联系咨询处理', '2115', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:contactLead:handle', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2118', '法律条款', '2050', '4', 'legal', 'cupid/legal/index', '', 'CupidLegal', 1, 0, 'C', '0', '0', 'cupid:legal:list', 'documentation', 'admin', sysdate(), '', null, 'Cupid 服务条款与隐私政策管理');
insert into sys_menu values('2119', '法律条款查询', '2118', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:legal:query', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('2120', '法律条款编辑', '2118', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:legal:edit', '#', 'admin', sysdate(), '', null, '');

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id between 2000 and 2120
where r.role_key = 'cupid_admin' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on (m.menu_id between 2000 and 2039 or m.menu_id between 2060 and 2065)
where r.role_key = 'cupid_reviewer' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id in (2000, 2010, 2011, 2020, 2021, 2030, 2031, 2032, 2033, 2034, 2035, 2036, 2060, 2061, 2062)
where r.role_key = 'cupid_auditor' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id in (2099, 2104, 2105, 2106, 2107)
where r.role_key = 'cupid_auditor' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id in (2040, 2041, 2042)
where r.role_key = 'cupid_support' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id in (2080, 2081, 2082, 2115, 2116, 2117)
where r.role_key = 'cupid_support' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id in (2089, 2090, 2092)
where r.role_key = 'cupid_support' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id in (2099, 2100, 2101, 2103)
where r.role_key = 'cupid_support' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id between 2070 and 2079
where r.role_key = 'cupid_event_manager' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id between 2040 and 2047
where r.role_key = 'cupid_profile_operator' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id in (2050, 2051, 2052, 2053, 2080, 2084, 2085, 2086, 2087, 2088, 2118, 2119, 2120)
where r.role_key = 'cupid_content_operator' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id in (2080, 2095, 2096, 2097, 2098, 2110, 2111, 2112, 2113, 2114)
where r.role_key = 'cupid_payment_operator' and r.del_flag = '0';

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id in (2099, 2104, 2105, 2106, 2107, 2109)
where r.role_key = 'cupid_monitor_reader' and r.del_flag = '0';

-- Legal documents required by registration and account flows.
insert into cm_legal_documents (id, type, version, status, effective_at, created_at, updated_at) values
  ('6f0081c5-e57a-5470-8177-93902e24302d', 'terms', '1.0', 'active', '2026-01-01 00:00:00', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('85a634d2-f126-5d90-be6d-d550f2b920fc', 'privacy', '1.0', 'active', '2026-01-01 00:00:00', '2026-01-01 00:00:00', '2026-01-01 00:00:00');

-- 3A.7 Legal document contents
insert into cm_legal_document_contents (id, document_id, locale, title, sections, created_at, updated_at) values
  ('d5f896e8-5bf2-547a-b4c5-bebadee254a0', '6f0081c5-e57a-5470-8177-93902e24302d', 'zh', 'Cupid Match 平台服务条款', '[{"heading":"第一条 定义与接受","clauses":[{"number":"1.1","body":"Cupid Match 平台（以下简称\\"平台\\"）是由 Cupid Match 运营方（以下简称\\"我们\\"）提供的婚恋中介撮合服务平台。"},{"number":"1.2","body":"本服务条款（以下简称\\"条款\\"）是您与平台之间关于使用平台服务的完整协议。您在注册时勾选\\"我已阅读并同意\\"，即表示您已完整阅读、充分理解并自愿接受本条款的全部内容。"},{"number":"1.3","body":"平台可能通过弹窗、页面提示、站内信等方式向您发送通知。您继续使用平台服务即表示您同意接收此类通知。"}],"sortOrder":1},{"heading":"第二条 账号注册与安全","clauses":[{"number":"2.1","body":"注册资格：您确认您年满 18 周岁，具有完全民事行为能力。如果您代表他人（如子女）注册，您需获得该人士的明确授权。"},{"number":"2.2","body":"注册信息：您应提供真实、准确、完整的注册信息，包括但不限于姓名、邮箱或手机号。注册信息发生变更时，您应及时更新。"},{"number":"2.3","body":"账号安全：您对账号下的所有活动负责。请妥善保管您的登录凭证，不得将账号出借、转让或授权他人使用。如发现账号被盗用，应立即通知平台。"},{"number":"2.4","body":"实名认证：平台有权要求您完成实名认证。未通过实名认证的账号，平台可限制部分功能的使用。"}],"sortOrder":2},{"heading":"第三条 服务内容","clauses":[{"number":"3.1","body":"平台提供以下核心服务：\\n（a）个人资料创建与展示：您可创建个人相亲资料，包括个人信息、照片、择偶偏好等；\\n（b）智能匹配与推荐：平台根据您的资料和偏好，推荐匹配度较高的其他用户；\\n（c）资料浏览与搜索：您可在平台范围内浏览和筛选其他用户的公开资料；\\n（d）私人介绍服务：平台顾问根据双方情况提供定向撮合介绍服务；\\n（e）线下活动：平台定期组织线下交友活动，您可报名参加；\\n（f）顾问服务：平台顾问提供婚恋咨询、资料优化、撮合跟进等服务。"},{"number":"3.2","body":"平台保留根据运营需要调整、增减服务内容的权利。重大调整将提前 7 日在平台上公告。"}],"sortOrder":3},{"heading":"第四条 会员与付费","clauses":[{"number":"4.1","body":"平台提供免费基础服务和付费会员服务。免费用户可访问基本功能，付费会员享有更多权益（如增加私人介绍额度、优先活动报名、专属顾问服务等）。"},{"number":"4.2","body":"会员套餐和价格以平台公布为准。平台可能不时调整套餐内容和价格，调整前已购买的套餐不受影响。"},{"number":"4.3","body":"除法律规定的情形外，已支付的会员费用不予退还。"},{"number":"4.4","body":"会员到期后，您将恢复免费用户权限。平台保留在会员到期前提醒您续费的权利。"}],"sortOrder":4},{"heading":"第五条 用户行为规范","clauses":[{"number":"5.1","body":"您承诺在使用平台过程中遵守以下规范：\\n（a）遵守中华人民共和国法律法规及您所在地区的适用法律；\\n（b）遵守社会公序良俗，尊重他人合法权益；\\n（c）发布真实、合法、准确的信息，不编造虚假身份、年龄、婚姻状况、职业等资料；\\n（d）不利用平台从事任何违法违规活动，包括但不限于诈骗、传销、赌博、色情服务等。"},{"number":"5.2","body":"禁止行为包括但不限于：\\n（a）骚扰、辱骂、恐吓、跟踪其他用户；\\n（b）未经许可收集、存储、传播其他用户的个人信息；\\n（c）发布商业广告、垃圾信息或与婚恋交友无关的内容；\\n（d）绕开平台私下交易或进行资金往来；\\n（e）利用技术手段干扰平台正常运营（如爬虫、刷量、注入攻击等）；\\n（f）冒用平台名义或冒充平台工作人员。"}],"sortOrder":5},{"heading":"第六条 信息审核与处置","clauses":[{"number":"6.1","body":"平台有权对用户发布的资料、照片、文字等内容进行审核。审核标准包括但不限于真实性、合法性、合规性。"},{"number":"6.2","body":"如发现您发布的内容违反本条款或法律法规，平台有权采取以下一项或多项措施：\\n（a）要求您限期修改或删除违规内容；\\n（b）暂时或永久限制您发布内容的权限；\\n（c）暂时冻结或永久关闭您的账号；\\n（d）向有关主管部门报告；\\n（e）保留追究法律责任的权利。"},{"number":"6.3","body":"平台对用户内容的审核不意味着平台认可该内容的真实性或合法性。用户对其发布的内容独立承担法律责任。"}],"sortOrder":6},{"heading":"第七条 隐私保护","clauses":[{"number":"7.1","body":"平台高度重视您的隐私保护。您的个人信息将按照《隐私说明》进行收集、使用和保护。《隐私说明》是本条款不可分割的组成部分。"},{"number":"7.2","body":"未经您的明确同意，平台不会向第三方披露您的联系方式（手机号、邮箱、微信号等）。私人介绍成功后，联系方式在双方确认的情况下方可交换。"},{"number":"7.3","body":"您授权平台在以下范围内使用您的资料信息：\\n（a）在平台内展示您的个人资料（按您的隐私设置控制可见范围）；\\n（b）向平台顾问展示您的资料以便提供撮合服务；\\n（c）向您推荐匹配度较高的其他用户；\\n（d）用于平台服务的改进和优化（匿名化处理后）。"}],"sortOrder":7},{"heading":"第八条 知识产权","clauses":[{"number":"8.1","body":"平台的所有内容，包括但不限于文字、图片、图标、界面设计、软件代码、数据汇编等，均受知识产权法律保护。未经平台书面许可，任何人不得复制、修改、传播或利用。"},{"number":"8.2","body":"您在平台上发布的内容（照片、文字等），您保留所有权。您授予平台在平台范围内使用、展示、分发这些内容的非独占许可，以便为您提供服务。"},{"number":"8.3","body":"您保证您在平台上发布的内容不侵犯任何第三方的知识产权或其他合法权益。如因此给平台造成损失，您应承担赔偿责任。"}],"sortOrder":8},{"heading":"第九条 免责声明","clauses":[{"number":"9.1","body":"平台作为婚恋信息撮合平台，尽力为用户提供真实、可靠的服务，但在以下范围内不承担责任：\\n（a）平台不保证任何匹配推荐或活动必然促成恋爱关系或婚姻；\\n（b）平台不对用户自行发布的信息的准确性、完整性承担保证责任；\\n（c）用户之间的线下交往、资金往来由用户自行判断风险并承担后果。"},{"number":"9.2","body":"因不可抗力（自然灾害、战争、政策变化、网络攻击等）导致服务中断或数据丢失的，平台不承担责任，但应在合理时间内恢复服务。"},{"number":"9.3","body":"您在与其他用户交往过程中应保持理性判断，注意人身和财产安全。平台建议首次线下见面选择公共场所。"}],"sortOrder":9},{"heading":"第十条 违约责任与赔偿","clauses":[{"number":"10.1","body":"如您违反本条款，给平台或第三方造成损失的，您应承担相应的赔偿责任。"},{"number":"10.2","body":"平台的赔偿责任仅限于直接损失，且总额不超过您在过去 12 个月内向平台支付的费用总额。"},{"number":"10.3","body":"本条款的任何规定不限制或排除法律禁止限制或排除的责任。"}],"sortOrder":10},{"heading":"第十一条 条款修改","clauses":[{"number":"11.1","body":"平台有权根据需要修改本条款。修改后的条款将在平台公布，公布后继续使用平台服务即表示您接受修改后的条款。"},{"number":"11.2","body":"如您不同意修改后的条款，您应停止使用平台服务并注销账号。"},{"number":"11.3","body":"重大条款修改，平台将通过站内信或邮件方式提前 7 日通知您。"}],"sortOrder":11},{"heading":"第十二条 适用法律与争议解决","clauses":[{"number":"12.1","body":"本条款的订立、执行和解释适用中华人民共和国法律。"},{"number":"12.2","body":"因本条款引起的或与本条款有关的争议，双方应友好协商解决。协商不成的，任何一方均可向平台运营方所在地有管辖权的人民法院提起诉讼。"},{"number":"12.3","body":"本条款的部分条款无效不影响其余条款的效力。"}],"sortOrder":12}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('ad431728-0b31-56c9-81ec-e28b8e6cae38', '6f0081c5-e57a-5470-8177-93902e24302d', 'en', 'Cupid Match Platform Terms of Service', '[{"heading":"Article 1 Definitions and Acceptance","clauses":[{"number":"1.1","body":"The Cupid Match platform (the Platform) is a matchmaking and relationship-introduction service platform provided by the operator of Cupid Match (we, us, or our)."},{"number":"1.2","body":"These Terms of Service (the Terms) constitute the complete agreement between you and the Platform regarding your use of Platform services. By ticking I have read and agree during registration, you confirm that you have read, understood, and voluntarily accepted all provisions of these Terms."},{"number":"1.3","body":"The Platform may send notices to you through pop-ups, page prompts, in-app messages, and similar methods. Your continued use of Platform services means that you agree to receive such notices."}],"sortOrder":1},{"heading":"Article 2 Account Registration and Security","clauses":[{"number":"2.1","body":"Registration eligibility: You confirm that you are at least 18 years old and have full civil capacity. If you register on behalf of another person, such as your child, you must have that person’s express authorization."},{"number":"2.2","body":"Registration information: You must provide true, accurate, and complete registration information, including but not limited to your name, email address, or phone number. You must update such information promptly if it changes."},{"number":"2.3","body":"Account security: You are responsible for all activities under your account. You must keep your login credentials secure and may not lend, transfer, or authorize others to use your account. If you discover unauthorized use of your account, you must notify the Platform immediately."},{"number":"2.4","body":"Identity verification: The Platform has the right to require you to complete identity verification. If your account does not pass identity verification, the Platform may restrict your use of certain functions."}],"sortOrder":2},{"heading":"Article 3 Services","clauses":[{"number":"3.1","body":"The Platform provides the following core services:\\n(a) profile creation and display: you may create a matchmaking profile, including personal information, photos, and partner preferences;\\n(b) intelligent matching and recommendations: the Platform recommends other users with higher compatibility based on your profile and preferences;\\n(c) profile browsing and search: you may browse and filter other users’ public profiles within the Platform;\\n(d) private introduction services: Platform advisors provide targeted matchmaking introductions based on both parties’ circumstances;\\n(e) offline events: the Platform regularly organizes offline social events for which you may register;\\n(f) advisor services: Platform advisors may provide relationship consultation, profile optimization, matchmaking follow-up, and related services."},{"number":"3.2","body":"The Platform reserves the right to adjust, add, or remove services based on operational needs. Material adjustments will be announced on the Platform 7 days in advance."}],"sortOrder":3},{"heading":"Article 4 Membership and Paid Services","clauses":[{"number":"4.1","body":"The Platform provides free basic services and paid membership services. Free users may access basic functions. Paid members enjoy additional benefits, such as increased private introduction quotas, priority event registration, and dedicated advisor services."},{"number":"4.2","body":"Membership packages and prices are subject to the information published by the Platform. The Platform may adjust package content and pricing from time to time. Packages already purchased before an adjustment are not affected."},{"number":"4.3","body":"Except where required by law, paid membership fees are non-refundable."},{"number":"4.4","body":"After your membership expires, your account will return to free-user permissions. The Platform reserves the right to remind you to renew before expiration."}],"sortOrder":4},{"heading":"Article 5 User Conduct","clauses":[{"number":"5.1","body":"You undertake to comply with the following rules when using the Platform:\\n(a) comply with the laws and regulations of the People’s Republic of China and the applicable laws of your location;\\n(b) comply with public order and good morals and respect the lawful rights and interests of others;\\n(c) publish true, lawful, and accurate information and not fabricate false identity, age, marital status, occupation, or similar information;\\n(d) not use the Platform for any illegal or non-compliant activity, including but not limited to fraud, pyramid schemes, gambling, or sexual services."},{"number":"5.2","body":"Prohibited conduct includes but is not limited to:\\n(a) harassing, insulting, threatening, or stalking other users;\\n(b) collecting, storing, or disseminating other users’ personal information without permission;\\n(c) publishing commercial advertisements, spam, or content unrelated to matchmaking or dating;\\n(d) bypassing the Platform for private transactions or fund transfers;\\n(e) using technical means to interfere with normal Platform operations, such as crawlers, traffic manipulation, or injection attacks;\\n(f) using the Platform’s name without authorization or impersonating Platform staff."}],"sortOrder":5},{"heading":"Article 6 Content Review and Handling","clauses":[{"number":"6.1","body":"The Platform has the right to review materials, photos, text, and other content published by users. Review standards include but are not limited to authenticity, legality, and compliance."},{"number":"6.2","body":"If content you publish violates these Terms or applicable laws and regulations, the Platform has the right to take one or more of the following measures:\\n(a) require you to modify or delete the violating content within a specified period;\\n(b) temporarily or permanently restrict your permission to publish content;\\n(c) temporarily freeze or permanently close your account;\\n(d) report the matter to competent authorities;\\n(e) reserve the right to pursue legal liability."},{"number":"6.3","body":"The Platform’s review of user content does not mean that the Platform recognizes the authenticity or legality of such content. Users independently bear legal responsibility for the content they publish."}],"sortOrder":6},{"heading":"Article 7 Privacy Protection","clauses":[{"number":"7.1","body":"The Platform attaches great importance to protecting your privacy. Your personal information will be collected, used, and protected in accordance with the Privacy Notice. The Privacy Notice forms an integral part of these Terms."},{"number":"7.2","body":"Without your express consent, the Platform will not disclose your contact details, such as phone number, email address, or WeChat ID, to third parties. After a private introduction succeeds, contact details may be exchanged only upon confirmation by both parties."},{"number":"7.3","body":"You authorize the Platform to use your profile information within the following scope:\\n(a) display your profile within the Platform, subject to your privacy settings;\\n(b) show your profile to Platform advisors so that they may provide matchmaking services;\\n(c) recommend other users with higher compatibility to you;\\n(d) improve and optimize Platform services after anonymization."}],"sortOrder":7},{"heading":"Article 8 Intellectual Property","clauses":[{"number":"8.1","body":"All Platform content, including but not limited to text, images, icons, interface designs, software code, and data compilations, is protected by intellectual property laws. No person may copy, modify, distribute, or use such content without the Platform’s written permission."},{"number":"8.2","body":"You retain ownership of content you publish on the Platform, such as photos and text. You grant the Platform a non-exclusive license to use, display, and distribute such content within the Platform for the purpose of providing services to you."},{"number":"8.3","body":"You warrant that content you publish on the Platform does not infringe the intellectual property rights or other lawful rights and interests of any third party. If losses are caused to the Platform as a result, you shall be liable for compensation."}],"sortOrder":8},{"heading":"Article 9 Disclaimers","clauses":[{"number":"9.1","body":"As a matchmaking information and introduction platform, the Platform strives to provide authentic and reliable services, but does not assume liability within the following scope:\\n(a) the Platform does not guarantee that any matching recommendation or event will necessarily lead to a romantic relationship or marriage;\\n(b) the Platform does not guarantee the accuracy or completeness of information independently published by users;\\n(c) users must independently assess and bear the consequences of offline interactions and fund transfers between users."},{"number":"9.2","body":"The Platform is not liable for service interruption or data loss caused by force majeure, such as natural disasters, war, policy changes, or cyberattacks, but will restore services within a reasonable time."},{"number":"9.3","body":"You should maintain rational judgment when interacting with other users and pay attention to personal and property safety. The Platform recommends that first offline meetings take place in public places."}],"sortOrder":9},{"heading":"Article 10 Breach Liability and Compensation","clauses":[{"number":"10.1","body":"If you violate these Terms and cause losses to the Platform or any third party, you shall bear corresponding compensation liability."},{"number":"10.2","body":"The Platform’s compensation liability is limited to direct losses and shall not exceed the total fees you paid to the Platform during the preceding 12 months."},{"number":"10.3","body":"No provision of these Terms limits or excludes liability where such limitation or exclusion is prohibited by law."}],"sortOrder":10},{"heading":"Article 11 Modification of Terms","clauses":[{"number":"11.1","body":"The Platform has the right to modify these Terms as needed. Modified Terms will be published on the Platform. Your continued use of Platform services after publication means that you accept the modified Terms."},{"number":"11.2","body":"If you do not agree to the modified Terms, you should stop using Platform services and cancel your account."},{"number":"11.3","body":"For material modifications to these Terms, the Platform will notify you 7 days in advance by in-app message or email."}],"sortOrder":11},{"heading":"Article 12 Governing Law and Dispute Resolution","clauses":[{"number":"12.1","body":"The formation, performance, and interpretation of these Terms are governed by the laws of the People’s Republic of China."},{"number":"12.2","body":"Any dispute arising out of or relating to these Terms shall first be resolved through friendly consultation. If consultation fails, either party may bring a lawsuit before a competent people’s court at the place where the Platform operator is located."},{"number":"12.3","body":"The invalidity of any part of these Terms does not affect the validity of the remaining provisions."}],"sortOrder":12}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('574278a3-7d42-5f40-acd8-54af85f6f421', '6f0081c5-e57a-5470-8177-93902e24302d', 'fr', 'Conditions d utilisation de la plateforme Cupid Match', '[{"heading":"Article 1 Definitions et acceptation","clauses":[{"number":"1.1","body":"La plateforme Cupid Match (la Plateforme) est une plateforme de mise en relation matrimoniale et de services d introduction fournie par l operateur de Cupid Match (nous, notre ou nos)."},{"number":"1.2","body":"Les presentes conditions d utilisation (les Conditions) constituent l accord complet entre vous et la Plateforme concernant l utilisation des services de la Plateforme. En cochant J ai lu et j accepte lors de l inscription, vous confirmez avoir lu integralement, compris pleinement et accepte volontairement toutes les dispositions des presentes Conditions."},{"number":"1.3","body":"La Plateforme peut vous envoyer des notifications par fenetre contextuelle, message sur page, message interne ou moyen similaire. La poursuite de l utilisation des services de la Plateforme vaut acceptation de recevoir ces notifications."}],"sortOrder":1},{"heading":"Article 2 Inscription et securite du compte","clauses":[{"number":"2.1","body":"Eligibilite a l inscription : vous confirmez avoir au moins 18 ans et disposer de la pleine capacite civile. Si vous vous inscrivez pour le compte d une autre personne, par exemple votre enfant, vous devez obtenir son autorisation expresse."},{"number":"2.2","body":"Informations d inscription : vous devez fournir des informations d inscription veridiques, exactes et completes, y compris notamment votre nom, votre adresse email ou votre numero de telephone. Vous devez les mettre a jour rapidement en cas de changement."},{"number":"2.3","body":"Securite du compte : vous etes responsable de toutes les activites effectuees avec votre compte. Vous devez proteger vos identifiants de connexion et ne pouvez pas preter, transferer ou autoriser un tiers a utiliser votre compte. En cas d utilisation non autorisee, vous devez avertir immediatement la Plateforme."},{"number":"2.4","body":"Verification d identite : la Plateforme peut vous demander de completer une verification d identite. Si le compte ne reussit pas cette verification, la Plateforme peut limiter l acces a certaines fonctions."}],"sortOrder":2},{"heading":"Article 3 Contenu des services","clauses":[{"number":"3.1","body":"La Plateforme fournit les services principaux suivants :\\n(a) creation et affichage du profil : vous pouvez creer un profil de rencontre comprenant des informations personnelles, des photos et des preferences de partenaire ;\\n(b) mise en relation intelligente et recommandations : la Plateforme recommande d autres utilisateurs ayant une compatibilite elevee selon votre profil et vos preferences ;\\n(c) consultation et recherche de profils : vous pouvez consulter et filtrer les profils publics d autres utilisateurs dans le cadre de la Plateforme ;\\n(d) service d introduction privee : les conseillers de la Plateforme fournissent des introductions ciblees selon la situation des deux parties ;\\n(e) evenements hors ligne : la Plateforme organise regulierement des evenements de rencontre auxquels vous pouvez vous inscrire ;\\n(f) service de conseil : les conseillers peuvent fournir consultation, optimisation de profil, suivi de mise en relation et services connexes."},{"number":"3.2","body":"La Plateforme se reserve le droit d ajuster, d ajouter ou de supprimer des services selon ses besoins operationnels. Les ajustements importants seront annonces sur la Plateforme 7 jours a l avance."}],"sortOrder":3},{"heading":"Article 4 Abonnement et services payants","clauses":[{"number":"4.1","body":"La Plateforme propose des services de base gratuits et des services d abonnement payants. Les utilisateurs gratuits peuvent acceder aux fonctions de base. Les membres payants beneficient de droits supplementaires, tels que quotas d introduction privee augmentes, priorite d inscription aux evenements et service de conseiller dedie."},{"number":"4.2","body":"Les formules et prix d abonnement sont ceux publies par la Plateforme. La Plateforme peut ajuster le contenu et le prix des formules. Les formules deja achetees avant l ajustement ne sont pas affectees."},{"number":"4.3","body":"Sauf disposition legale contraire, les frais d abonnement deja payes ne sont pas remboursables."},{"number":"4.4","body":"A l expiration de votre abonnement, votre compte revient aux autorisations d utilisateur gratuit. La Plateforme se reserve le droit de vous rappeler le renouvellement avant expiration."}],"sortOrder":4},{"heading":"Article 5 Regles de conduite des utilisateurs","clauses":[{"number":"5.1","body":"Vous vous engagez a respecter les regles suivantes lors de l utilisation de la Plateforme :\\n(a) respecter les lois et reglements de la Republique populaire de Chine et les lois applicables de votre lieu de residence ;\\n(b) respecter l ordre public, les bonnes moeurs et les droits legitimes d autrui ;\\n(c) publier des informations veridiques, legales et exactes, sans fabriquer de fausse identite, age, situation matrimoniale, profession ou information similaire ;\\n(d) ne pas utiliser la Plateforme pour des activites illegales ou non conformes, y compris notamment fraude, systeme pyramidal, jeux d argent ou services sexuels."},{"number":"5.2","body":"Les comportements interdits comprennent notamment :\\n(a) harceler, insulter, menacer ou suivre d autres utilisateurs ;\\n(b) collecter, stocker ou diffuser les informations personnelles d autres utilisateurs sans autorisation ;\\n(c) publier de la publicite commerciale, du spam ou du contenu sans lien avec les rencontres ;\\n(d) contourner la Plateforme pour realiser des transactions privees ou des transferts d argent ;\\n(e) utiliser des moyens techniques pour perturber le fonctionnement normal de la Plateforme, tels que robots d exploration, manipulation de trafic ou attaques par injection ;\\n(f) utiliser le nom de la Plateforme sans autorisation ou se faire passer pour un membre du personnel de la Plateforme."}],"sortOrder":5},{"heading":"Article 6 Verification et traitement du contenu","clauses":[{"number":"6.1","body":"La Plateforme a le droit de verifier les informations, photos, textes et autres contenus publies par les utilisateurs. Les criteres de verification comprennent notamment authenticite, legalite et conformite."},{"number":"6.2","body":"Si un contenu que vous publiez viole les presentes Conditions ou les lois et reglements applicables, la Plateforme peut prendre une ou plusieurs des mesures suivantes :\\n(a) vous demander de modifier ou supprimer le contenu non conforme dans un delai determine ;\\n(b) limiter temporairement ou definitivement votre droit de publier du contenu ;\\n(c) suspendre temporairement ou fermer definitivement votre compte ;\\n(d) signaler la situation aux autorites competentes ;\\n(e) se reserver le droit d engager votre responsabilite juridique."},{"number":"6.3","body":"La verification du contenu par la Plateforme ne signifie pas que la Plateforme reconnait son authenticite ou sa legalite. Les utilisateurs assument seuls la responsabilite juridique du contenu qu ils publient."}],"sortOrder":6},{"heading":"Article 7 Protection de la vie privee","clauses":[{"number":"7.1","body":"La Plateforme attache une grande importance a la protection de votre vie privee. Vos informations personnelles sont collectees, utilisees et protegees conformement a la Politique de confidentialite. La Politique de confidentialite fait partie integrante des presentes Conditions."},{"number":"7.2","body":"Sans votre consentement explicite, la Plateforme ne divulguera pas vos coordonnees, telles que telephone, email ou identifiant WeChat, a des tiers. Apres une introduction privee reussie, les coordonnees ne peuvent etre echangees qu avec confirmation des deux parties."},{"number":"7.3","body":"Vous autorisez la Plateforme a utiliser vos informations de profil dans les limites suivantes :\\n(a) afficher votre profil sur la Plateforme selon vos parametres de confidentialite ;\\n(b) montrer votre profil aux conseillers de la Plateforme afin de fournir le service de mise en relation ;\\n(c) vous recommander d autres utilisateurs avec une compatibilite elevee ;\\n(d) ameliorer et optimiser les services de la Plateforme apres anonymisation."}],"sortOrder":7},{"heading":"Article 8 Propriete intellectuelle","clauses":[{"number":"8.1","body":"Tous les contenus de la Plateforme, y compris notamment textes, images, icones, conception d interface, code logiciel et compilations de donnees, sont proteges par les lois relatives a la propriete intellectuelle. Nul ne peut copier, modifier, diffuser ou utiliser ces contenus sans autorisation ecrite de la Plateforme."},{"number":"8.2","body":"Vous conservez la propriete des contenus que vous publiez sur la Plateforme, tels que photos et textes. Vous accordez a la Plateforme une licence non exclusive pour utiliser, afficher et distribuer ces contenus dans le cadre de la Plateforme afin de vous fournir les services."},{"number":"8.3","body":"Vous garantissez que les contenus que vous publiez sur la Plateforme ne portent pas atteinte aux droits de propriete intellectuelle ou autres droits legitimes de tiers. Si la Plateforme subit un prejudice de ce fait, vous devrez l indemniser."}],"sortOrder":8},{"heading":"Article 9 Exclusions de responsabilite","clauses":[{"number":"9.1","body":"En tant que plateforme d information et de mise en relation matrimoniale, la Plateforme s efforce de fournir des services authentiques et fiables, mais n assume pas de responsabilite dans les cas suivants :\\n(a) la Plateforme ne garantit pas qu une recommandation ou un evenement aboutira necessairement a une relation amoureuse ou a un mariage ;\\n(b) la Plateforme ne garantit pas l exactitude ou l exhaustivite des informations publiees directement par les utilisateurs ;\\n(c) les interactions hors ligne et transferts d argent entre utilisateurs relevent de leur propre evaluation des risques et de leur propre responsabilite."},{"number":"9.2","body":"La Plateforme n est pas responsable des interruptions de service ou pertes de donnees causees par un cas de force majeure, tel que catastrophe naturelle, guerre, changement de politique ou cyberattaque, mais elle retablira les services dans un delai raisonnable."},{"number":"9.3","body":"Vous devez faire preuve de discernement lors de vos interactions avec d autres utilisateurs et veiller a votre securite personnelle et patrimoniale. La Plateforme recommande que la premiere rencontre hors ligne ait lieu dans un endroit public."}],"sortOrder":9},{"heading":"Article 10 Responsabilite pour violation et indemnisation","clauses":[{"number":"10.1","body":"Si vous violez les presentes Conditions et causez un prejudice a la Plateforme ou a un tiers, vous devez assumer la responsabilite d indemnisation correspondante."},{"number":"10.2","body":"La responsabilite d indemnisation de la Plateforme est limitee aux pertes directes et ne peut depasser le montant total des frais que vous avez payes a la Plateforme au cours des 12 derniers mois."},{"number":"10.3","body":"Aucune disposition des presentes Conditions ne limite ou exclut une responsabilite lorsque la loi interdit une telle limitation ou exclusion."}],"sortOrder":10},{"heading":"Article 11 Modification des Conditions","clauses":[{"number":"11.1","body":"La Plateforme peut modifier les presentes Conditions si necessaire. Les Conditions modifiees seront publiees sur la Plateforme. La poursuite de l utilisation des services apres publication vaut acceptation des Conditions modifiees."},{"number":"11.2","body":"Si vous n acceptez pas les Conditions modifiees, vous devez cesser d utiliser les services de la Plateforme et supprimer votre compte."},{"number":"11.3","body":"En cas de modification importante des Conditions, la Plateforme vous en informera 7 jours a l avance par message interne ou email."}],"sortOrder":11},{"heading":"Article 12 Loi applicable et reglement des litiges","clauses":[{"number":"12.1","body":"La formation, l execution et l interpretation des presentes Conditions sont regies par les lois de la Republique populaire de Chine."},{"number":"12.2","body":"Tout litige decoulant des presentes Conditions ou s y rapportant doit d abord etre resolu par consultation amiable. A defaut d accord, chaque partie peut saisir le tribunal populaire competent du lieu ou se trouve l operateur de la Plateforme."},{"number":"12.3","body":"L invalidite d une partie des presentes Conditions n affecte pas la validite des autres dispositions."}],"sortOrder":12}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('e6527e8a-6c1f-5bea-aa8b-3cf678fbdd1e', '85a634d2-f126-5d90-be6d-d550f2b920fc', 'zh', 'Cupid Match 隐私说明', '[{"heading":"第一条 我们收集的信息","clauses":[{"number":"1.1","body":"账号信息：注册时收集的姓名、手机号或邮箱、登录密码（加密存储）。"},{"number":"1.2","body":"个人资料信息：您主动填写的婚恋资料，包括但不限于性别、出生年份、身高、所在城市、学历、行业、职业方向、婚姻状态、子女情况、交友意向、择偶偏好、生活习惯、个性特征、个人简介、标签等。"},{"number":"1.3","body":"照片与媒体：您上传的个人照片。平台可能对照片进行审核以确保符合平台规范。"},{"number":"1.4","body":"认证信息：实名认证、学历认证、婚姻状态认证时提交的身份证件、学历证明、法律文件等。"},{"number":"1.5","body":"联系方式：您的手机号、邮箱、微信号。联系方式仅用于账号安全和私人介绍成功后的双方交换，不会公开在您的资料页。"},{"number":"1.6","body":"行为数据：您在平台上的浏览记录、收藏记录、活动报名记录、私人介绍申请记录、顾问沟通记录等。"},{"number":"1.7","body":"设备信息：您访问平台时使用的设备类型、操作系统、IP 地址、浏览器类型等。"},{"number":"1.8","body":"支付信息：您购买会员时的支付凭证。平台不直接存储您的银行卡号或支付密码，支付由第三方支付服务商处理。"}],"sortOrder":1},{"heading":"第二条 信息使用方式","clauses":[{"number":"2.1","body":"平台使用您的信息用于以下目的：\\n（a）创建和管理您的账号；\\n（b）提供婚恋匹配推荐服务；\\n（c）优化推荐算法和用户体验；\\n（d）组织和协调线下活动；\\n（e）提供顾问撮合和跟进服务；\\n（f）处理您的支付和会员事务；\\n（g）保障平台安全，防范欺诈和滥用；\\n（h）遵守法律法规要求。"},{"number":"2.2","body":"平台不会使用您的个人信息进行自动化决策，导致对您产生法律效力或类似重大影响。"},{"number":"2.3","body":"平台可能对收集的信息进行匿名化或去标识化处理后，用于统计分析、服务改进和商业规划。此类处理后信息不再属于个人信息。"}],"sortOrder":2},{"heading":"第三条 信息存储与跨境传输","clauses":[{"number":"3.1","body":"您的个人信息存储在中华人民共和国境内的服务器上。"},{"number":"3.2","body":"如因服务需要将信息传输至境外，平台将按照法律法规要求进行安全评估，并取得您的单独同意。"},{"number":"3.3","body":"平台仅在实现服务目的所需的最短期限内保留您的个人信息。账号注销后，平台将在 30 日内删除或匿名化您的个人信息，法律另有规定的除外。"}],"sortOrder":3},{"heading":"第四条 信息安全保护","clauses":[{"number":"4.1","body":"平台采用行业标准的安全技术和组织措施保护您的个人信息，包括但不限于：\\n（a）数据传输采用 HTTPS/TLS 加密；\\n（b）密码采用单向哈希加盐存储；\\n（c）敏感个人信息加密存储；\\n（d）访问权限最小化原则，仅授权人员可访问必要的个人信息；\\n（e）定期安全审计和漏洞扫描。"},{"number":"4.2","body":"若发生个人信息安全事件，平台将按照法律法规要求及时告知您，并向主管部门报告。"},{"number":"4.3","body":"您应妥善保管登录凭证，避免在公共设备上保存登录状态，定期更换密码。"}],"sortOrder":4},{"heading":"第五条 信息共享与披露","clauses":[{"number":"5.1","body":"未经您明确同意，平台不会向第三方共享您的个人信息，以下情形除外：\\n（a）在您主动发起私人介绍且对方接受后，按双方确认范围交换联系方式；\\n（b）为完成支付，与第三方支付服务商共享必要的支付信息；\\n（c）法律法规要求或行政、司法机关依法提出请求；\\n（d）为保护平台、用户或公众的合法权益免受损害。"},{"number":"5.2","body":"平台与第三方服务商合作时，将通过合同要求其遵守不低于本政策标准的数据保护义务。"},{"number":"5.3","body":"除上述情形外，平台不会向任何第三方出售、出租或以其他方式提供您的个人信息。"}],"sortOrder":5},{"heading":"第六条 您的权利","clauses":[{"number":"6.1","body":"查阅权：您可以在账户设置中随时查看您提供的个人信息。"},{"number":"6.2","body":"更正权：如您的个人信息发生变化或有误，您可以在账户设置中自行修改。部分认证信息修改需经平台审核。"},{"number":"6.3","body":"删除权：您可以在账户设置中删除您的部分信息。您也可以申请注销账号，账号注销后所有个人信息将被删除或匿名化。"},{"number":"6.4","body":"导出权：您可以申请导出您在平台上的个人数据副本，平台将在 15 个工作日内处理。"},{"number":"6.5","body":"撤回同意权：您可以通过修改隐私设置撤回对特定信息使用的同意。撤回同意不影响此前基于同意的信息处理的合法性。"},{"number":"6.6","body":"投诉权：如您认为平台处理您个人信息的行为侵犯了您的合法权益，您可以向平台投诉或向监管部门举报。"}],"sortOrder":6},{"heading":"第七条 Cookie 与同类技术","clauses":[{"number":"7.1","body":"平台使用 Cookie 和类似技术来识别您的登录状态、记住您的偏好设置、分析平台使用情况。"},{"number":"7.2","body":"您可以通过浏览器设置管理或删除 Cookie。但禁用 Cookie 可能导致部分功能无法使用。"},{"number":"7.3","body":"平台可能使用第三方分析服务（如百度统计）来了解用户使用情况，这些服务可能使用自己的 Cookie。"}],"sortOrder":7},{"heading":"第八条 未成年人保护","clauses":[{"number":"8.1","body":"平台仅向年满 18 周岁的用户提供服务。"},{"number":"8.2","body":"平台不会故意收集未满 18 周岁的未成年人的个人信息。如发现误收集，将立即删除。"},{"number":"8.3","body":"如果您是父母或监护人，且发现您的未成年子女向平台提供了个人信息，请立即联系我们。"}],"sortOrder":8},{"heading":"第九条 政策更新","clauses":[{"number":"9.1","body":"平台可能根据法律法规变化或服务调整更新本隐私政策。"},{"number":"9.2","body":"更新后的政策将在平台公布。重大变更将通过站内信或邮件通知您。"},{"number":"9.3","body":"您继续使用平台服务即表示您同意更新后的隐私政策。如您不同意，应停止使用并注销账号。"}],"sortOrder":9},{"heading":"第十条 联系我们","clauses":[{"number":"10.1","body":"如您对本隐私政策有任何疑问、意见或投诉，请通过以下方式联系我们：\\n\\n邮箱：privacy@rencontreaparis.com\\n微信：RencontreParis\\n城市：Paris / France"},{"number":"10.2","body":"我们将在收到您的请求后 15 个工作日内回复。"}],"sortOrder":10}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('5390e1d4-1b72-5b90-b87e-2f582c9c216a', '85a634d2-f126-5d90-be6d-d550f2b920fc', 'en', 'Cupid Match Privacy Notice', '[{"heading":"Article 1 Information We Collect","clauses":[{"number":"1.1","body":"Account information: name, phone number or email address, and login password collected during registration. Passwords are stored in encrypted form."},{"number":"1.2","body":"Profile information: matchmaking profile information you voluntarily provide, including but not limited to gender, year of birth, height, city, education, industry, career direction, marital status, children-related information, relationship intention, partner preferences, lifestyle, personality traits, personal introduction, and tags."},{"number":"1.3","body":"Photos and media: personal photos uploaded by you. The Platform may review photos to ensure compliance with Platform rules."},{"number":"1.4","body":"Verification information: identity documents, education certificates, legal documents, and other materials submitted for identity, education, or marital status verification."},{"number":"1.5","body":"Contact details: your phone number, email address, and WeChat ID. Contact details are used only for account security and exchange after a successful private introduction, and will not be publicly displayed on your profile page."},{"number":"1.6","body":"Behavior data: browsing records, favorites, event registration records, private introduction request records, advisor communication records, and similar Platform activity data."},{"number":"1.7","body":"Device information: device type, operating system, IP address, browser type, and similar information when you access the Platform."},{"number":"1.8","body":"Payment information: payment proof generated when you purchase membership. The Platform does not directly store your bank card number or payment password. Payments are processed by third-party payment service providers."}],"sortOrder":1},{"heading":"Article 2 How We Use Information","clauses":[{"number":"2.1","body":"The Platform uses your information for the following purposes:\\n(a) creating and managing your account;\\n(b) providing matchmaking recommendations;\\n(c) optimizing recommendation algorithms and user experience;\\n(d) organizing and coordinating offline events;\\n(e) providing advisor matchmaking and follow-up services;\\n(f) handling payment and membership matters;\\n(g) protecting Platform security and preventing fraud and abuse;\\n(h) complying with laws and regulations."},{"number":"2.2","body":"The Platform will not use your personal information for automated decision-making that produces legal effects or similarly significant impacts on you."},{"number":"2.3","body":"The Platform may anonymize or de-identify collected information and use it for statistical analysis, service improvement, and business planning. Information processed in this way no longer constitutes personal information."}],"sortOrder":2},{"heading":"Article 3 Information Storage and Cross-Border Transfer","clauses":[{"number":"3.1","body":"Your personal information is stored on servers located within the territory of the People’s Republic of China."},{"number":"3.2","body":"If service needs require information to be transferred overseas, the Platform will conduct security assessments and obtain your separate consent in accordance with applicable laws and regulations."},{"number":"3.3","body":"The Platform retains your personal information only for the minimum period necessary to achieve the service purposes. After account cancellation, the Platform will delete or anonymize your personal information within 30 days, unless otherwise required by law."}],"sortOrder":3},{"heading":"Article 4 Information Security","clauses":[{"number":"4.1","body":"The Platform adopts industry-standard technical and organizational security measures to protect your personal information, including but not limited to:\\n(a) HTTPS/TLS encryption for data transmission;\\n(b) one-way salted hashing for password storage;\\n(c) encrypted storage of sensitive personal information;\\n(d) least-privilege access control, with only authorized personnel able to access necessary personal information;\\n(e) regular security audits and vulnerability scans."},{"number":"4.2","body":"If a personal information security incident occurs, the Platform will notify you and report to competent authorities in accordance with laws and regulations."},{"number":"4.3","body":"You should keep your login credentials secure, avoid saving login status on public devices, and change your password regularly."}],"sortOrder":4},{"heading":"Article 5 Information Sharing and Disclosure","clauses":[{"number":"5.1","body":"Without your express consent, the Platform will not share your personal information with third parties, except in the following circumstances:\\n(a) after you initiate a private introduction and the other party accepts, contact details are exchanged within the scope confirmed by both parties;\\n(b) necessary payment information is shared with third-party payment service providers to complete payment;\\n(c) laws and regulations require disclosure, or administrative or judicial authorities make lawful requests;\\n(d) disclosure is necessary to protect the lawful rights and interests of the Platform, users, or the public from harm."},{"number":"5.2","body":"When the Platform cooperates with third-party service providers, it will require them by contract to comply with data protection obligations no less protective than this policy."},{"number":"5.3","body":"Except for the circumstances above, the Platform will not sell, rent, or otherwise provide your personal information to any third party."}],"sortOrder":5},{"heading":"Article 6 Your Rights","clauses":[{"number":"6.1","body":"Right of access: You may view the personal information you provided at any time in account settings."},{"number":"6.2","body":"Right of correction: If your personal information changes or is inaccurate, you may modify it in account settings. Changes to certain verification information require Platform review."},{"number":"6.3","body":"Right of deletion: You may delete part of your information in account settings. You may also apply to cancel your account. After account cancellation, all personal information will be deleted or anonymized."},{"number":"6.4","body":"Right of export: You may request a copy of your personal data on the Platform. The Platform will process the request within 15 working days."},{"number":"6.5","body":"Right to withdraw consent: You may withdraw consent for specific information use by modifying privacy settings. Withdrawal of consent does not affect the lawfulness of information processing conducted before withdrawal."},{"number":"6.6","body":"Right to complain: If you believe the Platform’s handling of your personal information infringes your lawful rights and interests, you may file a complaint with the Platform or report to regulatory authorities."}],"sortOrder":6},{"heading":"Article 7 Cookies and Similar Technologies","clauses":[{"number":"7.1","body":"The Platform uses cookies and similar technologies to identify your login status, remember your preferences, and analyze Platform usage."},{"number":"7.2","body":"You may manage or delete cookies through browser settings. However, disabling cookies may cause some functions to become unavailable."},{"number":"7.3","body":"The Platform may use third-party analytics services, such as Baidu Analytics, to understand user usage. These services may use their own cookies."}],"sortOrder":7},{"heading":"Article 8 Protection of Minors","clauses":[{"number":"8.1","body":"The Platform provides services only to users who are at least 18 years old."},{"number":"8.2","body":"The Platform does not knowingly collect personal information from minors under 18. If such information is discovered to have been collected by mistake, it will be deleted immediately."},{"number":"8.3","body":"If you are a parent or guardian and discover that your minor child has provided personal information to the Platform, please contact us immediately."}],"sortOrder":8},{"heading":"Article 9 Policy Updates","clauses":[{"number":"9.1","body":"The Platform may update this Privacy Policy according to changes in laws and regulations or service adjustments."},{"number":"9.2","body":"The updated policy will be published on the Platform. Material changes will be notified to you by in-app message or email."},{"number":"9.3","body":"Your continued use of Platform services means that you agree to the updated Privacy Policy. If you do not agree, you should stop using the services and cancel your account."}],"sortOrder":9},{"heading":"Article 10 Contact Us","clauses":[{"number":"10.1","body":"If you have any questions, comments, or complaints about this Privacy Policy, please contact us through the following methods:\\n\\nEmail: privacy@rencontreaparis.com\\nWeChat: RencontreParis\\nCity: Paris / France"},{"number":"10.2","body":"We will respond within 15 working days after receiving your request."}],"sortOrder":10}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('ae2ecb72-bbcd-5218-b156-62c646a2e380', '85a634d2-f126-5d90-be6d-d550f2b920fc', 'fr', 'Politique de confidentialite Cupid Match', '[{"heading":"Article 1 Informations que nous collectons","clauses":[{"number":"1.1","body":"Informations de compte : nom, numero de telephone ou adresse email, et mot de passe de connexion collectes lors de l inscription. Les mots de passe sont stockes sous forme chiffree."},{"number":"1.2","body":"Informations de profil : donnees de rencontre que vous fournissez volontairement, y compris notamment sexe, annee de naissance, taille, ville, education, secteur, orientation professionnelle, situation matrimoniale, informations relatives aux enfants, intention relationnelle, preferences de partenaire, mode de vie, traits de personnalite, presentation personnelle et etiquettes."},{"number":"1.3","body":"Photos et medias : photos personnelles que vous televersez. La Plateforme peut verifier les photos afin de garantir leur conformite aux regles de la Plateforme."},{"number":"1.4","body":"Informations de verification : documents d identite, justificatifs de diplome, documents juridiques et autres elements soumis lors de la verification d identite, d education ou de situation matrimoniale."},{"number":"1.5","body":"Coordonnees : votre numero de telephone, adresse email et identifiant WeChat. Les coordonnees servent uniquement a la securite du compte et a l echange apres une introduction privee reussie. Elles ne sont pas affichees publiquement sur votre page de profil."},{"number":"1.6","body":"Donnees comportementales : historiques de consultation, favoris, inscriptions aux evenements, demandes d introduction privee, communications avec les conseillers et donnees similaires d activite sur la Plateforme."},{"number":"1.7","body":"Informations sur l appareil : type d appareil, systeme d exploitation, adresse IP, type de navigateur et informations similaires lorsque vous accedez a la Plateforme."},{"number":"1.8","body":"Informations de paiement : justificatifs de paiement generes lors de l achat d un abonnement. La Plateforme ne stocke pas directement votre numero de carte bancaire ni votre mot de passe de paiement. Les paiements sont traites par des prestataires tiers de paiement."}],"sortOrder":1},{"heading":"Article 2 Utilisation des informations","clauses":[{"number":"2.1","body":"La Plateforme utilise vos informations aux fins suivantes :\\n(a) creer et gerer votre compte ;\\n(b) fournir des recommandations de mise en relation ;\\n(c) optimiser les algorithmes de recommandation et l experience utilisateur ;\\n(d) organiser et coordonner les evenements hors ligne ;\\n(e) fournir des services de conseil, de mise en relation et de suivi ;\\n(f) traiter les paiements et les questions d abonnement ;\\n(g) proteger la securite de la Plateforme et prevenir la fraude et les abus ;\\n(h) respecter les lois et reglements applicables."},{"number":"2.2","body":"La Plateforme n utilisera pas vos informations personnelles pour prendre des decisions automatisees produisant des effets juridiques ou des effets similaires significatifs a votre egard."},{"number":"2.3","body":"La Plateforme peut anonymiser ou de-identifier les informations collectees et les utiliser pour des analyses statistiques, l amelioration des services et la planification commerciale. Les informations ainsi traitees ne constituent plus des informations personnelles."}],"sortOrder":2},{"heading":"Article 3 Stockage et transfert transfrontalier","clauses":[{"number":"3.1","body":"Vos informations personnelles sont stockees sur des serveurs situes sur le territoire de la Republique populaire de Chine."},{"number":"3.2","body":"Si les besoins du service exigent un transfert d informations a l etranger, la Plateforme procedera aux evaluations de securite requises par les lois et reglements et obtiendra votre consentement separe."},{"number":"3.3","body":"La Plateforme conserve vos informations personnelles uniquement pendant la duree minimale necessaire a la realisation des finalites du service. Apres suppression du compte, la Plateforme supprimera ou anonymisera vos informations personnelles dans un delai de 30 jours, sauf disposition legale contraire."}],"sortOrder":3},{"heading":"Article 4 Securite des informations","clauses":[{"number":"4.1","body":"La Plateforme adopte des mesures techniques et organisationnelles conformes aux standards du secteur pour proteger vos informations personnelles, y compris notamment :\\n(a) chiffrement HTTPS/TLS pour la transmission des donnees ;\\n(b) stockage des mots de passe par hachage sale a sens unique ;\\n(c) stockage chiffre des informations personnelles sensibles ;\\n(d) controle d acces selon le principe du moindre privilege, seuls les personnels autorises pouvant acceder aux informations necessaires ;\\n(e) audits de securite et analyses de vulnerabilite reguliers."},{"number":"4.2","body":"En cas d incident de securite concernant des informations personnelles, la Plateforme vous informera et le signalera aux autorites competentes conformement aux lois et reglements."},{"number":"4.3","body":"Vous devez proteger vos identifiants de connexion, eviter de conserver une session ouverte sur un appareil public et changer regulierement votre mot de passe."}],"sortOrder":4},{"heading":"Article 5 Partage et divulgation des informations","clauses":[{"number":"5.1","body":"Sans votre consentement explicite, la Plateforme ne partagera pas vos informations personnelles avec des tiers, sauf dans les cas suivants :\\n(a) apres votre demande d introduction privee et l acceptation par l autre partie, les coordonnees sont echangees dans la limite confirmee par les deux parties ;\\n(b) les informations de paiement necessaires sont partagees avec un prestataire tiers de paiement pour finaliser le paiement ;\\n(c) la loi ou la reglementation l exige, ou une autorite administrative ou judiciaire en fait la demande legalement ;\\n(d) le partage est necessaire pour proteger les droits et interets legitimes de la Plateforme, des utilisateurs ou du public contre un dommage."},{"number":"5.2","body":"Lorsque la Plateforme coopere avec des prestataires tiers, elle leur impose contractuellement des obligations de protection des donnees au moins equivalentes a celles de la presente politique."},{"number":"5.3","body":"Sauf dans les situations ci-dessus, la Plateforme ne vendra, louera ni fournira autrement vos informations personnelles a aucun tiers."}],"sortOrder":5},{"heading":"Article 6 Vos droits","clauses":[{"number":"6.1","body":"Droit d acces : vous pouvez consulter a tout moment les informations personnelles que vous avez fournies dans les parametres du compte."},{"number":"6.2","body":"Droit de rectification : si vos informations personnelles changent ou sont inexactes, vous pouvez les modifier dans les parametres du compte. Certaines informations de verification doivent etre examinees par la Plateforme."},{"number":"6.3","body":"Droit de suppression : vous pouvez supprimer une partie de vos informations dans les parametres du compte. Vous pouvez egalement demander la suppression de votre compte. Apres suppression du compte, toutes les informations personnelles seront supprimees ou anonymisees."},{"number":"6.4","body":"Droit d exportation : vous pouvez demander une copie de vos donnees personnelles sur la Plateforme. La Plateforme traitera la demande dans un delai de 15 jours ouvrables."},{"number":"6.5","body":"Droit de retrait du consentement : vous pouvez retirer votre consentement a certaines utilisations des informations en modifiant vos parametres de confidentialite. Le retrait du consentement n affecte pas la legalite des traitements effectues avant le retrait."},{"number":"6.6","body":"Droit de plainte : si vous estimez que le traitement de vos informations personnelles par la Plateforme porte atteinte a vos droits et interets legitimes, vous pouvez deposer une plainte aupres de la Plateforme ou signaler le fait aux autorites de controle."}],"sortOrder":6},{"heading":"Article 7 Cookies et technologies similaires","clauses":[{"number":"7.1","body":"La Plateforme utilise des cookies et technologies similaires pour identifier votre etat de connexion, memoriser vos preferences et analyser l utilisation de la Plateforme."},{"number":"7.2","body":"Vous pouvez gerer ou supprimer les cookies via les parametres du navigateur. Toutefois, la desactivation des cookies peut rendre certaines fonctions indisponibles."},{"number":"7.3","body":"La Plateforme peut utiliser des services d analyse tiers, tels que Baidu Analytics, pour comprendre l utilisation par les utilisateurs. Ces services peuvent utiliser leurs propres cookies."}],"sortOrder":7},{"heading":"Article 8 Protection des mineurs","clauses":[{"number":"8.1","body":"La Plateforme fournit ses services uniquement aux utilisateurs ages d au moins 18 ans."},{"number":"8.2","body":"La Plateforme ne collecte pas sciemment les informations personnelles de mineurs de moins de 18 ans. Si une telle collecte par erreur est constatee, les informations seront supprimees immediatement."},{"number":"8.3","body":"Si vous etes parent ou tuteur et constatez que votre enfant mineur a fourni des informations personnelles a la Plateforme, veuillez nous contacter immediatement."}],"sortOrder":8},{"heading":"Article 9 Mise a jour de la politique","clauses":[{"number":"9.1","body":"La Plateforme peut mettre a jour la presente Politique de confidentialite selon les changements de lois et reglements ou les ajustements de service."},{"number":"9.2","body":"La politique mise a jour sera publiee sur la Plateforme. Les changements importants vous seront notifies par message interne ou email."},{"number":"9.3","body":"La poursuite de l utilisation des services de la Plateforme vaut acceptation de la Politique de confidentialite mise a jour. Si vous n acceptez pas, vous devez cesser d utiliser les services et supprimer votre compte."}],"sortOrder":9},{"heading":"Article 10 Nous contacter","clauses":[{"number":"10.1","body":"Pour toute question, suggestion ou plainte concernant la presente Politique de confidentialite, vous pouvez nous contacter par les moyens suivants :\\n\\nEmail : privacy@rencontreaparis.com\\nWeChat : RencontreParis\\nVille : Paris / France"},{"number":"10.2","body":"Nous repondrons dans un delai de 15 jours ouvrables apres reception de votre demande."}],"sortOrder":10}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00');

-- Membership plan definitions.
-- 3A.16 cm_membership_plans
insert into cm_membership_plans (id, tier, price_cents, currency, cny_price_cents, billing_type, billing_period, validity_months, private_introduction_quota, private_introduction_period, event_quota, event_priority_enabled, staff_review_enabled, profile_detail_access_level, staff_support_level, concierge_priority, featured, sort_order, is_active, created_at, updated_at) values
  ('f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'free', 0, 'EUR', 0, 'free', null, null, 0, 'monthly', 0, 0, 0, 'registered', 'none', 0, 0, 1, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'silver', 6500, 'EUR', 49900, 'recurring', 'monthly', null, 5, 'monthly', 12, 0, 1, 'registered', 'standard', 0, 0, 2, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'gold', 10000, 'EUR', 77000, 'recurring', 'monthly', null, 15, 'monthly', 20, 1, 1, 'premium', 'priority', 1, 1, 3, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('9fb53b84-a341-5b63-b6e8-35a474540a4c', 'diamond', 15000, 'EUR', 115500, 'recurring', 'monthly', null, 30, 'monthly', 24, 1, 1, 'premium', 'concierge', 1, 0, 4, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00');

-- Stripe test Price 映射；生产环境上线前应替换为 live 环境的真实 prod_xxx / price_xxx。
insert into cm_membership_plan_payment_prices (id, plan_id, provider, environment, mode, provider_product_id, provider_price_id, currency, billing_period, status, created_at, updated_at) values
  ('fa100000-0000-4000-8000-000000000001', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'stripe', 'test', 'subscription', 'prod_UqeA8CRJHdNEQr', 'price_1TqwsPCsC9pa7rgAJEpWaov1', 'EUR', 'monthly', 'active', now(), now()),
  ('fa100000-0000-4000-8000-000000000002', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'stripe', 'test', 'subscription', 'prod_UqeB6YvxmN1eoK', 'price_1Tqwt1CsC9pa7rgAoWnyLWo2', 'EUR', 'monthly', 'active', now(), now()),
  ('fa100000-0000-4000-8000-000000000003', '9fb53b84-a341-5b63-b6e8-35a474540a4c', 'stripe', 'test', 'subscription', 'prod_UqeBWbAhuDjNiB', 'price_1TqwtECsC9pa7rgAlihgTqBc', 'EUR', 'monthly', 'active', now(), now());

-- 3A.17 cm_membership_plan_localized_fields
insert into cm_membership_plan_localized_fields (id, plan_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('087a89d0-6345-5d47-9a5d-64662d124d42', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'name', 'zh', '免费会员', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('9635c460-ed4a-50ed-bb67-8534089019b1', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'name', 'fr', 'Gratuit', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('16e62f41-c303-5327-b871-869fedce3671', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'name', 'en', 'Free', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('eeeb9000-b10c-5f4d-b58c-e566c8ea0594', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'description', 'zh', '基础浏览和匹配功能', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('59722038-aee9-582f-8898-9b101021c40e', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'description', 'fr', 'Consultation et matching de base', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('439ff16d-7ef0-5c96-8151-3f8b9671a65c', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'description', 'en', 'Basic browsing and matching', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('3cec9f31-5749-522a-9d63-7aa146082559', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'name', 'zh', '白银会员', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('528a28d1-c43a-5819-8157-eec7342602d5', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'name', 'fr', 'Argent', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('b0df0f19-1cd4-5ee0-b70f-2a457eb379df', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'name', 'en', 'Silver', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('61329d75-865c-5931-99d8-3ea3381b1512', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'description', 'zh', '基础顾问支持与稳定的正式接触节奏', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('e4449a61-ce63-59d0-9678-a5f7e604a40c', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'description', 'fr', 'Accompagnement standard et rythme relationnel regulier', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('ca912782-aa61-5da0-a2c7-e4bebb4b07e6', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'description', 'en', 'Standard advisor support and a steady relationship pace', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('0e5705d3-7919-57ba-a16f-d69752009231', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'name', 'zh', '黄金会员', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('32ec8316-7c5f-5402-b5de-6ef19f9c3094', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'name', 'fr', 'Or', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('445ff36c-8c7f-5c0b-9033-b38793c0cbfc', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'name', 'en', 'Gold', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('7d72854f-ea44-5c97-84fd-02afd26b5895', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'description', 'zh', '专属顾问和更多可见性', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('30248b56-9a97-502d-b98b-d829e0716c12', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'description', 'fr', 'Conseiller dedie et visibilite accrue', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('9197f852-5ad1-51a4-92a2-24cc61977580', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'description', 'en', 'Dedicated advisor and enhanced visibility', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('f33f791c-1ebe-5641-ab53-5af6fec18745', '9fb53b84-a341-5b63-b6e8-35a474540a4c', 'name', 'zh', '钻石会员', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('3739a5a2-6789-5559-a938-ceefce95f9af', '9fb53b84-a341-5b63-b6e8-35a474540a4c', 'name', 'fr', 'Diamant', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('53b1a49f-54e9-5c72-813a-a0dbaf23b7b9', '9fb53b84-a341-5b63-b6e8-35a474540a4c', 'name', 'en', 'Diamond', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('9b1ab1ab-b2ec-5e87-a933-7e70ef59f848', '9fb53b84-a341-5b63-b6e8-35a474540a4c', 'description', 'zh', '深度顾问服务和每月 30 次私人介绍', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('4924d48d-151c-5a29-bf21-bc714058fa22', '9fb53b84-a341-5b63-b6e8-35a474540a4c', 'description', 'fr', 'Service de conciergerie et 30 introductions privees par mois', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('397fbad3-12e3-544f-acf0-2a6a1328da28', '9fb53b84-a341-5b63-b6e8-35a474540a4c', 'description', 'en', 'Concierge service and 30 private introductions per month', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20');


-- Inbox and verification templates.
-- 3A.31 cm_inbox_templates
insert into cm_inbox_templates (id, template_code, message_type, subject_type, action_type, status) values
  ('10000000-0000-5000-8000-000000000001', 'welcome_message', 'system_notice', null, null, 'enabled'),
  ('10000000-0000-5000-8000-000000000002', 'profile_review_approved', 'status_update', 'profile', null, 'enabled'),
  ('10000000-0000-5000-8000-000000000003', 'profile_review_rejected', 'status_update', 'profile', null, 'enabled'),
  ('10000000-0000-5000-8000-000000000004', 'photo_review_approved', 'status_update', 'profile', null, 'enabled'),
  ('10000000-0000-5000-8000-000000000005', 'photo_review_rejected', 'status_update', 'profile', null, 'enabled'),
  ('10000000-0000-5000-8000-000000000006', 'verification_approved', 'status_update', 'profile', null, 'enabled'),
  ('10000000-0000-5000-8000-000000000007', 'verification_rejected', 'status_update', 'profile', null, 'enabled'),
  ('10000000-0000-5000-8000-000000000008', 'event_registration_status_changed', 'status_update', 'event', null, 'enabled'),
  ('10000000-0000-5000-8000-000000000009', 'private_introduction_status_changed', 'status_update', 'private_introduction_request', null, 'enabled'),
  ('10000000-0000-5000-8000-000000000010', 'event_reminder_24h', 'action_prompt', 'event', 'view_event', 'enabled');

insert into cm_inbox_template_localized_fields (id, template_id, locale, name, body) values
  ('11000000-0000-5000-8000-000000000001', '10000000-0000-5000-8000-000000000001', 'zh', '欢迎通知', '欢迎使用 Cupid Match。'),
  ('11000000-0000-5000-8000-000000000002', '10000000-0000-5000-8000-000000000001', 'fr', 'Bienvenue', 'Bienvenue sur Cupid Match.'),
  ('11000000-0000-5000-8000-000000000003', '10000000-0000-5000-8000-000000000001', 'en', 'Welcome', 'Welcome to Cupid Match.'),
  ('11000000-0000-5000-8000-000000000004', '10000000-0000-5000-8000-000000000002', 'zh', '资料审核通过', '你的资料 {{profileName}} 已通过审核。'),
  ('11000000-0000-5000-8000-000000000005', '10000000-0000-5000-8000-000000000002', 'fr', 'Profil approuve', 'Votre profil {{profileName}} a ete approuve.'),
  ('11000000-0000-5000-8000-000000000006', '10000000-0000-5000-8000-000000000002', 'en', 'Profile approved', 'Your profile {{profileName}} was approved.'),
  ('11000000-0000-5000-8000-000000000007', '10000000-0000-5000-8000-000000000003', 'zh', '资料审核未通过', '你的资料 {{profileName}} 未通过审核：{{reason}}'),
  ('11000000-0000-5000-8000-000000000008', '10000000-0000-5000-8000-000000000003', 'fr', 'Profil refuse', 'Votre profil {{profileName}} a ete refuse : {{reason}}'),
  ('11000000-0000-5000-8000-000000000009', '10000000-0000-5000-8000-000000000003', 'en', 'Profile rejected', 'Your profile {{profileName}} was rejected: {{reason}}'),
  ('11000000-0000-5000-8000-000000000010', '10000000-0000-5000-8000-000000000004', 'zh', '照片审核通过', '资料 {{profileName}} 的照片已通过审核。'),
  ('11000000-0000-5000-8000-000000000011', '10000000-0000-5000-8000-000000000004', 'fr', 'Photo approuvee', 'La photo du profil {{profileName}} a ete approuvee.'),
  ('11000000-0000-5000-8000-000000000012', '10000000-0000-5000-8000-000000000004', 'en', 'Photo approved', 'A photo for {{profileName}} was approved.'),
  ('11000000-0000-5000-8000-000000000013', '10000000-0000-5000-8000-000000000005', 'zh', '照片审核未通过', '资料 {{profileName}} 的照片未通过审核：{{reason}}'),
  ('11000000-0000-5000-8000-000000000014', '10000000-0000-5000-8000-000000000005', 'fr', 'Photo refusee', 'La photo du profil {{profileName}} a ete refusee : {{reason}}'),
  ('11000000-0000-5000-8000-000000000015', '10000000-0000-5000-8000-000000000005', 'en', 'Photo rejected', 'A photo for {{profileName}} was rejected: {{reason}}'),
  ('11000000-0000-5000-8000-000000000016', '10000000-0000-5000-8000-000000000006', 'zh', '认证审核通过', '你的{{verificationType}}认证已通过。'),
  ('11000000-0000-5000-8000-000000000017', '10000000-0000-5000-8000-000000000006', 'fr', 'Verification approuvee', 'Votre verification {{verificationType}} a ete approuvee.'),
  ('11000000-0000-5000-8000-000000000018', '10000000-0000-5000-8000-000000000006', 'en', 'Verification approved', 'Your {{verificationType}} verification was approved.'),
  ('11000000-0000-5000-8000-000000000019', '10000000-0000-5000-8000-000000000007', 'zh', '认证审核未通过', '你的{{verificationType}}认证未通过：{{reason}}'),
  ('11000000-0000-5000-8000-000000000020', '10000000-0000-5000-8000-000000000007', 'fr', 'Verification refusee', 'Votre verification {{verificationType}} a ete refusee : {{reason}}'),
  ('11000000-0000-5000-8000-000000000021', '10000000-0000-5000-8000-000000000007', 'en', 'Verification rejected', 'Your {{verificationType}} verification was rejected: {{reason}}'),
  ('11000000-0000-5000-8000-000000000022', '10000000-0000-5000-8000-000000000008', 'zh', '活动报名状态更新', '活动《{{eventTitle}}》的报名状态已更新为 {{status}}。'),
  ('11000000-0000-5000-8000-000000000023', '10000000-0000-5000-8000-000000000008', 'fr', 'Statut inscription evenement', 'Le statut de votre inscription a {{eventTitle}} est maintenant {{status}}.'),
  ('11000000-0000-5000-8000-000000000024', '10000000-0000-5000-8000-000000000008', 'en', 'Event registration updated', 'Your registration for {{eventTitle}} is now {{status}}.'),
  ('11000000-0000-5000-8000-000000000025', '10000000-0000-5000-8000-000000000009', 'zh', '私人介绍状态更新', '你的私人介绍申请状态已更新为 {{status}}。'),
  ('11000000-0000-5000-8000-000000000026', '10000000-0000-5000-8000-000000000009', 'fr', 'Statut introduction privee', 'Votre demande introduction privee est maintenant {{status}}.'),
  ('11000000-0000-5000-8000-000000000027', '10000000-0000-5000-8000-000000000009', 'en', 'Private introduction updated', 'Your private introduction request is now {{status}}.'),
  ('11000000-0000-5000-8000-000000000028', '10000000-0000-5000-8000-000000000010', 'zh', '活动开始提醒', '活动《{{eventTitle}}》将在 {{startsAt}} 开始，请提前做好准备。'),
  ('11000000-0000-5000-8000-000000000029', '10000000-0000-5000-8000-000000000010', 'fr', 'Rappel evenement', 'L evenement {{eventTitle}} commencera le {{startsAt}}. Merci de vous preparer a l avance.'),
  ('11000000-0000-5000-8000-000000000030', '10000000-0000-5000-8000-000000000010', 'en', 'Event reminder', 'The event {{eventTitle}} starts at {{startsAt}}. Please prepare in advance.');


-- 5J3. Verification Email templates
insert into cm_inbox_templates (id, template_code, message_type, status) values
  ('e9300000-0000-4000-8000-000000000001', 'verification_registration', 'text', 'enabled'),
  ('e9300000-0000-4000-8000-000000000002', 'verification_password_reset', 'text', 'enabled'),
  ('e9300000-0000-4000-8000-000000000003', 'verification_identity_bind', 'text', 'enabled'),
  ('e9300000-0000-4000-8000-000000000004', 'verification_mfa', 'text', 'enabled');

insert into cm_inbox_template_localized_fields (id, template_id, locale, name, body) values
  ('e9310000-0000-4000-8000-000000000001','e9300000-0000-4000-8000-000000000001','zh','Cupid Match 注册验证码','您的验证码是 {{code}}，{{ttlMinutes}} 分钟内有效。'),
  ('e9310000-0000-4000-8000-000000000002','e9300000-0000-4000-8000-000000000001','fr','Code de vérification Cupid Match','Votre code est {{code}}. Il est valable pendant {{ttlMinutes}} minutes.'),
  ('e9310000-0000-4000-8000-000000000003','e9300000-0000-4000-8000-000000000001','en','Cupid Match registration code','Your code is {{code}}. It is valid for {{ttlMinutes}} minutes.'),
  ('e9310000-0000-4000-8000-000000000004','e9300000-0000-4000-8000-000000000002','zh','Cupid Match 密码重置验证码','您的密码重置验证码是 {{code}}，{{ttlMinutes}} 分钟内有效。'),
  ('e9310000-0000-4000-8000-000000000005','e9300000-0000-4000-8000-000000000002','fr','Code de réinitialisation Cupid Match','Votre code de réinitialisation est {{code}}. Il est valable pendant {{ttlMinutes}} minutes.'),
  ('e9310000-0000-4000-8000-000000000006','e9300000-0000-4000-8000-000000000002','en','Cupid Match password reset code','Your password reset code is {{code}}. It is valid for {{ttlMinutes}} minutes.'),
  ('e9310000-0000-4000-8000-000000000007','e9300000-0000-4000-8000-000000000003','zh','Cupid Match 身份绑定验证码','您的身份绑定验证码是 {{code}}，{{ttlMinutes}} 分钟内有效。'),
  ('e9310000-0000-4000-8000-000000000008','e9300000-0000-4000-8000-000000000003','fr','Code de liaison Cupid Match','Votre code de liaison est {{code}}. Il est valable pendant {{ttlMinutes}} minutes.'),
  ('e9310000-0000-4000-8000-000000000009','e9300000-0000-4000-8000-000000000003','en','Cupid Match identity binding code','Your identity binding code is {{code}}. It is valid for {{ttlMinutes}} minutes.'),
  ('e9310000-0000-4000-8000-000000000010','e9300000-0000-4000-8000-000000000004','zh','Cupid Match MFA 验证码','您的 MFA 验证码是 {{code}}，{{ttlMinutes}} 分钟内有效。'),
  ('e9310000-0000-4000-8000-000000000011','e9300000-0000-4000-8000-000000000004','fr','Code MFA Cupid Match','Votre code MFA est {{code}}. Il est valable pendant {{ttlMinutes}} minutes.'),
  ('e9310000-0000-4000-8000-000000000012','e9300000-0000-4000-8000-000000000004','en','Cupid Match MFA code','Your MFA code is {{code}}. It is valid for {{ttlMinutes}} minutes.');

commit;
