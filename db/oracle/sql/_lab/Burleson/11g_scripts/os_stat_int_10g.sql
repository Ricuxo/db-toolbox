/*  */
select e.stat_name "Statistic Name"
     , decode(e.stat_name, 'NUM_CPUS', e.value, e.value - b.value) "Total"
     , decode( instrb(e.stat_name, 'BYTES'), 0, to_number(null)
             , round((e.value - b.value)/( select
       avg( extract( day from (e1.end_interval_time-b1.end_interval_time) )*24*60*60+
           extract( hour from (e1.end_interval_time-b1.end_interval_time) )*60*60+
           extract( minute from (e1.end_interval_time-b1.end_interval_time) )*60+
           extract( second from (e1.end_interval_time-b1.end_interval_time)) )     
      from dba_hist_snapshot  b1
          ,dba_hist_snapshot  e1
     where b1.snap_id         = b.snap_id
       and e1.snap_id         = e.snap_id
       and b1.dbid            = b.dbid
       and e1.dbid            = e.dbid
       and b1.instance_number = b.instance_number
       and e1.instance_number = e.instance_number
       and b1.startup_time    = e1.startup_time
       and b1.end_interval_time < e1.end_interval_time ),2)) "Per Second" 
 from  dba_hist_osstat  b
     , dba_hist_osstat  e
 where b.snap_id         = &pBgnSnap
   and e.snap_id         = &pEndSnap
   and b.dbid            = &pDbId
   and e.dbid            = &pDbId
   and b.instance_number = &pInstNum
   and e.instance_number = &pInstNum
   and b.stat_id         = e.stat_id
   and e.value          >= b.value
   and e.value          >  0
 order by 1 asc
