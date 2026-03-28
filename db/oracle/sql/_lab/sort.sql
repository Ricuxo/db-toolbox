prompt ########################################################################
prompt ## SORT USAGE
prompt ########################################################################
set trimspoo on trimout on
set lines 200
set pages 200
column sid format 9999
column user_ora format a13
column conexao format a9
column status format a8
column user_unix format a9
column estacao format a25
column process format a7    heading 'PROCESS'
column comando format a15
column loc format a3
column tablespace format a15
column osuser format a20
column conexao format a16
set linesize 200
set pause off
set echo off
set feed off
set pagesize 1000
set feed on
break on tablespace
compute sum of "blocks*8192/1024" on tablespace
select to_char(sysdate,'DD/MM/YY-HH24:MI:SS') data from dual
/
select tablespace,b.sid,b.username,b.status,b.osuser,b.process client_proc,to_char(b.logon_time,'DD/MM-HH24:MI:SS') CONEXAO,b.SQL_HASH_VALUE,sqlhash,blocks*8192/1024
from v$sort_usage a,v$session b
where a.session_addr=b.saddr
order by 1 desc,blocks*8192/1024
/
select tablespace_name,CURRENT_USERS,TOTAL_BLOCKS*8192/1024,USED_BLOCKS*8192/1024,FREE_BLOCKS*8192/1024
from v$sort_segment
/

