-- enqueue_stats.sql

select
 *
from
   gv$enqueue_stat
where
   total_wait#>0
order by
   inst_id,
cum_wait_time desc;