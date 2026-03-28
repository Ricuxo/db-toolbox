/*  */
set verify off feedback off heading off
accept start_date prompt 'Enter date (dd-mon-yy) to start listing from:'
accept start_hour prompt 'Enter hour (hh24) to start listing from:'
spool rep_out\DCARS\hrsumm2.doc
select to_char(trunc(check_date),'dd-mon-yy')||','||to_char(check_hour)||','||to_char(hitratio)||','||to_char(period_hit_ratio)||','||to_char(period_usage)||','||to_char(users)
from hit_ratios
where check_date>=to_date('&&start_date','dd-mon-yy') and 
check_hour>=to_number(&&start_hour)
order by check_date,check_hour
/
spool off
set verify on feedback on
ttitle off

