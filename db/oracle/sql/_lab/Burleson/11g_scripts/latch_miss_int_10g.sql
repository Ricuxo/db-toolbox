/*  */
select   latchname "Latch Name",
         nwmisses "No Wait Misses",
         sleeps "Sleeps",
    		 waiter_sleeps "Waiter Sleeps"
From (
select e.parent_name||' '||e.where_in_code  latchname
     , e.nwfail_count - nvl(b.nwfail_count,0) nwmisses
     , e.sleep_count  - nvl(b.sleep_count,0)  sleeps
     , e.wtr_slp_count - nvl(b.wtr_slp_count,0)   waiter_sleeps	
  from dba_hist_latch_misses_summary  b
     , dba_hist_latch_misses_summary  e
 where b.snap_id(+)         = &pBgnSnap
   and e.snap_id            = &pEndSnap
   and b.dbid(+)            = &pDbId
   and e.dbid               = &pDbId
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = &pInstNum
   and e.instance_number    = &pInstNum
   and b.instance_number(+) = e.instance_number
   and b.parent_name(+)     = e.parent_name
   and b.where_in_code(+)   = e.where_in_code
   and e.sleep_count        > nvl(b.sleep_count,0)
)
 order by 1, 3 desc
