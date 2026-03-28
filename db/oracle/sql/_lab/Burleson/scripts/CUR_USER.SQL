/*  */
REM
REM title: current_users.sql
REM
REM  FUNCTION: PROVIDE LISTING OF CURRENTLY ACTIVE USERS
REM
REM  LIMITS: NONE
REM
REM
REM
start title80 "DATABASE CURRENT USERS REPORT"
define output = rep_out\&db\cur_usrs
spool &output
column username format a30 heading 'USERNAME'
column count(*) format 999 heading '# OF LOGINS'
select nvl(username,'SYS') username, count(*) from v$session
group by username
order by username;
spool off
clear columns
ttitle off
pause press enter to continue



