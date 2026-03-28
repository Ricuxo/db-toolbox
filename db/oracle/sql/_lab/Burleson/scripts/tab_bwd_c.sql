/*  */
col tablespace_name format a29
col table_name format a27
col owner format a17
col chain_cnt heading 'Chained|Rows'
set lines 132 pages 47
@title132 'Table Block Wait Determination Values'
spool rep_out\&&db\tab_bwd_c
select owner,table_name,tablespace_name,pct_free,pct_used,ini_trans,freelists,chain_cnt
from dba_tables where owner not in (select * from no_check) and chain_cnt>0
order by owner,tablespace_name,table_name
/
spool off
undef columns
set lines 80 pages 22

