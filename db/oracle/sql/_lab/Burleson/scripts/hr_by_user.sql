/*  */
col username format a15
column machine format a24
column program format a36
column sid format 999
column hit_ratio format 999.99 heading 'Hit|Ratio'
column seconds_idle heading 'Seconds|Idle'
column login format a22 heading 'Login'
column lockwait format a4 heading 'Lock|Wait'
start title132 'Hit Ratio by User'
set lines 200 pages 50
spool rep_out\&db\hr_by_user
SELECT A.USERNAME, 
  A.sid, 
  A.MACHINE, 
  C.spid OS_ID, 
  status,
  TO_CHAR(logon_time,'DD-MON-YY HH24:MI:SS PM') login,
  DECODE(A.LOCKWAIT,NULL,'No','Yes') Lockwait,
  round(100 * (consistent_gets + block_gets - physical_reads) /
  decode((consistent_gets + block_gets),0,1,(consistent_gets + block_gets)),2) HIT_RATIO ,
  LAST_CALL_ET SECONDS_IDLE,
  A.PROGRAM
FROM sys.V_$SESSION A, 
     sys.V_$SESS_IO B,
     sys.v_$process C
WHERE (A.SID = B.SID ) and 
      (( A.username is not null) and (A.paddr = C.addr )) 
order by A.username;
spool off
set lines 80 pages 22
