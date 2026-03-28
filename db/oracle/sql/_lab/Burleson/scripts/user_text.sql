/*  */

set lines 132 pages 55
break on sql_address on username
start title132 'Active SQL Text in Shared Memory'
spool rep_out\&db\active_text
select sql_address,username,sql_text
from v$session,v$sqltext
where v$session.sql_address is not null and
v$session.sql_address=v$sqltext.address
order by username, sql_address, piece
/
spool off
set pages 22 lines 80
pause Press enter to continue
