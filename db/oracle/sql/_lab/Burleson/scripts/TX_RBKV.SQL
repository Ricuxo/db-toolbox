/*  */
create view trans_per_rollback (name,sid,pid,transaction,terminal) as
select  r.name, l.Sid, p.spid,NVL(p.username, 'no transaction'),  p.terminal
from  v$lock l, v$process p, v$rollname r
where l.Sid = p.pid (+)
and     TRUNC(l.id1(+) / 65536) = r.usn and l.type(+) = 'TX' and l.lmode(+) = 6
;

