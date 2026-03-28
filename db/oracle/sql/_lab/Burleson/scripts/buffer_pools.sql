/*  */
rem buffer_pools.sql
rem FUNCTION; Show status of blocks in all pools
rem from pipeline
rem
start title132 'Buffer Pool Status'
spool rep_out\&db\buffer_pools
select 'KEEP' POOL, o.name, count(buf#) BLOCKS
from obj$ o, x$bh x
where o.dataobj# = x.obj
and x.state !=0
and o.owner# !=0
and buf# >= (select x.start_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='KEEP')
and buf# <= (select x.end_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='KEEP')
group by 'KEEP',o.name
union all
select 'DEFAULT' POOL, o.name, count(buf#) BLOCKS
from obj$ o, x$bh x
where o.dataobj# = x.obj
and x.state !=0
and o.owner# !=0
and buf# >= (select x.start_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='DEFAULT')
and buf# <= (select x.end_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='DEFAULT')
group by 'DEFAULT',o.name
union all
select 'RECYCLE' POOL, o.name, count(buf#) BLOCKS
from obj$ o, x$bh x
where o.dataobj# = x.obj
and buf# >= (select x.start_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='RECYCLE')
and x.state !=0
and o.owner# !=0
and buf# <= (select x.end_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='RECYCLE')
group by 'RECYCLE',o.name 
/
spool off
ttitle off
