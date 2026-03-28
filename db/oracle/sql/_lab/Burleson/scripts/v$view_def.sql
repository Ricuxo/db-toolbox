/*  */
column view_name format a20 heading 'V$ View Name'
column view_definition format a50 word_wrapped heading 'View SQL Definition'
set lines 78 pages 47 verify off feedback off
start title80 'V$ View Definitions'
spool rep_out\&db\v$view_def
select * from sys.v_$fixed_view_definition 
/
spool off
set pages 22 verify on feedback on
ttitle off
clear columns
