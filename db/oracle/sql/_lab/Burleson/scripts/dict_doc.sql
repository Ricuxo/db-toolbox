/*  */
column table_name format a25 heading 'View Name'
column tab_comments format a37 word_wrapped heading 'Table Commnet'
column column_name format a25 heading 'Column Name'
column col_comments format a37 word_wrapped heading 'Column Comment'
break on table_name on tab_comments
set lines 131 feedback off verify off pages 47
start title132 'Dictionary Documentation'
spool rep_out\&db\dict_doc
select distinct a.table_name,a.comments tab_comments,b.column_name,
b.comments col_comments
from dba_tab_comments a, dba_col_comments b
where a.owner=b.owner and
a.table_name=b.table_name and
(a.table_name like 'DBA_%' or
a.table_name like '%$')
order by table_name
/
spool off
clear columns
clear breaks
set lines 80 pages 22 feedback on verify on
ttitle off
