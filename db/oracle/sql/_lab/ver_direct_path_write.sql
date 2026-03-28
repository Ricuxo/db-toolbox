select a.name, b.sid, b.value, 
       round((sysdate - c.logon_time) * 24) hours_connected
from   v$statname a, v$sesstat b, v$session c
where  b.sid        = c.sid
and    a.statistic# = b.statistic#
and    b.value      > 0
and    a.name       = 'physical writes direct'
order by b.value
/
