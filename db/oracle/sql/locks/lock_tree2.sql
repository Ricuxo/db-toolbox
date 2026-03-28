col blk_sess format a11
col wtr_sess format a11
col blocker format a10
col waiter format a10
col duration format a9
col blocked_object format a50
select /*+ rule */
a.inst_id ||',' || a.sid || ',' || a.serial# blk_sess,
a.username blocker,
h.type,
b.inst_id||','||b.sid || ',' || b.serial# wtr_sess,
b.username waiter,
o.owner || '.' || o.object_name ||
nvl2 (subobject_name, '.' || subobject_name, null) blocked_object,
lpad (to_char (trunc (w.ctime / 3600)), 3, '0') || ':' ||
lpad (to_char (mod (trunc (w.ctime / 60), 60)), 2, '0') || ':' ||
lpad (to_char (mod (w.ctime, 60)), 2, '0') duration
from gv$lock h, gv$lock w, gv$session a, gv$session b, dba_objects o
where h.block != 0
and h.lmode != 0
and h.lmode != 1
and w.request != 0
and w.id1 = h.id1
and w.id2 = h.id2
and h.sid = a.sid
and w.sid = b.sid and h.inst_id = a.inst_id
and decode (w.type, 'TX', b.row_wait_obj#,
'TM', w.id1)
= o.object_id