/*  */
-- ******************************************************************
--    
--   Free for non-commercial use!  To license, e-mail info@rampant.cc
-- ******************************************************************
prompt 
prompt  This will query the dba_hist_sysstat view to display all values 
prompt  that exceed the value specified in 
prompt  the "where" clause of the query.
prompt

set pages 999

break on snap_time skip 2

accept stat_name   char   prompt 'Enter Statistic Name:  ';
accept stat_value  number prompt 'Enter Statistics Threshold value:  ';


col snap_time   format a19
col value       format 999,999,999

select
   to_char(begin_interval_time,'yyyy-mm-dd hh24:mi') snap_time,
   value
from
   dba_hist_sysstat
  natural join
   dba_hist_snapshot
where
   stat_name = '&stat_name'
and
  value > &stat_value
order by
   to_char(begin_interval_time,'yyyy-mm-dd hh24:mi')
;
