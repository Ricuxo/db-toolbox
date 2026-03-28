SET HEAD OFF
select 'kill -9 '||p.spid|| '       #'||s.username||'   '||seconds_in_wait||' '||event||' '||s.status
   from dba_blockers b, v$process p, v$session s, v$session_wait w
   where b.holding_session=s.sid
and w.sid = s.sid
 and s.paddr=p.addr
/
SET HEAD ON