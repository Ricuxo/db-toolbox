select 
   sql_id,
   sql_exec_id,
   sql_exec_start,
   max(tm) tm,
   (sysdate-sql_exec_start) * 3600*24 ela_tm
from 
   (select 
      sql_id,
      sql_exec_id,
      sql_exec_start,
      ( ( Cast(sample_time AS DATE) ) -
            ( Cast(sql_exec_start AS DATE) ) ) * ( 3600 * 24 ) tm
    from   
      v$active_session_history
    where  
      sql_exec_id is not null
    and 
      user_id=93
       )
   group by 
      sql_id,
      sql_exec_id,
     sql_exec_start
   having 
      max(tm) > &exec_time
order by 
   sql_exec_start;
