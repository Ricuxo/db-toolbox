/*  */
rem*************** RevealNet Oracle Administration ***********************
rem
rem  File: defrag7.sql
rem
rem  This is a part of the RevealNet Oracle Administration library.
rem       
rem  All rights reserved.
rem
rem  For more information, call RevealNet at 1-800-REVEAL4
rem  or check out our Web page: www.revealnet.com
rem
rem  Modifications (Date, Who, Description)
rem
rem  FUNCTION: Uses the "set events" command to manually coalesce
rem  FUNCTION: any tablespace with greater than 1 fragment. You
rem  FUNCTION: may wish to alter to exclude the temporary tablespace.
rem  FUNCTION: The procedure uses the FREE_SPACE view which is a 
rem  FUNCTION: summarized version of the DBA_FREE_SPACE view.
rem  FUNCTION: This procedure must be run from SYS user id.
rem
rem
@free2_spc
clear columns
clear computes
ttitle off
set heading off feedback off echo off termout off
spool def.sql
select 
	'alter session set events '||
	''''||'immediate trace name coalesce level '||ts#||''''||';'
from
	sys.ts$,
	free_space
where
	ts#=file_id-1 and pieces>1;
spool off
@def.sql
host del def.sql
set heading on feedback on termout on
@free2_spc

