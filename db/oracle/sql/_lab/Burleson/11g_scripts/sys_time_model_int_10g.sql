/*  */
column "Statistic Name" format A40
column "Time (s)" format 999,999
column "Percent of Total DB Time" format 999,999

select e.stat_name "Statistic Name"
     , (e.value - b.value)/1000000        "Time (s)"
     , decode( e.stat_name,'DB time'
             , to_number(null)
             , 100*(e.value - b.value)
             )/
     ( select nvl((e1.value - b1.value),-1)
     from dba_hist_sys_time_model  e1
        , dba_hist_sys_time_model  b1
     where b1.snap_id              = b.snap_id
     and e1.snap_id                = e.snap_id
     and b1.dbid                   = b.dbid
     and e1.dbid                   = e.dbid
     and b1.instance_number        = b.instance_number
     and e1.instance_number        = e.instance_number
     and b1.stat_name             = 'DB time'
     and b1.stat_id                = e1.stat_id
)        
     "Percent of Total DB Time"
  from dba_hist_sys_time_model e
     , dba_hist_sys_time_model b
 where b.snap_id                = &pBgnSnap
   and e.snap_id                = &pEndSnap
   and b.dbid                   = &pDbId
   and e.dbid                   = &pDbId
   and b.instance_number        = &pInst_Num
   and e.instance_number        = &pInst_Num
   and b.stat_id                = e.stat_id
   and e.value - b.value > 0
 order by 2 desc;
