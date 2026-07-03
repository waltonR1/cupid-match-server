-- Phase 9.5：Quartz 真实业务任务
-- 本文件用于已有数据库的一次性升级；全量重建请直接执行 cm_schema.sql 和 cm_seed.sql。

set @cm_sql = if(
  exists (
    select 1 from information_schema.statistics
    where table_schema = database()
      and table_name = 'cm_private_introduction_requests'
      and index_name = 'idx_cm_intro_status_expires'
  ),
  'select 1',
  'alter table cm_private_introduction_requests add key idx_cm_intro_status_expires (status, expires_at)'
);
prepare cm_stmt from @cm_sql;
execute cm_stmt;
deallocate prepare cm_stmt;

set @cm_sql = if(
  exists (
    select 1 from information_schema.statistics
    where table_schema = database()
      and table_name = 'cm_user_memberships'
      and index_name = 'idx_cm_user_memberships_status_expires'
  ),
  'select 1',
  'alter table cm_user_memberships add key idx_cm_user_memberships_status_expires (status, expires_at)'
);
prepare cm_stmt from @cm_sql;
execute cm_stmt;
deallocate prepare cm_stmt;

set @cm_sql = if(
  exists (
    select 1 from information_schema.statistics
    where table_schema = database()
      and table_name = 'cm_user_security_challenges'
      and index_name = 'idx_cm_security_challenge_status_expires'
  ),
  'select 1',
  'alter table cm_user_security_challenges add key idx_cm_security_challenge_status_expires (status, expires_at)'
);
prepare cm_stmt from @cm_sql;
execute cm_stmt;
deallocate prepare cm_stmt;

insert into sys_dict_data (
  dict_sort, dict_label, dict_value, dict_type, css_class, list_class,
  is_default, status, create_by, create_time, remark
)
select
  3, 'Cupid业务', 'CUPID', 'sys_job_group', '', 'primary',
  'N', '0', 'admin', sysdate(), 'Cupid业务任务分组'
where not exists (
  select 1 from sys_dict_data
  where dict_type = 'sys_job_group' and dict_value = 'CUPID'
);

insert into sys_config (
  config_name, config_key, config_value, config_type,
  create_by, create_time, remark
)
select
  'Cupid-定时维护批量大小', 'cupid.scheduler.batchSize', '500', 'Y',
  'admin', sysdate(), '允许范围50-2000，非法值自动回退为500'
where not exists (
  select 1 from sys_config
  where config_key = 'cupid.scheduler.batchSize'
);

insert into sys_job (
  job_name, job_group, invoke_target, cron_expression,
  misfire_policy, concurrent, status, create_by, create_time, remark
)
select
  '私人介绍过期补偿', 'CUPID', 'cupidTask.expireIntroductionRequests',
  '0 */10 * * * ?', '3', '1', '0', 'admin', sysdate(),
  '处理过期私人介绍申请并返还权益'
where not exists (
  select 1 from sys_job
  where job_group = 'CUPID'
    and invoke_target = 'cupidTask.expireIntroductionRequests'
);

insert into sys_job (
  job_name, job_group, invoke_target, cron_expression,
  misfire_policy, concurrent, status, create_by, create_time, remark
)
select
  '安全挑战过期清理', 'CUPID', 'cupidTask.expireSecurityChallenges',
  '30 */10 * * * ?', '3', '1', '0', 'admin', sysdate(),
  '标记已过期的安全挑战'
where not exists (
  select 1 from sys_job
  where job_group = 'CUPID'
    and invoke_target = 'cupidTask.expireSecurityChallenges'
);

insert into sys_job (
  job_name, job_group, invoke_target, cron_expression,
  misfire_policy, concurrent, status, create_by, create_time, remark
)
select
  '会员到期状态同步', 'CUPID', 'cupidTask.expireMemberships',
  '0 5 * * * ?', '3', '1', '0', 'admin', sysdate(),
  '将超过有效期的有效会员同步为已过期'
where not exists (
  select 1 from sys_job
  where job_group = 'CUPID'
    and invoke_target = 'cupidTask.expireMemberships'
);
