/*  */
column username                 format a15 heading User
column granted_role             format a20 heading Roles
column default_role             format a9  heading Default?
column admin_option             format a7  heading Admin?
column profile                  format a15 heading 'Users Profile'
rem
set pages 55 lines 132
start title132 'ORACLE DBA/RESOURCE REPORT'
define output = rep_out\&db\dr_rep
break on username on profile
spool &output
select username, profile,
granted_role, admin_option, default_role
from sys.dba_users a, sys.dba_role_privs b
where a.username = b.grantee
and granted_role in ('DBA','RESOURCE')
order by username,
profile, granted_role
/
spool off
set pages 22 lines 80
ttitle off
clear columns
