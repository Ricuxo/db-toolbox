/*  */
 select
                sql_id
              , buffer_gets_total "Buffer Gets"
              , executions_total "Executions"
              , buffer_gets_total/executions_total "Gets / Exec"
              , pct*100 "% Total"
              , cpu_time_total/1000000 "CPU Time (s)"
              , elapsed_time_total/1000000 "Elapsed Time (s)"
              , module "SQL Module"
              , stmt  "SQL Statement"
from
(select
                e.sql_id sql_id
              , e.buffer_gets_total - nvl(b.buffer_gets_total,0) buffer_gets_total
              , e.executions_total - nvl(b.executions_total,0) executions_total
              , (e.buffer_gets_total - nvl(b.buffer_gets_total,0))/
                (  select e1.value - nvl(b1.value,0)
                   from dba_hist_sysstat b1 , dba_hist_sysstat e1
                        where b1.snap_id(+)          = b.snap_id
                          and e1.snap_id             = e.snap_id
                          and b1.dbid(+)             = b.dbid
                          and e1.dbid                = e.dbid
                          and b1.instance_number(+)  = b.instance_number
                          and e1.instance_number     = e.instance_number
                          and b1.stat_id             = e1.stat_id
                          and e1.stat_name           = 'session logical reads'

) pct
              , e.elapsed_time_total - nvl(b.elapsed_time_total,0) elapsed_time_total
              , e.cpu_time_total - nvl(b.cpu_time_total,0) cpu_time_total
              , e.module
              , t.sql_text  stmt
       from dba_hist_sqlstat  e
          , dba_hist_sqlstat  b
          , dba_hist_sqltext  t
      where b.snap_id(+)         = @pBgnSnap
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.sql_id(+)          = e.sql_id
        and e.snap_id            = &pEndSnap
        and e.dbid               = &pDBId
        and e.instance_number    = &pInstNum
        and (e.executions_total - nvl(b.executions_total,0)) > 0
        and t.sql_id             = b.sql_id
)
     order by 2 desc
