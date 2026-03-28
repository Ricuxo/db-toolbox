/*  */
REM
REM NAME        : USER7.SQL
REM FUNCTION    : GENERATE USER_REPORT
REM USE         : CALLED BY USER_REPORT.COM
REM Limitations : None
REM
set pagesize 40  linesize 131
rem
column username                 format a10 heading User
column default_tablespace       format a20 heading "Default Tablespace"
column temporary_tablespace     format a20 heading "Temporary Tablespace"
column granted_role             format a25 heading Roles
column default_role             format a9  heading Default?
column admin_option             format a7  heading Admin?
column profile                  format a15 heading 'Users Profile'
rem
start title132 'ORACLE USER REPORT'
define output = rep_out\&db\usr_rep
break on username skip 1 on default_tablespace on temporary_tablespace on profile
spool &output
rem 
select username, default_tablespace, temporary_tablespace, profile,
granted_role, admin_option, default_role 
from sys.dba_users a, sys.dba_role_privs b
where a.username = b.grantee 
order by username, default_tablespace, temporary_tablespace, 
profile, granted_role;
rem
spool off
set termout on flush on feedback on verify on
clear columns
clear breaks
pause Press enter to continue
