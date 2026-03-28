set lines 500
col TARGET_NAME for a40
SELECT TARGET_NAME, TARGET_TYPE, AVAILABILITY_STATUS 
FROM MGMT$AVAILABILITY_CURRENT 
WHERE AVAILABILITY_STATUS_CODE IN ('0', '4');


set lines 500
col TARGET_NAME for a40
SELECT TARGET_NAME, TARGET_TYPE, AVAILABILITY_STATUS 
FROM MGMT$AVAILABILITY_CURRENT 
WHERE TARGET_TYPE in ('oracle_database','has');




set lines 500
col TARGET_NAME for a40
SELECT TARGET_NAME
FROM MGMT$AVAILABILITY_CURRENT 
WHERE TARGET_TYPE='has' and TARGET_NAME like 'has_cea%pr%' or TARGET_NAME like 'has_drs%';


set lines 500
col TARGET_NAME for a40
SELECT TARGET_NAME
FROM MGMT$AVAILABILITY_CURRENT 
WHERE TARGET_TYPE='has' and TARGET_NAME like 'has_cea%pr%' or TARGET_NAME like 'has_drs%'
order by 1;


SET echo on
with ds1_os as
(select t.target_name,
decode(p.property_value, 23, 'Oracle Solaris on SPARC (64-bit)',
233, 'Microsoft Windows x64 (64-bit)',
267, 'Oracle Solaris on x86-64 (64-bit)',
226, 'Linux x86-64') as OS_NAME, -- add more decode value as you wish
(SELECT PROPERTY_VALUE FROM SYSMAN.MGMT$TARGET_PROPERTIES WHERE PROPERTY_NAME='orcl_gtp_target_version' AND TARGET_GUID=T.TARGET_GUID) as OS_Version
from mgmt$target t, mgmt$target_properties p
where p.target_guid=t.target_guid
and p.target_type='host'
and p.property_value in (select property_value from mgmt$targeT_properties where property_name='ARUID'))
select db.TARGET_NAME, db.type_display_name, prop.PROPERTY_VALUE as DB_VERSION,
ds1_os.targeT_name as host_name, ds1_os.OS_NAME, ds1_os.OS_Version
from SYSMAN.MGMT$TARGET db, SYSMAN.MGMT$TARGET_PROPERTIES prop, ds1_os
where db.HOST_NAME = ds1_os.TARGET_NAME
and db.TARGET_GUID = prop.TARGET_GUID
and prop.PROPERTY_NAME='orcl_gtp_target_version'
and db.target_type in ('oracle_database','rac_database','osm_instance','cluster_asm', 'oracle_pdb', 'has')
order by 1;
