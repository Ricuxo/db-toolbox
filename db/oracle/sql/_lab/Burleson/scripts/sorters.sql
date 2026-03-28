/*  */
col sql_text format a40 word_wrapped
col username format a15
col sid format 999999
col system_date format a20 heading 'System|Date'
set lines 132 pages 50
ttitle2 'Sorters Report'
spool sorters
select 
to_char(system_date,'dd-mon-yyyy hh24:mi') system_date, sid,username,
extents,blocks,sql_text from sorters
/
spool off
