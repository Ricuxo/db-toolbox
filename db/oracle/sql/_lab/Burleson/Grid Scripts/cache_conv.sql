-- cache_conv.sql

select
  a.inst_id "Instance",
  a.value/b.value "Avg Cache Conv. Time",
  c.value/d.value "Avg Cache Get Time",
  e.value "GC Convert Timeouts"
from
   GV$SYSSTAT A,
   GV$SYSSTAT B,
   GV$SYSSTAT C,
   GV$SYSSTAT D,
   GV$SYSSTAT E
where
  a.name='global cache convert time' and
  b.name='global cache converts' and
  c.name='global cache get time' and
  d.name='global cache gets' and
  e.name='global cache convert timeouts' and
  b.inst_id=a.inst_id and
  c.inst_id=a.inst_id and
  d.inst_id=a.inst_id and
  e.inst_id=a.inst_id
order by
  a.inst_id;
