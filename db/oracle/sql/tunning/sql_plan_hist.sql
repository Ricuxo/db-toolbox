col data form a20
col old_exec form a18
col last_exec form a18

select /*+ parallel(b 4) */ to_char(min(begin_interval_time),'YYYY-MM-DD HH24:MI') old_exec, to_char(max(begin_interval_time),'YYYY-MM-DD HH24:MI') last_exec, a.plan_hash_value, trunc(avg(OPTIMIZER_COST)) cost, avg(elapsed_time_delta/executions_delta)/1000000 elapsed_exe, sql_profile
from dba_hist_sqlstat a, dba_hist_snapshot b
where a.sql_id='&1'
and a.snap_id=b.snap_id
and a.executions_delta > 0
group by a.plan_hash_value, sql_profile
order by 2;

