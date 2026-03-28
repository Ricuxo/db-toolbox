/*  */
set long 10000
column query format a80 word_wrapped
set heading off pages 0
spool rep_Out\dwprd\basic_mviews.doc
select 'create or replace materialized view '||owner||'.'||mview_name||' as '||chr(10)||query from dba_mviews
/
spool off
