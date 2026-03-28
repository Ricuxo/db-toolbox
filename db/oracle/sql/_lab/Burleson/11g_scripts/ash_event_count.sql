

select
   h.sql_id,
   count(*)
from
   dba_hist_active_sess_history h,
   v$sql                        s
where
   h.sql_id = s.sql_id 
and
   s.sql_fulltext like '%orders%'
having 
   count(*) > 1
group by
   h.sql_id
order by 
   2 DESC
;
