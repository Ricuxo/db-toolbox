/*  */
rem
rem title:    ddcache.sql
rem FUNCTION: report on the v$rowcache table
rem HISTORY:  created sept 1995 MRA
rem
start title80 "DD Cache Hit Ratio"
spool rep_out\&db\ddcache
SELECT (SUM(getmisses)/SUM(gets))*100 Miss_percent
FROM V$ROWCACHE
/
spool off
pause Press enter to continue
ttitle off
