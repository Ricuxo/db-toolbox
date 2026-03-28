column sid format 9999
column user_ora format a15
column conexao format a9
column status format a8
column user_unix format a9
column estacao format a25
column process format a7    heading 'PROCESS'
column comando format a15
column loc format a3
column cpu format 9999
col tablespace format a20
set linesize 200
set pause off
set echo off
--set feed off
set pagesize 1000
select a.sid SID,
       a.SQL_HASH_VALUE,
       a.username USER_ORA,
       decode (substr(a.osuser,1,9),'OraUser','C/S',
              substr(a.osuser,1,9)) USER_UNIX,
       decode (substr(a.terminal,1,6),'Window',machine,machine) ESTACAO,
       to_char(logon_time,'HH24:MI:SS') CONEXAO,
       c.OPERATION_TYPE,c.POLICY,c.WORK_AREA_SIZE,c.ACTUAL_MEM_USED,c.TEMPSEG_SIZE,c.TABLESPACE
from v$session  a,v$process b,V$SQL_WORKAREA_ACTIVE c
where a.paddr=b.addr
and a.sid=c.sid
and   a.username!=' ' 
and   a.username <> 'SYS' 
--and   a.status='ACTIVE'
order by SID,OPERATION_TYPE
/
set feed on
