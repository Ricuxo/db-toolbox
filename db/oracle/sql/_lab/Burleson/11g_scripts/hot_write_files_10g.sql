/*  */
-- ******************************************************************
--    
--   Free for non-commercial use!  To license, e-mail info@rampant.cc
-- ******************************************************************
prompt 
prompt  This will identify any single file who's write I/O
prompt  is more than 25% of the total write I/O of the database.
prompt

set pages 999

break on snap_time skip 2

col filename      format a40
col phywrts       format 999,999,999
col snap_time     format a20

select 
   to_char(begin_interval_time,'yyyy-mm-dd hh24:mi') snap_time,        
   filename,
   phywrts
from
   dba_hist_filestatxs 
natural join
   dba_hist_snapshot
where
   phywrts > 0
and
   phywrts * 4 >
(
select
   avg(value)               all_phys_writes
from
   dba_hist_sysstat
  natural join
   dba_hist_snapshot
where
   stat_name = 'physical writes'
and
  value > 0
)
order by
   to_char(begin_interval_time,'yyyy-mm-dd hh24:mi'),
   phywrts desc
;
