/*  */
REM
REM NAME        : ROLE.SQL
REM FUNCTION    : GENERATE ROLES REPORT
REM USE         : CALLED BY ROLE_REPORT.COM
REM Limitations : None
REM
set flush off term off pagesize 58  linesize 78
column grantee          heading 'User or Role'
column admin_option     heading 'Admin?'
break on grantee
start title80 'ORACLE ROLES REPORT'
define output = 'rep_out\&db\role_rpt'
spool &output
select grantee, privilege, admin_option 
from sys.dba_sys_privs
order by grantee;
spool off
set flush on term on pagesize 22  linesize 80
clear columns
clear breaks
ttitle off
pause Press enter to continue

