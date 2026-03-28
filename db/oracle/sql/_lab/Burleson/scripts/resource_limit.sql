/*  */
col resource_name format a27 
col current_utilization format 9999 heading curr
col max_utilitization format 9999 heading max
start title80 'Resource Limits'
spool rep_out\&db\resource_limit
select * from v$resource_limit
/
spool off
