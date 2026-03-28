/*  */
set lines 132 pages 55
column del_lf_rows_len format 999,999,999 heading 'Deleted Bytes'
column lf_rows_len format 999,999,999 heading 'Filled Bytes'
column browning format 999.90 heading 'Percent|Browned'
start title132 "Index Browning Report"
spool rep_out/&db/browning.lst
select 
	name,del_lf_rows_len,lf_rows_len,
	(del_lf_rows_len/decode((lf_rows_len+del_lf_rows_len),0,1,
       lf_rows_len+del_lf_rows_len))*100 browning
            , (LF_ROWS-DISTINCT_KEYS)*100/ decode(LF_ROWS,0,1,LF_ROWS) DISTINCTIVENESS 
from 
	stat_temp 
where 
	lf_rows_len>0;
spool off
