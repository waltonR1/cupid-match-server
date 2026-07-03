-- Phase 9.7：高风险运维能力收口
-- 本文件用于已有数据库的一次性升级；全量重建请直接执行 cm_schema.sql 和 cm_seed.sql。

insert into sys_menu (
  menu_id, menu_name, parent_id, order_num, path, component,
  query, route_name, is_frame, is_cache, menu_type, visible, status,
  perms, icon, create_by, create_time, remark
)
select
  1061, '缓存清理', 114, 1, '#', '',
  '', '', 1, 0, 'F', '0', '0',
  'monitor:cache:clear', '#', 'admin', sysdate(), '缓存清理操作'
where not exists (
  select 1 from sys_menu where perms = 'monitor:cache:clear'
);

delete rm
from sys_role_menu rm
join sys_role r on r.role_id = rm.role_id
where (r.role_key = 'common' or r.role_key like 'cupid\_%')
  and rm.menu_id in (
    105, 106, 109, 110, 113, 114,
    1025, 1026, 1027, 1028, 1029,
    1030, 1031, 1032, 1033, 1034,
    1046, 1047, 1048,
    1049, 1050, 1051, 1052, 1053, 1054,
    1061
  );
