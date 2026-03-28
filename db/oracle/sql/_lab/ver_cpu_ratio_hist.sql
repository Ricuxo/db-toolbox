select  to_char(end_time,'dd/mm/yyyy hh24:mi:ss') end_time,
        value
from    sys.v_$sysmetric_history
where   metric_name = 'Database CPU Time Ratio'
order by 1;
