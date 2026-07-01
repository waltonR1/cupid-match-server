-- ---------------------------------------------------------------------------
-- Phase 9.1 - C-end security events
--
-- Scope:
--   1. Create Cupid security event table
--   2. Seed admin menu/buttons for security event center
--   3. Grant menu permissions to selected Cupid admin roles
--
-- Notes:
--   - This script is intended for incremental local/dev execution.
--   - It does not modify legacy Phase 8 SQL files.
--   - C-end security events must not be written into sys_logininfor.
-- ---------------------------------------------------------------------------

-- ============================================================================
-- 1. Security event table
-- ============================================================================

create table if not exists cm_security_events (
  id varchar(64) not null comment 'Primary ID',
  user_id varchar(64) default null comment 'Cupid user ID',
  identity_id varchar(64) default null comment 'Cupid auth identity ID',
  event_type varchar(64) not null comment 'Event type code',
  event_result varchar(32) not null comment 'Event result: success/failed/blocked',
  risk_level varchar(32) default null comment 'Risk level code',
  ip varchar(64) default null comment 'Client IP',
  user_agent varchar(512) default null comment 'Client user-agent',
  device_id varchar(128) default null comment 'Client device ID',
  detail_json text comment 'Structured event details',
  created_at datetime not null default current_timestamp comment 'Creation time',
  primary key (id),
  key idx_cm_security_events_user_time (user_id, created_at),
  key idx_cm_security_events_type_time (event_type, created_at),
  key idx_cm_security_events_result_time (event_result, created_at),
  key idx_cm_security_events_created_at (created_at)
) engine=innodb default charset=utf8mb4 collate=utf8mb4_general_ci comment='Cupid C-end security events';

-- ============================================================================
-- 2. Menu and button seed
-- ============================================================================

delete from sys_role_menu where menu_id in (2106, 2107, 2108);
delete from sys_menu where menu_id in (2106, 2107, 2108);

insert into sys_menu values
('2106', '安全事件', '2099', '3', 'security-event', 'cupid/security-event/index', '', 'CupidSecurityEvent', 1, 0, 'C', '0', '0', 'cupid:security:event:list', 'warning', 'admin', sysdate(), '', null, 'Cupid C端安全事件中心');

insert into sys_menu values
('2107', '安全事件查询', '2106', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:security:event:query', '#', 'admin', sysdate(), '', null, '');

insert into sys_menu values
('2108', '安全事件导出', '2106', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'cupid:security:event:export', '#', 'admin', sysdate(), '', null, '');

-- ============================================================================
-- 3. Role grants
-- ============================================================================

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id
from sys_role r
join sys_menu m on m.menu_id in (2106, 2107, 2108)
where r.role_key = 'cupid_admin'
  and r.del_flag = '0'
  and not exists (
    select 1 from sys_role_menu rm
    where rm.role_id = r.role_id and rm.menu_id = m.menu_id
  );

insert into sys_role_menu (role_id, menu_id)
select r.role_id, m.menu_id
from sys_role r
join sys_menu m on m.menu_id in (2099, 2106, 2107)
where r.role_key = 'cupid_auditor'
  and r.del_flag = '0'
  and not exists (
    select 1 from sys_role_menu rm
    where rm.role_id = r.role_id and rm.menu_id = m.menu_id
  );

-- Optional:
-- If later confirmed that cupid_support can view security events,
-- grant (2099, 2106, 2107) to role_key = 'cupid_support' in a follow-up patch.
