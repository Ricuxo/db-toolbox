/*  */
-- ******************************************************************
--    
--   Free for non-commercial use!  To license, e-mail info@rampant.cc
-- ******************************************************************
prompt
prompt  This will query the dba_hist_sysstat view to display
prompt  average values by day-of-the-week
prompt

set pages 999

accept stat_name char prompt 'Enter Statistic Name:  ';


col snap_time   format a19
col avg_value   format 999,999,999

select
   to_char(begin_interval_time,'day')   snap_time,
   avg(value)                           avg_value
from
   dba_hist_sysstat
natural join
   dba_hist_snapshot
where
   stat_name = '&stat_name'
group by
   to_char(begin_interval_time,'day')
order by
   decode(
   to_char(begin_interval_time,'day'),
    'sunday',1,
    'monday',2,
    'tuesday',3,
    'wednesday',4,
    'thursday',5,
    'friday',6,
    'saturday',7
   )
;

