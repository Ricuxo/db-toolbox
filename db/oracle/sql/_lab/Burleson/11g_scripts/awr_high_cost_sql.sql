/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

col c1 heading 'SQL|ID'              format a13
col c2 heading 'Cost'                format 9,999,999
col c3 heading 'SQL Text'            format a200


select
  p.sql_id            c1,
  p.cost              c2,
  to_char(substr(s.sql_text,1,4000)) c3
from
  dba_hist_sql_plan    p,
  dba_hist_sqltext     s
where
      p.id = 0
  and
      p.sql_id = s.sql_id
  and
      p.cost is not null
order by  
  p.cost desc
;
