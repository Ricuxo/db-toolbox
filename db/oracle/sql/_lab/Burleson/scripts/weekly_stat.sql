/*  */
clear columns
undef minus_value
ttitle off
column min_value new_value minus_value noprint
column date1 new_value date2  noprint;
column date3 new_value date4  noprint;
column temp_date new_value rep_date noprint
column name format a40
set pages 0 verify off feedback off
accept start_date prompt 'Enter Date for Statistics Run (dd-mon-yy): '
rem
rem define start_date = '&2';
select (to_date('&&start_date','dd-mon-yy')-4)+(7/24) date1 from dual;
select to_date('&&start_date','dd-mon-yy')+(16/24) date3 from dual;
select nvl(min(value),0) min_value from dba_running_stats where
name='table fetch by rowid' 
and meas_date between '&&date2' and '&&date4'
and to_number(to_char(meas_date,'hh24')) between 7 and 18;
rem
select to_char(to_date('&&start_date','dd-mon-yy'),'ddmonyy') temp_date from dual;
start title80 'Average Weekly Values Report'
define output='rep_out\&db\avg_week_&rep_date';
ttitle on
spool &&output
select name||'(avg)' name, round(avg(value-&minus_value),0) value
from dba_running_stats
where name='table fetch by rowid' 
and meas_date between '&&date2' and '&&date4'
and to_number(to_char(meas_date,'hh24')) between 8 and 16
and round(value-&&minus_value,0)>0
group by name
union
select 'USERS (avg)' name, round(avg(users),0) value
from hit_ratios where
check_date between '&&date2' and '&&date4'
and check_hour between 8 and 16
group by 1
union
select 'INTERACTIONS(total)' name,count(*) value from summarize_interactions
where action_date between trunc(to_date('&&date2','dd-mon-yy')) and trunc(to_date('&&date4','dd-mon-yy')+1)
group by 1
union
select 'CONTACTS(total)' name,count(*) value from dbo.users
where bbs_creation_ts between trunc(to_date('&&date2','dd-mon-yy')) and trunc(to_date('&&date4','dd-mon-yy')+1)
and site_id>1
group by 1
UNION
select 'State: '||name||'(avg user count)' name, round(avg(value),0) value
from dba_running_stats
where name IN ('ALABAMA','TENNESSEE','FLORIDA','GEORGIA','MISSISSIPPI',
 'NORTH CAROLINA','FLORIDA','LOUISIANA','UNKNOWN','SOUTH CAROLINA','KENTUCKY') 
and meas_date between '&&date2' and '&&date4'
and to_number(to_char(meas_date,'hh24')) between 8 and 16
and round(value,0)>0
group by name
order by 1
;
spool off
undef start_date
ttitle off
