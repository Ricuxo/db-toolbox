/*  */
col free_space heading 'Free|Space'
col avg_free_size heading 'Average|Free|Size'
col used_space heading 'Used|Space'
col avg_used_size heading 'Average|Used|Size'
col request_failures heading 'Request|Failures'
col last_failure_size heading 'Last|Failure|Size'
set lines 132 pages 47
start title132 'Shared Pool Reserved Space Report'
spool rep_out\&&db\sp_res_rep
select free_space,avg_free_size, used_space,
avg_used_size,request_failures,last_failure_size
from v$shared_pool_reserved
/
spool off
ttitle off
set lines 80 pages 22

