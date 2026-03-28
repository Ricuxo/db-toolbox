/*  */
rem chained_rows.sql
rem FUNCTION: SHow percentage of chained rows
rem tables must have been analyzed
rem MRA
rem
column "Chain Percent" format 999.99
column table_name heading 'Table|Name'
column chain_cnt heading 'Chained|Rows'
column num_rows heading 'Row|Count'
set pages 47
set feedback off
@title80 'Chained Rows Report'
spool rep_out/&db/chained_rows
select table_name,chain_cnt, num_rows, chain_cnt/num_rows*100 "Chain Percent" from dba_tables
where
chain_cnt>1 
/
--and owner not in ('SYS','SYSTEM')
spool off
ttitle off

