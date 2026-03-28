/*  */
@title80 'Enqueues Report'
spool rep_out\&db\enqueues
prompt Enqueues
col name format a25
col lock format a4 heading 'Lock'
col gets format 9,999,999 heading 'Gets'
col waits format 9,999,999 heading 'Waits'
col Mode format a4
SELECT *      FROM v$sysstat     WHERE class=4;

SELECT chr(bitand(p1,-16777216)/16777215)||
         chr(bitand(p1, 16711680)/65535) "Lock",
         to_char( bitand(p1, 65535) )    "Mode"
    FROM v$session_wait
   WHERE event = 'enqueue'
  
/

Prompt Enqueue Stats

select * from v$enqueue_stat where cum_wait_time>0
/
spool off
ttitle off
