/*  */
REM event                       cause                           action
REM --------------------------- -----------------------------   -----------------------------------------
REM free buffer waits           DBWR not writing frequently     inscrease number of checkpoints 
REM                             enough  
REM latch free                  contention for latches          dependent upon latch
REM buffer busy waits           I/O contention, Parallel        tune I/O and distribute data effectively
REM                             Server conntention for data
REM                             blocks
REM db file sequential read     I/O contention                  tune I/O and distribute data effectively
REM db file scattered read      too many table scans            tune I/O, distribute data effectively
REM                                                             improperly tuned SQL statements
REM db file parallel write      not checkpointing frequently    increase number of checkpoints
REM                             enough
REM undo segment extension      too much dynamic extenstion/    appropriatley size rollback segments
REM                             shrinking of rollback segments
REM undo segment tx slot`       not enough rollback segments    create the appropriate number of segments
REM
column event format a25
column username format a10
set lin 131 pages 50 
set pau off
@title132 'Database Waits'
spool rep_out\&db\waits_list
select username, V$SESSION_WAIT.sid, event, seconds_in_wait, wait_time, p1 , p2, p3, state
  from V$SESSION_WAIT, V$SESSION
where V$SESSION_WAIT.SID = V$SESSION.SID
  and NOT(event like 'SQL%') 
  and NOT(event like '%message%')
  and NOT(event like '%timer%')
  and NOT(event like '%pipe get%')
  and state = 'WAITING'
  order by wait_time desc, event
/
spool off

