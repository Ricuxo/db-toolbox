/*  */
rem
rem FUNCTION: Report on Redo log statistics
rem
col name format a30 heading 'Statistic|Name'
col value heading 'Statistic|Value'
start title80 "Redo Log Statistics"
spool rep_out\&db\red_stat
SELECT name, value
FROM v$sysstat
WHERE name like '%redo%'
order by name
/
spool off
pause Press enter to continue
ttitle off

