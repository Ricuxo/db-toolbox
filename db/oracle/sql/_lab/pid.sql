select 
a.sid, a.serial#,c.spid,a.inst_id,a.username, a.machine, a.osuser, a.status,b.address,b.sql_text
from gv$session a, gv$sql b, gv$process c
where 
a.SQL_ADDRESS=b.ADDRESS(+) and
a.inst_id=b.inst_id(+) and
a.paddr=c.addr and
a.inst_id=c.inst_id and
c.spid=&spid
order by 1,2;