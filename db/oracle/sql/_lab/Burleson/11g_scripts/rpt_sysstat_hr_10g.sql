/*  */
-- ******************************************************************
--    
--   Free for non-commercial use!  To license, e-mail info@rampant.cc
-- ******************************************************************
prompt 
prompt
prompt  This will query the dba_hist_sysstat view to 
prompt  display average values by hour of the day 
prompt

set pages 999

break on snap_time skip 2

accept stat_name char prompt 'Enter Statistics Name:  ';


col snap_time   format a19
col avg_value   format 999,999,999

select
   to_char(begin_interval_time,'hh24') snap_time,
   avg(value)                          avg_value
from
   dba_hist_sysstat
  natural join
   dba_hist_snapshot
where
   stat_name = '&stat_name'
group by
   to_char(begin_interval_time,'hh24')
order by 
   to_char(begin_interval_time,'hh24')
;
