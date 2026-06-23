-- Cupid Match Phase 8.2.3 认证材料安全与治理增量迁移
-- 用途：为现有认证材料表补充安全检查字段和索引。

alter table cm_profile_verification_materials
  add column scan_status varchar(20) not null default 'passed' comment '安全检查状态' after material_url,
  add column scan_message varchar(255) default null comment '安全检查说明' after scan_status,
  add column scanned_at datetime default null comment '安全检查时间' after scan_message;

update cm_profile_verification_materials
set scan_status = 'passed',
    scan_message = coalesce(scan_message, 'legacy_material_without_file'),
    scanned_at = coalesce(scanned_at, now())
where scan_status is null
   or scan_status = ''
   or scanned_at is null;

create index idx_cm_profile_verification_materials_scan
  on cm_profile_verification_materials (scan_status, scanned_at);
