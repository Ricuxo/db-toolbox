SET MARKUP HTML ON SPOOL ON
set trimspool    on
set linesize         1000
set pagesize         200
col control      for a10
col schema       for a10
col version      for a10
col comp_name    for a36

Prompt ==============================================================
Prompt Nome do arquivo com diretóompt ==============================================================
Prompt

spool geral_$ORACLE_SID.html

Prompt ==============================================================
Prompt DATA EXECUTADO
Prompt ==============================================================

select to_char(sysdate, 'DD-MM-YYYY  HH:MI:SS') from dual;

Prompt ==============================================================
Prompt Versoes dos componentes
Prompt ==============================================================
Prompt

select * from v$version;

Prompt ==============================================================
Prompt NLS LANGUAGE
Prompt ==============================================================
Prompt

select * from nls_database_parameters;
Prompt
Prompt ==============================================================
Prompt Info Database
Prompt ==============================================================
Prompt

col name for a15
col PLATFORM_NAME for a20

select DBID, NAME, CREATED, LOG_MODE, OPEN_RESETLOGS, VERSION_TIME, OPEN_MODE,
       DATABASE_ROLE, PLATFORM_ID, PLATFORM_NAME, FLASHBACK_ON, DB_UNIQUE_NAME,force_logging
from v$database;

Prompt
Prompt ==============================================================
Prompt Info Character
Prompt ==============================================================
Prompt


select * from nls_database_parameters;


Prompt
Prompt ==============================================================
Prompt Info Instancia
Prompt ==============================================================
Prompt

col HOST_NAME for a20

select INST_ID, THREAD#, INSTANCE_NAME, HOST_NAME, VERSION, STATUS, PARALLEL,
       ARCHIVER, SHUTDOWN_PENDING, DATABASE_STATUS, BLOCKED
from gv$instance;

Prompt
Prompt ==============================================================
Prompt ControlFiles
Prompt ==============================================================
Prompt

col name for a60

select * from v$controlfile;

Prompt
Prompt ==============================================================
Prompt Datafiles
Prompt ==============================================================
Prompt

col file_name for a70

select tablespace_name, file_name, bytes, STATUS, ONLINE_STATUS
from dba_data_files order by 1,2;

Prompt
Prompt ==============================================================
Prompt SUM Datafiles
Prompt ==============================================================
Prompt


select sum(bytes)/1024/1024/1024
from dba_data_files;

Prompt
Prompt ==============================================================
Prompt Tempfiles
Prompt ==============================================================
Prompt

select tablespace_name, file_name, bytes, status from dba_temp_files;

Prompt
Prompt ==============================================================
Prompt Espaçlivre nos tablespaces
Prompt ==============================================================
Prompt

select  a.tablespace_name,
       round(a.bytes_alloc / 1024 / 1024) megs_alloc,
       round(nvl(b.bytes_free, 0) / 1024 / 1024) megs_free,
       round((a.bytes_alloc - nvl(b.bytes_free, 0)) / 1024 / 1024) megs_used,
       round((nvl(b.bytes_free, 0) / a.bytes_alloc) * 100) Pct_Free,
       100 - round((nvl(b.bytes_free, 0) / a.bytes_alloc) * 100) Pct_used,
       round(maxbytes/1048576) Max
from  ( select  f.tablespace_name,
               sum(f.bytes) bytes_alloc,
               sum(decode(f.autoextensible, 'YES',f.maxbytes,'NO', f.bytes)) maxbytes
        from dba_data_files f
        group by tablespace_name) a,
      ( select  f.tablespace_name,
               sum(f.bytes)  bytes_free
        from dba_free_space f
        group by tablespace_name) b
where a.tablespace_name = b.tablespace_name (+)
union all
select h.tablespace_name,
       round(sum(h.bytes_free + h.bytes_used) / 1048576) megs_alloc,
       round(sum((h.bytes_free + h.bytes_used) - nvl(p.bytes_used, 0)) / 1048576) megs_free,
       round(sum(nvl(p.bytes_used, 0))/ 1048576) megs_used,
       round((sum((h.bytes_free + h.bytes_used) - nvl(p.bytes_used, 0)) / sum(h.bytes_used + h.bytes_free)) * 100) Pct_Free,
       100 - round((sum((h.bytes_free + h.bytes_used) - nvl(p.bytes_used, 0)) / sum(h.bytes_used + h.bytes_free)) * 100) pct_used,
       round(sum(f.maxbytes) / 1048576) max
from   sys.v_$TEMP_SPACE_HEADER h, sys.v_$Temp_extent_pool p, dba_temp_files f
where  p.file_id(+) = h.file_id
and    p.tablespace_name(+) = h.tablespace_name
and    f.file_id = h.file_id
and    f.tablespace_name = h.tablespace_name
group by h.tablespace_name
ORDER BY 5 desc;

Prompt
Prompt ==============================================================
Prompt TAblespaces
Prompt ==============================================================
Prompt

select tablespace_name, block_size, status, contents,
       extent_management, segment_space_management,
       retention, bigfile, logging, allocation_type
from dba_tablespaces
order by tablespace_name;

Prompt
Prompt ==============================================================
Prompt LogFiles
Prompt ==============================================================
Prompt

col MEMBER for a80

select l.GROUP#, lf.status,lf.member, l.bytes
from v$logfile lf, v$log l
where l.GROUP# = lf.GROUP#
order by l.group#;

Prompt
Prompt ==============================================================
Prompt Distribuicao dos objetos nas tablespaces
Prompt ==============================================================
Prompt

select owner, segment_type, tablespace_name, count(*)
from dba_segments
where owner not in ('SYS','SYSTEM')
and segment_type in ('INDEX','TABLE')
--and SEGMENT_NAME not like 'BIN%'
group by owner, segment_type, tablespace_name
order by owner, segment_type, tablespace_name;

Prompt
Prompt ==============================================================
Prompt Numero de objetos por tablespace
Prompt ==============================================================
Prompt

select tablespace_name, count(*)
from dba_segments
--where SEGMENT_NAME not like 'BIN%'
group by tablespace_name
order by tablespace_name;

Prompt
Prompt ==============================================================
Prompt Numero de objetos por usuario
Prompt ==============================================================
Prompt

select owner, object_type, count(*)
from dba_objects
--where OBJECT_NAME not like 'BIN%'
group by owner, object_type
order by owner, object_type;

Prompt
Prompt ==============================================================
Prompt Objetos invás por usuario
Prompt ==============================================================
Prompt

select owner, object_type, substr(object_name,1,40) nome_objeto
from dba_objects
where status = 'INVALID'
 -- and OBJECT_NAME not like 'BIN%'
order by 1,2,3;

Prompt
Prompt ==============================================================
Prompt Total de Objetos invás por usuáPrompt ==============================================================
Prompt

select owner, count(*)
from dba_objects
where status = 'INVALID'
 -- and OBJECT_NAME not like 'BIN%'
group by owner;


Prompt
Prompt ==============================================================
Prompt Dados dos usuarios
Prompt ==============================================================
Prompt

select username, default_tablespace, temporary_tablespace, PASSWORD, PROFILE
from dba_users
order by username;

Prompt
Prompt ==============================================================
Prompt Parâos do banco
Prompt ==============================================================
Prompt
col name for a50
col value for a100
select name, value
from v$parameter
order by name;


Prompt
Prompt ==============================================================
Prompt Parametros do SPFILE
Prompt ==============================================================
Prompt
SET LINESIZE 500

COLUMN name  FORMAT A30
COLUMN value FORMAT A60
COLUMN displayvalue FORMAT A60

SELECT sp.sid,
       sp.name,
       sp.value,
       sp.display_value
FROM   v$spparameter sp
ORDER BY sp.name, sp.sid;

Prompt
Prompt ==============================================================
Prompt Database properties
Prompt ==============================================================
Prompt

col property_value for a30
col description for a70

select property_name, property_value, description
  from database_properties
  where property_name in ( 'DEFAULT_TBS_TYPE',
                           'DEFAULT_TEMP_TABLESPACE',
                           'NLS_CHARACTERSET',
                           'DEFAULT_PERMANENT_TABLESPACE' );

Prompt ===============================
Prompt Display options
Prompt ===============================

col parameter for a40
col value for a30

select * from v$option
order by value;
--order by  PARAMETER;

Prompt =======================================================================
Prompt Display new versions and status
Prompt =======================================================================

column comp_name format a35

SELECT comp_name, status, substr(version,1,10) as version, modified
from dba_server_registry
order by modified;

Prompt
Prompt ==============================================================
Prompt Opcoes instaladas
Prompt ==============================================================
Prompt

select comp_id, control, schema, version, status, comp_name
from dba_registry order by comp_name;

Prompt
Prompt ==============================================================
Prompt JOBS - DBA_SCHEDULER_JOBS
Prompt ==============================================================
Prompt

col owner for a22
col job_action for a20
col start_date for a20
col repeat_interval for a20
col end_date for a20
col job_name for a20

select owner, job_name, START_DATE, REPEAT_INTERVAL,END_DATE,
       ENABLED, STATE, JOB_TYPE, JOB_ACTION
from DBA_SCHEDULER_JOBS
order by owner;




Prompt
Prompt ==============================================================
Prompt JOBS - DBA_JOBS
Prompt ==============================================================
Prompt

col schema_user for a10
col what for a60

select job, schema_user, last_sec, next_sec, NEXT_DATE, broken, FAILURES, what
from dba_jobs
order by next_sec asc;



Prompt
Prompt ==============================================================
Prompt RMAN - V$RMAN_BACKUP_JOB_DETAILS
Prompt ==============================================================
Prompt

COL STATUS FORMAT a9
COL hrs    FORMAT 999.99


SELECT SESSION_KEY, INPUT_TYPE, STATUS,
       TO_CHAR(START_TIME,'mm/dd/yy hh24:mi') start_time,
       TO_CHAR(END_TIME,'mm/dd/yy hh24:mi')   end_time,
       ELAPSED_SECONDS/3600                   hrs
FROM V$RMAN_BACKUP_JOB_DETAILS
ORDER BY SESSION_KEY;

Prompt
Prompt ==============================================================
Prompt RMAN - 30 DIAS BACKUP
Prompt ==============================================================
Prompt

set lines 220
set pages 1000
col cf for 9,999
col df for 9,999
col elapsed_seconds heading "ELAPSED|SECONDS"
col i0 for 9,999
col i1 for 9,999
col l for 9,999
col output_mbytes for 9,999,999 heading "OUTPUT|MBYTES"
col session_recid for 999999 heading "SESSION|RECID"
col session_stamp for 99999999999 heading "SESSION|STAMP"
col status for a10 trunc
col time_taken_display for a10 heading "TIME|TAKEN"
col output_instance for 9999 heading "OUT|INST"
select
  j.session_recid, j.session_stamp,
  to_char(j.start_time, 'yyyy-mm-dd hh24:mi:ss') start_time,
  to_char(j.end_time, 'yyyy-mm-dd hh24:mi:ss') end_time,
  (j.output_bytes/1024/1024) output_mbytes, j.status, j.input_type,
  decode(to_char(j.start_time, 'd'), 1, 'Sunday', 2, 'Monday',
                                     3, 'Tuesday', 4, 'Wednesday',
                                     5, 'Thursday', 6, 'Friday',
                                     7, 'Saturday') dow,
  j.elapsed_seconds, j.time_taken_display,
  x.cf, x.df, x.i0, x.i1, x.l,
  ro.inst_id output_instance
from V$RMAN_BACKUP_JOB_DETAILS j
  left outer join (select
                     d.session_recid, d.session_stamp,
                     sum(case when d.controlfile_included = 'YES' then d.pieces else 0 end) CF,
                     sum(case when d.controlfile_included = 'NO'
                               and d.backup_type||d.incremental_level = 'D' then d.pieces else 0 end) DF,
                     sum(case when d.backup_type||d.incremental_level = 'D0' then d.pieces else 0 end) I0,
                     sum(case when d.backup_type||d.incremental_level = 'I1' then d.pieces else 0 end) I1,
                     sum(case when d.backup_type = 'L' then d.pieces else 0 end) L
                   from
                     V$BACKUP_SET_DETAILS d
                     join V$BACKUP_SET s on s.set_stamp = d.set_stamp and s.set_count = d.set_count
                   where s.input_file_scan_only = 'NO'
                   group by d.session_recid, d.session_stamp) x
    on x.session_recid = j.session_recid and x.session_stamp = j.session_stamp
  left outer join (select o.session_recid, o.session_stamp, min(inst_id) inst_id
                   from GV$RMAN_OUTPUT o
                   group by o.session_recid, o.session_stamp)
    ro on ro.session_recid = j.session_recid and ro.session_stamp = j.session_stamp
where j.start_time > trunc(sysdate)-30
order by j.start_time;


Prompt
Prompt ==============================================================
Prompt Roles dos usuarios
Prompt ==============================================================
Prompt

select grantee, granted_role, admin_option, default_role
  from dba_role_privs
order by granted_role,grantee;


/*
Prompt =======================================================================
Prompt Constraints
Prompt =======================================================================

col owner for a20

select owner, table_name, constraint_name, constraint_type as type, r_constraint_name as r,
status, deferred, validated, last_change, invalid
from dba_constraints
--where owner in ('xxx')
order by owner, table_name, type, constraint_name;

*/


Prompt =======================================================================
Prompt Constraints - total
Prompt =======================================================================

col owner for a20

select owner, constraint_type, count(*)
from dba_constraints
--where owner in ('xxx')
group by owner, constraint_type
order by owner, constraint_type;

/*
Prompt
Prompt ==============================================================
Prompt Constraints desabilitadas
Prompt ==============================================================
Prompt

col owner for a20

select substr(owner,1,20), table_name, constraint_name, constraint_type as type, r_constraint_name as r,
status, deferred, validated, last_change, invalid
from dba_constraints
where status <> 'ENABLED'
order by owner, type, table_name, constraint_name, status;
*/

spool off
