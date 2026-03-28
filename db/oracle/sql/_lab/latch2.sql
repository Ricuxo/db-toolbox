column name format a30
column event format a30
select rpad(l.name,30,'.') name, rpad(w.event,30,'.') event, count(1) 
  from v$session_wait w, v$latch l
 where  l.latch#(+)     = w.p2 
 group by w.event, l.name;
