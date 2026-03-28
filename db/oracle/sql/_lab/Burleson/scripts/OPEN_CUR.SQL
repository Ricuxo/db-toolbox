/*  */
rem
rem FUNCTION: Provide a count of open cursors per user
rem
rem open_cursors.sql
rem
column user_name    heading User
column num          heading Number|Of|Cursors
start title80 'Open Cursors By User'
set lines 80 pages 59
spool rep_out\&db\opn_curs
select user_name, count(*) num from sys.v_$open_cursor group by user_name;
spool off
clear columns
ttitle off
set pages 22
pause Press enter to continue
