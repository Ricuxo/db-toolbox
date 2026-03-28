set lines 150
column osuser format a15
select v.sid, U.USERNAME, U.OSUSER, v.owner, v.type
from v$access V, V$SESSION U, v$process p
where  V.object = upper('&table')
AND V.SID = U.SID(+)
and p.addr(+) = u.paddr
and u.username is not null
/

