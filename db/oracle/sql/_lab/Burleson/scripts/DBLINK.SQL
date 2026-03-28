/*  */
REM
REM NAME         : DBLINK.SQL
REM FUNCTION     : GENERATE REPORT OF DATABASE LINKS
REM USE          : FROM SQLPLUS
REM Limitations  : None
REM
set pages 58 lines 130 verify off term off
start title132 "Db Links Report"
spool rep_out\&db\dblinks
column host             format a60      heading "Connect String Used"
column owner            format a15      heading "Creator of DB Link"
column db_link          format a10      heading " DB Link Name" 
column username         format a15      heading "Connecting User"
column password         format a15      heading "Password"
column create                           heading "Date Created" 
select 
	host, 
	owner, 
	db_link, 
	username, 
	created
from 
	dba_db_links
order by 
	owner, 
	host;
spool off
pause Press enter to continue
set pages 22 lines 80 verify on termout on
ttitle off
clear columns
