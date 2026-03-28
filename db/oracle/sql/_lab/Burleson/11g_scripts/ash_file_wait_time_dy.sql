

select
   f.file_name file_name,
   COUNT(*)    Wait_Number,
   SUM(h.time_waited) Total_Time_Waited
from
   v$active_session_history     h,
   dba_data_files               f
where
   h.current_file# = f.file_id
group by
   f.file_name
order by f.file_name DESC
;
