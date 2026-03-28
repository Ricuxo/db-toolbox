break on report 
compute sum of soma on report
select rpad(l.name,30,'.') name, rpad(w.event,30,'.') event, count(1) soma
  from v$session_wait w, v$latch l
 where  l.latch#(+)     = w.p2
 and    w.event not like 'SQL*Net message%'
 and    w.event not in ('rdbms ipc message', 'queue messages')
 group by w.event, l.name
/
