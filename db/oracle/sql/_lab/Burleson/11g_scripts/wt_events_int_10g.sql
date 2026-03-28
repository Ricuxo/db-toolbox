/*  */
select event
     , waits "Waits"
     , time "Wait Time (s)"
     , pct*100 "Percent of Total"
     , waitclass "Wait Class"
from (select e.event_name event
                     , e.total_waits - nvl(b.total_waits,0)  waits
                     , (e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000  time
                     , (e.time_waited_micro - nvl(b.time_waited_micro,0))/
                       (select sum(e1.time_waited_micro - nvl(b1.time_waited_micro,0)) from dba_hist_system_event b1 , dba_hist_system_event e1
                        where b1.snap_id(+)          = b.snap_id
                          and e1.snap_id             = e.snap_id
                          and b1.dbid(+)             = b.dbid
                          and e1.dbid                = e.dbid
                          and b1.instance_number(+)  = b.instance_number
                          and e1.instance_number     = e.instance_number
                          and b1.event_id(+)         = e1.event_id
                          and e1.total_waits         > nvl(b1.total_waits,0)
                          and e1.wait_class          <> 'Idle'
  )  pct
                     , e.wait_class waitclass
                 from
                   dba_hist_system_event b ,
                   dba_hist_system_event e
                where b.snap_id(+)          = &pBgnSnap
                  and e.snap_id             = &pEndSnap
                  and b.dbid(+)             = &pDbId
                  and e.dbid                = &pDbId
                  and b.instance_number(+)  = &pInstNum
                  and e.instance_number     = &pInstNum
                  and b.event_id(+)         = e.event_id
                  and e.total_waits         > nvl(b.total_waits,0)
                  and e.wait_class          <> 'Idle'
         order by time desc, waits desc
       )
