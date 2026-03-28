/*  */
rem
rem FUNCTION: Report on Rollback (UNDO) statistics
rem
start title80 "Rollback Statistics"
spool rep_out\&db\red_stat
SELECT class, count
FROM v$waitstat
WHERE class IN ('free list', 'system undo header', 'system undo block',
                'undo header', 'undo block')
order by class
/
spool off
pause Press enter to continue
ttitle off

