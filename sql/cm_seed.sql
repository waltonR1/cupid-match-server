-- ---------------------------------------------------------------------------
-- Cupid Match consolidated seed data (DML only)
--
-- Sections:
--   1. RuoYi base data
--   2. Cupid admin roles & menus
--   3. Cupid Match sample data (Phase 8.2.4 adapted)
--   4. Admin review test data (Phase 8.2.4 adapted)
--   5. Additional varied-status test data
--
-- Run after sql/cm_schema.sql.
-- ---------------------------------------------------------------------------

-- ============================================================================
-- Section 1: RuoYi Base Data
-- ============================================================================

-- 1
insert into sys_dept values(100,  0,   '0',          '若依科技',   0, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(101,  100, '0,100',      '深圳总公司', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(102,  100, '0,100',      '长沙分公司', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(103,  101, '0,100,101',  '研发部门',   1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(104,  101, '0,100,101',  '市场部门',   2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(105,  101, '0,100,101',  '测试部门',   3, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(106,  101, '0,100,101',  '财务部门',   4, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(107,  101, '0,100,101',  '运维部门',   5, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(108,  102, '0,100,102',  '市场部门',   1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(109,  102, '0,100,102',  '财务部门',   2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);

-- 2
insert into sys_user values(1,  103, 'admin', '若依', '00', 'ry@163.com', '15888888888', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '管理员');
insert into sys_user values(2,  105, 'ry',    '若依', '00', 'ry@qq.com',  '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', sysdate(), sysdate(), 'admin', sysdate(), '', null, '测试员');

-- 3
insert into sys_post values(1, 'ceo',  '董事长',    1, '0', 'admin', sysdate(), '', null, '');
insert into sys_post values(2, 'se',   '项目经理',  2, '0', 'admin', sysdate(), '', null, '');
insert into sys_post values(3, 'hr',   '人力资源',  3, '0', 'admin', sysdate(), '', null, '');
insert into sys_post values(4, 'user', '普通员工',  4, '0', 'admin', sysdate(), '', null, '');

-- 4
insert into sys_role values('1', '超级管理员',  'admin',  1, 1, 1, 1, '0', '0', 'admin', sysdate(), '', null, '超级管理员');
insert into sys_role values('2', '普通角色',    'common', 2, 2, 1, 1, '0', '0', 'admin', sysdate(), '', null, '普通角色');

-- 5
insert into sys_menu values('1', '系统管理', '0', '1', 'system',           null, '', '', 1, 0, 'M', '0', '0', '', 'system',   'admin', sysdate(), '', null, '系统管理目录');
insert into sys_menu values('2', '系统监控', '0', '2', 'monitor',          null, '', '', 1, 0, 'M', '0', '0', '', 'monitor',  'admin', sysdate(), '', null, '系统监控目录');
insert into sys_menu values('3', '系统工具', '0', '3', 'tool',             null, '', '', 1, 0, 'M', '0', '0', '', 'tool',     'admin', sysdate(), '', null, '系统工具目录');
insert into sys_menu values('4', '若依官网', '0', '4', 'http://ruoyi.vip', null, '', '', 0, 0, 'M', '0', '0', '', 'guide',    'admin', sysdate(), '', null, '若依官网地址');
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

-- 6
insert into sys_user_role values ('1', '1');
insert into sys_user_role values ('2', '2');

-- 7
insert into sys_role_menu values ('2', '1');
insert into sys_role_menu values ('2', '2');
insert into sys_role_menu values ('2', '3');
insert into sys_role_menu values ('2', '4');
insert into sys_role_menu values ('2', '100');
insert into sys_role_menu values ('2', '101');
insert into sys_role_menu values ('2', '102');
insert into sys_role_menu values ('2', '103');
insert into sys_role_menu values ('2', '104');
insert into sys_role_menu values ('2', '105');
insert into sys_role_menu values ('2', '106');
insert into sys_role_menu values ('2', '107');
insert into sys_role_menu values ('2', '108');
insert into sys_role_menu values ('2', '109');
insert into sys_role_menu values ('2', '110');
insert into sys_role_menu values ('2', '111');
insert into sys_role_menu values ('2', '112');
insert into sys_role_menu values ('2', '113');
insert into sys_role_menu values ('2', '114');
insert into sys_role_menu values ('2', '115');
insert into sys_role_menu values ('2', '116');
insert into sys_role_menu values ('2', '117');
insert into sys_role_menu values ('2', '500');
insert into sys_role_menu values ('2', '501');
insert into sys_role_menu values ('2', '1000');
insert into sys_role_menu values ('2', '1001');
insert into sys_role_menu values ('2', '1002');
insert into sys_role_menu values ('2', '1003');
insert into sys_role_menu values ('2', '1004');
insert into sys_role_menu values ('2', '1005');
insert into sys_role_menu values ('2', '1006');
insert into sys_role_menu values ('2', '1007');
insert into sys_role_menu values ('2', '1008');
insert into sys_role_menu values ('2', '1009');
insert into sys_role_menu values ('2', '1010');
insert into sys_role_menu values ('2', '1011');
insert into sys_role_menu values ('2', '1012');
insert into sys_role_menu values ('2', '1013');
insert into sys_role_menu values ('2', '1014');
insert into sys_role_menu values ('2', '1015');
insert into sys_role_menu values ('2', '1016');
insert into sys_role_menu values ('2', '1017');
insert into sys_role_menu values ('2', '1018');
insert into sys_role_menu values ('2', '1019');
insert into sys_role_menu values ('2', '1020');
insert into sys_role_menu values ('2', '1021');
insert into sys_role_menu values ('2', '1022');
insert into sys_role_menu values ('2', '1023');
insert into sys_role_menu values ('2', '1024');
insert into sys_role_menu values ('2', '1025');
insert into sys_role_menu values ('2', '1026');
insert into sys_role_menu values ('2', '1027');
insert into sys_role_menu values ('2', '1028');
insert into sys_role_menu values ('2', '1029');
insert into sys_role_menu values ('2', '1030');
insert into sys_role_menu values ('2', '1031');
insert into sys_role_menu values ('2', '1032');
insert into sys_role_menu values ('2', '1033');
insert into sys_role_menu values ('2', '1034');
insert into sys_role_menu values ('2', '1035');
insert into sys_role_menu values ('2', '1036');
insert into sys_role_menu values ('2', '1037');
insert into sys_role_menu values ('2', '1038');
insert into sys_role_menu values ('2', '1039');
insert into sys_role_menu values ('2', '1040');
insert into sys_role_menu values ('2', '1041');
insert into sys_role_menu values ('2', '1042');
insert into sys_role_menu values ('2', '1043');
insert into sys_role_menu values ('2', '1044');
insert into sys_role_menu values ('2', '1045');
insert into sys_role_menu values ('2', '1046');
insert into sys_role_menu values ('2', '1047');
insert into sys_role_menu values ('2', '1048');
insert into sys_role_menu values ('2', '1049');
insert into sys_role_menu values ('2', '1050');
insert into sys_role_menu values ('2', '1051');
insert into sys_role_menu values ('2', '1052');
insert into sys_role_menu values ('2', '1053');
insert into sys_role_menu values ('2', '1054');
insert into sys_role_menu values ('2', '1055');
insert into sys_role_menu values ('2', '1056');
insert into sys_role_menu values ('2', '1057');
insert into sys_role_menu values ('2', '1058');
insert into sys_role_menu values ('2', '1059');
insert into sys_role_menu values ('2', '1060');

delete from sys_role_menu
where role_id = '2'
  and menu_id in (
    105, 106, 109, 110, 113, 114,
    1025, 1026, 1027, 1028, 1029,
    1030, 1031, 1032, 1033, 1034,
    1046, 1047, 1048,
    1049, 1050, 1051, 1052, 1053, 1054,
    1061
  );

-- 8
insert into sys_role_dept values ('2', '100');
insert into sys_role_dept values ('2', '101');
insert into sys_role_dept values ('2', '105');

-- 9
insert into sys_user_post values ('1', '1');
insert into sys_user_post values ('2', '2');

-- 11
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

-- 15
insert into sys_job values(1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams',        '0/10 * * * * ?', '3', '1', '1', 'admin', sysdate(), '', null, '');
insert into sys_job values(2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(\'ry\')',  '0/15 * * * * ?', '3', '1', '1', 'admin', sysdate(), '', null, '');
insert into sys_job values(3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)',  '0/20 * * * * ?', '3', '1', '1', 'admin', sysdate(), '', null, '');
insert into sys_job values(4, '私人介绍过期补偿', 'CUPID', 'cupidTask.expireIntroductionRequests', '0 */10 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '处理过期私人介绍申请并返还权益');
insert into sys_job values(5, '安全挑战过期清理', 'CUPID', 'cupidTask.expireSecurityChallenges', '30 */10 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '标记已过期的安全挑战');
insert into sys_job values(6, '会员到期状态同步', 'CUPID', 'cupidTask.expireMemberships', '0 5 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '将超过有效期的有效会员同步为已过期');
insert into sys_job values(7, '活动站内提醒', 'CUPID', 'cupidTask.sendEventReminders', '0 */10 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '向24小时内开始的活动确认用户发送站内提醒');
insert into sys_job values(8, '跟进事项逾期提醒', 'CUPID', 'cupidTask.sendOverdueStaffTaskReminders', '30 */10 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '向逾期跟进事项负责人发送后台通知');
insert into sys_job values(9, '翻译失败重试', 'CUPID', 'cupidTask.retryFailedTranslations', '0 */5 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '按指数退避重试机器翻译失败任务');
insert into sys_job values(10, '消息失败重试', 'CUPID', 'cupidTask.retryFailedMessages', '30 */5 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '重试瞬时基础设施异常导致的站内消息失败');
insert into sys_job values(11, '运营数据定期清理', 'CUPID', 'cupidTask.cleanupOperationalData', '0 20 3 * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '按保留策略分批清理技术日志及过期运行数据');
insert into sys_job values(12, '活动生命周期同步', 'CUPID', 'cupidTask.synchronizeEventLifecycle', '0 */5 * * * ?', '3', '1', '0', 'admin', sysdate(), '', null, '自动确认报名、递补候补并归档已结束活动');

-- 17
insert into sys_notice values('1', '温馨提醒：2018-07-01 若依新版本发布啦', '2', '新版本内容', '0', 'admin', sysdate(), '', null, '管理员');
insert into sys_notice values('2', '维护通知：2018-07-01 若依系统凌晨维护', '1', '维护内容',   '0', 'admin', sysdate(), '', null, '管理员');
insert into sys_notice values('3', '若依开源框架介绍', '1', '<p><span style=\"color: rgb(230, 0, 0);\">项目介绍</span></p><p><font color=\"#333333\">RuoYi开源项目是为企业用户定制的后台脚手架框架，为企业打造的一站式解决方案，降低企业开发成本，提升开发效率。主要包括用户管理、角色管理、部门管理、菜单管理、参数管理、字典管理、</font><span style=\"color: rgb(51, 51, 51);\">岗位管理</span><span style=\"color: rgb(51, 51, 51);\">、定时任务</span><span style=\"color: rgb(51, 51, 51);\">、</span><span style=\"color: rgb(51, 51, 51);\">服务监控、登录日志、操作日志、代码生成等功能。其中，还支持多数据源、数据权限、国际化、Redis缓存、Docker部署、滑动验证码、第三方认证登录、分布式事务、</span><font color=\"#333333\">分布式文件存储</font><span style=\"color: rgb(51, 51, 51);\">、分库分表处理等技术特点。</span></p><p><img src=\"https://foruda.gitee.com/images/1773931848342439032/a4d22313_1815095.png\" style=\"width: 64px;\"><br></p><p><span style=\"color: rgb(230, 0, 0);\">官网及演示</span></p><p><span style=\"color: rgb(51, 51, 51);\">若依官网地址：&nbsp;</span><a href=\"http://ruoyi.vip\" target=\"_blank\">http://ruoyi.vip</a><a href=\"http://ruoyi.vip\" target=\"_blank\"></a></p><p><span style=\"color: rgb(51, 51, 51);\">若依文档地址：&nbsp;</span><a href=\"http://doc.ruoyi.vip\" target=\"_blank\">http://doc.ruoyi.vip</a><br></p><p><span style=\"color: rgb(51, 51, 51);\">演示地址【不分离版】：&nbsp;</span><a href=\"http://demo.ruoyi.vip\" target=\"_blank\">http://demo.ruoyi.vip</a></p><p><span style=\"color: rgb(51, 51, 51);\">演示地址【分离版本】：&nbsp;</span><a href=\"http://vue.ruoyi.vip\" target=\"_blank\">http://vue.ruoyi.vip</a></p><p><span style=\"color: rgb(51, 51, 51);\">演示地址【微服务版】：&nbsp;</span><a href=\"http://cloud.ruoyi.vip\" target=\"_blank\">http://cloud.ruoyi.vip</a></p><p><span style=\"color: rgb(51, 51, 51);\">演示地址【移动端版】：&nbsp;</span><a href=\"http://h5.ruoyi.vip\" target=\"_blank\">http://h5.ruoyi.vip</a></p><p><br style=\"color: rgb(48, 49, 51); font-family: &quot;Helvetica Neue&quot;, Helvetica, Arial, sans-serif; font-size: 12px;\"></p>', '0', 'admin', sysdate(), '', null, '管理员');

-- ============================================================================
-- Section 2: Cupid Admin Roles and Menus
-- ============================================================================

start transaction;

delete rm from sys_role_menu rm inner join sys_menu m on m.menu_id = rm.menu_id
where m.menu_id = 4 and m.menu_name = '若依官网' and m.path = 'http://ruoyi.vip';

delete from sys_menu where menu_id = 4 and menu_name = '若依官网' and path = 'http://ruoyi.vip';

delete nr from sys_notice_read nr inner join sys_notice n on n.notice_id = nr.notice_id
where (n.notice_id = 1 and n.notice_title = '温馨提醒：2018-07-01 若依新版本发布啦')
   or (n.notice_id = 2 and n.notice_title = '维护通知：2018-07-01 若依系统凌晨维护')
   or (n.notice_id = 3 and n.notice_title = '若依开源框架介绍');

delete from sys_notice
where (notice_id = 1 and notice_title = '温馨提醒：2018-07-01 若依新版本发布啦')
   or (notice_id = 2 and notice_title = '维护通知：2018-07-01 若依系统凌晨维护')
   or (notice_id = 3 and notice_title = '若依开源框架介绍');

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

delete from sys_role_menu where menu_id between 2000 and 2109;
delete from sys_menu where menu_id between 2000 and 2109;

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

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id between 2000 and 2109
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
select r.role_id, m.menu_id from sys_role r join sys_menu m on m.menu_id in (2080, 2081, 2082)
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

commit;

-- ============================================================================
-- Section 3: Cupid Match Complete Business Data (Phase 8.2.4 adapted)
-- ============================================================================

-- 3A.1 Users
insert into cm_users (id, account_name, avatar_url, preferred_locale, status, created_at, updated_at) values
  ('efdca298-c977-5502-ad2e-8ba480ca1ea3', 'Lin', '', 'zh', 'active', '2026-01-18 00:00:00', '2026-05-27 18:33:11');

-- 3A.2 Auth identities
insert into cm_auth_identities (id, user_id, provider, identifier, password_hash, verified_at, created_at, updated_at) values
  ('866d5279-f964-5513-92af-3e3c3005e0af', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'email', 'lin@example.com', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', '2026-01-18 00:00:00', '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('dab49d53-34f1-552a-b3fb-a90847e7adae', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'phone', '13333333333', '$2a$10$Mps2ruiJN2eRgv0u90HSRuwxwvfrR5UIeVhLozyoxMNWm4esUFV6W', '2026-06-01 12:16:53', '2026-06-01 12:16:53', '2026-06-01 12:16:53');

-- 3A.3 Security settings
insert into cm_user_security_settings (id, user_id, mfa_enabled, mfa_method, mfa_identity_id, mfa_enabled_at, last_challenge_at, created_at, updated_at) values
  ('c12c12d6-7cf2-580c-afa8-86439bbe71a3', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 1, 'email', '866d5279-f964-5513-92af-3e3c3005e0af', '2026-05-31 14:39:34', '2026-06-01 12:50:47', '2026-05-31 14:39:34', '2026-06-01 12:50:47');

-- 3A.4 Security challenges
insert into cm_user_security_challenges (id, user_id, action, method, identity_id, status, challenge_token, expires_at, verified_at, consumed_at, created_at, updated_at) values
  ('fc53472e-6584-5b40-906e-b4f5b222e183', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'export_data', 'email', '866d5279-f964-5513-92af-3e3c3005e0af', 'consumed', 'challenge-security-token-001-1780238394772', '2026-05-31 14:44:54', '2026-05-31 14:39:54', '2026-05-31 14:39:54', '2026-05-31 14:39:39', '2026-05-31 14:39:54'),
  ('04d4e928-0644-5dcf-865e-6426d8069384', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'export_data', 'email', '866d5279-f964-5513-92af-3e3c3005e0af', 'pending', null, '2026-05-31 14:45:04', null, null, '2026-05-31 14:40:04', '2026-05-31 14:40:04'),
  ('aed0ae4f-b415-585c-9b9e-0d03817240ae', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'export_data', 'email', '866d5279-f964-5513-92af-3e3c3005e0af', 'pending', null, '2026-05-31 14:46:05', null, null, '2026-05-31 14:41:05', '2026-05-31 14:41:05'),
  ('0d6ece63-908e-53ff-941b-ef0c2a5cced2', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'export_data', 'email', '866d5279-f964-5513-92af-3e3c3005e0af', 'pending', null, '2026-06-01 12:55:47', null, null, '2026-06-01 12:50:47', '2026-06-01 12:50:47');

-- 3A.5 User preferences
insert into cm_user_preferences (id, user_id, preferred_city_code, preferred_contact_channel, staff_contact_enabled, family_assist_enabled, introduction_updates_enabled, event_reminders_enabled, service_announcements_enabled, marketing_emails_enabled, analytics_consent_enabled, created_at, updated_at) values
  ('0ddabb82-4c33-5f95-8cea-4ee08f4fdd2e', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'FR:paris', 'email', 1, 1, 1, 1, 1, 0, 0, '2026-01-01 00:00:00', '2026-05-27 18:36:02');

-- 3A.6 Legal documents
insert into cm_legal_documents (id, type, version, status, effective_at, created_at, updated_at) values
  ('6f0081c5-e57a-5470-8177-93902e24302d', 'terms', '1.0', 'active', '2026-01-01 00:00:00', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('85a634d2-f126-5d90-be6d-d550f2b920fc', 'privacy', '1.0', 'active', '2026-01-01 00:00:00', '2026-01-01 00:00:00', '2026-01-01 00:00:00');

-- 3A.7 Legal document contents
insert into cm_legal_document_contents (id, document_id, locale, title, sections, created_at, updated_at) values
  ('d5f896e8-5bf2-547a-b4c5-bebadee254a0', '6f0081c5-e57a-5470-8177-93902e24302d', 'zh', 'Cupid Match 平台服务条款', '[{"heading":"第一条 定义与接受","clauses":[{"number":"1.1","body":"Cupid Match 平台（以下简称\\"平台\\"）是由 Cupid Match 运营方（以下简称\\"我们\\"）提供的婚恋中介撮合服务平台。"},{"number":"1.2","body":"本服务条款（以下简称\\"条款\\"）是您与平台之间关于使用平台服务的完整协议。您在注册时勾选\\"我已阅读并同意\\"，即表示您已完整阅读、充分理解并自愿接受本条款的全部内容。"},{"number":"1.3","body":"平台可能通过弹窗、页面提示、站内信等方式向您发送通知。您继续使用平台服务即表示您同意接收此类通知。"}],"sortOrder":1},{"heading":"第二条 账号注册与安全","clauses":[{"number":"2.1","body":"注册资格：您确认您年满 18 周岁，具有完全民事行为能力。如果您代表他人（如子女）注册，您需获得该人士的明确授权。"},{"number":"2.2","body":"注册信息：您应提供真实、准确、完整的注册信息，包括但不限于姓名、邮箱或手机号。注册信息发生变更时，您应及时更新。"},{"number":"2.3","body":"账号安全：您对账号下的所有活动负责。请妥善保管您的登录凭证，不得将账号出借、转让或授权他人使用。如发现账号被盗用，应立即通知平台。"},{"number":"2.4","body":"实名认证：平台有权要求您完成实名认证。未通过实名认证的账号，平台可限制部分功能的使用。"}],"sortOrder":2},{"heading":"第三条 服务内容","clauses":[{"number":"3.1","body":"平台提供以下核心服务：\\n（a）个人资料创建与展示：您可创建个人相亲资料，包括个人信息、照片、择偶偏好等；\\n（b）智能匹配与推荐：平台根据您的资料和偏好，推荐匹配度较高的其他用户；\\n（c）资料浏览与搜索：您可在平台范围内浏览和筛选其他用户的公开资料；\\n（d）私人介绍服务：平台顾问根据双方情况提供定向撮合介绍服务；\\n（e）线下活动：平台定期组织线下交友活动，您可报名参加；\\n（f）顾问服务：平台顾问提供婚恋咨询、资料优化、撮合跟进等服务。"},{"number":"3.2","body":"平台保留根据运营需要调整、增减服务内容的权利。重大调整将提前 7 日在平台上公告。"}],"sortOrder":3},{"heading":"第四条 会员与付费","clauses":[{"number":"4.1","body":"平台提供免费基础服务和付费会员服务。免费用户可访问基本功能，付费会员享有更多权益（如增加私人介绍额度、优先活动报名、专属顾问服务等）。"},{"number":"4.2","body":"会员套餐和价格以平台公布为准。平台可能不时调整套餐内容和价格，调整前已购买的套餐不受影响。"},{"number":"4.3","body":"除法律规定的情形外，已支付的会员费用不予退还。"},{"number":"4.4","body":"会员到期后，您将恢复免费用户权限。平台保留在会员到期前提醒您续费的权利。"}],"sortOrder":4},{"heading":"第五条 用户行为规范","clauses":[{"number":"5.1","body":"您承诺在使用平台过程中遵守以下规范：\\n（a）遵守中华人民共和国法律法规及您所在地区的适用法律；\\n（b）遵守社会公序良俗，尊重他人合法权益；\\n（c）发布真实、合法、准确的信息，不编造虚假身份、年龄、婚姻状况、职业等资料；\\n（d）不利用平台从事任何违法违规活动，包括但不限于诈骗、传销、赌博、色情服务等。"},{"number":"5.2","body":"禁止行为包括但不限于：\\n（a）骚扰、辱骂、恐吓、跟踪其他用户；\\n（b）未经许可收集、存储、传播其他用户的个人信息；\\n（c）发布商业广告、垃圾信息或与婚恋交友无关的内容；\\n（d）绕开平台私下交易或进行资金往来；\\n（e）利用技术手段干扰平台正常运营（如爬虫、刷量、注入攻击等）；\\n（f）冒用平台名义或冒充平台工作人员。"}],"sortOrder":5},{"heading":"第六条 信息审核与处置","clauses":[{"number":"6.1","body":"平台有权对用户发布的资料、照片、文字等内容进行审核。审核标准包括但不限于真实性、合法性、合规性。"},{"number":"6.2","body":"如发现您发布的内容违反本条款或法律法规，平台有权采取以下一项或多项措施：\\n（a）要求您限期修改或删除违规内容；\\n（b）暂时或永久限制您发布内容的权限；\\n（c）暂时冻结或永久关闭您的账号；\\n（d）向有关主管部门报告；\\n（e）保留追究法律责任的权利。"},{"number":"6.3","body":"平台对用户内容的审核不意味着平台认可该内容的真实性或合法性。用户对其发布的内容独立承担法律责任。"}],"sortOrder":6},{"heading":"第七条 隐私保护","clauses":[{"number":"7.1","body":"平台高度重视您的隐私保护。您的个人信息将按照《隐私说明》进行收集、使用和保护。《隐私说明》是本条款不可分割的组成部分。"},{"number":"7.2","body":"未经您的明确同意，平台不会向第三方披露您的联系方式（手机号、邮箱、微信号等）。私人介绍成功后，联系方式在双方确认的情况下方可交换。"},{"number":"7.3","body":"您授权平台在以下范围内使用您的资料信息：\\n（a）在平台内展示您的个人资料（按您的隐私设置控制可见范围）；\\n（b）向平台顾问展示您的资料以便提供撮合服务；\\n（c）向您推荐匹配度较高的其他用户；\\n（d）用于平台服务的改进和优化（匿名化处理后）。"}],"sortOrder":7},{"heading":"第八条 知识产权","clauses":[{"number":"8.1","body":"平台的所有内容，包括但不限于文字、图片、图标、界面设计、软件代码、数据汇编等，均受知识产权法律保护。未经平台书面许可，任何人不得复制、修改、传播或利用。"},{"number":"8.2","body":"您在平台上发布的内容（照片、文字等），您保留所有权。您授予平台在平台范围内使用、展示、分发这些内容的非独占许可，以便为您提供服务。"},{"number":"8.3","body":"您保证您在平台上发布的内容不侵犯任何第三方的知识产权或其他合法权益。如因此给平台造成损失，您应承担赔偿责任。"}],"sortOrder":8},{"heading":"第九条 免责声明","clauses":[{"number":"9.1","body":"平台作为婚恋信息撮合平台，尽力为用户提供真实、可靠的服务，但在以下范围内不承担责任：\\n（a）平台不保证任何匹配推荐或活动必然促成恋爱关系或婚姻；\\n（b）平台不对用户自行发布的信息的准确性、完整性承担保证责任；\\n（c）用户之间的线下交往、资金往来由用户自行判断风险并承担后果。"},{"number":"9.2","body":"因不可抗力（自然灾害、战争、政策变化、网络攻击等）导致服务中断或数据丢失的，平台不承担责任，但应在合理时间内恢复服务。"},{"number":"9.3","body":"您在与其他用户交往过程中应保持理性判断，注意人身和财产安全。平台建议首次线下见面选择公共场所。"}],"sortOrder":9},{"heading":"第十条 违约责任与赔偿","clauses":[{"number":"10.1","body":"如您违反本条款，给平台或第三方造成损失的，您应承担相应的赔偿责任。"},{"number":"10.2","body":"平台的赔偿责任仅限于直接损失，且总额不超过您在过去 12 个月内向平台支付的费用总额。"},{"number":"10.3","body":"本条款的任何规定不限制或排除法律禁止限制或排除的责任。"}],"sortOrder":10},{"heading":"第十一条 条款修改","clauses":[{"number":"11.1","body":"平台有权根据需要修改本条款。修改后的条款将在平台公布，公布后继续使用平台服务即表示您接受修改后的条款。"},{"number":"11.2","body":"如您不同意修改后的条款，您应停止使用平台服务并注销账号。"},{"number":"11.3","body":"重大条款修改，平台将通过站内信或邮件方式提前 7 日通知您。"}],"sortOrder":11},{"heading":"第十二条 适用法律与争议解决","clauses":[{"number":"12.1","body":"本条款的订立、执行和解释适用中华人民共和国法律。"},{"number":"12.2","body":"因本条款引起的或与本条款有关的争议，双方应友好协商解决。协商不成的，任何一方均可向平台运营方所在地有管辖权的人民法院提起诉讼。"},{"number":"12.3","body":"本条款的部分条款无效不影响其余条款的效力。"}],"sortOrder":12}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('ad431728-0b31-56c9-81ec-e28b8e6cae38', '6f0081c5-e57a-5470-8177-93902e24302d', 'en', 'Cupid Match Platform Terms of Service', '[{"heading":"Article 1 Definitions and Acceptance","clauses":[{"number":"1.1","body":"The Cupid Match platform (the Platform) is a matchmaking and relationship-introduction service platform provided by the operator of Cupid Match (we, us, or our)."},{"number":"1.2","body":"These Terms of Service (the Terms) constitute the complete agreement between you and the Platform regarding your use of Platform services. By ticking I have read and agree during registration, you confirm that you have read, understood, and voluntarily accepted all provisions of these Terms."},{"number":"1.3","body":"The Platform may send notices to you through pop-ups, page prompts, in-app messages, and similar methods. Your continued use of Platform services means that you agree to receive such notices."}],"sortOrder":1},{"heading":"Article 2 Account Registration and Security","clauses":[{"number":"2.1","body":"Registration eligibility: You confirm that you are at least 18 years old and have full civil capacity. If you register on behalf of another person, such as your child, you must have that person’s express authorization."},{"number":"2.2","body":"Registration information: You must provide true, accurate, and complete registration information, including but not limited to your name, email address, or phone number. You must update such information promptly if it changes."},{"number":"2.3","body":"Account security: You are responsible for all activities under your account. You must keep your login credentials secure and may not lend, transfer, or authorize others to use your account. If you discover unauthorized use of your account, you must notify the Platform immediately."},{"number":"2.4","body":"Identity verification: The Platform has the right to require you to complete identity verification. If your account does not pass identity verification, the Platform may restrict your use of certain functions."}],"sortOrder":2},{"heading":"Article 3 Services","clauses":[{"number":"3.1","body":"The Platform provides the following core services:\\n(a) profile creation and display: you may create a matchmaking profile, including personal information, photos, and partner preferences;\\n(b) intelligent matching and recommendations: the Platform recommends other users with higher compatibility based on your profile and preferences;\\n(c) profile browsing and search: you may browse and filter other users’ public profiles within the Platform;\\n(d) private introduction services: Platform advisors provide targeted matchmaking introductions based on both parties’ circumstances;\\n(e) offline events: the Platform regularly organizes offline social events for which you may register;\\n(f) advisor services: Platform advisors may provide relationship consultation, profile optimization, matchmaking follow-up, and related services."},{"number":"3.2","body":"The Platform reserves the right to adjust, add, or remove services based on operational needs. Material adjustments will be announced on the Platform 7 days in advance."}],"sortOrder":3},{"heading":"Article 4 Membership and Paid Services","clauses":[{"number":"4.1","body":"The Platform provides free basic services and paid membership services. Free users may access basic functions. Paid members enjoy additional benefits, such as increased private introduction quotas, priority event registration, and dedicated advisor services."},{"number":"4.2","body":"Membership packages and prices are subject to the information published by the Platform. The Platform may adjust package content and pricing from time to time. Packages already purchased before an adjustment are not affected."},{"number":"4.3","body":"Except where required by law, paid membership fees are non-refundable."},{"number":"4.4","body":"After your membership expires, your account will return to free-user permissions. The Platform reserves the right to remind you to renew before expiration."}],"sortOrder":4},{"heading":"Article 5 User Conduct","clauses":[{"number":"5.1","body":"You undertake to comply with the following rules when using the Platform:\\n(a) comply with the laws and regulations of the People’s Republic of China and the applicable laws of your location;\\n(b) comply with public order and good morals and respect the lawful rights and interests of others;\\n(c) publish true, lawful, and accurate information and not fabricate false identity, age, marital status, occupation, or similar information;\\n(d) not use the Platform for any illegal or non-compliant activity, including but not limited to fraud, pyramid schemes, gambling, or sexual services."},{"number":"5.2","body":"Prohibited conduct includes but is not limited to:\\n(a) harassing, insulting, threatening, or stalking other users;\\n(b) collecting, storing, or disseminating other users’ personal information without permission;\\n(c) publishing commercial advertisements, spam, or content unrelated to matchmaking or dating;\\n(d) bypassing the Platform for private transactions or fund transfers;\\n(e) using technical means to interfere with normal Platform operations, such as crawlers, traffic manipulation, or injection attacks;\\n(f) using the Platform’s name without authorization or impersonating Platform staff."}],"sortOrder":5},{"heading":"Article 6 Content Review and Handling","clauses":[{"number":"6.1","body":"The Platform has the right to review materials, photos, text, and other content published by users. Review standards include but are not limited to authenticity, legality, and compliance."},{"number":"6.2","body":"If content you publish violates these Terms or applicable laws and regulations, the Platform has the right to take one or more of the following measures:\\n(a) require you to modify or delete the violating content within a specified period;\\n(b) temporarily or permanently restrict your permission to publish content;\\n(c) temporarily freeze or permanently close your account;\\n(d) report the matter to competent authorities;\\n(e) reserve the right to pursue legal liability."},{"number":"6.3","body":"The Platform’s review of user content does not mean that the Platform recognizes the authenticity or legality of such content. Users independently bear legal responsibility for the content they publish."}],"sortOrder":6},{"heading":"Article 7 Privacy Protection","clauses":[{"number":"7.1","body":"The Platform attaches great importance to protecting your privacy. Your personal information will be collected, used, and protected in accordance with the Privacy Notice. The Privacy Notice forms an integral part of these Terms."},{"number":"7.2","body":"Without your express consent, the Platform will not disclose your contact details, such as phone number, email address, or WeChat ID, to third parties. After a private introduction succeeds, contact details may be exchanged only upon confirmation by both parties."},{"number":"7.3","body":"You authorize the Platform to use your profile information within the following scope:\\n(a) display your profile within the Platform, subject to your privacy settings;\\n(b) show your profile to Platform advisors so that they may provide matchmaking services;\\n(c) recommend other users with higher compatibility to you;\\n(d) improve and optimize Platform services after anonymization."}],"sortOrder":7},{"heading":"Article 8 Intellectual Property","clauses":[{"number":"8.1","body":"All Platform content, including but not limited to text, images, icons, interface designs, software code, and data compilations, is protected by intellectual property laws. No person may copy, modify, distribute, or use such content without the Platform’s written permission."},{"number":"8.2","body":"You retain ownership of content you publish on the Platform, such as photos and text. You grant the Platform a non-exclusive license to use, display, and distribute such content within the Platform for the purpose of providing services to you."},{"number":"8.3","body":"You warrant that content you publish on the Platform does not infringe the intellectual property rights or other lawful rights and interests of any third party. If losses are caused to the Platform as a result, you shall be liable for compensation."}],"sortOrder":8},{"heading":"Article 9 Disclaimers","clauses":[{"number":"9.1","body":"As a matchmaking information and introduction platform, the Platform strives to provide authentic and reliable services, but does not assume liability within the following scope:\\n(a) the Platform does not guarantee that any matching recommendation or event will necessarily lead to a romantic relationship or marriage;\\n(b) the Platform does not guarantee the accuracy or completeness of information independently published by users;\\n(c) users must independently assess and bear the consequences of offline interactions and fund transfers between users."},{"number":"9.2","body":"The Platform is not liable for service interruption or data loss caused by force majeure, such as natural disasters, war, policy changes, or cyberattacks, but will restore services within a reasonable time."},{"number":"9.3","body":"You should maintain rational judgment when interacting with other users and pay attention to personal and property safety. The Platform recommends that first offline meetings take place in public places."}],"sortOrder":9},{"heading":"Article 10 Breach Liability and Compensation","clauses":[{"number":"10.1","body":"If you violate these Terms and cause losses to the Platform or any third party, you shall bear corresponding compensation liability."},{"number":"10.2","body":"The Platform’s compensation liability is limited to direct losses and shall not exceed the total fees you paid to the Platform during the preceding 12 months."},{"number":"10.3","body":"No provision of these Terms limits or excludes liability where such limitation or exclusion is prohibited by law."}],"sortOrder":10},{"heading":"Article 11 Modification of Terms","clauses":[{"number":"11.1","body":"The Platform has the right to modify these Terms as needed. Modified Terms will be published on the Platform. Your continued use of Platform services after publication means that you accept the modified Terms."},{"number":"11.2","body":"If you do not agree to the modified Terms, you should stop using Platform services and cancel your account."},{"number":"11.3","body":"For material modifications to these Terms, the Platform will notify you 7 days in advance by in-app message or email."}],"sortOrder":11},{"heading":"Article 12 Governing Law and Dispute Resolution","clauses":[{"number":"12.1","body":"The formation, performance, and interpretation of these Terms are governed by the laws of the People’s Republic of China."},{"number":"12.2","body":"Any dispute arising out of or relating to these Terms shall first be resolved through friendly consultation. If consultation fails, either party may bring a lawsuit before a competent people’s court at the place where the Platform operator is located."},{"number":"12.3","body":"The invalidity of any part of these Terms does not affect the validity of the remaining provisions."}],"sortOrder":12}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('574278a3-7d42-5f40-acd8-54af85f6f421', '6f0081c5-e57a-5470-8177-93902e24302d', 'fr', 'Conditions d utilisation de la plateforme Cupid Match', '[{"heading":"Article 1 Definitions et acceptation","clauses":[{"number":"1.1","body":"La plateforme Cupid Match (la Plateforme) est une plateforme de mise en relation matrimoniale et de services d introduction fournie par l operateur de Cupid Match (nous, notre ou nos)."},{"number":"1.2","body":"Les presentes conditions d utilisation (les Conditions) constituent l accord complet entre vous et la Plateforme concernant l utilisation des services de la Plateforme. En cochant J ai lu et j accepte lors de l inscription, vous confirmez avoir lu integralement, compris pleinement et accepte volontairement toutes les dispositions des presentes Conditions."},{"number":"1.3","body":"La Plateforme peut vous envoyer des notifications par fenetre contextuelle, message sur page, message interne ou moyen similaire. La poursuite de l utilisation des services de la Plateforme vaut acceptation de recevoir ces notifications."}],"sortOrder":1},{"heading":"Article 2 Inscription et securite du compte","clauses":[{"number":"2.1","body":"Eligibilite a l inscription : vous confirmez avoir au moins 18 ans et disposer de la pleine capacite civile. Si vous vous inscrivez pour le compte d une autre personne, par exemple votre enfant, vous devez obtenir son autorisation expresse."},{"number":"2.2","body":"Informations d inscription : vous devez fournir des informations d inscription veridiques, exactes et completes, y compris notamment votre nom, votre adresse email ou votre numero de telephone. Vous devez les mettre a jour rapidement en cas de changement."},{"number":"2.3","body":"Securite du compte : vous etes responsable de toutes les activites effectuees avec votre compte. Vous devez proteger vos identifiants de connexion et ne pouvez pas preter, transferer ou autoriser un tiers a utiliser votre compte. En cas d utilisation non autorisee, vous devez avertir immediatement la Plateforme."},{"number":"2.4","body":"Verification d identite : la Plateforme peut vous demander de completer une verification d identite. Si le compte ne reussit pas cette verification, la Plateforme peut limiter l acces a certaines fonctions."}],"sortOrder":2},{"heading":"Article 3 Contenu des services","clauses":[{"number":"3.1","body":"La Plateforme fournit les services principaux suivants :\\n(a) creation et affichage du profil : vous pouvez creer un profil de rencontre comprenant des informations personnelles, des photos et des preferences de partenaire ;\\n(b) mise en relation intelligente et recommandations : la Plateforme recommande d autres utilisateurs ayant une compatibilite elevee selon votre profil et vos preferences ;\\n(c) consultation et recherche de profils : vous pouvez consulter et filtrer les profils publics d autres utilisateurs dans le cadre de la Plateforme ;\\n(d) service d introduction privee : les conseillers de la Plateforme fournissent des introductions ciblees selon la situation des deux parties ;\\n(e) evenements hors ligne : la Plateforme organise regulierement des evenements de rencontre auxquels vous pouvez vous inscrire ;\\n(f) service de conseil : les conseillers peuvent fournir consultation, optimisation de profil, suivi de mise en relation et services connexes."},{"number":"3.2","body":"La Plateforme se reserve le droit d ajuster, d ajouter ou de supprimer des services selon ses besoins operationnels. Les ajustements importants seront annonces sur la Plateforme 7 jours a l avance."}],"sortOrder":3},{"heading":"Article 4 Abonnement et services payants","clauses":[{"number":"4.1","body":"La Plateforme propose des services de base gratuits et des services d abonnement payants. Les utilisateurs gratuits peuvent acceder aux fonctions de base. Les membres payants beneficient de droits supplementaires, tels que quotas d introduction privee augmentes, priorite d inscription aux evenements et service de conseiller dedie."},{"number":"4.2","body":"Les formules et prix d abonnement sont ceux publies par la Plateforme. La Plateforme peut ajuster le contenu et le prix des formules. Les formules deja achetees avant l ajustement ne sont pas affectees."},{"number":"4.3","body":"Sauf disposition legale contraire, les frais d abonnement deja payes ne sont pas remboursables."},{"number":"4.4","body":"A l expiration de votre abonnement, votre compte revient aux autorisations d utilisateur gratuit. La Plateforme se reserve le droit de vous rappeler le renouvellement avant expiration."}],"sortOrder":4},{"heading":"Article 5 Regles de conduite des utilisateurs","clauses":[{"number":"5.1","body":"Vous vous engagez a respecter les regles suivantes lors de l utilisation de la Plateforme :\\n(a) respecter les lois et reglements de la Republique populaire de Chine et les lois applicables de votre lieu de residence ;\\n(b) respecter l ordre public, les bonnes moeurs et les droits legitimes d autrui ;\\n(c) publier des informations veridiques, legales et exactes, sans fabriquer de fausse identite, age, situation matrimoniale, profession ou information similaire ;\\n(d) ne pas utiliser la Plateforme pour des activites illegales ou non conformes, y compris notamment fraude, systeme pyramidal, jeux d argent ou services sexuels."},{"number":"5.2","body":"Les comportements interdits comprennent notamment :\\n(a) harceler, insulter, menacer ou suivre d autres utilisateurs ;\\n(b) collecter, stocker ou diffuser les informations personnelles d autres utilisateurs sans autorisation ;\\n(c) publier de la publicite commerciale, du spam ou du contenu sans lien avec les rencontres ;\\n(d) contourner la Plateforme pour realiser des transactions privees ou des transferts d argent ;\\n(e) utiliser des moyens techniques pour perturber le fonctionnement normal de la Plateforme, tels que robots d exploration, manipulation de trafic ou attaques par injection ;\\n(f) utiliser le nom de la Plateforme sans autorisation ou se faire passer pour un membre du personnel de la Plateforme."}],"sortOrder":5},{"heading":"Article 6 Verification et traitement du contenu","clauses":[{"number":"6.1","body":"La Plateforme a le droit de verifier les informations, photos, textes et autres contenus publies par les utilisateurs. Les criteres de verification comprennent notamment authenticite, legalite et conformite."},{"number":"6.2","body":"Si un contenu que vous publiez viole les presentes Conditions ou les lois et reglements applicables, la Plateforme peut prendre une ou plusieurs des mesures suivantes :\\n(a) vous demander de modifier ou supprimer le contenu non conforme dans un delai determine ;\\n(b) limiter temporairement ou definitivement votre droit de publier du contenu ;\\n(c) suspendre temporairement ou fermer definitivement votre compte ;\\n(d) signaler la situation aux autorites competentes ;\\n(e) se reserver le droit d engager votre responsabilite juridique."},{"number":"6.3","body":"La verification du contenu par la Plateforme ne signifie pas que la Plateforme reconnait son authenticite ou sa legalite. Les utilisateurs assument seuls la responsabilite juridique du contenu qu ils publient."}],"sortOrder":6},{"heading":"Article 7 Protection de la vie privee","clauses":[{"number":"7.1","body":"La Plateforme attache une grande importance a la protection de votre vie privee. Vos informations personnelles sont collectees, utilisees et protegees conformement a la Politique de confidentialite. La Politique de confidentialite fait partie integrante des presentes Conditions."},{"number":"7.2","body":"Sans votre consentement explicite, la Plateforme ne divulguera pas vos coordonnees, telles que telephone, email ou identifiant WeChat, a des tiers. Apres une introduction privee reussie, les coordonnees ne peuvent etre echangees qu avec confirmation des deux parties."},{"number":"7.3","body":"Vous autorisez la Plateforme a utiliser vos informations de profil dans les limites suivantes :\\n(a) afficher votre profil sur la Plateforme selon vos parametres de confidentialite ;\\n(b) montrer votre profil aux conseillers de la Plateforme afin de fournir le service de mise en relation ;\\n(c) vous recommander d autres utilisateurs avec une compatibilite elevee ;\\n(d) ameliorer et optimiser les services de la Plateforme apres anonymisation."}],"sortOrder":7},{"heading":"Article 8 Propriete intellectuelle","clauses":[{"number":"8.1","body":"Tous les contenus de la Plateforme, y compris notamment textes, images, icones, conception d interface, code logiciel et compilations de donnees, sont proteges par les lois relatives a la propriete intellectuelle. Nul ne peut copier, modifier, diffuser ou utiliser ces contenus sans autorisation ecrite de la Plateforme."},{"number":"8.2","body":"Vous conservez la propriete des contenus que vous publiez sur la Plateforme, tels que photos et textes. Vous accordez a la Plateforme une licence non exclusive pour utiliser, afficher et distribuer ces contenus dans le cadre de la Plateforme afin de vous fournir les services."},{"number":"8.3","body":"Vous garantissez que les contenus que vous publiez sur la Plateforme ne portent pas atteinte aux droits de propriete intellectuelle ou autres droits legitimes de tiers. Si la Plateforme subit un prejudice de ce fait, vous devrez l indemniser."}],"sortOrder":8},{"heading":"Article 9 Exclusions de responsabilite","clauses":[{"number":"9.1","body":"En tant que plateforme d information et de mise en relation matrimoniale, la Plateforme s efforce de fournir des services authentiques et fiables, mais n assume pas de responsabilite dans les cas suivants :\\n(a) la Plateforme ne garantit pas qu une recommandation ou un evenement aboutira necessairement a une relation amoureuse ou a un mariage ;\\n(b) la Plateforme ne garantit pas l exactitude ou l exhaustivite des informations publiees directement par les utilisateurs ;\\n(c) les interactions hors ligne et transferts d argent entre utilisateurs relevent de leur propre evaluation des risques et de leur propre responsabilite."},{"number":"9.2","body":"La Plateforme n est pas responsable des interruptions de service ou pertes de donnees causees par un cas de force majeure, tel que catastrophe naturelle, guerre, changement de politique ou cyberattaque, mais elle retablira les services dans un delai raisonnable."},{"number":"9.3","body":"Vous devez faire preuve de discernement lors de vos interactions avec d autres utilisateurs et veiller a votre securite personnelle et patrimoniale. La Plateforme recommande que la premiere rencontre hors ligne ait lieu dans un endroit public."}],"sortOrder":9},{"heading":"Article 10 Responsabilite pour violation et indemnisation","clauses":[{"number":"10.1","body":"Si vous violez les presentes Conditions et causez un prejudice a la Plateforme ou a un tiers, vous devez assumer la responsabilite d indemnisation correspondante."},{"number":"10.2","body":"La responsabilite d indemnisation de la Plateforme est limitee aux pertes directes et ne peut depasser le montant total des frais que vous avez payes a la Plateforme au cours des 12 derniers mois."},{"number":"10.3","body":"Aucune disposition des presentes Conditions ne limite ou exclut une responsabilite lorsque la loi interdit une telle limitation ou exclusion."}],"sortOrder":10},{"heading":"Article 11 Modification des Conditions","clauses":[{"number":"11.1","body":"La Plateforme peut modifier les presentes Conditions si necessaire. Les Conditions modifiees seront publiees sur la Plateforme. La poursuite de l utilisation des services apres publication vaut acceptation des Conditions modifiees."},{"number":"11.2","body":"Si vous n acceptez pas les Conditions modifiees, vous devez cesser d utiliser les services de la Plateforme et supprimer votre compte."},{"number":"11.3","body":"En cas de modification importante des Conditions, la Plateforme vous en informera 7 jours a l avance par message interne ou email."}],"sortOrder":11},{"heading":"Article 12 Loi applicable et reglement des litiges","clauses":[{"number":"12.1","body":"La formation, l execution et l interpretation des presentes Conditions sont regies par les lois de la Republique populaire de Chine."},{"number":"12.2","body":"Tout litige decoulant des presentes Conditions ou s y rapportant doit d abord etre resolu par consultation amiable. A defaut d accord, chaque partie peut saisir le tribunal populaire competent du lieu ou se trouve l operateur de la Plateforme."},{"number":"12.3","body":"L invalidite d une partie des presentes Conditions n affecte pas la validite des autres dispositions."}],"sortOrder":12}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('e6527e8a-6c1f-5bea-aa8b-3cf678fbdd1e', '85a634d2-f126-5d90-be6d-d550f2b920fc', 'zh', 'Cupid Match 隐私说明', '[{"heading":"第一条 我们收集的信息","clauses":[{"number":"1.1","body":"账号信息：注册时收集的姓名、手机号或邮箱、登录密码（加密存储）。"},{"number":"1.2","body":"个人资料信息：您主动填写的婚恋资料，包括但不限于性别、出生年份、身高、所在城市、学历、行业、职业方向、婚姻状态、子女情况、交友意向、择偶偏好、生活习惯、个性特征、个人简介、标签等。"},{"number":"1.3","body":"照片与媒体：您上传的个人照片。平台可能对照片进行审核以确保符合平台规范。"},{"number":"1.4","body":"认证信息：实名认证、学历认证、婚姻状态认证时提交的身份证件、学历证明、法律文件等。"},{"number":"1.5","body":"联系方式：您的手机号、邮箱、微信号。联系方式仅用于账号安全和私人介绍成功后的双方交换，不会公开在您的资料页。"},{"number":"1.6","body":"行为数据：您在平台上的浏览记录、收藏记录、活动报名记录、私人介绍申请记录、顾问沟通记录等。"},{"number":"1.7","body":"设备信息：您访问平台时使用的设备类型、操作系统、IP 地址、浏览器类型等。"},{"number":"1.8","body":"支付信息：您购买会员时的支付凭证。平台不直接存储您的银行卡号或支付密码，支付由第三方支付服务商处理。"}],"sortOrder":1},{"heading":"第二条 信息使用方式","clauses":[{"number":"2.1","body":"平台使用您的信息用于以下目的：\\n（a）创建和管理您的账号；\\n（b）提供婚恋匹配推荐服务；\\n（c）优化推荐算法和用户体验；\\n（d）组织和协调线下活动；\\n（e）提供顾问撮合和跟进服务；\\n（f）处理您的支付和会员事务；\\n（g）保障平台安全，防范欺诈和滥用；\\n（h）遵守法律法规要求。"},{"number":"2.2","body":"平台不会使用您的个人信息进行自动化决策，导致对您产生法律效力或类似重大影响。"},{"number":"2.3","body":"平台可能对收集的信息进行匿名化或去标识化处理后，用于统计分析、服务改进和商业规划。此类处理后信息不再属于个人信息。"}],"sortOrder":2},{"heading":"第三条 信息存储与跨境传输","clauses":[{"number":"3.1","body":"您的个人信息存储在中华人民共和国境内的服务器上。"},{"number":"3.2","body":"如因服务需要将信息传输至境外，平台将按照法律法规要求进行安全评估，并取得您的单独同意。"},{"number":"3.3","body":"平台仅在实现服务目的所需的最短期限内保留您的个人信息。账号注销后，平台将在 30 日内删除或匿名化您的个人信息，法律另有规定的除外。"}],"sortOrder":3},{"heading":"第四条 信息安全保护","clauses":[{"number":"4.1","body":"平台采用行业标准的安全技术和组织措施保护您的个人信息，包括但不限于：\\n（a）数据传输采用 HTTPS/TLS 加密；\\n（b）密码采用单向哈希加盐存储；\\n（c）敏感个人信息加密存储；\\n（d）访问权限最小化原则，仅授权人员可访问必要的个人信息；\\n（e）定期安全审计和漏洞扫描。"},{"number":"4.2","body":"若发生个人信息安全事件，平台将按照法律法规要求及时告知您，并向主管部门报告。"},{"number":"4.3","body":"您应妥善保管登录凭证，避免在公共设备上保存登录状态，定期更换密码。"}],"sortOrder":4},{"heading":"第五条 信息共享与披露","clauses":[{"number":"5.1","body":"未经您明确同意，平台不会向第三方共享您的个人信息，以下情形除外：\\n（a）在您主动发起私人介绍且对方接受后，按双方确认范围交换联系方式；\\n（b）为完成支付，与第三方支付服务商共享必要的支付信息；\\n（c）法律法规要求或行政、司法机关依法提出请求；\\n（d）为保护平台、用户或公众的合法权益免受损害。"},{"number":"5.2","body":"平台与第三方服务商合作时，将通过合同要求其遵守不低于本政策标准的数据保护义务。"},{"number":"5.3","body":"除上述情形外，平台不会向任何第三方出售、出租或以其他方式提供您的个人信息。"}],"sortOrder":5},{"heading":"第六条 您的权利","clauses":[{"number":"6.1","body":"查阅权：您可以在账户设置中随时查看您提供的个人信息。"},{"number":"6.2","body":"更正权：如您的个人信息发生变化或有误，您可以在账户设置中自行修改。部分认证信息修改需经平台审核。"},{"number":"6.3","body":"删除权：您可以在账户设置中删除您的部分信息。您也可以申请注销账号，账号注销后所有个人信息将被删除或匿名化。"},{"number":"6.4","body":"导出权：您可以申请导出您在平台上的个人数据副本，平台将在 15 个工作日内处理。"},{"number":"6.5","body":"撤回同意权：您可以通过修改隐私设置撤回对特定信息使用的同意。撤回同意不影响此前基于同意的信息处理的合法性。"},{"number":"6.6","body":"投诉权：如您认为平台处理您个人信息的行为侵犯了您的合法权益，您可以向平台投诉或向监管部门举报。"}],"sortOrder":6},{"heading":"第七条 Cookie 与同类技术","clauses":[{"number":"7.1","body":"平台使用 Cookie 和类似技术来识别您的登录状态、记住您的偏好设置、分析平台使用情况。"},{"number":"7.2","body":"您可以通过浏览器设置管理或删除 Cookie。但禁用 Cookie 可能导致部分功能无法使用。"},{"number":"7.3","body":"平台可能使用第三方分析服务（如百度统计）来了解用户使用情况，这些服务可能使用自己的 Cookie。"}],"sortOrder":7},{"heading":"第八条 未成年人保护","clauses":[{"number":"8.1","body":"平台仅向年满 18 周岁的用户提供服务。"},{"number":"8.2","body":"平台不会故意收集未满 18 周岁的未成年人的个人信息。如发现误收集，将立即删除。"},{"number":"8.3","body":"如果您是父母或监护人，且发现您的未成年子女向平台提供了个人信息，请立即联系我们。"}],"sortOrder":8},{"heading":"第九条 政策更新","clauses":[{"number":"9.1","body":"平台可能根据法律法规变化或服务调整更新本隐私政策。"},{"number":"9.2","body":"更新后的政策将在平台公布。重大变更将通过站内信或邮件通知您。"},{"number":"9.3","body":"您继续使用平台服务即表示您同意更新后的隐私政策。如您不同意，应停止使用并注销账号。"}],"sortOrder":9},{"heading":"第十条 联系我们","clauses":[{"number":"10.1","body":"如您对本隐私政策有任何疑问、意见或投诉，请通过以下方式联系我们：\\n\\n邮箱：privacy@cupidmatch.com\\n地址：[平台运营方注册地址]\\n客服电话：[客服电话号码]"},{"number":"10.2","body":"我们将在收到您的请求后 15 个工作日内回复。"}],"sortOrder":10}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('5390e1d4-1b72-5b90-b87e-2f582c9c216a', '85a634d2-f126-5d90-be6d-d550f2b920fc', 'en', 'Cupid Match Privacy Notice', '[{"heading":"Article 1 Information We Collect","clauses":[{"number":"1.1","body":"Account information: name, phone number or email address, and login password collected during registration. Passwords are stored in encrypted form."},{"number":"1.2","body":"Profile information: matchmaking profile information you voluntarily provide, including but not limited to gender, year of birth, height, city, education, industry, career direction, marital status, children-related information, relationship intention, partner preferences, lifestyle, personality traits, personal introduction, and tags."},{"number":"1.3","body":"Photos and media: personal photos uploaded by you. The Platform may review photos to ensure compliance with Platform rules."},{"number":"1.4","body":"Verification information: identity documents, education certificates, legal documents, and other materials submitted for identity, education, or marital status verification."},{"number":"1.5","body":"Contact details: your phone number, email address, and WeChat ID. Contact details are used only for account security and exchange after a successful private introduction, and will not be publicly displayed on your profile page."},{"number":"1.6","body":"Behavior data: browsing records, favorites, event registration records, private introduction request records, advisor communication records, and similar Platform activity data."},{"number":"1.7","body":"Device information: device type, operating system, IP address, browser type, and similar information when you access the Platform."},{"number":"1.8","body":"Payment information: payment proof generated when you purchase membership. The Platform does not directly store your bank card number or payment password. Payments are processed by third-party payment service providers."}],"sortOrder":1},{"heading":"Article 2 How We Use Information","clauses":[{"number":"2.1","body":"The Platform uses your information for the following purposes:\\n(a) creating and managing your account;\\n(b) providing matchmaking recommendations;\\n(c) optimizing recommendation algorithms and user experience;\\n(d) organizing and coordinating offline events;\\n(e) providing advisor matchmaking and follow-up services;\\n(f) handling payment and membership matters;\\n(g) protecting Platform security and preventing fraud and abuse;\\n(h) complying with laws and regulations."},{"number":"2.2","body":"The Platform will not use your personal information for automated decision-making that produces legal effects or similarly significant impacts on you."},{"number":"2.3","body":"The Platform may anonymize or de-identify collected information and use it for statistical analysis, service improvement, and business planning. Information processed in this way no longer constitutes personal information."}],"sortOrder":2},{"heading":"Article 3 Information Storage and Cross-Border Transfer","clauses":[{"number":"3.1","body":"Your personal information is stored on servers located within the territory of the People’s Republic of China."},{"number":"3.2","body":"If service needs require information to be transferred overseas, the Platform will conduct security assessments and obtain your separate consent in accordance with applicable laws and regulations."},{"number":"3.3","body":"The Platform retains your personal information only for the minimum period necessary to achieve the service purposes. After account cancellation, the Platform will delete or anonymize your personal information within 30 days, unless otherwise required by law."}],"sortOrder":3},{"heading":"Article 4 Information Security","clauses":[{"number":"4.1","body":"The Platform adopts industry-standard technical and organizational security measures to protect your personal information, including but not limited to:\\n(a) HTTPS/TLS encryption for data transmission;\\n(b) one-way salted hashing for password storage;\\n(c) encrypted storage of sensitive personal information;\\n(d) least-privilege access control, with only authorized personnel able to access necessary personal information;\\n(e) regular security audits and vulnerability scans."},{"number":"4.2","body":"If a personal information security incident occurs, the Platform will notify you and report to competent authorities in accordance with laws and regulations."},{"number":"4.3","body":"You should keep your login credentials secure, avoid saving login status on public devices, and change your password regularly."}],"sortOrder":4},{"heading":"Article 5 Information Sharing and Disclosure","clauses":[{"number":"5.1","body":"Without your express consent, the Platform will not share your personal information with third parties, except in the following circumstances:\\n(a) after you initiate a private introduction and the other party accepts, contact details are exchanged within the scope confirmed by both parties;\\n(b) necessary payment information is shared with third-party payment service providers to complete payment;\\n(c) laws and regulations require disclosure, or administrative or judicial authorities make lawful requests;\\n(d) disclosure is necessary to protect the lawful rights and interests of the Platform, users, or the public from harm."},{"number":"5.2","body":"When the Platform cooperates with third-party service providers, it will require them by contract to comply with data protection obligations no less protective than this policy."},{"number":"5.3","body":"Except for the circumstances above, the Platform will not sell, rent, or otherwise provide your personal information to any third party."}],"sortOrder":5},{"heading":"Article 6 Your Rights","clauses":[{"number":"6.1","body":"Right of access: You may view the personal information you provided at any time in account settings."},{"number":"6.2","body":"Right of correction: If your personal information changes or is inaccurate, you may modify it in account settings. Changes to certain verification information require Platform review."},{"number":"6.3","body":"Right of deletion: You may delete part of your information in account settings. You may also apply to cancel your account. After account cancellation, all personal information will be deleted or anonymized."},{"number":"6.4","body":"Right of export: You may request a copy of your personal data on the Platform. The Platform will process the request within 15 working days."},{"number":"6.5","body":"Right to withdraw consent: You may withdraw consent for specific information use by modifying privacy settings. Withdrawal of consent does not affect the lawfulness of information processing conducted before withdrawal."},{"number":"6.6","body":"Right to complain: If you believe the Platform’s handling of your personal information infringes your lawful rights and interests, you may file a complaint with the Platform or report to regulatory authorities."}],"sortOrder":6},{"heading":"Article 7 Cookies and Similar Technologies","clauses":[{"number":"7.1","body":"The Platform uses cookies and similar technologies to identify your login status, remember your preferences, and analyze Platform usage."},{"number":"7.2","body":"You may manage or delete cookies through browser settings. However, disabling cookies may cause some functions to become unavailable."},{"number":"7.3","body":"The Platform may use third-party analytics services, such as Baidu Analytics, to understand user usage. These services may use their own cookies."}],"sortOrder":7},{"heading":"Article 8 Protection of Minors","clauses":[{"number":"8.1","body":"The Platform provides services only to users who are at least 18 years old."},{"number":"8.2","body":"The Platform does not knowingly collect personal information from minors under 18. If such information is discovered to have been collected by mistake, it will be deleted immediately."},{"number":"8.3","body":"If you are a parent or guardian and discover that your minor child has provided personal information to the Platform, please contact us immediately."}],"sortOrder":8},{"heading":"Article 9 Policy Updates","clauses":[{"number":"9.1","body":"The Platform may update this Privacy Policy according to changes in laws and regulations or service adjustments."},{"number":"9.2","body":"The updated policy will be published on the Platform. Material changes will be notified to you by in-app message or email."},{"number":"9.3","body":"Your continued use of Platform services means that you agree to the updated Privacy Policy. If you do not agree, you should stop using the services and cancel your account."}],"sortOrder":9},{"heading":"Article 10 Contact Us","clauses":[{"number":"10.1","body":"If you have any questions, comments, or complaints about this Privacy Policy, please contact us through the following methods:\\n\\nEmail: privacy@cupidmatch.com\\nAddress: [Registered address of the Platform operator]\\nCustomer service phone: [Customer service phone number]"},{"number":"10.2","body":"We will respond within 15 working days after receiving your request."}],"sortOrder":10}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('ae2ecb72-bbcd-5218-b156-62c646a2e380', '85a634d2-f126-5d90-be6d-d550f2b920fc', 'fr', 'Politique de confidentialite Cupid Match', '[{"heading":"Article 1 Informations que nous collectons","clauses":[{"number":"1.1","body":"Informations de compte : nom, numero de telephone ou adresse email, et mot de passe de connexion collectes lors de l inscription. Les mots de passe sont stockes sous forme chiffree."},{"number":"1.2","body":"Informations de profil : donnees de rencontre que vous fournissez volontairement, y compris notamment sexe, annee de naissance, taille, ville, education, secteur, orientation professionnelle, situation matrimoniale, informations relatives aux enfants, intention relationnelle, preferences de partenaire, mode de vie, traits de personnalite, presentation personnelle et etiquettes."},{"number":"1.3","body":"Photos et medias : photos personnelles que vous televersez. La Plateforme peut verifier les photos afin de garantir leur conformite aux regles de la Plateforme."},{"number":"1.4","body":"Informations de verification : documents d identite, justificatifs de diplome, documents juridiques et autres elements soumis lors de la verification d identite, d education ou de situation matrimoniale."},{"number":"1.5","body":"Coordonnees : votre numero de telephone, adresse email et identifiant WeChat. Les coordonnees servent uniquement a la securite du compte et a l echange apres une introduction privee reussie. Elles ne sont pas affichees publiquement sur votre page de profil."},{"number":"1.6","body":"Donnees comportementales : historiques de consultation, favoris, inscriptions aux evenements, demandes d introduction privee, communications avec les conseillers et donnees similaires d activite sur la Plateforme."},{"number":"1.7","body":"Informations sur l appareil : type d appareil, systeme d exploitation, adresse IP, type de navigateur et informations similaires lorsque vous accedez a la Plateforme."},{"number":"1.8","body":"Informations de paiement : justificatifs de paiement generes lors de l achat d un abonnement. La Plateforme ne stocke pas directement votre numero de carte bancaire ni votre mot de passe de paiement. Les paiements sont traites par des prestataires tiers de paiement."}],"sortOrder":1},{"heading":"Article 2 Utilisation des informations","clauses":[{"number":"2.1","body":"La Plateforme utilise vos informations aux fins suivantes :\\n(a) creer et gerer votre compte ;\\n(b) fournir des recommandations de mise en relation ;\\n(c) optimiser les algorithmes de recommandation et l experience utilisateur ;\\n(d) organiser et coordonner les evenements hors ligne ;\\n(e) fournir des services de conseil, de mise en relation et de suivi ;\\n(f) traiter les paiements et les questions d abonnement ;\\n(g) proteger la securite de la Plateforme et prevenir la fraude et les abus ;\\n(h) respecter les lois et reglements applicables."},{"number":"2.2","body":"La Plateforme n utilisera pas vos informations personnelles pour prendre des decisions automatisees produisant des effets juridiques ou des effets similaires significatifs a votre egard."},{"number":"2.3","body":"La Plateforme peut anonymiser ou de-identifier les informations collectees et les utiliser pour des analyses statistiques, l amelioration des services et la planification commerciale. Les informations ainsi traitees ne constituent plus des informations personnelles."}],"sortOrder":2},{"heading":"Article 3 Stockage et transfert transfrontalier","clauses":[{"number":"3.1","body":"Vos informations personnelles sont stockees sur des serveurs situes sur le territoire de la Republique populaire de Chine."},{"number":"3.2","body":"Si les besoins du service exigent un transfert d informations a l etranger, la Plateforme procedera aux evaluations de securite requises par les lois et reglements et obtiendra votre consentement separe."},{"number":"3.3","body":"La Plateforme conserve vos informations personnelles uniquement pendant la duree minimale necessaire a la realisation des finalites du service. Apres suppression du compte, la Plateforme supprimera ou anonymisera vos informations personnelles dans un delai de 30 jours, sauf disposition legale contraire."}],"sortOrder":3},{"heading":"Article 4 Securite des informations","clauses":[{"number":"4.1","body":"La Plateforme adopte des mesures techniques et organisationnelles conformes aux standards du secteur pour proteger vos informations personnelles, y compris notamment :\\n(a) chiffrement HTTPS/TLS pour la transmission des donnees ;\\n(b) stockage des mots de passe par hachage sale a sens unique ;\\n(c) stockage chiffre des informations personnelles sensibles ;\\n(d) controle d acces selon le principe du moindre privilege, seuls les personnels autorises pouvant acceder aux informations necessaires ;\\n(e) audits de securite et analyses de vulnerabilite reguliers."},{"number":"4.2","body":"En cas d incident de securite concernant des informations personnelles, la Plateforme vous informera et le signalera aux autorites competentes conformement aux lois et reglements."},{"number":"4.3","body":"Vous devez proteger vos identifiants de connexion, eviter de conserver une session ouverte sur un appareil public et changer regulierement votre mot de passe."}],"sortOrder":4},{"heading":"Article 5 Partage et divulgation des informations","clauses":[{"number":"5.1","body":"Sans votre consentement explicite, la Plateforme ne partagera pas vos informations personnelles avec des tiers, sauf dans les cas suivants :\\n(a) apres votre demande d introduction privee et l acceptation par l autre partie, les coordonnees sont echangees dans la limite confirmee par les deux parties ;\\n(b) les informations de paiement necessaires sont partagees avec un prestataire tiers de paiement pour finaliser le paiement ;\\n(c) la loi ou la reglementation l exige, ou une autorite administrative ou judiciaire en fait la demande legalement ;\\n(d) le partage est necessaire pour proteger les droits et interets legitimes de la Plateforme, des utilisateurs ou du public contre un dommage."},{"number":"5.2","body":"Lorsque la Plateforme coopere avec des prestataires tiers, elle leur impose contractuellement des obligations de protection des donnees au moins equivalentes a celles de la presente politique."},{"number":"5.3","body":"Sauf dans les situations ci-dessus, la Plateforme ne vendra, louera ni fournira autrement vos informations personnelles a aucun tiers."}],"sortOrder":5},{"heading":"Article 6 Vos droits","clauses":[{"number":"6.1","body":"Droit d acces : vous pouvez consulter a tout moment les informations personnelles que vous avez fournies dans les parametres du compte."},{"number":"6.2","body":"Droit de rectification : si vos informations personnelles changent ou sont inexactes, vous pouvez les modifier dans les parametres du compte. Certaines informations de verification doivent etre examinees par la Plateforme."},{"number":"6.3","body":"Droit de suppression : vous pouvez supprimer une partie de vos informations dans les parametres du compte. Vous pouvez egalement demander la suppression de votre compte. Apres suppression du compte, toutes les informations personnelles seront supprimees ou anonymisees."},{"number":"6.4","body":"Droit d exportation : vous pouvez demander une copie de vos donnees personnelles sur la Plateforme. La Plateforme traitera la demande dans un delai de 15 jours ouvrables."},{"number":"6.5","body":"Droit de retrait du consentement : vous pouvez retirer votre consentement a certaines utilisations des informations en modifiant vos parametres de confidentialite. Le retrait du consentement n affecte pas la legalite des traitements effectues avant le retrait."},{"number":"6.6","body":"Droit de plainte : si vous estimez que le traitement de vos informations personnelles par la Plateforme porte atteinte a vos droits et interets legitimes, vous pouvez deposer une plainte aupres de la Plateforme ou signaler le fait aux autorites de controle."}],"sortOrder":6},{"heading":"Article 7 Cookies et technologies similaires","clauses":[{"number":"7.1","body":"La Plateforme utilise des cookies et technologies similaires pour identifier votre etat de connexion, memoriser vos preferences et analyser l utilisation de la Plateforme."},{"number":"7.2","body":"Vous pouvez gerer ou supprimer les cookies via les parametres du navigateur. Toutefois, la desactivation des cookies peut rendre certaines fonctions indisponibles."},{"number":"7.3","body":"La Plateforme peut utiliser des services d analyse tiers, tels que Baidu Analytics, pour comprendre l utilisation par les utilisateurs. Ces services peuvent utiliser leurs propres cookies."}],"sortOrder":7},{"heading":"Article 8 Protection des mineurs","clauses":[{"number":"8.1","body":"La Plateforme fournit ses services uniquement aux utilisateurs ages d au moins 18 ans."},{"number":"8.2","body":"La Plateforme ne collecte pas sciemment les informations personnelles de mineurs de moins de 18 ans. Si une telle collecte par erreur est constatee, les informations seront supprimees immediatement."},{"number":"8.3","body":"Si vous etes parent ou tuteur et constatez que votre enfant mineur a fourni des informations personnelles a la Plateforme, veuillez nous contacter immediatement."}],"sortOrder":8},{"heading":"Article 9 Mise a jour de la politique","clauses":[{"number":"9.1","body":"La Plateforme peut mettre a jour la presente Politique de confidentialite selon les changements de lois et reglements ou les ajustements de service."},{"number":"9.2","body":"La politique mise a jour sera publiee sur la Plateforme. Les changements importants vous seront notifies par message interne ou email."},{"number":"9.3","body":"La poursuite de l utilisation des services de la Plateforme vaut acceptation de la Politique de confidentialite mise a jour. Si vous n acceptez pas, vous devez cesser d utiliser les services et supprimer votre compte."}],"sortOrder":9},{"heading":"Article 10 Nous contacter","clauses":[{"number":"10.1","body":"Pour toute question, suggestion ou plainte concernant la presente Politique de confidentialite, vous pouvez nous contacter par les moyens suivants :\\n\\nEmail : privacy@cupidmatch.com\\nAdresse : [Adresse d enregistrement de l operateur de la Plateforme]\\nTelephone du service client : [Numero du service client]"},{"number":"10.2","body":"Nous repondrons dans un delai de 15 jours ouvrables apres reception de votre demande."}],"sortOrder":10}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00');

-- 3A.8 User agreement acceptances
insert into cm_user_agreement_acceptances (id, user_id, document_type, document_version, accepted_at, created_at) values
  ('4757b4e9-0b69-5c9e-ba64-0cee9c6ac4f5', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'terms', '1.0', '2026-05-15 22:13:49', '2026-05-15 22:13:49'),
  ('46464343-a0da-5394-afcd-870960046e79', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'privacy', '1.0', '2026-05-15 22:13:49', '2026-05-15 22:13:49');

-- 3B.1 cm_profiles (Phase 8.2.4: added 5 new columns between industry_code and marital_status)
insert into cm_profiles (id, profile_type, gender, birth_year, height, city_code, country_code, nationality_code, profile_status, last_active_at, family_visible, degree_level, education_code, industry_code, relationship_goal_code, residence_plan_code, preferred_education_code, family_life_code, exercise_code, marital_status, has_children, children_plan, accepts_long_distance, dating_intention_code, relocation, preferred_age_min, preferred_age_max, preferred_location, smoking, drinking, activity_level, weekend_style, pets, communication_style, archived_at, created_at, updated_at) values
  ('506ce3c7-b236-5b44-b8d0-459c4250ea03', 'self', 'female', 1995, 168, 'FR:paris', 'FR', 'FR', 'open', '2026-04-20 18:30:00', 0, 'master', 'master_general', 'other', 'other', 'other', 'other', 'other', 'other', 'never_married', 0, 'wants', 1, 'serious', 'willing', 28, 40, 'regional', 'never', 'social', 'high', 'flexible', 'likes', 'direct', null, '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'self', 'male', 1992, 178, 'FR:paris', 'FR', 'CN', 'open', '2026-04-22 09:00:00', 1, 'master', 'master_general', 'technology', 'other', 'other', 'other', 'other', 'other', 'never_married', 0, 'wants', 1, 'marriage', 'willing', 28, 40, 'regional', 'never', 'social', 'high', 'flexible', 'likes', 'direct', null, '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('d7a4c336-b6f4-5079-a4ad-c47b4044a740', 'self', 'female', 1990, 170, 'FR:paris', 'FR', 'FR', 'review', '2026-04-21 20:30:00', 1, 'phd', 'other', 'other', 'other', 'other', 'other', 'other', 'other', 'divorced', 1, 'does_not_want', 1, 'exclusive', 'willing', 28, 40, 'regional', 'never', 'social', 'low', 'flexible', 'likes', 'direct', null, '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'self', 'male', 1991, 174, 'CH:geneva', 'CH', 'CH', 'open', '2026-04-25 07:50:00', 1, 'master', 'master_general', 'finance', 'other', 'other', 'other', 'other', 'other', 'never_married', 0, 'wants', 1, 'cross_border', 'willing', 28, 40, 'regional', 'never', 'social', 'high', 'flexible', 'likes', 'direct', null, '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'self', 'female', 1993, 171, 'NL:amsterdam', 'NL', 'NL', 'open', '2026-04-21 10:45:00', 1, 'master', 'master_general', 'other', 'other', 'other', 'other', 'other', 'other', 'divorced', 0, 'wants', 1, 'serious', 'willing', 28, 40, 'regional', 'never', 'social', 'moderate', 'flexible', 'likes', 'direct', null, '2026-02-14 00:00:00', '2026-04-21 10:45:00');

-- 3B.2 cm_profile_languages
insert into cm_profile_languages (profile_id, language_code) values
  ('506ce3c7-b236-5b44-b8d0-459c4250ea03', 'FR'),
  ('506ce3c7-b236-5b44-b8d0-459c4250ea03', 'EN'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'ZH'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'FR'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'EN'),
  ('d7a4c336-b6f4-5079-a4ad-c47b4044a740', 'FR'),
  ('d7a4c336-b6f4-5079-a4ad-c47b4044a740', 'EN'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'FR'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'EN'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'DE'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'EN'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'NL'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'FR');

-- 3B.3 cm_profile_relationship_values
insert into cm_profile_relationship_values (profile_id, value_code) values
  ('506ce3c7-b236-5b44-b8d0-459c4250ea03', 'honesty'),
  ('506ce3c7-b236-5b44-b8d0-459c4250ea03', 'growth'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'loyalty'),
  ('503a9c99-2842-54db-8858-24fbd3108e3b', 'support'),
  ('d7a4c336-b6f4-5079-a4ad-c47b4044a740', 'respect'),
  ('d7a4c336-b6f4-5079-a4ad-c47b4044a740', 'communication'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'family'),
  ('7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'trust'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'respect'),
  ('f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'communication');

-- 3C.1 cm_profile_localized_fields (Phase 8.2.4: ONLY profile_name, career_direction, summary)
insert into cm_profile_localized_fields (id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('13b171ee-b159-5b8d-9664-e1e233dfc855', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'profile_name', 'zh', '', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-24 00:00:00'),
  ('2d90a2e8-6303-567a-babf-43e580480a61', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'profile_name', 'fr', '', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-24 00:00:00'),
  ('9009f810-bb96-5004-8616-b233aaa18c11', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'profile_name', 'en', '', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-24 00:00:00'),
  ('58024103-1dc2-5d47-8fb7-364cc7cf3845', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'career_direction', 'zh', '品牌策略', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4452c68b-c089-5d77-abc4-3427ea22e431', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'career_direction', 'fr', 'Strategie de marque', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('9a9d75ee-6172-5b75-be64-5a047844f6ab', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'career_direction', 'en', 'Brand strategist', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('8a3f876a-6225-55a1-bea6-be0176dc202f', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'summary', 'zh', '重视表达、节奏和跨文化理解。', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('a1410e30-c32b-5f70-9774-25b5c78217cb', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'summary', 'fr', 'Attentive a la communication, au rythme et a la comprehension interculturelle.', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('20fe4256-d922-55eb-b03a-abc1b8aea433', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'summary', 'en', 'Values communication, pacing, and intercultural understanding.', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('52b18e22-9af2-5933-a11d-78c4fa3bff1b', '503a9c99-2842-54db-8858-24fbd3108e3b', 'profile_name', 'zh', 'Lin', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('25ab232d-05c5-5739-aa6c-32ccf63a7497', '503a9c99-2842-54db-8858-24fbd3108e3b', 'profile_name', 'fr', 'Profile Lin', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-24 00:00:00'),
  ('313cae33-f67f-5890-b8dd-d15d800b4514', '503a9c99-2842-54db-8858-24fbd3108e3b', 'profile_name', 'en', 'Lin profile', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-24 00:00:00'),
  ('27e96d3a-b2f2-562f-8430-06467d6f604e', '503a9c99-2842-54db-8858-24fbd3108e3b', 'career_direction', 'zh', '产品负责人', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('e00833d9-3d70-5561-9148-fba2207ad9a4', '503a9c99-2842-54db-8858-24fbd3108e3b', 'career_direction', 'fr', 'Responsable produit', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('49b14928-323b-5478-bcf4-fd508c9e7ddb', '503a9c99-2842-54db-8858-24fbd3108e3b', 'career_direction', 'en', 'Product lead', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('9c98ea72-5578-5804-8dca-0dea16aac841', '503a9c99-2842-54db-8858-24fbd3108e3b', 'summary', 'zh', '重视长期关系中的稳定、透明和行动力。', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('25ee86d8-56dc-5a01-b292-d489264eda40', '503a9c99-2842-54db-8858-24fbd3108e3b', 'summary', 'fr', 'Cherche de la stabilite, de la clarte et de l action dans une relation durable.', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('fc4455ae-ebc8-5339-8bb8-c654075414c3', '503a9c99-2842-54db-8858-24fbd3108e3b', 'summary', 'en', 'Values stability, clarity, and follow-through in a long-term relationship.', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('ede9cdb0-337d-5c5f-ad59-fe11c00e5c12', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'profile_name', 'zh', '', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-24 00:00:00'),
  ('c344497f-e98f-5ad9-b6d1-88bfbaf01044', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'profile_name', 'fr', '', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-24 00:00:00'),
  ('7e261815-231b-5a03-9836-a84100c16217', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'profile_name', 'en', '', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-24 00:00:00'),
  ('3b3189ef-c0f1-5155-a97a-2c815f2118a8', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'career_direction', 'zh', '公共政策研究员', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('fcffc6bc-7436-5bf8-b025-d24cf0afc20a', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'career_direction', 'fr', 'Chercheuse en politiques publiques', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('dec8ec20-e926-52bf-a9ec-1fefe90c78b8', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'career_direction', 'en', 'Public policy researcher', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('55ef25db-a4b2-52d1-9b41-6b1ecdc27879', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'summary', 'zh', '希望在成熟、清晰和尊重边界的前提下推进关系。', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0816d7c1-01c1-5d2f-aea4-fa235de5782f', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'summary', 'fr', 'Souhaite avancer dans un cadre mature, clair et respectueux des limites.', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('e256a23b-0f72-5501-b6c1-ccb72f8c1a3a', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'summary', 'en', 'Wants to move forward in a mature, clear, and boundary-respecting way.', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('d878c23a-d44d-510d-bb86-e94a76576cdb', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'profile_name', 'zh', '', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-24 00:00:00'),
  ('4d5de3f8-4c52-53ab-bbdd-58a064a6f995', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'profile_name', 'fr', '', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-24 00:00:00'),
  ('503bb249-d469-53ac-aad5-d0d1af413a2a', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'profile_name', 'en', '', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-24 00:00:00'),
  ('0e930ce3-44b5-58fb-9f0b-19401039a08f', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'career_direction', 'zh', '投融资经理', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('cd762bf5-bddd-5ecd-a8ae-8900fc76c2e8', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'career_direction', 'fr', 'Manager financement', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('f21d02e9-40c9-5f47-a62d-096919507932', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'career_direction', 'en', 'Finance manager', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('daeab0d8-8d71-5f9a-9d30-613486c575f1', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'summary', 'zh', '重视跨城市协同能力和长期执行力。', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('157d0ee0-3316-5d48-8c55-63db29de661d', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'summary', 'fr', 'Valorise la coordination entre villes et la capacite d execution.', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('1c5b61a6-09e8-5a2b-bbe3-39183809d05b', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'summary', 'en', 'Values cross-city coordination and long-term execution.', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('78b9ae00-772c-5154-b6b8-64ead275423c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'profile_name', 'zh', '', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-24 00:00:00'),
  ('283cd4b8-e803-506d-9298-d52427f0ccf0', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'profile_name', 'fr', '', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-24 00:00:00'),
  ('8d58ae14-4ca7-5060-b0c9-f7f976b0c5b4', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'profile_name', 'en', '', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-24 00:00:00'),
  ('86ed4159-d277-5fe3-9427-56ab8f60a304', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'career_direction', 'zh', '用户研究员', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('44f988a9-cb65-5445-9cdf-204d34653188', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'career_direction', 'fr', 'Chercheuse UX', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('4af68b24-506c-580f-b55c-09a4d4bad50c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'career_direction', 'en', 'UX researcher', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('5f612d53-753a-5374-a3a2-f9b771cf7f26', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'summary', 'zh', '重视生活一致性与沟通质量。', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('65959282-d45c-5fe6-85d8-413873eb8291', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'summary', 'fr', 'Attachee a la coherence de vie et a la qualite de communication.', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('dbe28286-d590-5427-90dc-57b3975fc5d6', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'summary', 'en', 'Values lifestyle consistency and communication quality.', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20');

-- 3D.1 cm_profile_option_extra_texts (Phase 8.2.4: moved from cm_profile_localized_fields)
insert into cm_profile_option_extra_texts (id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('4e70e287-f162-5299-a03f-eeb5390dfee0', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('c65deaec-a398-53e0-b2e8-ed79bc24c7c3', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('b3a86c83-af16-5b7c-b962-330977e2f430', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('0e0be4ec-1257-5d7a-b4d0-c501414f3ecf', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'industry', 'zh', '奢侈品', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('75d2bb45-d18f-57be-bec9-a7a219a83c20', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'industry', 'fr', 'Luxe', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('81b60cfe-a34e-53bb-afeb-468062d7adab', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'industry', 'en', 'Luxury', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('8e20a47d-65c6-5c03-b6ce-0c315c07748c', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'relationship_goal', 'zh', '一年内确认节奏', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('94d638c7-8a25-5081-aef3-d8c59cd2575a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'relationship_goal', 'fr', 'Clarifier le rythme sous un an', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('ba4bf557-ff69-5e46-b663-e196a4b6be40', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'relationship_goal', 'en', 'Clarify long-term pace within a year', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4b6531f3-9ab5-5d59-b5e4-ad850df89cd6', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'residence_plan', 'zh', '优先巴黎，也接受欧洲双城', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2f51835d-0714-5191-bfa7-bd4f0372246a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'residence_plan', 'fr', 'Paris en priorite, ouverte a une double ville en Europe', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('1e7d3b37-6e03-52b2-ae14-b4403448c047', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'residence_plan', 'en', 'Prefers Paris, open to a two-city setup in Europe', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('03e1f2bb-a584-55bc-b741-c8df5a978f8a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('b1bac649-581d-5327-ba3b-aa5bea7c97e7', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4f406ecf-c201-5516-b054-757eef5b4101', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('60cfd810-e44c-5f2d-8b60-510591607338', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('40c926c6-6ae6-5084-b428-c3fbc8c12a56', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4cef23f0-cc0e-5aa1-8144-38fddd73e518', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('8093a9d3-25ad-5ca6-9beb-61f212ad0fc9', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'exercise', 'zh', '每周瑜伽和步行', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2681fe86-aa0f-51b1-92c9-e4b285a450e5', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'exercise', 'fr', 'Yoga et marche chaque semaine', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('e8d1f95d-2832-5d54-8ebb-f47726f22619', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'exercise', 'en', 'Weekly yoga and walking', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('cfb798df-d5d8-561b-9436-ecdf9ad75da8', '503a9c99-2842-54db-8858-24fbd3108e3b', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('6673c574-99a5-5af3-a6f5-76d6b11c5840', '503a9c99-2842-54db-8858-24fbd3108e3b', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('48de2e20-662d-5af2-8d60-8354f558c83c', '503a9c99-2842-54db-8858-24fbd3108e3b', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('5c01edf1-45b3-5253-b90a-cdd96701d4cc', '503a9c99-2842-54db-8858-24fbd3108e3b', 'industry', 'zh', '科技', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('2ad075e6-808c-5110-b42c-0bd872aac784', '503a9c99-2842-54db-8858-24fbd3108e3b', 'industry', 'fr', 'Tech', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('22fac3e8-d831-57cb-ae8e-b0d5541d203e', '503a9c99-2842-54db-8858-24fbd3108e3b', 'industry', 'en', 'Technology', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('c0e81e04-6ff8-5352-a3c6-6bab2cae7904', '503a9c99-2842-54db-8858-24fbd3108e3b', 'relationship_goal', 'zh', '明确方向后稳步推进', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('84b09491-2f4d-5738-a815-73198214388b', '503a9c99-2842-54db-8858-24fbd3108e3b', 'relationship_goal', 'fr', 'Avancer de facon stable une fois l orientation clarifiee', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('39516afa-c5c9-54b5-a2d8-a479127fb30c', '503a9c99-2842-54db-8858-24fbd3108e3b', 'relationship_goal', 'en', 'Move steadily once long-term direction is clear', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('246e9e32-2a2a-5fb0-8c55-bf6e50106f9f', '503a9c99-2842-54db-8858-24fbd3108e3b', 'residence_plan', 'zh', '巴黎长期发展', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('37836562-fd88-5a70-8b8b-f5a652f33388', '503a9c99-2842-54db-8858-24fbd3108e3b', 'residence_plan', 'fr', 'Projet long terme a Paris', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('aecbaef9-0087-5464-b57f-1b03db382f9d', '503a9c99-2842-54db-8858-24fbd3108e3b', 'residence_plan', 'en', 'Long-term plan in Paris', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('4b732c26-2681-5215-8aa6-b33347e3aa45', '503a9c99-2842-54db-8858-24fbd3108e3b', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('1e0ff0bb-6fee-58da-96fe-f9c909e1be19', '503a9c99-2842-54db-8858-24fbd3108e3b', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('9da63b95-838f-5525-b0e1-bb6242578c83', '503a9c99-2842-54db-8858-24fbd3108e3b', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('53958c78-a60d-511d-80e0-9ac4e6bde4f1', '503a9c99-2842-54db-8858-24fbd3108e3b', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('8691cd21-dceb-50cf-bcbb-b11153cef4f8', '503a9c99-2842-54db-8858-24fbd3108e3b', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('02f06a86-4ce8-56e4-b5b5-8e1c38d40ffe', '503a9c99-2842-54db-8858-24fbd3108e3b', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('7c493dc6-6069-5e1c-ba33-43d0809f88cc', '503a9c99-2842-54db-8858-24fbd3108e3b', 'exercise', 'zh', '跑步和力量训练', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('bba70d5a-8c71-5186-89ff-7088b0ea65b1', '503a9c99-2842-54db-8858-24fbd3108e3b', 'exercise', 'fr', 'Course et renforcement', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('4c584a5e-a5fa-5e3d-bf76-61844c3f5612', '503a9c99-2842-54db-8858-24fbd3108e3b', 'exercise', 'en', 'Running and strength training', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('b0fea0a9-7ff6-5e3e-ad52-9fe8c184ec47', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'education', 'zh', '博士', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('1b33ee72-91c2-57ca-97d0-b8779776d3cd', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'education', 'fr', 'Doctorat', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0faaf556-8542-55cc-ac8c-d6205716c01a', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'education', 'en', 'PhD', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('e76cecc7-cd23-521f-9c57-45228f00085f', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'industry', 'zh', '公共事务', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0d9b2ecb-64f1-5ae1-bc73-5790225f0918', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'industry', 'fr', 'Affaires publiques', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('527f8239-f786-52a3-8f86-6dad50382b6d', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'industry', 'en', 'Public affairs', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('ac3dd044-42f7-5cf8-9adb-8bc9ba3c55c8', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'relationship_goal', 'zh', '先确认家庭节奏与城市安排', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('1289fbf8-2e32-540d-93af-d23c287b96c8', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'relationship_goal', 'fr', 'Verifier d abord le rythme familial et la logistique des villes', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('7e9bbc0d-5001-559f-addf-dd9d3c9092cb', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'relationship_goal', 'en', 'First confirm family rhythm and city logistics', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('3c38b18f-a801-5c75-82f4-cdcf272836c6', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'residence_plan', 'zh', '巴黎为主，也可双城', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('695ab81e-2ac6-5738-be4f-78d090e0c12d', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'residence_plan', 'fr', 'Paris prioritaire, possible double ville', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('55c14f7a-1095-5cd6-a08f-599735658373', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'residence_plan', 'en', 'Paris first, open to a two-city setup', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('26406b90-3705-5d98-b4d6-98145d4d793b', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('f194a1c2-83b5-5779-a40f-d7ad32bc87f5', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('15a80999-44cd-5388-b94e-676705824ba2', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('a5c35c39-d23e-5398-866d-a3c8c0696d2c', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('c49458d9-3b9f-564d-a24e-d61bd20e5bee', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('6e85e6b7-d50c-53c6-8379-49b4da48d9e6', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('7635cfe1-ea59-5c15-9c78-c0c0e068f498', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'exercise', 'zh', '步行和网球', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('7dea2da5-5d8f-53f6-9a18-d35b5c91c39b', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'exercise', 'fr', 'Marche et tennis', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('82866ad4-3421-595e-b2c2-c8fe239e3a91', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'exercise', 'en', 'Walking and tennis', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0cca6e29-e534-5d5e-a1b3-edcb02c9e907', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('efb2f04f-5b5b-54e1-b165-7177dde52b02', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('29ac3832-8304-53d4-bc0e-0ce05b935d47', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('0eb26d16-0ec4-5d19-becd-72911e4c0bae', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'industry', 'zh', '金融', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('8838a5df-fdd0-55c5-94a1-531721dcb72c', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'industry', 'fr', 'Finance', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('321e2e48-9b26-5270-afd5-64277956c5f9', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'industry', 'en', 'Finance', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('cdbb1e44-c636-5894-9dad-b5a43e491c08', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'relationship_goal', 'zh', '接受跨境安排，优先确定共同城市策略', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('9275ab86-88db-51a0-9727-adac6f70f7b7', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'relationship_goal', 'fr', 'Ouvert au transfrontalier avec strategie de ville commune', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('f1886399-7b6e-5c0b-b417-aa2e54a4f32d', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'relationship_goal', 'en', 'Open to cross-border setup with a shared city strategy', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('69d7f902-90ba-59ef-b12d-5e2425c46f87', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'residence_plan', 'zh', '日内瓦为主，接受巴黎双城', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('1007ac50-4280-5324-a4a6-26159eb93aef', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'residence_plan', 'fr', 'Geneve en base, possible schema Geneve-Paris', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('76226226-43c5-5812-8723-03aaaf927f64', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'residence_plan', 'en', 'Geneva-based, open to Geneva-Paris setup', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('5df6c783-8c5e-53b4-9903-82a6a88627a3', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('f9eb7077-02da-5489-bc9c-ea561dae3b78', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('0686cb87-a0fd-5317-a488-796034a3fbfa', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('c2dd5995-84c2-52ea-8804-83de8e6f2174', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('9b87080c-d7da-5916-91af-19d197335233', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('182f54bc-06ef-5c03-8b1c-897b09e7917b', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('3c505de4-b273-5845-bbe1-5ac643535845', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'exercise', 'zh', '滑雪和徒步', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('195534b1-b535-5ff4-9596-07287dac5719', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'exercise', 'fr', 'Ski et randonnee', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('84224217-0d89-550e-8e1a-ea2abed8d24f', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'exercise', 'en', 'Skiing and hiking', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('4496617a-f643-51cd-a376-69cc50e1186f', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('9b4f73c7-e199-5764-a65e-3dc38e36aed0', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('c18b1c79-2ffb-50b0-8e08-7c0e3b776e62', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('7a9048ed-26a0-52ce-85c3-4efb9b7966e7', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'industry', 'zh', '数字产品', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('64efcb6a-9332-51eb-8e0c-767e0cb4707c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'industry', 'fr', 'Produit numerique', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('d22f53bd-e01a-5416-b237-e6105a1e69e0', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'industry', 'en', 'Digital product', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('b9268581-70f9-5098-a378-31800fec1f50', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'relationship_goal', 'zh', '先建立共同生活节奏，再推进长期关系', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('29ca8eb7-060e-578b-af81-a1f2330a898f', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'relationship_goal', 'fr', 'Installer un rythme de vie commun avant de projeter le long terme', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('c7a747ff-1731-5292-af91-f981758308b7', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'relationship_goal', 'en', 'Build daily-life rhythm first, then advance long-term plans', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('720b9871-bba5-52ad-962f-f9254e36395f', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'residence_plan', 'zh', '阿姆斯特丹为主，接受巴黎/布鲁塞尔协同', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('4bb8cdc8-8094-5f6a-846b-955a225f9678', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'residence_plan', 'fr', 'Base Amsterdam, ouverte a Paris ou Bruxelles', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('82c76128-4ecf-52ca-b866-524179da172c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'residence_plan', 'en', 'Amsterdam-based, open to Paris/Brussels coordination', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('e3631400-f153-5354-94de-fe56eaa8081c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('395506b6-3dcb-5803-9d6a-91280987a9d0', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('a8d76440-cf2b-5bbb-8078-72cf73fb1d5e', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('b2a48efe-0b1e-5358-8761-0bd7e07a9cf6', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('c96d41c2-da26-53d0-be7d-503d5692cf18', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('4187449e-9017-5f06-ac1d-3e88e2a06052', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('a85f9ce1-5f82-5a36-9402-95982715c22c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'exercise', 'zh', '划船和慢跑', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('7b981b34-b0b0-5321-a421-a49f9d3f6ae9', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'exercise', 'fr', 'Rameur et jogging', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('88f28cb8-67d1-5b6d-ac0f-726ab261442c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'exercise', 'en', 'Rowing and jogging', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20');

-- 3A.9 cm_profile_localized_items
insert into cm_profile_localized_items (id, profile_id, field_name, item_order, locale, value, source, provider, status, created_at, updated_at) values
  ('9707592f-595f-5bc1-9bca-484fa48e1fe5', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4d0f0f82-90b8-5d98-bc6c-836263977537', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('d5062173-7224-5f8b-9aaf-c618236f6317', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('d90b9fec-c0f5-50f0-b083-cb0b308d2353', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('f0aa0038-596e-5322-8c5b-8026e1e45ec9', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('12043a25-1fbe-583f-acc9-9f946c01e5ad', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('edc80f35-1b91-5b57-9b22-9af70e859aaf', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 0, 'zh', '表达清晰', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('ef3976dd-b41d-5214-9e49-a6cccb7f0022', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 0, 'fr', 'Communication claire', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('1cd98d81-baa6-5f2d-bc0d-552fcf4c94f3', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 0, 'en', 'Clear communicator', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('c6a791b6-babe-5ab7-bad7-9c7166762b05', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 1, 'zh', '审美稳定', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('c43508f3-7eac-549c-9723-3651d9291da1', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 1, 'fr', 'Sens esthetique stable', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2f57e21e-cc2a-5d53-b350-6696c3d7bd7b', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 1, 'en', 'Consistent taste', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('8d8a0030-ab0b-5167-a515-81c27152c50f', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 2, 'zh', '重视边界', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('8ddfa90c-ccfd-55e4-9b86-18cb86aa2e4f', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 2, 'fr', 'Respecte les limites', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('b313dde0-dd57-56ba-bee3-1cab4eeb31a6', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'personality_traits', 2, 'en', 'Values boundaries', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('a351f601-65ae-5b6c-b771-2ac68a5ccc83', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 0, 'zh', '展览', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('615ff39f-f38a-5d05-b27c-a34c97e37f60', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 0, 'fr', 'Expositions', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('aa79d3e0-2403-54b1-b5a4-c7d2cb5d5f2d', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 0, 'en', 'Exhibitions', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2a409dbe-d1c5-5da7-b932-cbf4c5291597', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 1, 'zh', '城市散步', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('9b643cc8-3398-5659-ac4b-0c377caf6150', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 1, 'fr', 'Balades urbaines', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('e77e2a71-8ce3-5117-a2a6-e30f9c00f0d2', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 1, 'en', 'City walks', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('18ad84bd-4801-59f2-922e-6e6ced928c8a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 2, 'zh', '法式烹饪', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('4ef0bcca-32f4-5d77-b496-78936e2b6fe2', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 2, 'fr', 'Cuisine francaise', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('c60275ef-6ea6-524e-b197-8fbba0145888', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'interests', 2, 'en', 'French cooking', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2d0754e2-f742-5b9f-bcc7-6568fc5f36c1', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 0, 'zh', '文化活动', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('9a65d176-5879-5629-a6e2-523e36ac8c3a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 0, 'fr', 'Activites culturelles', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('808414b9-fb65-56db-8af2-e2042244b4c3', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 0, 'en', 'Cultural activities', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('cd2bf547-9c31-5fe0-b2a8-5e0159c24641', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 1, 'zh', '城市生活', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('71006629-e0bc-5d25-af5e-e7354560cabb', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 1, 'fr', 'Vie urbaine', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('50cdc4a1-954c-52d8-8445-cb86ee7d538a', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 1, 'en', 'City life', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('c6aa9913-84b6-578e-b8a6-e86a422de74d', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 2, 'zh', '稳定节奏', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('df4bedd0-ce1d-50a6-8db1-0ca1177dc2f0', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 2, 'fr', 'Rythme stable', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('1839f64f-2a4b-5146-8186-b02f5dc82ab9', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'tags', 2, 'en', 'Steady pace', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('2072fbb9-fb26-5a2b-bdc1-73758f4b4eec', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('1ae26191-2668-55c9-bc31-a650a57b4c55', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('659920ec-34da-5074-be7a-1cb842cbb2ca', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('e978c89f-3d92-5a07-8e66-a133b416323a', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('e47997b1-afd9-5108-9c24-7af15bbecdad', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('9fd9564c-767a-5a1c-bf88-18f8adaec470', '503a9c99-2842-54db-8858-24fbd3108e3b', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('2c4fc79a-8190-5fd0-9c07-2feaf9df0fae', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 0, 'zh', '目标清晰', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('d504a106-e085-5db4-9d4b-7a1d6bf9da9f', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 0, 'fr', 'Objectifs clairs', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('fa676115-e197-5472-adf2-6d2fef873fbd', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 0, 'en', 'Clear goals', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('72955b27-e856-5825-8177-b8e64eefd839', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 1, 'zh', '执行力强', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('97d068dc-dd7e-529e-a978-cdc2c9dee8fd', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 1, 'fr', 'Fort sens de l execution', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('ee3ed886-d8bf-51fd-9c19-fb58027be331', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 1, 'en', 'Strong follow-through', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('d57e83b3-f0a7-577e-b539-2911f58222fc', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 2, 'zh', '情绪稳定', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('27c49f83-9483-557e-88c4-855217d5288f', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 2, 'fr', 'Stable emotionnellement', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('1597f4d4-5785-5bf0-9767-b2b0509ecdb0', '503a9c99-2842-54db-8858-24fbd3108e3b', 'personality_traits', 2, 'en', 'Emotionally steady', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('c2a8ba36-2e20-56de-bb05-7ce2e76ef84f', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 0, 'zh', '骑行', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('5aec2d5c-40e6-58ff-b267-f9b9ed64c9fc', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 0, 'fr', 'Velo', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('01a17b44-18be-56cf-8679-cf39809f7789', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 0, 'en', 'Cycling', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('bc9d5943-283a-5df2-86fb-b1ca59bfedd1', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 1, 'zh', '产品播客', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('1e669f1d-dcba-5250-a8de-07f43e7ce9c1', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 1, 'fr', 'Podcasts produit', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('e1cdef4f-5f26-54f9-818a-d9e745cba4db', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 1, 'en', 'Product podcasts', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('1123282e-f8d0-50a3-a050-38fe0f08f39b', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 2, 'zh', '周末做饭', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('580fe557-1d97-5d11-89d5-80820cdf24bb', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 2, 'fr', 'Cuisine le week-end', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('c7725346-068b-5b25-90d7-008620e86483', '503a9c99-2842-54db-8858-24fbd3108e3b', 'interests', 2, 'en', 'Weekend cooking', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('c70e4e37-41a7-5105-a153-72584415bf09', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 0, 'zh', '长期关系', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('be674512-162f-5536-8a91-1855039e6a98', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 0, 'fr', 'Long terme', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('97aa5303-fed6-5972-9d8c-91590b23ce90', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 0, 'en', 'Long-term', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('b6fe3495-f4cc-52a5-9be5-7034d982d49c', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 1, 'zh', '顾问协同', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('45566ebc-1144-5a5e-8caa-f0fbd9a1a7d2', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 1, 'fr', 'Coordination conseiller', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('247f34e2-1bb2-539d-b0b1-1f8e7ce314dc', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 1, 'en', 'Advisor-supported', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('caa8915e-2fcd-5012-b1aa-aea6c0bf720c', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 2, 'zh', '跨文化', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('f770e12d-1b4d-567a-a5ac-9840ffb90caa', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 2, 'fr', 'Interculturel', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('5715ac23-1d62-56f4-aae6-4bfcfe115bad', '503a9c99-2842-54db-8858-24fbd3108e3b', 'tags', 2, 'en', 'Cross-cultural', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('2cbcda5e-7773-578f-8f05-5a2500536992', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('6ff1583a-e441-5ff6-aa06-1528bf037146', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('efbdc9dc-d72b-5667-b94e-b694780b5091', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('11e32e22-6d52-5d00-acf1-e1bf21bf8a69', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('581f67ed-5e14-5482-bec7-1353302427ea', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('498d62e3-a54b-5167-bc42-920b87c8fe39', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0d869475-466e-5221-bdfb-b00140e9ac44', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 0, 'zh', '温和直接', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('ff7ea61f-41d1-5215-a2ea-208f68efef8f', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 0, 'fr', 'Douce et directe', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('7e3ca8ce-6e78-5193-b7c2-1aa1c79ebd28', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 0, 'en', 'Warm and direct', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('285e1c14-fee2-5c43-93d9-7556f009e711', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 1, 'zh', '生活有秩序', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('2015df2e-5429-5467-9b5f-26a634d1d7b9', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 1, 'fr', 'Vie bien organisee', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('4183dd85-97df-5f0a-8345-dedd6d5030fc', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 1, 'en', 'Well organized', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('e60a4a79-d80a-5e41-a152-4db6219263c0', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 2, 'zh', '重视真实相处', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('0ee31112-45f7-5081-a8a7-972ec84eb8ad', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 2, 'fr', 'Valorise l authenticite', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('5a2af7ae-935b-5edb-a4db-789450f8b119', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'personality_traits', 2, 'en', 'Values authenticity', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('84dc370d-a0c4-5efd-ac01-102502136935', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 0, 'zh', '阅读', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('105b5d3a-76da-5c32-a363-d6107c2eb683', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 0, 'fr', 'Lecture', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('61826833-34f7-577b-8f88-673e50ba1195', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 0, 'en', 'Reading', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('b8c746ff-b530-5600-8a8d-9fbac126ce5e', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 1, 'zh', '散步', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('3726a9f1-cfce-5d85-ab83-3ef58f2e5e54', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 1, 'fr', 'Balades', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('438e3430-de9e-516f-9f93-666d94f45f07', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 1, 'en', 'Walks', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('adb26e97-d833-5ac8-bcc1-b93c4f07d2b6', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 2, 'zh', '周末探店', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('6aa40ee1-3135-51dc-841e-feee7d938382', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 2, 'fr', 'Decouvertes le week-end', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('3bb14fb5-ed7d-5d26-bc9e-5c095d373837', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'interests', 2, 'en', 'Weekend discoveries', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('a7e000fa-7449-5548-b3dd-437b26115701', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 0, 'zh', '家庭节奏', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('2ec1da8d-b6d1-5cca-9414-4e5b1dffee7c', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 0, 'fr', 'Rythme familial', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('1d6df03b-7d00-5909-8c04-238f123686d8', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 0, 'en', 'Family rhythm', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('89e29a58-86bf-5c2b-b0a3-40c78925db7a', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 1, 'zh', '双城安排', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('19530580-d97d-50d6-a2b2-09ab5c164adc', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 1, 'fr', 'Deux villes', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('527e4755-1c7a-56c6-bdec-6503460d2571', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 1, 'en', 'Two-city setup', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('fe2209a8-10cd-5fbd-b7ee-2b0af1d3202a', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 2, 'zh', '成熟沟通', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('d07e5182-5d85-5055-8e2f-d2f3e6df5315', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 2, 'fr', 'Communication mature', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('42e9a311-04c3-57b0-a8bd-b1cfa14fa619', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'tags', 2, 'en', 'Mature communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('4d3442b2-56a2-5500-a2ba-2522e49e1d45', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('1523e661-34a8-57cb-887a-5cdf8e51e147', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('9f4ad05f-5dec-5e19-8f1a-f6e2008c88f0', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('7fd31078-1bed-5f33-8c55-da1a09d61a39', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('fe0591cb-980f-5fb5-b85b-4b87923a76b3', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('03fb47ce-5787-52fe-8930-8947aef2c895', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('03e9da58-0c81-5db0-84c1-45bb6c15d2b7', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 0, 'zh', '时间观念强', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('35411f5f-6439-55ce-b095-44dd61aba0e4', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 0, 'fr', 'Tres ponctuel', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('5c18d106-f055-5189-8d17-a37ac9abfea3', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 0, 'en', 'Very punctual', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('9e66e827-95ff-59a8-8c41-8a513256706b', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 1, 'zh', '跨文化适应力好', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('ce55cd68-b276-598c-a57f-786a204fc102', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 1, 'fr', 'Aisance interculturelle', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('ff5b6a22-d952-5873-923a-6f7ed418dcaa', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 1, 'en', 'Cross-cultural ease', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('a1c37419-638e-5569-a448-55fe98056f06', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 2, 'zh', '重视承诺', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('aa744d94-7708-5956-96f3-0435bb0b87ff', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 2, 'fr', 'Attache aux engagements', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('a076534a-4c25-52b6-99b5-b327e5c89ff6', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'personality_traits', 2, 'en', 'Commitment-minded', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('db8f13cd-2e6e-5469-9074-567c09a47dbc', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 0, 'zh', '滑雪', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('413e2161-88e7-5e55-968b-9581de39d367', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 0, 'fr', 'Ski', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('0847e129-0afb-54c0-b40d-cb9c8c9136f6', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 0, 'en', 'Skiing', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('acb2026a-e336-5c01-bc5b-1e3eb8ea27dc', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 1, 'zh', '徒步', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('9e6a71cb-b690-5935-b0e2-6186c76280f0', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 1, 'fr', 'Randonnee', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('ac1f3c57-9f04-5977-ae71-17f671100adc', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 1, 'en', 'Hiking', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('ea8147eb-3532-52b1-8a64-c0a0980abd33', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 2, 'zh', '城市短途旅行', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('d1ad23b8-9e98-56fb-b7f9-89abcb39254c', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 2, 'fr', 'Escapades urbaines', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('c9171629-d936-5276-8331-3595fcb58a33', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'interests', 2, 'en', 'City breaks', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('697d6338-ea7b-5b34-b866-e922d1cd1bec', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 0, 'zh', '跨境节奏', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('fd300753-ff9b-5aff-b737-04ba616b1794', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 0, 'fr', 'Transfrontalier', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('96ae347c-51b7-5af3-b69f-6a3ce215b02e', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 0, 'en', 'Cross-border', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('c61093c3-1a1f-579d-a90f-0fd63273ee07', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 1, 'zh', '高匹配意愿', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('238cabe4-466e-579c-a5b3-204497b1e07c', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 1, 'fr', 'Intention elevee', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('75377ff4-96c5-5f57-80c7-a44b6d711349', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 1, 'en', 'High matching intent', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('59fcc817-3668-53c9-ae6c-06697f7259bf', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 2, 'zh', '执行力', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('6e4ad6de-18fb-5716-b995-2fb2ac7cc388', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 2, 'fr', 'Execution', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('3b25d7bd-2917-5b67-be4a-629355a85925', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'tags', 2, 'en', 'Execution', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('3f60c249-e3d8-548b-a4d5-de6799de0be2', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('a08d00ac-fcaa-5d0d-8064-669c4536a44a', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('31d7d94a-6d0b-51c1-a4dd-46f7cca3f4d8', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('c69982f5-9e13-52c8-ace0-4113f485ac1f', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('d18b0231-f413-5c8c-bb76-2e72efae24be', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('82cffe0c-86b1-5f3a-acc2-a5dc2fe78469', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('5611722a-57a9-5844-9ed1-be813ed96876', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 0, 'zh', '温和直接', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('3312d1be-3b0c-59e1-b59f-427a8179e134', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 0, 'fr', 'Douce et directe', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('e25a8901-ec00-599f-ad54-aa97d58cd45f', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 0, 'en', 'Warm and direct', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('fc4c8089-9be1-5f96-8ff6-6edeeefc5d55', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 1, 'zh', '生活有秩序', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('cbd75c21-ca1f-5439-ae2c-514c06dc96b1', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 1, 'fr', 'Vie bien organisee', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('8ce54e37-853b-5416-932b-77156428df7b', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 1, 'en', 'Well organized', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('e5a1861e-b646-542e-a514-bfb24598d50d', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 2, 'zh', '重视真实相处', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('7cfe1d80-0a32-589a-b267-ad9387b4c3c1', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 2, 'fr', 'Valorise l authenticite', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('de46be3f-2be2-5ff0-a7f9-99e1f30a8a0b', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'personality_traits', 2, 'en', 'Values authenticity', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('03257880-4953-545b-a765-ca761830c08e', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 0, 'zh', '阅读', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('7c49194d-0235-55cc-8aae-a2ab45415365', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 0, 'fr', 'Lecture', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('8835dd84-816e-59b3-97ab-72178705cb03', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 0, 'en', 'Reading', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('32198e77-c406-568a-9161-9cddf0302d56', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 1, 'zh', '散步', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('9e0c2acb-3f1d-52dd-83af-c07964f69cf6', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 1, 'fr', 'Balades', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('734928e8-fe9e-5562-90cc-47866e3e02ed', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 1, 'en', 'Walks', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('96bdaed5-d0a9-5dd4-8093-b2a5d3d63fcc', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 2, 'zh', '周末探店', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('deddecf2-caf6-5eb1-b729-9fe2fe752b99', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 2, 'fr', 'Decouvertes le week-end', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('3b25a046-eb87-5add-ac4a-05a1e3dc3a7c', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'interests', 2, 'en', 'Weekend discoveries', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('ca415402-1f2f-5eed-8eb7-95009ab534f0', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 0, 'zh', '跨文化', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('adb162d7-b172-5949-b19e-e2ddda037224', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 0, 'fr', 'Interculturel', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('0952ea1c-6c13-5188-b53b-da371f638733', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 0, 'en', 'Cross-cultural', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('faffdceb-2e27-5ce1-957f-3e606a8128ae', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 1, 'zh', '沟通质量', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('100e0b4a-8981-576d-a922-5b58528c46d9', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 1, 'fr', 'Qualite echange', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('11a00f3a-bdc9-5ece-8a6f-906989158fed', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 1, 'en', 'Communication quality', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('7229ac57-ae91-57d3-a317-7bc5dff989d4', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 2, 'zh', '生活一致', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('b0359cd9-4d8b-5771-9d42-e11ecd1f30a9', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 2, 'fr', 'Coherence de vie', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('602542cb-4db1-5237-8f6e-053e9382b2f4', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'tags', 2, 'en', 'Lifestyle alignment', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20');

-- 3A.10 cm_profile_photos
insert into cm_profile_photos (id, profile_id, url, is_primary, sort_order, status, created_at, updated_at) values
  ('f4391fce-c307-5754-83ab-efd016d9aada', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'https://picsum.photos/seed/p-001-1/900/1200', 1, 1, 'approved', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('b1485a44-d50c-5529-b41e-b61d87902a7b', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'https://picsum.photos/seed/p-001-2/900/1200', 0, 2, 'approved', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('d1286d2d-c0bb-51de-b1b4-c343ffda3e9c', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'https://picsum.photos/seed/p-001-3/900/1200', 0, 3, 'approved', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('9189edae-6db1-566d-abbc-ebf8ce71b63a', '503a9c99-2842-54db-8858-24fbd3108e3b', 'https://picsum.photos/seed/p-002-1/900/1200', 1, 1, 'approved', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('27367cf8-7d47-55d1-b745-376e53d8ab80', '503a9c99-2842-54db-8858-24fbd3108e3b', 'https://picsum.photos/seed/p-002-2/900/1200', 0, 2, 'approved', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('ce6bd69f-1a5d-567c-a881-3e83aca50550', '503a9c99-2842-54db-8858-24fbd3108e3b', 'https://picsum.photos/seed/p-002-3/900/1200', 0, 3, 'approved', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('e9675246-2d82-594a-adf1-bb4ace1c384b', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'https://picsum.photos/seed/p-006-1/900/1200', 1, 1, 'approved', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('e7050e2b-8592-5b6a-aa22-859e20d3c9fa', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'https://picsum.photos/seed/p-006-2/900/1200', 0, 2, 'approved', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('cc38e10c-0461-5ecc-9518-a67811f5c7b4', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'https://picsum.photos/seed/p-006-3/900/1200', 0, 3, 'approved', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('ac0f143b-13c9-548f-a15b-3d6763bc1576', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'https://picsum.photos/seed/p-009-1/900/1200', 1, 1, 'approved', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('31f97d57-ccd0-51c1-8b94-05d8f36c5288', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'https://picsum.photos/seed/p-009-2/900/1200', 0, 2, 'approved', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('393d2339-10b6-5dd9-bafc-4befd3a800fc', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'https://picsum.photos/seed/p-009-3/900/1200', 0, 3, 'approved', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('d1113beb-ce6f-5cf1-996b-f0834252e153', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'https://picsum.photos/seed/p-010-1/900/1200', 1, 1, 'approved', '2026-02-14 00:00:00', '2026-04-21 10:45:00'),
  ('cd6ee5a1-7302-56fd-a8bc-4cfb747a53ed', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'https://picsum.photos/seed/p-010-2/900/1200', 0, 2, 'approved', '2026-02-14 00:00:00', '2026-04-21 10:45:00'),
  ('d732ca77-9605-5651-9437-1f8b45e87f25', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'https://picsum.photos/seed/p-010-3/900/1200', 0, 3, 'approved', '2026-02-14 00:00:00', '2026-04-21 10:45:00');

-- 3A.11 cm_profile_ownerships
insert into cm_profile_ownerships (id, user_id, profile_id, relationship_to_profile, permission, status, invited_by_user_id, accepted_at, revoked_at, created_at, updated_at) values
  ('ce1facca-cc05-5f3c-8c31-58deda8629ac', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '503a9c99-2842-54db-8858-24fbd3108e3b', 'self', 'owner', 'active', null, null, null, '2026-01-01 00:00:00', '2026-05-25 21:07:58');

-- 3A.12 cm_profile_internal_records
insert into cm_profile_internal_records (id, profile_id, is_featured, source, updated_by_user_id, created_at, updated_at) values
  ('7ab713a0-49ec-50ce-8249-8b9a76897f96', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 0, null, null, '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('478efbe6-fca6-5281-979b-54083466ab54', '503a9c99-2842-54db-8858-24fbd3108e3b', 1, null, null, '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('c0194fe5-c673-522e-8e8e-7a70c1756be7', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 0, null, null, '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('ab6bf2a4-8581-52c6-b12f-89f53d5f31e1', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 1, null, null, '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('8890d441-fb8d-5a09-97b5-7a5f6a0a1e92', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 0, null, null, '2026-02-14 00:00:00', '2026-04-21 10:45:00');

-- 3A.13 cm_profile_verifications
insert into cm_profile_verifications (id, profile_id, legal_name, date_of_birth, identity_status, education_status, income_status, marital_status, review_status, verified_at, verified_by_user_id, created_at, updated_at) values
  ('512e1727-7810-5a09-8ce6-750f72a633ff', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'Aline M.', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('b8b2aece-5ed3-5e5c-906a-4f770c0b951f', '503a9c99-2842-54db-8858-24fbd3108e3b', 'Lin S.', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('1fe5ee5f-2e5e-5f8b-8251-2fd5ab8ddce5', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'Sophie L.', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('9894e977-083c-5d2c-8a4e-4b7d3b539930', '7972f5d4-3d0d-5ffb-8815-45d43049e2a8', 'Martin K.', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('c25eb929-8172-5434-96d1-db4a93a4c2f8', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'Iris N.', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-02-14 00:00:00', '2026-04-21 10:45:00');

-- 3A.14 cm_profile_contacts
insert into cm_profile_contacts (id, profile_id, phone, email, wechat, preferred_channel, visibility, created_at, updated_at) values
  ('e076859b-73d2-55bd-bf3e-7bbea0853691', '506ce3c7-b236-5b44-b8d0-459c4250ea03', '+33 6 12 34 56 78', 'aline.m@example.com', null, 'phone', 'after_introduction', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('27544d96-4bd3-5b0a-8b2c-3227e57fdc23', '503a9c99-2842-54db-8858-24fbd3108e3b', '+33 6 98 76 54 32', 'loic.d@example.com', 'loic_dubois', 'phone', 'after_introduction', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('e1445318-683e-557c-bcc5-8a9599b4d74f', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', '+33 6 11 22 33 44', 'camille.m@example.com', 'camille_martin', 'email', 'after_introduction', '2026-02-14 00:00:00', '2026-05-28 10:00:00');

-- 3A.15 cm_profile_privacy_preferences
insert into cm_profile_privacy_preferences (id, profile_id, hide_marital_status, hide_has_children, hide_children_plan, hide_accepts_long_distance, hide_smoking, hide_drinking, created_at, updated_at) values
  ('1caff97d-06d9-53cb-a771-e169c484b90f', '503a9c99-2842-54db-8858-24fbd3108e3b', 0, 0, 0, 0, 0, 0, '2026-05-23 11:02:04', '2026-05-23 11:02:33');

-- 3A.16 cm_membership_plans
insert into cm_membership_plans (id, tier, price_cents, currency, cny_price_cents, billing_type, billing_period, validity_months, private_introduction_quota, private_introduction_period, event_quota, event_priority_enabled, staff_review_enabled, profile_detail_access_level, staff_support_level, concierge_priority, featured, sort_order, is_active, created_at, updated_at) values
  ('f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'free', 0, 'EUR', 0, 'free', null, null, 0, 'monthly', 0, 0, 0, 'registered', 'none', 0, 0, 1, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'silver', 6500, 'EUR', 49900, 'one_time', null, 12, 5, 'monthly', 12, 0, 1, 'registered', 'standard', 0, 0, 2, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'gold', 10000, 'EUR', 77000, 'one_time', null, 6, 15, 'monthly', 20, 1, 1, 'premium', 'priority', 1, 1, 3, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('9fb53b84-a341-5b63-b6e8-35a474540a4c', 'diamond', 15000, 'EUR', 115500, 'one_time', null, 12, 30, 'monthly', 24, 1, 1, 'premium', 'concierge', 1, 0, 4, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00');

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

-- 3A.18 cm_user_memberships
insert into cm_user_memberships (id, user_id, plan_id, tier, status, started_at, expires_at, created_at, updated_at) values
  ('d052548f-34dc-54f9-aab7-6dca95709306', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'gold', 'active', '2026-01-18 00:00:00', '2026-07-18 00:00:00', '2026-01-18 00:00:00', '2026-01-18 00:00:00');

-- 3A.19 cm_user_entitlement_balances
insert into cm_user_entitlement_balances (id, user_id, membership_id, entitlement_code, period_started_at, period_ends_at, quota_total, quota_used, quota_remaining, created_at, updated_at) values
  ('202f036e-42b5-506e-9509-1cfb4960555f', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'd052548f-34dc-54f9-aab7-6dca95709306', 'private_introduction', '2026-06-01 00:00:00', '2026-06-30 00:00:00', 15, 1, 14, '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('6f796142-1339-5002-980e-8a2c61382c4b', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'd052548f-34dc-54f9-aab7-6dca95709306', 'event_registration', '2026-01-18 00:00:00', '2026-07-18 00:00:00', 20, 0, 20, '2026-01-18 00:00:00', '2026-01-18 00:00:00');

-- 3A.20 cm_events
insert into cm_events (id, status, visibility, consumes_membership_quota, city_code, address_visibility, event_date, start_time, end_time, capacity, cover_image_url, created_at, updated_at) values
  ('0ed043fe-531a-511d-940b-5daa55de963e', 'open', 'registered', 0, 'FR:paris', 'registered_only', '2026-05-12', '18:30', '21:00', 12, 'https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=1200&q=80', '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('38f69abd-73b4-5464-8b07-a95a9bb58547', 'waitlist', 'member', 1, 'FR:paris', 'confirmed_attendee_only', '2026-05-20', '19:00', '22:00', 8, 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=80', '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('1bcb995a-540c-5c66-9b92-52471c43e587', 'open', 'registered', 1, 'BE:brussels', 'registered_only', '2026-05-28', '14:30', '17:00', 16, 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80', '2026-04-01 00:00:00', '2026-05-01 00:00:00');

-- 3A.21 cm_event_localized_fields
insert into cm_event_localized_fields (id, event_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('098259d0-1a0c-5c74-a27f-f1f9a9868317', '0ed043fe-531a-511d-940b-5daa55de963e', 'title', 'zh', '春季双语沙龙', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('6be3fb00-fa24-5763-97d7-105cdfc82cf6', '0ed043fe-531a-511d-940b-5daa55de963e', 'title', 'fr', 'Salon bilingue du printemps', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('730263d9-f33f-52de-940c-70681b10446e', '0ed043fe-531a-511d-940b-5daa55de963e', 'title', 'en', 'Spring bilingual salon', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('eb44aded-1de3-545f-a6b4-78dbc4ae514c', '0ed043fe-531a-511d-940b-5daa55de963e', 'summary', 'zh', '围绕跨文化关系、工作节奏和城市生活展开小组交流。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('4c2cf0b0-3b2b-5d5d-b3fd-bc4fe74100fb', '0ed043fe-531a-511d-940b-5daa55de963e', 'summary', 'fr', 'Echanges en petits groupes autour des relations interculturelles et du rythme de vie.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('608010d4-f61a-59cb-ad15-fb1adaeb16b1', '0ed043fe-531a-511d-940b-5daa55de963e', 'summary', 'en', 'Small-group conversations around intercultural dating and lifestyle pace.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f12a23ae-ad4d-5c98-8fd1-46c42a71cae9', '0ed043fe-531a-511d-940b-5daa55de963e', 'venue', 'zh', '左岸私享沙龙', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('48416a3f-4bd1-5e14-bc13-4f12990f3321', '0ed043fe-531a-511d-940b-5daa55de963e', 'venue', 'fr', 'Salon prive rive gauche', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c1dcab44-e5a6-55e6-abc4-c1fbf23bc5b4', '0ed043fe-531a-511d-940b-5daa55de963e', 'venue', 'en', 'Left Bank private salon', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('e171bcbe-22f3-5c06-9742-d8a49b6fa1ae', '0ed043fe-531a-511d-940b-5daa55de963e', 'address', 'zh', '巴黎第六区圣日耳曼大道 128 号', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('eabb5bc9-f915-5e93-9b1d-722445657fc6', '0ed043fe-531a-511d-940b-5daa55de963e', 'address', 'fr', '128 boulevard Saint-Germain, 75006 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('823e1b05-b46a-5e38-8047-0bfc1ac7df17', '0ed043fe-531a-511d-940b-5daa55de963e', 'address', 'en', '128 Boulevard Saint-Germain, 75006 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('801bfc04-9f7e-5178-bafa-58d3dfe567b4', '0ed043fe-531a-511d-940b-5daa55de963e', 'format', 'zh', '12人主题沙龙', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('0ca86cb5-6c3e-5d0b-99bf-d5b45fc702ff', '0ed043fe-531a-511d-940b-5daa55de963e', 'format', 'fr', 'Salon thematique, 12 personnes', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f1fab27d-b06e-5dad-a32f-eacf91d1b5fd', '0ed043fe-531a-511d-940b-5daa55de963e', 'format', 'en', '12-person themed salon', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('9136df29-bd9c-5f70-a2ab-89ea5b633a70', '0ed043fe-531a-511d-940b-5daa55de963e', 'audience', 'zh', '适合 27-35 岁、希望稳定发展的会员', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f9dc2768-48b0-581d-bce5-f6a206ec1dcb', '0ed043fe-531a-511d-940b-5daa55de963e', 'audience', 'fr', 'Pour 27-35 ans avec intention relationnelle stable', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c310e57d-21f1-58c7-8c2d-c925ee950cf5', '0ed043fe-531a-511d-940b-5daa55de963e', 'audience', 'en', 'For members aged 27-35 seeking stable development', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('08b7091f-4412-52e4-8598-d4d6513988c3', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'title', 'zh', '左岸晚餐局', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('5986ce9b-c38f-57ff-90f9-ab28b74b5329', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'title', 'fr', 'Diner rive gauche', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('faa6f609-43d4-511c-bae3-0a509ae58783', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'title', 'en', 'Left Bank dinner gathering', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('69ba7ece-622a-50b1-8270-c53f828d1cfb', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'summary', 'zh', '适合把线上兴趣转化为线下确认。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('63da2126-201b-5b9c-82c9-82ce4961a1fa', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'summary', 'fr', 'Format intime pour valider une affinite observee en ligne.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('0d37bb47-70f0-5d8e-b5ba-a837b5aaeb28', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'summary', 'en', 'An intimate format to validate affinity first seen online.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('9a581508-62db-5845-8289-e9680bf327e7', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'venue', 'zh', '玛黑区私宴空间', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('790f4bac-d93e-5bd7-a73b-c5fab9e29f26', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'venue', 'fr', 'Table privee au Marais', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('6c550e5d-3fa0-5d9e-8387-a38da2240af2', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'venue', 'en', 'Private dinner in Le Marais', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('dafa2892-c1d6-5de3-9c5d-96f7571ae717', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'address', 'zh', '巴黎玛黑区维埃耶杜唐普勒街 42 号', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('310705cc-3dd8-57ee-b80d-0b70199db207', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'address', 'fr', '42 rue Vieille-du-Temple, 75004 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c3b4196e-18c3-5350-ab8d-a310c33c35cf', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'address', 'en', '42 Rue Vieille-du-Temple, 75004 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('5fbb4fc1-ff8c-51c5-a93b-f9c9c2068d58', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'format', 'zh', '8人精选晚餐', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('5a638e2d-6de3-52ab-9d75-9b1deb613f78', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'format', 'fr', 'Diner selectif, 8 personnes', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('cec43408-960c-5ccb-bf2c-fb21e81fd01e', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'format', 'en', '8-person curated dinner', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('72014f57-07f9-5230-b3be-24391ffafcea', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'audience', 'zh', '主要面向已完成资料审核的会员', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c85132a4-fdaa-5bff-b81e-cf93eefd64a1', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'audience', 'fr', 'Principalement membres verifies', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('4da97f04-6216-560a-bacf-9602d23b3f45', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'audience', 'en', 'Mainly for profile-verified members', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('5e2c742a-cc5e-5a42-ae22-2352ccbd46b7', '1bcb995a-540c-5c66-9b92-52471c43e587', 'title', 'zh', '文化散步与咖啡交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('3a52bf89-db02-54ac-9874-b89c9121616b', '1bcb995a-540c-5c66-9b92-52471c43e587', 'title', 'fr', 'Parcours culturel et cafe', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('dcb85612-b2c9-5f50-91a3-0faf759231f4', '1bcb995a-540c-5c66-9b92-52471c43e587', 'title', 'en', 'Culture walk and coffee exchange', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('0e1c0fbf-752e-57ef-85d3-57d621dab2f7', '1bcb995a-540c-5c66-9b92-52471c43e587', 'summary', 'zh', '以更轻松的方式开启第一次真实见面。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('7c7180ae-6b4c-5498-a7e7-23bae99e3009', '1bcb995a-540c-5c66-9b92-52471c43e587', 'summary', 'fr', 'Un format leger pour transformer le premier contact en rencontre reelle.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ba8888a7-4e0d-51b4-8507-b45795247927', '1bcb995a-540c-5c66-9b92-52471c43e587', 'summary', 'en', 'A lighter format for turning first contact into a real meeting.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('a8660d58-09f2-5386-ac94-b533611d7d4b', '1bcb995a-540c-5c66-9b92-52471c43e587', 'venue', 'zh', '欧洲区文化空间', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('fc89056c-2fb8-5f63-809a-62996a62111c', '1bcb995a-540c-5c66-9b92-52471c43e587', 'venue', 'fr', 'Espace culturel du quartier europeen', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('bed52f4a-ede5-5e6f-9b2f-e0e0fa1a0796', '1bcb995a-540c-5c66-9b92-52471c43e587', 'venue', 'en', 'European Quarter cultural venue', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('0b1dafff-c914-5fad-aeae-84445ce6408a', '1bcb995a-540c-5c66-9b92-52471c43e587', 'address', 'zh', '布鲁塞尔欧洲区舒曼广场 6 号', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('9e75b292-f73f-594b-91ef-3360faf17317', '1bcb995a-540c-5c66-9b92-52471c43e587', 'address', 'fr', '6 rond-point Schuman, 1040 Bruxelles', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f0ec33b0-e29a-5257-8495-4392883a45db', '1bcb995a-540c-5c66-9b92-52471c43e587', 'address', 'en', '6 Schuman Roundabout, 1040 Brussels', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('98c7abb6-1245-50ba-93dd-ea5878bef2f9', '1bcb995a-540c-5c66-9b92-52471c43e587', 'format', 'zh', '城市散步 + 交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('82ba3908-f9ac-5f75-9f14-5efe7c188264', '1bcb995a-540c-5c66-9b92-52471c43e587', 'format', 'fr', 'Balade urbaine + echanges', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('9a8802b6-8510-572a-bea3-db0f140aac5c', '1bcb995a-540c-5c66-9b92-52471c43e587', 'format', 'en', 'City walk plus discussion', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('431ae6c2-bae7-5819-b64f-7c8e4173f0d3', '1bcb995a-540c-5c66-9b92-52471c43e587', 'audience', 'zh', '适合首次参加平台活动的新会员', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('77a40a99-e124-5287-8e9c-f6626815321e', '1bcb995a-540c-5c66-9b92-52471c43e587', 'audience', 'fr', 'Ideal pour une premiere participation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('3e368fd6-5dfe-53d6-9c79-cf1d95748fcd', '1bcb995a-540c-5c66-9b92-52471c43e587', 'audience', 'en', 'Good for first-time participants', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20');

-- 3A.22 cm_event_note_items
insert into cm_event_note_items (id, event_id, sort_order, created_at, updated_at) values
  ('7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', '0ed043fe-531a-511d-940b-5daa55de963e', 1, '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('2b540c39-95cf-54d2-8ae6-6be251c4b254', '38f69abd-73b4-5464-8b07-a95a9bb58547', 1, '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ea365481-9ca7-5e19-b318-0193b796680b', '1bcb995a-540c-5c66-9b92-52471c43e587', 1, '2026-04-01 00:00:00', '2026-05-18 12:07:20');

-- 3A.23 cm_event_note_item_localized_fields
insert into cm_event_note_item_localized_fields (id, note_item_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('27006c38-cc71-548d-a6f0-a79588db75e6', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'title', 'zh', '策展说明', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('2942ca21-c90b-5284-874a-19fb26dbba53', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'description', 'zh', '策展人会在报名后确认资料完整度与参与节奏。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('b184551f-88d2-520f-b9f5-c01da77f9028', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'title', 'fr', 'Note du curateur', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('3a6cc4c7-09f9-591f-a5e1-ada9f44ed112', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'description', 'fr', 'Le curateur confirme le dossier et le rythme apres la demande.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('b9c9e650-5ed7-5193-b653-4ac465f41a52', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'title', 'en', 'Curator note', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('74cd14cc-5631-51e4-8cea-24f693ddaf51', '7f13c809-d5b5-5ca6-8fb4-9a67acf1362d', 'description', 'en', 'A curator reviews profile readiness and pacing after submission.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('b1378a53-05a2-5234-9e48-1744b6571e76', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'title', 'zh', '参与说明', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ed59599d-45c7-5822-a54c-3e8952cbcea1', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'description', 'zh', '本场优先邀请已完成资料审核并适合晚餐节奏的会员。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('add5a691-2eaa-5aa8-8110-e62885034894', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'title', 'fr', 'Participation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('2f04bc8b-ed29-5a2c-8444-035eae17951f', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'description', 'fr', 'Priorite aux membres verifies et adaptes au format diner.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('8bdc86c9-d378-58b8-8266-b68bd98604d6', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'title', 'en', 'Participation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('cf9d72f1-d8f2-5128-a663-6d85f2886935', '2b540c39-95cf-54d2-8ae6-6be251c4b254', 'description', 'en', 'Priority is given to verified members suited to the dinner format.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('e9516d09-3ceb-51ad-8060-2f5324100aa4', 'ea365481-9ca7-5e19-b318-0193b796680b', 'title', 'zh', '首次参与', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('7ef98175-a68c-5bc5-a0bc-1613dd0c6fbd', 'ea365481-9ca7-5e19-b318-0193b796680b', 'description', 'zh', '适合第一次参加平台活动的会员，策展人会协助控制交流边界。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('2ced69f2-9f68-5554-9c74-8f4c943b98f8', 'ea365481-9ca7-5e19-b318-0193b796680b', 'title', 'fr', 'Premiere participation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ad08c502-3242-50ed-838f-4f5b8fd588a2', 'ea365481-9ca7-5e19-b318-0193b796680b', 'description', 'fr', 'Format adapte a une premiere participation, avec cadrage du curateur.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('271ab3ac-01aa-5472-8529-7ea920d172b5', 'ea365481-9ca7-5e19-b318-0193b796680b', 'title', 'en', 'First participation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('96e7cc06-478f-5c23-b18e-b767198957d2', 'ea365481-9ca7-5e19-b318-0193b796680b', 'description', 'en', 'Good for first participation, with curator-guided boundaries.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20');

-- 3A.24 cm_event_relationship_focuses
insert into cm_event_relationship_focuses (id, event_id, focus_order, locale, value, source, provider, status, created_at, updated_at) values
  ('02b6b13f-2190-5b84-b8e8-e3ccc1bb7b4a', '0ed043fe-531a-511d-940b-5daa55de963e', 0, 'zh', '跨文化关系', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('645200ac-4cfe-533a-bb30-d72d43b626cb', '0ed043fe-531a-511d-940b-5daa55de963e', 0, 'fr', 'Relations interculturelles', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('fae02a3f-70e2-5f68-8e75-cac1e834762f', '0ed043fe-531a-511d-940b-5daa55de963e', 0, 'en', 'Intercultural relationship', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('dd703583-84b2-51f4-b5ca-c65588f9432b', '0ed043fe-531a-511d-940b-5daa55de963e', 1, 'zh', '稳定发展', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('6619bbf6-67c8-5ec6-aabd-0611142f1bef', '0ed043fe-531a-511d-940b-5daa55de963e', 1, 'fr', 'Relation stable', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c6ba32b3-0d7c-583e-abd8-b83d50e7c56d', '0ed043fe-531a-511d-940b-5daa55de963e', 1, 'en', 'Stable development', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f330c8ad-0169-550a-9e6d-a9bfceab7ee5', '38f69abd-73b4-5464-8b07-a95a9bb58547', 0, 'zh', '线下确认', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('bd03385a-dec4-504e-93fc-255f0af0d0e7', '38f69abd-73b4-5464-8b07-a95a9bb58547', 0, 'fr', 'Validation hors ligne', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('5354683c-7344-5a03-b02b-46132fb00afd', '38f69abd-73b4-5464-8b07-a95a9bb58547', 0, 'en', 'Offline confirmation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('50824732-8ca6-5de5-9c6f-9b7b0c63e0b9', '38f69abd-73b4-5464-8b07-a95a9bb58547', 1, 'zh', '高质量晚餐局', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('bb196efd-cd18-5d2a-adba-5bbd82e93b2d', '38f69abd-73b4-5464-8b07-a95a9bb58547', 1, 'fr', 'Diner selectif', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('56874f81-cc0c-5fd2-bbcf-1564f556e805', '38f69abd-73b4-5464-8b07-a95a9bb58547', 1, 'en', 'Curated dinner', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('61f83db8-3975-5c62-ac44-333c1187e7c3', '1bcb995a-540c-5c66-9b92-52471c43e587', 0, 'zh', '首次见面', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('bd0d5c4f-988c-5e59-a0b4-98d29dd5f38e', '1bcb995a-540c-5c66-9b92-52471c43e587', 0, 'fr', 'Premiere rencontre', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('eda7f6fd-c9ca-5d60-85db-e5c99bf5fd68', '1bcb995a-540c-5c66-9b92-52471c43e587', 0, 'en', 'First meeting', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('3aa28729-14c1-5b77-b0fd-7055c9024a89', '1bcb995a-540c-5c66-9b92-52471c43e587', 1, 'zh', '轻量交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('1cc6dfad-3f60-5362-bd0d-7c99a8972462', '1bcb995a-540c-5c66-9b92-52471c43e587', 1, 'fr', 'Echange leger', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('99afc51e-defa-51cd-94b4-88f99f66f0de', '1bcb995a-540c-5c66-9b92-52471c43e587', 1, 'en', 'Light conversation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20');

-- 3A.25 cm_event_language_codes
insert into cm_event_language_codes (event_id, language_code) values
  ('0ed043fe-531a-511d-940b-5daa55de963e', 'zh'),
  ('0ed043fe-531a-511d-940b-5daa55de963e', 'fr'),
  ('0ed043fe-531a-511d-940b-5daa55de963e', 'en'),
  ('38f69abd-73b4-5464-8b07-a95a9bb58547', 'zh'),
  ('38f69abd-73b4-5464-8b07-a95a9bb58547', 'fr'),
  ('38f69abd-73b4-5464-8b07-a95a9bb58547', 'en'),
  ('1bcb995a-540c-5c66-9b92-52471c43e587', 'fr'),
  ('1bcb995a-540c-5c66-9b92-52471c43e587', 'en');

-- 3A.26 cm_event_agenda_items
insert into cm_event_agenda_items (id, event_id, agenda_time, sort_order, created_at, updated_at) values
  ('5853a71e-9a57-5126-82da-bc25a7afb75e', '0ed043fe-531a-511d-940b-5daa55de963e', '18:30 - 19:00', 1, '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('dd835cd9-df78-552a-aa5b-1c5bf84e595c', '0ed043fe-531a-511d-940b-5daa55de963e', '19:00 - 19:45', 2, '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('24bb39e8-5b41-56a5-9270-a600375767dd', '38f69abd-73b4-5464-8b07-a95a9bb58547', '19:00 - 19:30', 1, '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('843e88fb-bf21-593f-a3b0-094f9c75edf9', '1bcb995a-540c-5c66-9b92-52471c43e587', '14:30 - 15:00', 1, '2026-04-01 00:00:00', '2026-05-01 00:00:00');

-- 3A.27 cm_event_agenda_item_localized_fields
insert into cm_event_agenda_item_localized_fields (id, agenda_item_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('7e440946-e3a2-5c8d-8cd3-aefbe83e0450', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'title', 'zh', '签到与活动说明', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('a1831cd3-6a85-5aea-80db-3cd4f6af3749', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'title', 'fr', 'Accueil et cadrage de l evenement', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('f764a51b-9fe0-5df7-8f81-0c6ff471bb89', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'title', 'en', 'Check-in and event framing', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('3bfbf9ea-e02b-5c58-a6d7-def409b960c1', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'description', 'zh', '确认到场信息并说明当晚节奏。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('018e46ee-6f02-581e-9d79-35175fb6b7a3', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'description', 'fr', 'Verification des arrivees et du rythme de la soiree.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('9baf8055-f075-5281-8fe0-a76207d7e1fd', '5853a71e-9a57-5126-82da-bc25a7afb75e', 'description', 'en', 'Arrival verification and evening pacing overview.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('27b85a30-24c0-5f53-8e8d-8b8a51f136ca', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'title', 'zh', '主题小组交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('bd2913a2-8683-523f-8d30-25c9e4001c12', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'title', 'fr', 'Echanges thematiques', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('448fe0b6-424d-56dc-b657-d088d767f772', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'title', 'en', 'Themed small-group exchange', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ef1d4784-372a-5b70-b373-863bad51edcc', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'description', 'zh', '围绕关系、工作和城市生活展开交流。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('57c2cd3e-e2a0-5ec1-b138-987622b72456', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'description', 'fr', 'Echanges autour des relations, du travail et de la vie urbaine.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c8cf352c-f38d-52c8-b3b2-c1d29b63a6ea', 'dd835cd9-df78-552a-aa5b-1c5bf84e595c', 'description', 'en', 'Conversation around relationships, work, and city life.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('e8595393-375c-58bd-8946-ab507f1d2909', '24bb39e8-5b41-56a5-9270-a600375767dd', 'title', 'zh', '入场与座位安排', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('02aa8a47-4144-5c9c-8cf4-c3ed68dbe04b', '24bb39e8-5b41-56a5-9270-a600375767dd', 'title', 'fr', 'Accueil et placement', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('fdec08d4-8925-5402-a22c-767879e593af', '24bb39e8-5b41-56a5-9270-a600375767dd', 'title', 'en', 'Arrival and seating', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('32a74c47-9134-50ec-a52d-0ff9c0a19a33', '24bb39e8-5b41-56a5-9270-a600375767dd', 'description', 'zh', '晚餐节奏与边界说明。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ba046c75-70b5-5ea1-825a-9d9dd66ff2ee', '24bb39e8-5b41-56a5-9270-a600375767dd', 'description', 'fr', 'Rappel du cadre et du rythme du diner.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('c44249b9-4eba-533f-b63e-4507d3b43497', '24bb39e8-5b41-56a5-9270-a600375767dd', 'description', 'en', 'Briefing on boundaries and dinner pacing.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('41683288-70b2-5cc6-8f72-e9df0aec16a4', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'title', 'zh', '集合与路线说明', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('e2666abc-e5b8-58cb-a704-01121ce625a3', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'title', 'fr', 'Rassemblement et briefing', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('a0a3ddc8-c76f-5e20-941c-0c9ae4e04113', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'title', 'en', 'Meet-up and route briefing', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('280fd9e6-3220-53bf-a967-d47c88d173f7', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'description', 'zh', '路线与交流节奏说明。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('1be260fc-52d1-505d-ae95-8a2888c880b5', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'description', 'fr', 'Rappel du parcours et du rythme d echange.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('b3ede8cb-287b-5574-9c76-fe48837fe4d9', '843e88fb-bf21-593f-a3b0-094f9c75edf9', 'description', 'en', 'Overview of the route and interaction rhythm.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20');

-- 3A.28 cm_event_registrations
insert into cm_event_registrations (id, user_id, event_id, status, requested_at, confirmed_at, declined_at, waitlisted_at, cancelled_at, attended_at, event_quota_consumed_at, event_quota_released_at, created_at, updated_at) values
  ('f44520c6-d6c7-5a4a-a6a2-40aada7743c6', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '0ed043fe-531a-511d-940b-5daa55de963e', 'cancelled', '2026-05-01 09:00:00', '2026-05-14 01:01:44', null, null, '2026-05-14 01:01:46', null, null, null, '2026-05-01 09:00:00', '2026-05-14 01:01:46'),
  ('85c16633-87ee-5350-9667-b5ec96f2b9e8', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '38f69abd-73b4-5464-8b07-a95a9bb58547', 'cancelled', '2026-05-01 09:00:00', null, null, null, '2026-05-14 00:37:05', null, null, null, '2026-05-01 09:00:00', '2026-05-14 00:37:05'),
  ('6dcca5e8-969b-5f47-9277-b56dbd051330', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '1bcb995a-540c-5c66-9b92-52471c43e587', 'cancelled', '2026-05-28 21:28:47', null, null, null, '2026-05-28 21:28:48', null, null, null, '2026-05-17 11:01:31', '2026-05-28 21:28:48');

-- 3A.29 cm_favorite_profiles
insert into cm_favorite_profiles (id, user_id, profile_id, created_at, updated_at) values
  ('98ddc269-dbdc-59d7-a1af-9ef27381be0e', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '506ce3c7-b236-5b44-b8d0-459c4250ea03', '2026-03-12 00:00:00', '2026-03-12 00:00:00'),
  ('f658d6c2-87e9-5f5f-b1d5-9562d3cdbf21', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', '2026-03-28 00:00:00', '2026-03-28 00:00:00');

-- 3A.30 cm_private_introduction_requests
insert into cm_private_introduction_requests (id, requester_user_id, requester_profile_id, target_profile_id, status, message, requested_at, expires_at, responded_at, cooldown_until, entitlement_balance_id, created_at, updated_at) values
  ('426dda67-8ff8-52f7-8426-558af6b32f0b', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', null, 'd7a4c336-b6f4-5079-a4ad-c47b4044a740', 'accepted', null, '2026-05-23 21:31:05', null, '2026-05-27 23:47:13', null, null, '2026-05-23 21:31:05', '2026-05-27 23:47:13');

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

-- 3A.32 cm_inbox_threads
insert into cm_inbox_threads (id, user_id, category, subject_type, subject_id, status, created_at, updated_at) values
  ('b8ce280f-3553-56b7-999f-d9cb6caa3acf', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'system', 'profile', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'open', '2026-05-20 09:00:00', '2026-05-28 08:30:00'),
  ('d85453a8-274f-566e-8343-e2534ae2fed7', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'system', null, null, 'open', '2026-05-28 06:00:00', '2026-06-01 09:00:00'),
  ('b7698c02-482b-52ce-9c48-ecd94d0a45b1', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'system', 'event', '0ed043fe-531a-511d-940b-5daa55de963e', 'open', '2026-05-25 14:00:00', '2026-05-27 10:00:00');

-- 3A.33 cm_inbox_messages
insert into cm_inbox_messages (id, thread_id, sender_type, sender_user_id, message_type, body, template_code, template_locale, action_type, action_payload, created_at, updated_at) values
  ('dafef4e8-ea97-5808-952a-fcb763a9ee8e', 'b8ce280f-3553-56b7-999f-d9cb6caa3acf', 'system', null, 'system_notice', '你的资料 p-001 平台审核已通过，现状态变更为 open。', 'profile_review_approved', 'zh', null, null, '2026-05-20 09:00:00', '2026-05-20 09:00:00'),
  ('e1b35056-d725-5437-8f19-9590a8edc873', 'b8ce280f-3553-56b7-999f-d9cb6caa3acf', 'system', null, 'text', '你的资料已完成身份认证，可信度已提升。', 'identity_verified', 'zh', null, null, '2026-05-28 08:30:00', '2026-05-28 08:30:00'),
  ('42e5b69a-ad71-56c4-9394-d6b67170e563', 'b7698c02-482b-52ce-9c48-ecd94d0a45b1', 'system', null, 'system_notice', '你报名的活动《巴黎春季交流酒会》报名已确认。', 'event_registration_confirmed', 'zh', null, null, '2026-05-25 14:00:00', '2026-05-25 14:00:00'),
  ('f4a77fc1-6370-5719-b596-b4ea5c0e0c14', 'b7698c02-482b-52ce-9c48-ecd94d0a45b1', 'system', null, 'text', '活动地址：巴黎 8 区 Rue du Faubourg Saint-Honore 25 号。请提前 15 分钟到场。', 'event_reminder', 'zh', null, null, '2026-05-27 10:00:00', '2026-05-27 10:00:00'),
  ('0fc92207-16a5-5a1f-ae42-cc856d2b40a6', 'd85453a8-274f-566e-8343-e2534ae2fed7', 'system', null, 'text', '欢迎使用相约巴黎！你可以创建资料、浏览活动、收藏感兴趣的会员。', 'welcome_message', 'zh', null, null, '2026-05-28 06:00:00', '2026-05-28 06:00:00');

-- 3A.34 cm_inbox_reads
insert into cm_inbox_reads (id, thread_id, user_id, last_read_at, created_at, updated_at) values
  ('59a024c0-aa7b-5075-8dcc-d13d777318a0', 'd85453a8-274f-566e-8343-e2534ae2fed7', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-05-28 07:00:00', '2026-05-28 07:00:00', '2026-05-28 07:00:00'),
  ('58938e35-a25f-57f3-816b-047224a3777d', 'b8ce280f-3553-56b7-999f-d9cb6caa3acf', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '2026-05-28 00:13:32', '2026-05-28 00:13:32', '2026-05-28 00:13:32');

-- ============================================================================
-- Section 4: Admin Review Test Data (Phase 8.2.4 adapted)
-- ============================================================================

-- 4A. Test users
insert into cm_users (id, account_name, avatar_url, preferred_locale, status, created_at, updated_at) values
  ('90000000-0000-4000-8000-000000000001', '审核测试用户 A', '', 'zh', 'active', now(), now()),
  ('90000000-0000-4000-8000-000000000002', '审核测试用户 B', '', 'zh', 'active', now(), now()),
  ('90000000-0000-4000-8000-000000000003', '审核测试用户 C', '', 'zh', 'active', now(), now());

-- 4B. Test profiles (Phase 8.2.4: added 5 new columns)
insert into cm_profiles (
  id, profile_type, gender, birth_year, height, city_code, country_code, nationality_code,
  profile_status, last_active_at, family_visible, degree_level, education_code, industry_code,
  relationship_goal_code, residence_plan_code, preferred_education_code, family_life_code, exercise_code,
  marital_status, has_children, children_plan, accepts_long_distance, dating_intention_code,
  relocation, preferred_age_min, preferred_age_max, preferred_location, smoking, drinking,
  activity_level, weekend_style, pets, communication_style, archived_at, created_at, updated_at
) values
  ('11111111-1111-4111-8111-111111111111', 'self', 'female', 1994, 168, 'FR:paris', 'FR', 'CN',
   'review', now(), 0, 'master', 'business_school', 'tech',
   'other', 'other', 'other', 'other', 'other',
   'never_married', 0, 'open_to_discuss', 1, 'marriage',
   'open_to_discuss', 30, 38, 'international', 'never', 'social',
   'moderate', 'social', 'likes', 'direct', null, now(), now()),
  ('22222222-2222-4222-8222-222222222222', 'family', 'male', 1990, 180, 'CN:shanghai', 'CN', 'CN',
   'open', now(), 1, 'bachelor', 'engineering', 'finance',
   'other', 'other', 'other', 'other', 'other',
   'never_married', 0, 'wants', 0, 'serious',
   'willing', 28, 36, 'regional', 'never', 'never',
   'high', 'outdoors', 'none', 'balanced', null, now(), now()),
  ('33333333-3333-4333-8333-333333333333', 'self', 'female', 1988, 165, 'FR:lyon', 'FR', 'FR',
   'review', now(), 0, 'phd', 'other', 'education',
   'other', 'other', 'other', 'other', 'other',
   'divorced', 1, 'does_not_want', 1, 'cross_border',
   'open_to_discuss', 35, 45, 'international', 'never', 'social',
   'moderate', 'indoors', 'has', 'indirect', null, now(), now());

-- 4C. Profile ownerships
insert into cm_profile_ownerships (
  id, user_id, profile_id, relationship_to_profile, permission, status,
  invited_by_user_id, accepted_at, revoked_at, created_at, updated_at
) values
  ('91000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'self', 'owner', 'active', null, now(), null, now(), now()),
  ('91000000-0000-4000-8000-000000000002', '90000000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'mother', 'manager', 'active', null, now(), null, now(), now()),
  ('91000000-0000-4000-8000-000000000003', '90000000-0000-4000-8000-000000000003', '33333333-3333-4333-8333-333333333333', 'self', 'owner', 'active', null, now(), null, now(), now());

-- 4D. Internal records
insert into cm_profile_internal_records (id, profile_id, is_featured, source, updated_by_user_id, created_at, updated_at) values
  ('92000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 0, 'self_submitted', null, now(), now()),
  ('92000000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 0, 'family_submitted', null, now(), now()),
  ('92000000-0000-4000-8000-000000000003', '33333333-3333-4333-8333-333333333333', 0, 'self_submitted', null, now(), now());

-- 4E. Localized fields (Phase 8.2.4: ONLY profile_name, career_direction, summary)
insert into cm_profile_localized_fields (id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('93000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'profile_name', 'zh', '审核测试 A', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'profile_name', 'fr', 'Test moderation A', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'profile_name', 'en', 'Review test A', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000008', '11111111-1111-4111-8111-111111111111', 'career_direction', 'zh', '产品经理', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000023', '11111111-1111-4111-8111-111111111111', 'career_direction', 'fr', 'Product manager', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000024', '11111111-1111-4111-8111-111111111111', 'career_direction', 'en', 'Product manager', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000009', '11111111-1111-4111-8111-111111111111', 'summary', 'zh', '测试资料：用于验证资料审核通过后按钮禁用和审计写入。', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000010', '11111111-1111-4111-8111-111111111111', 'summary', 'fr', 'Profil de test pour verifier la moderation multilingue.', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000011', '11111111-1111-4111-8111-111111111111', 'summary', 'en', 'Test profile for multilingual moderation checks.', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000101', '22222222-2222-4222-8222-222222222222', 'profile_name', 'zh', '审核测试 B', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000102', '22222222-2222-4222-8222-222222222222', 'profile_name', 'fr', 'Test moderation B', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000103', '22222222-2222-4222-8222-222222222222', 'profile_name', 'en', 'Review test B', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000106', '22222222-2222-4222-8222-222222222222', 'career_direction', 'zh', '投融资', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000121', '22222222-2222-4222-8222-222222222222', 'career_direction', 'fr', 'Investissement et financement', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000122', '22222222-2222-4222-8222-222222222222', 'career_direction', 'en', 'Investment and financing', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000107', '22222222-2222-4222-8222-222222222222', 'summary', 'zh', '测试资料：资料本身已开放，但照片仍在待审核。', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000201', '33333333-3333-4333-8333-333333333333', 'profile_name', 'zh', '审核测试 C', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000202', '33333333-3333-4333-8333-333333333333', 'profile_name', 'fr', 'Test moderation C', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000203', '33333333-3333-4333-8333-333333333333', 'profile_name', 'en', 'Review test C', 'machine', 'translation_api', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000206', '33333333-3333-4333-8333-333333333333', 'career_direction', 'zh', '公共政策研究', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000221', '33333333-3333-4333-8333-333333333333', 'career_direction', 'fr', 'Recherche en politiques publiques', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000222', '33333333-3333-4333-8333-333333333333', 'career_direction', 'en', 'Public policy research', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000207', '33333333-3333-4333-8333-333333333333', 'summary', 'zh', '测试资料：用于验证认证待审核状态和三语言展示。', 'manual', 'human', 'ready', now(), now());

-- 4F. Option extra texts (Phase 8.2.4: moved from localized_fields for education and industry)
insert into cm_profile_option_extra_texts (id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('93000000-0000-4000-8000-000000000018', '11111111-1111-4111-8111-111111111111', 'education', 'zh', '商学院', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000019', '11111111-1111-4111-8111-111111111111', 'education', 'fr', 'Ecole de commerce', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000020', '11111111-1111-4111-8111-111111111111', 'education', 'en', 'Business school', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000007', '11111111-1111-4111-8111-111111111111', 'industry', 'zh', '科技产品', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000021', '11111111-1111-4111-8111-111111111111', 'industry', 'fr', 'Produit tech', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000022', '11111111-1111-4111-8111-111111111111', 'industry', 'en', 'Tech product', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000116', '22222222-2222-4222-8222-222222222222', 'education', 'zh', '工程', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000117', '22222222-2222-4222-8222-222222222222', 'education', 'fr', 'Ingenierie', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000118', '22222222-2222-4222-8222-222222222222', 'education', 'en', 'Engineering', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000105', '22222222-2222-4222-8222-222222222222', 'industry', 'zh', '金融科技', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000119', '22222222-2222-4222-8222-222222222222', 'industry', 'fr', 'Fintech', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000120', '22222222-2222-4222-8222-222222222222', 'industry', 'en', 'Fintech', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000216', '33333333-3333-4333-8333-333333333333', 'education', 'zh', '公共政策', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000217', '33333333-3333-4333-8333-333333333333', 'education', 'fr', 'Politiques publiques', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000218', '33333333-3333-4333-8333-333333333333', 'education', 'en', 'Public policy', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000205', '33333333-3333-4333-8333-333333333333', 'industry', 'zh', '教育研究', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000219', '33333333-3333-4333-8333-333333333333', 'industry', 'fr', 'Recherche en education', 'manual', 'human', 'ready', now(), now()),
  ('93000000-0000-4000-8000-000000000220', '33333333-3333-4333-8333-333333333333', 'industry', 'en', 'Education research', 'manual', 'human', 'ready', now(), now());

-- 4G. Localized items
insert into cm_profile_localized_items (id, profile_id, field_name, item_order, locale, value, source, provider, status, created_at, updated_at) values
  ('94000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'tags', 0, 'zh', '待审核', 'manual', 'human', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'tags', 0, 'fr', 'A moderer', 'machine', 'translation_api', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'tags', 0, 'en', 'Pending review', 'machine', 'translation_api', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000004', '22222222-2222-4222-8222-222222222222', 'tags', 0, 'zh', '照片待审', 'manual', 'human', 'ready', now(), now()),
  ('94000000-0000-4000-8000-000000000005', '33333333-3333-4333-8333-333333333333', 'tags', 0, 'zh', '认证待审', 'manual', 'human', 'ready', now(), now());

-- 4H. Photos
insert into cm_profile_photos (id, profile_id, url, is_primary, sort_order, status, created_at, updated_at) values
  ('aaaa1111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'https://picsum.photos/seed/admin-review-a-1/900/1200', 1, 1, 'review', now(), now()),
  ('aaaa2222-2222-4222-8222-222222222222', '22222222-2222-4222-8222-222222222222', 'https://picsum.photos/seed/admin-review-b-1/900/1200', 1, 1, 'review', now(), now()),
  ('aaaa3333-3333-4333-8333-333333333333', '33333333-3333-4333-8333-333333333333', 'https://picsum.photos/seed/admin-review-c-1/900/1200', 1, 1, 'review', now(), now());

-- 4I. Verifications
insert into cm_profile_verifications (
  id, profile_id, legal_name, date_of_birth, identity_status, education_status,
  income_status, marital_status, review_status, verified_at, verified_by_user_id,
  created_at, updated_at
) values
  ('95000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'Test A', '1994-03-12', 'pending', 'pending', 'pending', 'pending', 'pending', null, null, now(), now()),
  ('95000000-0000-4000-8000-000000000002', '22222222-2222-4222-8222-222222222222', 'Test B', '1990-08-20', 'verified', 'verified', 'verified', 'verified', 'approved', now(), '1', now(), now()),
  ('95000000-0000-4000-8000-000000000003', '33333333-3333-4333-8333-333333333333', 'Test C', '1988-11-05', 'pending', 'rejected', 'pending', 'unverified', 'pending', null, null, now(), now());

-- 4J. Verification materials
insert into cm_profile_verification_materials (
  id, profile_id, material_type, status, legal_name, date_of_birth,
  material_name, material_url, scan_status, scan_message, review_note,
  submitted_by_user_id, submitted_at, reviewed_by_user_id, reviewed_at, rejection_reason, created_at, updated_at
) values
  ('96000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'identity', 'pending', 'Test A', '1994-03-12',
   '护照首页照片', 'private://verification/11111111/identity/passport-front-20260615.jpg', 'passed', null, '用户提交身份证明信息。',
   '90000000-0000-4000-8000-000000000001', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'education', 'pending', null, null,
   '硕士学位证书', 'private://verification/11111111/education/master-diploma-20260615.pdf', 'passed', null, '法国商学院硕士材料。',
   '90000000-0000-4000-8000-000000000001', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'income', 'pending', null, null,
   '近一年税单', 'private://verification/11111111/income/tax-statement-2025.pdf', 'passed', null, '近一年收入证明。',
   '90000000-0000-4000-8000-000000000001', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111', 'marital', 'pending', null, null,
   '未婚声明', 'private://verification/11111111/marital/single-status-declaration.pdf', 'passed', null, '婚姻状态声明。',
   '90000000-0000-4000-8000-000000000001', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000005', '22222222-2222-4222-8222-222222222222', 'identity', 'approved', 'Test B', '1990-08-20',
   '身份证正反面', 'private://verification/22222222/identity/id-card-combined.png', 'passed', null, '历史通过材料。',
   '90000000-0000-4000-8000-000000000002', now(), '1', now(), null, now(), now()),
  ('96000000-0000-4000-8000-000000000006', '22222222-2222-4222-8222-222222222222', 'education', 'approved', null, null,
   '本科学位证书', 'private://verification/22222222/education/bachelor-degree.pdf', 'passed', null, '历史通过材料。',
   '90000000-0000-4000-8000-000000000002', now(), '1', now(), null, now(), now()),
  ('96000000-0000-4000-8000-000000000007', '33333333-3333-4333-8333-333333333333', 'identity', 'pending', 'Test C', '1988-11-05',
   '护照扫描件', 'private://verification/33333333/identity/passport-scan-20260615.pdf', 'passed', null, '用户重新提交身份信息。',
   '90000000-0000-4000-8000-000000000003', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000008', '33333333-3333-4333-8333-333333333333', 'education', 'rejected', null, null,
   '博士学位证书', 'private://verification/33333333/education/phd-degree-blurry.jpg', 'passed', null, '扫描件不清晰。',
   '90000000-0000-4000-8000-000000000003', now(), '1', now(), '图片不清晰，请重新上传。', now(), now()),
  ('96000000-0000-4000-8000-000000000009', '33333333-3333-4333-8333-333333333333', 'income', 'pending', null, null,
   '自由职业收入说明', 'private://verification/33333333/income/freelance-income-statement.pdf', 'passed', null, '自由职业收入说明。',
   '90000000-0000-4000-8000-000000000003', now(), null, null, null, now(), now()),
  ('96000000-0000-4000-8000-000000000010', '33333333-3333-4333-8333-333333333333', 'marital', 'approved', null, null,
   '离婚证明', 'private://verification/33333333/marital/divorce-certificate.pdf', 'passed', null, '历史通过材料。',
   '90000000-0000-4000-8000-000000000003', now(), '1', now(), null, now(), now()),
  ('96000000-0000-4000-8000-000000000011', '22222222-2222-4222-8222-222222222222', 'income', 'approved', null, null,
   '雇主收入证明', 'private://verification/22222222/income/employer-income-letter.pdf', 'passed', null, 'HR 出具收入证明。',
   '90000000-0000-4000-8000-000000000002', now(), '1', now(), null, now(), now()),
  ('96000000-0000-4000-8000-000000000012', '22222222-2222-4222-8222-222222222222', 'marital', 'rejected', null, null,
   '婚姻状态截图', 'private://verification/22222222/marital/marital-status-screenshot.webp', 'passed', null, '材料缺少官方抬头。',
   '90000000-0000-4000-8000-000000000002', now(), '1', now(), '材料类型不符合认证要求。', now(), now());

-- ============================================================================
-- Section 5: Additional Varied-Status Test Data
-- ============================================================================

-- 5A. Extra users (varied statuses)
insert into cm_users (id, account_name, avatar_url, preferred_locale, status, created_at, updated_at) values
  ('d0000000-0000-4000-8000-000000000004', '用户 D (已停用)', '', 'zh', 'deactivated', '2026-03-15 00:00:00', '2026-05-01 00:00:00'),
  ('e0000000-0000-4000-8000-000000000005', '用户 E (暂停)', '', 'zh', 'suspended', '2026-04-01 00:00:00', '2026-06-01 00:00:00'),
  ('f0000000-0000-4000-8000-000000000006', '用户 F (新用户)', '', 'zh', 'active', now(), now());

-- 5B. Extra profiles (varied statuses)
insert into cm_profiles (
  id, profile_type, gender, birth_year, height, city_code, country_code, nationality_code,
  profile_status, last_active_at, family_visible, degree_level, education_code, industry_code,
  relationship_goal_code, residence_plan_code, preferred_education_code, family_life_code, exercise_code,
  marital_status, has_children, children_plan, accepts_long_distance, dating_intention_code,
  relocation, preferred_age_min, preferred_age_max, preferred_location, smoking, drinking,
  activity_level, weekend_style, pets, communication_style, archived_at, created_at, updated_at
) values
  ('dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'self', 'male', 1998, 182, 'FR:lyon', 'FR', 'FR',
   'draft', now(), 0, 'bachelor', 'bachelor_general', 'other',
   'other', 'other', 'other', 'other', 'other',
   'never_married', 0, 'open_to_discuss', 1, 'serious',
   'willing', 22, 30, 'regional', 'never', 'social',
   'high', 'outdoors', 'likes', 'direct', null, now(), now()),
  ('eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'self', 'female', 1985, 165, 'FR:nice', 'FR', 'FR',
   'paused', now(), 0, 'master', 'master_general', 'education',
   'other', 'other', 'other', 'other', 'other',
   'divorced', 1, 'does_not_want', 1, 'exclusive',
   'willing', 38, 50, 'regional', 'never', 'social',
   'moderate', 'social', 'none', 'balanced', null, now(), now()),
  ('ffffffff-ffff-4fff-8fff-ffffffffffff', 'self', 'male', 1978, 175, 'FR:marseille', 'FR', 'FR',
   'hidden', now(), 0, 'bachelor', 'bachelor_general', 'finance',
   'other', 'other', 'other', 'other', 'other',
   'never_married', 0, 'wants', 1, 'marriage',
   'willing', 35, 48, 'national', 'never', 'social',
   'low', 'indoors', 'has', 'indirect', null, now(), now());

-- 5B2. Profile ownerships for extra profiles
insert into cm_profile_ownerships (id, user_id, profile_id, relationship_to_profile, permission, status, invited_by_user_id, accepted_at, revoked_at, created_at, updated_at) values
  ('d1111111-1111-4111-8111-dddddddddddd', 'd0000000-0000-4000-8000-000000000004', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'self', 'owner', 'active', null, now(), null, now(), now()),
  ('e1111111-1111-4111-8111-eeeeeeeeeeee', 'e0000000-0000-4000-8000-000000000005', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'self', 'owner', 'active', null, now(), null, now(), now());

-- 5B3. Internal records for extra profiles
insert into cm_profile_internal_records (id, profile_id, is_featured, source, updated_by_user_id, created_at, updated_at) values
  ('d2222222-2222-4222-8222-dddddddddddd', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 0, 'self_submitted', null, now(), now()),
  ('e2222222-2222-4222-8222-eeeeeeeeeeee', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 0, 'self_submitted', null, now(), now()),
  ('f2222222-2222-4222-8222-ffffffffffff', 'ffffffff-ffff-4fff-8fff-ffffffffffff', 0, 'self_submitted', null, now(), now());

-- 5C. Extra memberships (varied statuses)
insert into cm_user_memberships (id, user_id, plan_id, tier, status, started_at, expires_at, created_at, updated_at) values
  ('d3000000-0000-4000-8000-000000000004', 'd0000000-0000-4000-8000-000000000004', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'silver', 'expired', '2026-01-01 00:00:00', '2026-04-01 00:00:00', '2026-01-01 00:00:00', '2026-04-01 00:00:00'),
  ('f3000000-0000-4000-8000-000000000006', 'f0000000-0000-4000-8000-000000000006', 'f04881cf-b31f-50c5-8e73-c5f861d0bd7f', 'free', 'cancelled', '2026-06-01 00:00:00', null, '2026-06-01 00:00:00', '2026-06-15 00:00:00');

-- 5D. Extra events (varied statuses)
insert into cm_events (id, status, visibility, consumes_membership_quota, city_code, address_visibility, event_date, start_time, end_time, capacity, cover_image_url, created_at, updated_at) values
  ('0dd00000-0000-4000-8000-000000000001', 'draft', 'registered', 0, 'FR:paris', 'registered_only', '2026-08-15', '18:00', '21:00', 20, 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1200&q=80', now(), now()),
  ('0cc00000-0000-4000-8000-000000000001', 'completed', 'member', 1, 'FR:lyon', 'confirmed_attendee_only', '2026-04-10', '19:00', '22:00', 10, 'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?auto=format&fit=crop&w=1200&q=80', '2026-03-01 00:00:00', '2026-04-10 00:00:00');

-- 5D2. Event localized fields for extra events
insert into cm_event_localized_fields (id, event_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('dd100000-0000-4000-8000-000000000001', '0dd00000-0000-4000-8000-000000000001', 'title', 'zh', '秋季品酒交友', 'manual', 'human', 'ready', now(), now()),
  ('dd100000-0000-4000-8000-000000000002', '0dd00000-0000-4000-8000-000000000001', 'title', 'fr', 'Degustation de vin d automne', 'manual', 'human', 'ready', now(), now()),
  ('dd100000-0000-4000-8000-000000000003', '0dd00000-0000-4000-8000-000000000001', 'title', 'en', 'Autumn wine tasting mixer', 'manual', 'human', 'ready', now(), now()),
  ('dd100000-0000-4000-8000-000000000004', '0cc00000-0000-4000-8000-000000000001', 'title', 'zh', '里昂春季晚宴', 'manual', 'human', 'ready', now(), now()),
  ('dd100000-0000-4000-8000-000000000005', '0cc00000-0000-4000-8000-000000000001', 'title', 'fr', 'Diner de printemps a Lyon', 'manual', 'human', 'ready', now(), now()),
  ('dd100000-0000-4000-8000-000000000006', '0cc00000-0000-4000-8000-000000000001', 'title', 'en', 'Spring dinner in Lyon', 'manual', 'human', 'ready', now(), now());

-- 5E. Extra verification materials (varied scan statuses)
insert into cm_profile_verification_materials (
  id, profile_id, material_type, status, legal_name, date_of_birth,
  material_name, material_url, scan_status, scan_message, review_note,
  submitted_by_user_id, submitted_at, reviewed_by_user_id, reviewed_at, rejection_reason, created_at, updated_at
) values
  ('d4000000-0000-4000-8000-000000000001', 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'identity', 'rejected', null, null,
   '可疑身份证明', 'private://verification/draft-profile/suspicious-id.jpg', 'failed', 'virus_detected', '扫描检测到异常。',
   'd0000000-0000-4000-8000-000000000004', now(), null, null, '材料扫描未通过安全检查。', now(), now()),
  ('e4000000-0000-4000-8000-000000000001', 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'education', 'pending', null, null,
   '博士学位证书', 'private://verification/paused-profile/phd-cert.pdf', 'pending', null, '待系统扫描。',
   'e0000000-0000-4000-8000-000000000005', now(), null, null, null, now(), now());

-- 5F. Extra private introduction requests (varied statuses)
insert into cm_private_introduction_requests (id, requester_user_id, requester_profile_id, target_profile_id, status, message, requested_at, expires_at, responded_at, cooldown_until, entitlement_balance_id, created_at, updated_at) values
  ('d5000000-0000-4000-8000-000000000001', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '503a9c99-2842-54db-8858-24fbd3108e3b', '506ce3c7-b236-5b44-b8d0-459c4250ea03', 'declined', '希望可以认识一下。', '2026-05-10 14:00:00', null, '2026-05-12 10:00:00', null, null, '2026-05-10 14:00:00', '2026-05-12 10:00:00'),
  ('d5000000-0000-4000-8000-000000000002', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '503a9c99-2842-54db-8858-24fbd3108e3b', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'cancelled', null, '2026-05-20 09:00:00', null, null, null, null, '2026-05-20 09:00:00', '2026-05-21 18:00:00'),
  ('d5000000-0000-4000-8000-000000000003', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', '503a9c99-2842-54db-8858-24fbd3108e3b', 'f82cb5a2-dfc7-5075-9f2a-f72498fc7642', 'requested', '希望平台评估是否适合安排一次私人介绍。', '2026-06-24 09:30:00', '2026-07-01 09:30:00', null, null, '202f036e-42b5-506e-9509-1cfb4960555f', '2026-06-24 09:30:00', '2026-06-24 09:30:00');

-- 5G. Extra inbox threads and messages (system notifications)
insert into cm_inbox_threads (id, user_id, category, subject_type, subject_id, status, created_at, updated_at) values
  ('d6000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000004', 'system', null, null, 'open', '2026-05-01 12:00:00', '2026-05-01 12:00:00'),
  ('d6000000-0000-4000-8000-000000000003', 'e0000000-0000-4000-8000-000000000005', 'system', null, null, 'open', '2026-06-01 08:00:00', '2026-06-01 08:00:00');

-- 5G2. Extra inbox messages
insert into cm_inbox_messages (id, thread_id, sender_type, sender_user_id, message_type, body, template_code, template_locale, action_type, action_payload, created_at, updated_at) values
  ('d6100000-0000-4000-8000-000000000001', 'd85453a8-274f-566e-8343-e2534ae2fed7', 'system', null, 'system_notice', '您的会员即将到期，请及时续费以保持权益。', 'membership_expiring', 'zh', null, null, '2026-06-01 09:00:00', '2026-06-01 09:00:00'),
  ('d6100000-0000-4000-8000-000000000002', 'd6000000-0000-4000-8000-000000000002', 'system', null, 'system_notice', '您的账号已被停用，如有疑问请联系客服。', 'account_deactivated', 'zh', null, null, '2026-05-01 12:00:00', '2026-05-01 12:00:00'),
  ('d6100000-0000-4000-8000-000000000003', 'd6000000-0000-4000-8000-000000000003', 'system', null, 'system_notice', '您的账号已被暂停，如需恢复请联系客服。', 'account_suspended', 'zh', null, null, '2026-06-01 08:00:00', '2026-06-01 08:00:00');

-- 5H. Extra event registrations (varied statuses)
insert into cm_event_registrations (id, user_id, event_id, status, requested_at, confirmed_at, declined_at, waitlisted_at, cancelled_at, attended_at, event_quota_consumed_at, event_quota_released_at, created_at, updated_at) values
  ('d7000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000004', '0cc00000-0000-4000-8000-000000000001', 'attended', '2026-03-15 10:00:00', '2026-03-16 10:00:00', null, null, null, '2026-04-10 19:00:00', null, null, '2026-03-15 10:00:00', '2026-04-10 23:00:00'),
  ('d7000000-0000-4000-8000-000000000003', 'e0000000-0000-4000-8000-000000000005', '1bcb995a-540c-5c66-9b92-52471c43e587', 'declined', '2026-05-20 14:00:00', null, '2026-05-22 10:00:00', null, null, null, null, null, '2026-05-20 14:00:00', '2026-05-22 10:00:00');

-- 5I. Staff tasks (varied statuses and priorities)
insert into cm_staff_tasks (id, assignee_sys_user_id, subject_type, subject_id, status, priority, due_at, completed_at, created_at, updated_at) values
  ('d8000000-0000-4000-8000-000000000001', 1, 'profile', '11111111-1111-4111-8111-111111111111', 'open', 'high', '2026-06-30 23:59:59', null, now(), now()),
  ('d8000000-0000-4000-8000-000000000002', 1, 'profile', '22222222-2222-4222-8222-222222222222', 'done', 'normal', '2026-06-15 23:59:59', '2026-06-14 10:00:00', '2026-06-01 00:00:00', '2026-06-14 10:00:00'),
  ('d8000000-0000-4000-8000-000000000003', 2, 'user', 'e0000000-0000-4000-8000-000000000005', 'snoozed', 'low', '2026-07-15 23:59:59', null, '2026-06-10 00:00:00', '2026-06-15 00:00:00');

-- 5I2. Staff task localized fields
insert into cm_staff_task_localized_fields (id, staff_task_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('d8100000-0000-4000-8000-000000000001', 'd8000000-0000-4000-8000-000000000001', 'note', 'zh', '需要优先审核资料 A，用户已提交全部认证材料。', 'manual', 'human', 'ready', now(), now()),
  ('d8100000-0000-4000-8000-000000000002', 'd8000000-0000-4000-8000-000000000002', 'note', 'zh', '资料 B 审核已完成，照片和认证均已通过。', 'manual', 'human', 'ready', '2026-06-14 10:00:00', '2026-06-14 10:00:00'),
  ('d8100000-0000-4000-8000-000000000003', 'd8000000-0000-4000-8000-000000000003', 'note', 'zh', '用户 E 暂停原因待确认，暂时延后处理。', 'manual', 'human', 'ready', now(), now());

-- 5J. Orders and payments
insert into cm_orders (id, user_id, plan_id, status, amount_cents, currency, created_at, updated_at) values
  ('d9000000-0000-4000-8000-000000000001', 'efdca298-c977-5502-ad2e-8ba480ca1ea3', 'eaf73332-f7d1-5f4b-82ba-11368eac30b6', 'paid', 10000, 'EUR', '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('d9000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000004', 'f2886d5f-1d2a-5fed-9b4f-8b23f2067f06', 'refunded', 6500, 'EUR', '2026-01-01 00:00:00', '2026-03-01 00:00:00');

-- 5J2. Payment records
insert into cm_payments (id, order_id, provider, provider_payment_id, status, amount_cents, currency, paid_at, created_at, updated_at) values
  ('d9100000-0000-4000-8000-000000000001', 'd9000000-0000-4000-8000-000000000001', 'stripe', 'pi_3NxK8qABCDEFGHIJKL', 'succeeded', 10000, 'EUR', '2026-01-18 00:00:00', '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('d9100000-0000-4000-8000-000000000002', 'd9000000-0000-4000-8000-000000000002', 'stripe', 'pi_3NxK8qMNOPQRSTUVWX', 'succeeded', 6500, 'EUR', '2026-01-01 00:00:00', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('d9100000-0000-4000-8000-000000000003', 'd9000000-0000-4000-8000-000000000002', 'stripe', 're_3NxK8qYZABCDEFGHIJ', 'refunded', 6500, 'EUR', '2026-03-01 00:00:00', '2026-03-01 00:00:00', '2026-03-01 00:00:00');

-- 5K. Audit logs
insert into cm_audit_logs (id, actor_type, actor_user_id, subject_type, subject_id, action, before_data, after_data, reason, created_at) values
  ('da000000-0000-4000-8000-000000000001', 'staff', '1', 'profile', '11111111-1111-4111-8111-111111111111', 'profile_review_approved', null, '{"profile_status":"open"}', '资料信息真实完整，审核通过。', '2026-06-15 10:00:00'),
  ('da000000-0000-4000-8000-000000000002', 'staff', '1', 'profile', '22222222-2222-4222-8222-222222222222', 'photo_review_approved', null, '{"photo_status":"approved"}', '照片符合平台规范。', '2026-06-15 11:00:00'),
  ('da000000-0000-4000-8000-000000000003', 'staff', '1', 'profile', '33333333-3333-4333-8333-333333333333', 'verification_review_rejected', '{"education_status":"pending"}', '{"education_status":"rejected"}', '学历材料不清晰。', '2026-06-16 09:00:00'),
  ('da000000-0000-4000-8000-000000000004', 'system', null, 'user', 'd0000000-0000-4000-8000-000000000004', 'user_deactivated', '{"status":"active"}', '{"status":"deactivated"}', '用户主动申请停用。', '2026-05-01 12:00:00'),
  ('da000000-0000-4000-8000-000000000005', 'staff', '2', 'user', 'e0000000-0000-4000-8000-000000000005', 'user_suspended', '{"status":"active"}', '{"status":"suspended"}', '违规行为调查中。', '2026-06-01 08:00:00'),
  ('da000000-0000-4000-8000-000000000006', 'staff', '1', 'verification_material', '96000000-0000-4000-8000-000000000008', 'verification_material_rejected', null, '{"status":"rejected"}', '图片不清晰，请重新上传。', '2026-06-16 10:00:00');
