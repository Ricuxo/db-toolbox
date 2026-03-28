column sid heading 'sid' format 999999999
column username heading 'username' format a10
column spid heading 'spid' format 999999999
column lockwait heading 'lockwait' format a17
column sql_text heading 'sql_text' format a50
set pages 10000 lines 120

select  distinct '*BLOCKER   ' STATUS_SESS,
       s.sid, s.username, p.spid,
       s.lockwait,
       q.sql_text
from
     ( select raddr, blocker.saddr, request  from v$_lock blocker, v$session s1
                                     where request = 0 
                                     and   blocker.saddr = s1.saddr
                                     and   s1.sid = &&sid) blocker,
       v$session s,
       v$process p,
       v$sql q
where blocker.saddr = s.saddr 
  and s.paddr = p.addr
  and q.address(+)=s.sql_address
union all
select  distinct '==WAITER  ' STATUS_SESS,
       s.sid, s.username, p.spid,
       s.lockwait,
       q.sql_text
from
     ( select unique raddr, saddr, request from v$_lock where request > 0 ) waiter,
     ( select raddr, blocker.saddr, request  from v$_lock blocker, v$session s1
                                     where request = 0 
                                     and   blocker.saddr = s1.saddr
                                     and   s1.sid = &&sid) blocker,
       v$session s,
       v$process p,
       v$sql q
where waiter.raddr = blocker.raddr
  and ( waiter.saddr = s.saddr or blocker.saddr = s.saddr )
  and s.paddr = p.addr
  and q.address=s.sql_address
order by 1 asc
/
