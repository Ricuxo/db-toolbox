prompt
prompt *************************** SESSOES ATIVAS *********************************

column sid format 9999
column user_ora format a13
column conexao format a9
column status format a8
column user_unix format a9
column process format a7    heading 'PROCESS'
column cpu format 999
column comando format a10
column loc format a3
column sid format 9999
column user_ora format a13
column conexao format a9
column status format a8
column user_unix format a9
column estacao format a25
column process format a7    heading 'PROCESS'
column comando format a10
column loc format a3

select a.sid SID,a.sql_hash_value,
       a.username USER_ORA,
       decode (substr(a.osuser,1,9),'OraUser','C/S',
              substr(a.osuser,1,9)) USER_UNIX,
       substr(decode (substr(a.terminal,1,6),'Window',machine,machine),1,25) ESTACAO,
       to_char(logon_time,'HH24:MI:SS') CONEXAO,
       b.spid,
       decode(a.lockwait,'','NAO','SIM') LOC,
       d.CONSISTENT_GETS GETS,
       d.BLOCK_CHANGES CHANGES,
       round(e.value/100/60) CPU_minutos,
       c.name COMANDO
from v$session a, v$process b, audit_actions c, v$sess_io d, v$sesstat e
where a.paddr=b.addr
and   a.username is not null
and   a.status='ACTIVE'
and   a.username like '&username%'
and a.command=c.action
and a.sid=d.sid
and a.sid=e.sid
and e.STATISTIC#=12
order by logon_time
/
set feed on
