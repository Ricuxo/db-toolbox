/*  */
REM NAME        : PROFILE.SQL
REM
REM FUNCTION    : GENERATE USER PROFILES REPORT
REM
REM USE         : CALLED BY PROFILE_REPORT.COM
REM
set flush off term off pagesize 58 linesize 78
column profile        	format A20  	heading Profile
column resource_name              		heading 'Resource:'
column limit          	format A15  	heading Limit
break on profile
start title80 'ORACLE PROFILES REPORT'
define output = rep_out\&db\profiles
spool &output
select profile, resource_name, limit  from sys.dba_profiles
order by profile;
spool off
set flush on term on pagesize 22 linesize 80
clear columns
clear breaks
pause Press enter to continue
