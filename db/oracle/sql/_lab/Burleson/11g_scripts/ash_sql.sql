/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

select 
   h.sql_id,
   s.sql_text
from
   dba_hist_active_sess_history h,
   v$sql                        s
where
   h.session_id = 74 
AND
   h.sql_id = s.sql_id 
AND
   TRUNC(h.sample_time) = TRUNC(SYSDATE) 
AND
   s.sql_fulltext like '%orders%';
