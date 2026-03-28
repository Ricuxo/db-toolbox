/*  */
col name for a30
break on pool skip 1

select 'KEEP' POOL, o.name, count(buf#) BLOCKS 
from sys.obj$ o, x$bh x 
where o.dataobj# = x.obj 
and x.state !=0 
and o.owner# !=0 
and buf# >= (select min(b.START_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'KEEP'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
and buf# <= (select max(b.END_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'KEEP'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
group by 'KEEP',o.name 
union all 
select 'DEFAULT' POOL, o.name, count(buf#) BLOCKS 
from sys.obj$ o, x$bh x 
where o.dataobj# = x.obj 
and x.state !=0 
and o.owner# !=0 
and buf# >= (select min(b.START_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'DEFAULT'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
and buf# <= (select max(b.END_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'DEFAULT'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
group by 'DEFAULT',o.name 
union all 
select 'RECYCLE' POOL, o.name, count(buf#) BLOCKS 
from sys.obj$ o, x$bh x 
where o.dataobj# = x.obj 
and x.state !=0 
and o.owner# !=0 
and buf# >= (select min(b.START_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'RECYCLE'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
and buf# <= (select max(b.END_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'RECYCLE'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
group by 'RECYCLE',o.name 
/

clear break
