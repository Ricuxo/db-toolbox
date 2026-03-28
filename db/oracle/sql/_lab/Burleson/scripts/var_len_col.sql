/*  */
col owner format a10 heading 'Owner'
col table_name format a30 heading 'Table Name'
col column_name format a25 heading 'Column Nmae'
col data_type format a10 heading 'Data Type'
col data_length heading 'Data Length'
set lines 132 pages 47
@title132 'Variable Length Columns'
spool rep_out\&db\var_len_col
select owner, table_name, column_name, data_type, data_length from dba_tab_columns
where owner=upper('&owner') and data_type in ('VARCHAR2','NUMBER')
order by 1,2,column_id
/
spool off
clear columns
ttitle off

