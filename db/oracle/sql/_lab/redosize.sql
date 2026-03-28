select s.SID, 
       se.username,
       se.program,
       se.module,
       t.NAME,
       s.VALUE
from v$sesstat s, v$statname t, v$session se
where s.STATISTIC# = t.STATISTIC#
and   s.sid = se.sid
and name = 'redo blocks written'
and se.username = 'RLH'
order by 3
/
