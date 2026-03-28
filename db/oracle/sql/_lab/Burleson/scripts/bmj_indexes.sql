/*  */
col index_owner format a11 heading 'Index|Owner'
col index_name format a10 heading 'Index|Owner'
col inner_table_owner format a11 heading 'Inner|Table Owner'
col inner_table_name format a11 heading 'Inner|Table Name'
col inner_table_column format a13 heading 'Inner|Table Column'
col outer_table_owner format a12 heading 'Outer|Table Owner'
col outer_table_name format a11 heading 'Outer|Table Name'
col outer_table_column format a13 heading 'Outer|Table Column'
set lines 132
@title132 'Bitmap Join Indexes'
spool rep_out\&&db\bmj_indexes
select 
      index_owner, index_name, 
      inner_table_owner, inner_table_name,inner_table_column,
      outer_table_owner,outer_table_name,outer_table_column
from 
      dba_join_ind_columns
where 
      index_owner = UPPER('&owner');
spool off
clear columns
ttitle off
set lines 80
