/*  */
rem
rem NAME: defrg73.sql
rem FUNCTION: Uses the "set events" command to manually coalesce
rem FUNCTION: any tablespace with greater than 1 fragment. You
rem FUNCTION: may wish to alter to exclude the temporary tablespace.
rem FUNCTION: The procedure uses the FREE_SPACE view which is a 
rem FUNCTION: summarized version of the DBA_FREE_SPACE view.
rem FUNCTION: This procedure must be run from SYS user id.
rem
rem HISTORY:
rem WHO		WHAT		WHEN
rem Mike Ault	Created		1/4/96
rem
@free_spc
clear columns
clear computes
define cr='chr(10)'
ttitle off
set heading off feedback off echo off termout off
spool def.sql
select 
	'alter tablespace '||tablespace||' coalesce;'||&&cr||
	'commit;'
from
	free_space
where
	pieces>1;
spool off
@def.sql
host del def.sql
set heading on feedback on termout on echo off
@free_spc
ttitle off
