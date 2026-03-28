/*  */
rem flush_rep.sql
rem MRA 7/21/98
rem Reports based on count of entries per day in the 
rem DBA_RUNNING_STATS table the number of flushes
rem of the shared pool. If average is excessive
rem increase the size of the shared pool or increase the 
rem ratio in the flush_it procedure.
rem
column flushes heading 'Flushes|of|Shared Pool'
column meas_date heading 'Date|of|Flushes'
set verify off feedback off
break on report
compute avg of flushes on report
accept min_date prompt 'Enter date (dd-mon-yy) to start from:'
accept no_days prompt 'Enter number of days for report:'
start title80 'Shared Pool Flushes'
spool rep_out/&db/flush.lis
select count(*) flushes, trunc(meas_date) meas_date 
from dba_running_stats 
where trunc(meas_date)>=to_date('&min_date','dd-mon-yy') and
trunc(meas_date)<=to_date('&min_date','dd-mon-yy')+to_number('&no_days')
and name like 'Flush%'
and upper(to_char(meas_date,'DY')) not in ('SAT','SUN')
group by trunc(meas_date)
/
spool off
clear computes
clear breaks
undef min_date
undef no_days
set verify on feedback on


