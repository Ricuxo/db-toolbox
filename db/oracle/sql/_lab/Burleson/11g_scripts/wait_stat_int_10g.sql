/*  */
select e.class "E.CLASS"
     , e.wait_count  - nvl(b.wait_count,0)     "Waits"
     , e.time        - nvl(b.time,0)           "Total Wait Time (cs)"
     , (e.time       - nvl(b.time,0)) /
       (e.wait_count - nvl(b.wait_count,0)) "Avg Time (cs)"
  from dba_hist_waitstat b
     , dba_hist_waitstat e
 where b.snap_id         = &pBgnSnap
   and e.snap_id         = &pEndSnap
   and b.dbid            = &pDbId
   and e.dbid            = &pDbId
   and b.dbid            = e.dbid
   and b.instance_number = &pInstNum
   and e.instance_number = &pInstNum
   and b.instance_number = e.instance_number
   and b.class           = e.class
   and b.wait_count      < e.wait_count
 order by 3 desc, 2 desc
