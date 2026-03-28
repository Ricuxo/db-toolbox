/*  */
REM: Grabs specific stats from DBA_RUNNING_STATS with deltas
REM
clear columns
undef minus_value
ttitle off
column min_value new_value minus_value noprint
column temp_date new_value rep_date noprint
column name format a40
set pages 0 verify off feedback off
accept start_date prompt 'Enter Date for Statistics Run (dd-mon-yy): '
rem
select nvl(min(value),0) min_value from dba_running_stats where
name='table fetch by rowid' 
and to_char(meas_date,'hh24') between 7 and 17
and trunc(meas_date)=to_date('&&start_date','dd-mon-yy');
rem
select to_char(to_date('&&start_date','dd-mon-yy'),'ddmonyy') temp_date from dual;
start title80 'Average Values Report'
define output='rep_out\&db\avg_stat_&rep_date';
ttitle on
spool &&output
select name||'(avg)' name, round(avg(value-&minus_value),0) value, trunc(meas_date) meas_date1
from dba_running_stats
where name='table fetch by rowid' 
and trunc(meas_date)=to_date('&&start_date','dd-mon-yy')
and to_char(meas_date,'hh24') between 8 and 16
and round(value-&&minus_value,0)>0
group by name, trunc(meas_date)
union
select name||'(max)' name, round(max(value-&minus_value),0) value, trunc(meas_date) meas_date1
from dba_running_stats
where name='table fetch by rowid' 
and trunc(meas_date)=to_date('&&start_date','dd-mon-yy')
and to_char(meas_date,'hh24') between 8 and 16
and round(value-&&minus_value,0)>0
group by name, trunc(meas_date)
union
select 'USERS (avg)' name, round(avg(users),0) value, check_date meas_date1
from hit_ratios where
check_date=trunc(to_date('&&start_date','dd-mon-yy'))
and check_hour between 8 and 16
group by 1,check_date
union
select 'USERS (max)' name, max(users) value, check_date meas_date1
from hit_ratios where
check_date=trunc(to_date('&&start_date','dd-mon-yy'))
and check_hour between 8 and 16
group by 1,check_date
union
select 'USERS (min)' name, min(users) value, check_date meas_date1
from hit_ratios where
check_date=trunc(to_date('&&start_date','dd-mon-yy'))
and check_hour between 8 and 16
group by 1,check_date
union
select name, count(value) value, trunc(meas_date) meas_date1
from dba_running_stats
where name like 'Flush%'
and trunc(meas_date)=to_date('&&start_date','dd-mon-yy')
and to_char(meas_date,'hh24') between 8 and 16
and round(value,0)>0
group by name, trunc(meas_date)
order by 1,3
;
spool off
undef start_date
ttitle off
