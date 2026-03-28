/*  */
col tablespace_name format a19
col table_name format a26
col owner format a19
col chain_cnt heading 'Chained|Rows'
col ini_trans format 9999 heading 'Ini|Tran'
col pct_used format 9999 heading 'PCT|Used'
col pct_free format 9999 heading 'PCT|Free'
col freelists format 99999 heading 'Free|Lists'
set lines 132 pages 47
@title132 'Table Block Wait Determination Values'
spool rep_out\&&db\tab_bwd
select owner,table_name,tablespace_name,pct_free,pct_used,ini_trans,freelists,chain_cnt
from dba_tables where owner not in ('SYS','SYSTEM','RMAN817','OEM_CAPACITY_PLANNER','PERFSTAT')
order by owner,tablespace_name,table_name
/
spool off
undef columns
set lines 80 pages 22

