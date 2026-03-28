/*  */
-- ******************************************************************
--    
--   Free for non-commercial use!  To license, e-mail info@rampant.cc
-- ******************************************************************

set lines 80;
set pages 999;

column mydate heading 'Yr.  Mo Dy  Hr.' format a16
column c1 heading "execs"    format 9,999,999
column c2 heading "Cache Misses|While Executing"    format 9,999,999
column c3 heading "Library Cache|Miss Ratio"     format 999.99999

break on mydate skip 2;

select 
   to_char(sn.end_interval_time,'yyyy-mm-dd HH24')  mydate,
   sum(new.pins-old.pins)                c1,
   sum(new.reloads-old.reloads)          c2,
   sum(new.reloads-old.reloads)/
   sum(new.pins-old.pins)                library_cache_miss_ratio
from 
   dba_hist_librarycache old,
   dba_hist_librarycache new,
   dba_hist_snapshot     sn
where
   new.snap_id = sn.snap_id
and
   old.snap_id = new.snap_id-1
and
   old.namespace = new.namespace
group by
   to_char(sn.end_interval_time,'yyyy-mm-dd HH24')
;
