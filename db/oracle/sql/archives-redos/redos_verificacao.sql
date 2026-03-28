col username for a30
set lines 500
select se.sid, se.username, se.program,
     s.name, st.value
from v$statname s, v$sesstat st, v$session se
where st.STATISTIC# = s.STATISTIC#
and s.name = 'redo size'
and st.sid = se.sid
order by 5;





select s.sid, n.name, s.value, sn.username, sn.program, sn.type, sn.module
from v$sesstat s 
  join v$statname n on n.statistic# = s.statistic#
  join v$session sn on sn.sid = s.sid
where name like '%redo entries%'
order by value;




SELECT s.sid, s.serial#, s.username, s.program, i.block_changes FROM 
v$session s, v$sess_io i WHERE s.sid = i.sid ORDER BY 5 , 1, 2, 3, 4;

SELECT s.sid, s.serial#, s.username, s.program,t.used_ublk, t.used_urec 
FROM v$session s, v$transaction t WHERE s.taddr = t.addr 
ORDER BY 5, 6 ,1, 2, 3, 4;
