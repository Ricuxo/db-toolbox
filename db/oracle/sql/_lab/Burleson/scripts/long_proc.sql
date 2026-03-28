/*  */
col sid heading 'Sid'
col ser heading 'Serial#'
col module format a20 heading 'Module|Name'
col program heading 'Program'
col last_call heading 'Last|Call'
col sql_hash_value heading 'Hash|Value'
col spid heading 'System|Pid'
col process heading 'Process'
set lines 132 pages 55
start title132 'Long Running Processes'
spool rep_out\&&db\long_proc
SELECT c.sid, c.serial# ser, c.module,
SUBSTR(c.program,1,10) Program,
c.last_call_et Last_Call, c.sql_hash_value,
d.spid, c.process
FROM v$session c, v$process d
where c.status='ACTIVE'
AND c.last_call_et>300
and c.paddr=d.addr
and c.lockwait is null
and (c.program like 'f60%'
or c.program like 'sqlplus%')
/
spool off
set lines 80 pages 22
ttitle off
