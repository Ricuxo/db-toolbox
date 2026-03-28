/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

col c1 heading 'Date'                format a20
col c2 heading 'Nested|Loops|Count'  format 99,999,999
col c3 heading 'Rows|Processed'      format 99,999,999
col c4 heading 'Disk|Reads'          format 99,999,999
col c5 heading 'CPU|Time'            format 99,999,999



accept nested_thr char prompt 'Enter Nested Join Threshold: '

ttitle 'Nested Join Threshold|&nested_thr'

select
   to_char(sn.begin_interval_time,'yy-mm-dd hh24')  c1,
   count(*)                                         c2,
   sum(st.rows_processed_delta)                     c3,
   sum(st.disk_reads_delta)                         c4,   
   sum(st.cpu_time_delta)                           c5
from
   dba_hist_snapshot sn,
   dba_hist_sql_plan  p,
   dba_hist_sqlstat  st
where
   st.sql_id = p.sql_id
and
   sn.snap_id = st.snap_id    
and    
   p.operation = 'NESTED LOOPS'
having
   count(*) > &hash_thr       
group by
   begin_interval_time;
