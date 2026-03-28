/*  */
-- *****************************************************************
--    
--   Free for non-commercial use!
--   To license, e-mail info@rampant.cc
-- *****************************************************************

set pages 999;

column bhr format 9.99
column mydate heading 'yr.  mo dy Hr.'

select
   to_char(end_interval_time,'day')      mydate,
   avg((((new.consistent_gets-old.consistent_gets)+(new.db_block_gets-old.db_block_gets))-(new.physical_reads-old.physical_reads))/
   ((new.consistent_gets-old.consistent_gets)+ (new.db_block_gets-old.db_block_gets))) bhr
from
   dba_hist_buffer_pool_stat old,
   dba_hist_buffer_pool_stat             new,
   dba_hist_snapshot sn
where
   new.name in ('DEFAULT','FAKE VIEW')
and
   new.name = old.name
and
   new.snap_id = sn.snap_id
and
   old.snap_id = sn.snap_id-1
and
   new.consistent_gets > 0
and
   old.consistent_gets > 0
having
   avg(
   (((new.consistent_gets-old.consistent_gets)+(new.db_block_gets-old.db_block_gets))-(new.physical_reads-old.physical_reads))/
   ((new.consistent_gets-old.consistent_gets)+(new.db_block_gets-old.db_block_gets))) < 1
group by
   to_char(end_interval_time,'day')
;

