select a.sid SID,
       a.username USER_ORA,
       to_char(logon_time,'DD/MM-HH24:MI') CONEXAO,
       to_char(a.LAST_CALL_ET,'DD/MM/YY-HH24:MI:SS'),
       b.spid PROCESS,a.process Cli_proc,
       d.CONSISTENT_GETS GETS,
       c.name COMANDO,
       decode(a.lockwait,'','NAO','SIM') LOC,substr(a.program,1,15) programa
from v$session  a,v$process b,audit_actions c,v$sess_io d,v$sesstat e,v$statname f
where a.paddr=b.addr
and   a.username!=' '
and a.sid=&1
and   a.username <> 'SYS'
and a.command=c.action
and a.sid=d.sid
and a.sid=e.sid
and e.STATISTIC#=f.STATISTIC#
and e.STATISTIC#=12
and f.STATISTIC#=12
order by GETS
/
