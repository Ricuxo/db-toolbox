/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

break on begin_interval_time skip 1

column phyrds              format 999,999,999
column begin_interval_time format a25
column file_name           format a45

select
   begin_interval_time,
   filename,
   phyrds
from
   dba_hist_filestatxs
  natural join
   dba_hist_snapshot
order by 
  begin_interval_time
;
