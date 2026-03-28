/*  */
select a.inst_id, "instance", a.value "global cache blocks lost",
b.value "global cache current blocks served",
c.value "global cache cr blocks served",
a.value/(b.value+c.value) ratio
from gv$sysstat a, gv$sysstat b, gv$sysstat c
where a.name='global cache blocks lost' and
      b.name='global cache current blocks served' and
      c.name='global cache cr blocks served' and
      b.inst_id=a.inst_id and c.inst_id = a.inst_id
/

