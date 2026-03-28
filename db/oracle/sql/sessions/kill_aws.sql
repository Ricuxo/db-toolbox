col spid for a15
col program for a15
col Execute_command for a70
col status for a20
SELECT s.inst_id,
       s.sid,
       s.serial#,
       p.spid,
       S.Username,
       S.Program,
       S.status,
       'exec rdsadmin.rdsadmin_util.kill('||s.sid||','||s.serial#||',method => ''IMMEDIATE'');' as Execute_command
FROM   gv$session s
       Join Gv$process P On P.Addr = S.Paddr And P.Inst_Id = S.Inst_Id
Where  S.Type != 'BACKGROUND'
  AND s.username = UPPER('&username')
  AND status = 'INACTIVE'
  AND MACHINE LIKE '%&machine%';