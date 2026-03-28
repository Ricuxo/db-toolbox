/*  */
rem chained_tab.sql
rem FUNCTION: Reports chained tables
rem MRA
rem
col tablespace_name format a15
col owner format a11
col table_name format a33
set lines 132 pages 47
@title132 'Tables With Chained Rows'
spool rep_out/&db/chained_tab
select owner,table_name,chain_cnt,num_rows,chain_cnt/num_rows*100 chn_pct,tablespace_name from dba_tables where chain_cnt>0
order by 1,4
/
spool off
ttitle off
