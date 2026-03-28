/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

break on begin_interval_time skip 1

column begin_interval_time format a25
column latch_name          format a40

select
   begin_interval_time,
   latch_name,
   gets,
   misses,
   sleeps
from
   dba_hist_latch
natural join
   dba_hist_snapshot
where
   (misses + sleeps ) > 0
order by
   begin_interval_time,
   misses DESC,
   sleeps DESC
;
