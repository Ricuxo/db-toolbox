/*  */
break on begin_interval_time skip 2

column phyrds              format 999,999,999
column begin_interval_time format a25

select 
   begin_interval_time, 
   filename,
   phyrds
from
   dba_hist_filestatxs 
natural join
   dba_hist_snapshot
;
