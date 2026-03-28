SET LINE 1000
select a.inst_id,
       decode(a.qcserial#, null, 'PARENT', 'CHILD') stmt_level,
       a.sid,
       a.serial#,
       b.username,
       b.osuser,
       c.event wait_event,
       c.p1,
       --c.p2,
       b.sql_id,
       b.sql_address,
       a.degree,
       a.req_degree
from   gv$px_session a, gv$session b, gv$session_wait c
where  a.sid = b.sid
AND    a.inst_id  =  b.inst_id
AND    a.sid	  =  c.sid
AND    a.inst_id  =  c.inst_id
order by a.qcsid, stmt_level desc
/