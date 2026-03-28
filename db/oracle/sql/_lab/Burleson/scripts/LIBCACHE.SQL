/*  */
rem
rem Title: libcache.sql
rem
rem FUNCTION: Generate a library cache report 
rem Mike Ault Burleson Consulting
rem
column namespace                        heading "Library Object"
column gets             format 99,999,999 heading "Gets"
column gethitratio      format 999.99   heading "Get Hit%"
column pins             format 999,999,999  heading "Pins"
column pinhitratio      format 999.99   heading "Pin Hit%"
column reloads          format 999,999   heading "Reloads"
column invalidations    format 999,999   heading  "Invalid"
column db format a10
start title80 "Library Caches Report"
set pages 58 lines 85 
define output = rep_out\&db\lib_cache
spool &output
select 
	namespace,
	gets,
	gethitratio*100 gethitratio,
	pins,
	pinhitratio*100 pinhitratio,
	RELOADS,
	INVALIDATIONS 
from 
	v$librarycache
/
spool off
pause Press enter to continue
set pages 22 lines 80
ttitle off
undef output
