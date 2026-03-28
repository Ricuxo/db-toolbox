/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

accept sqlid prompt ‘Please enter SQL ID: ‘

col c1 heading ‘Operation’           format a20
col c2 heading ‘Options’             format a20
col c3 heading ‘Object|Name’         format a25
col c4 heading ‘Search Columns’      format 999,999
col c5 heading ‘Cardinality’         format 999,999

select
   operation            c1,
   options              c2,
   object_name          c3,
   search_columns       c4,
   cardinality          c5
from
   dba_hist_sql_plan p
where
        p.sql_id = '&sqlid'
order by
   p.id;
