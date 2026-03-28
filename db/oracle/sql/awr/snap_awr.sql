# Lista os snapid gerado no banco de dados.

col instart_fmt noprint;
col inst_name format a12 heading 'Instance';
col db_name format a12 heading 'DB Name';
col snap_id format 99999990 heading 'Snap Id';
col snapdat format a18 heading 'Snap Started' just c;
col lvl format 99 heading 'Snap|Level';
set heading on;
break on inst_name on db_name on host on instart_fmt skip 1;
ttitle off;

SELECT TO_CHAR(s.startup_time) INST_START,
di.instance_name INST_NAME, di.db_name DB_NAME, s.snap_id SNAP_ID,
TO_CHAR(s.end_interval_time,'DD MON YYYY HH24:MI') SNAPDAT, s.snap_level LVL
FROM dba_hist_snapshot s, dba_hist_database_instance di
WHERE di.dbid = s.dbid
AND di.instance_number = s.instance_number
AND di.startup_time = s.startup_time
ORDER BY snap_id;