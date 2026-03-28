/*  */
select b.namespace "Name Space"
     , e.gets - b.gets  "Get Requests"
     , to_number(decode(e.gets,b.gets,null,
       100 - (e.gethits - b.gethits) * 100/(e.gets - b.gets))) "Get Pct Miss"
     , e.pins - b.pins "Pin Requests"
     , to_number(decode(e.pins,b.pins,null,
       100 - (e.pinhits - b.pinhits) * 100/(e.pins - b.pins))) "Pin Pct Miss"
     , e.reloads - b.reloads                                   "Reloads"
     , e.invalidations - b.invalidations                       "Invalidations"
  from dba_hist_librarycache  b
     , dba_hist_librarycache  e
 where b.snap_id         = &pBgnSnap
   and e.snap_id         = &pEndSnap
   and b.dbid            = &pDbId
   and e.dbid            = &pDbId
   and b.dbid            = e.dbid
   and b.instance_number = &pInstNum
   and e.instance_number = &pInstNum
   and b.instance_number = e.instance_number
   and b.namespace       = e.namespace
