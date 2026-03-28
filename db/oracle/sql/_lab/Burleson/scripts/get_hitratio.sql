/*  */
@title80 'Cummulative Hit Ratio'
spool rep_out\&db\hit_ratio
select a.inst_id, a.name pool, (1-(a.physical_reads/(a.db_block_gets+a.consistent_gets))) hit_ratio,
b.free_meg
from gv$buffer_pool_statistics a, (select d.inst_id, sum(decode(d.file#,0,1)*c.value)/(1024*1024) free_meg from gv$bh d, gv$parameter c where d.file#=0 and c.name='db_block_size' and d.inst_id=c.inst_id group by d.inst_id) b
where a.inst_id=b.inst_id 
order by inst_id
/
spool off
ttitle off
