/*  */
col owner heading 'Owner'
col index_type heading 'Index|Type'
col num heading 'Count'
@title80 'Index Type Report'
spool rep_out\&db\index_type
select owner, index_type, count(*) Num from dba_indexes group by owner, index_type;
spool off
ttitle off
clear columns
