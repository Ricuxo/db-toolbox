/*  */
select
  param "Parameter",
  gets "Get Requests",
  getm "Pct Miss",
  scans "Scan Requests",
  scanm "Pct Miss",
  mods "Mod Req",
  usage "Final Usage"
From
(select lower(b.parameter)                                        param
     , e.gets - b.gets                                           gets
     , to_number(decode(e.gets,b.gets,null,
       (e.getmisses - b.getmisses) * 100/(e.gets - b.gets)))     getm
     , e.scans - b.scans                                         scans
     , to_number(decode(e.scans,b.scans,null,
       (e.scanmisses - b.scanmisses) * 100/(e.scans - b.scans))) scanm
     , e.modifications - b.modifications                         mods
     , e.usage                                                   usage
  from dba_hist_rowcache_summary  b
     , dba_hist_rowcache_summary  e
 where b.snap_id         = &pBgnSnap
   and e.snap_id         = &pEndSnap
   and b.dbid            = &pDbId
   and e.dbid            = &pDbId
   and b.dbid            = e.dbid
   and b.instance_number = &pInstNum
   and e.instance_number = &pInstNum
   and b.instance_number = e.instance_number
   and b.parameter       = e.parameter
   and e.gets - b.gets   > 0   )
 order by param;
