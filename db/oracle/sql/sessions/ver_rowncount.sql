---SCRIPT DO GIL

set pages 50000 lines 500 long 999999999 serveroutput on echo off
alter session set nls_date_format='dd/mm/yyyy-hh24:mi:ss';
set timing on
col host_name for a10
col instance_name for a16
col "Inst" for 999
col spid for a10
col sid for 99999
col osuser for a8
col "status" for a9
col sql_id for a13
col username for a13
col "LockW" for a6
col "LOGON_TIME" for a14
col sql_fulltext for a130
col "MACHINE" for a10
col "BlkChanges" for 999999999
col "RowsProc" for 999999999
col "SecW" for 999999
col "Opn" for a26
col "Service" for a21
col "Profile" for a10
col "PLAN_HASH" for 99999999999
col "PROGRAM" for a10
col "SQL" for a26

select
s.inst_id "INST",s.status "STATUS",s.USERNAME,s.SID,s.serial#,
substr(s.machine,1,9) "MACHINE",substr(s.program,1,9) "PROGRAM",
to_char(s.LOGON_TIME,'dd/mm hh24:mi:ss') "LOGON_TIME",a.sql_id,
a.plan_hash_value "PLAN_HASH",
i.block_changes "BLKCHANGES",
a.rows_processed "ROWSPROC",
s.seconds_in_wait "SECW",
a.fetches,
substr(lower(a.sql_fulltext),1,25) "SQL"
from  gv$session s, gv$sess_io i, gV$sqlarea a, gv$process p
where p.addr=s.paddr
and  s.sql_hash_value=a.hash_value
and  s.sid = i.sid
and  a.inst_id = s.inst_id
and  s.inst_id = p.inst_id
and  p.inst_id = i.inst_id
--and a.SQL_ID='6nxj29k0gafdf'
and  to_char(s.LOGON_TIME,'yyyymmddhh24mi') > (select to_char(sysdate-2,'yyyymmdd')||1200 from dual) -- 12:00 dia anterior
AND s.logon_time between to_date('25/01/2024 02:01:00','dd/mm/yyyy hh24:mi:ss') and to_date('25/01/2024 07:20:00','dd/mm/yyyy hh24:mi:ss')
and  s.username not in (select username from dba_users where to_char(CREATED,'yyyymmdd')=(select to_char(CREATED,'yyyymmdd') from v$database))
order by to_char(s.LOGON_TIME,'yyyymmddhh24miss') asc
/