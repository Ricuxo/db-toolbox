/*  */
rem sql_text.sql
rem
rem Function: Get all SQL code from shared SQL area
rem
rem Mike Ault 2/28/97 Rev 0.
rem
break on address on sorts on users_executing
set pages 55 lines 132
start title132 'SQL Text in Shared Memory'
spool rep_out\&db\sql_text
select b.address,b.sql_text,sorts,users_executing
from v$sqlarea a, v$sqltext b
where
a.hash_value=b.hash_value
order by b.address,piece,sorts,users_executing
/
spool off
set pages 22 lines 80
pause Press enter to continue
