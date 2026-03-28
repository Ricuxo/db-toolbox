/*  */
rem awt.sql
rem FUNCTION: Give average wait time for MTS queues
rem MRA
rem
start title80.sql 'Average Wait Time Report'
spool rep_out/&db/awt
SELECT DECODE( totalq, 0, 'No Requests',
      wait/totalq || ' hundredths of seconds')
   "Average Wait Time Per Requests"
   FROM v$queue
   WHERE type = 'COMMON'
/
spool off
ttitle off

