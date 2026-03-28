-- Usage: @ver.sql <instance_id> <status> <event> <username>
set ver off
SET pages 250
SET lin 2000
COL COMMAND for a12 trunc
COL inst_id for 9999999
COL sid for 999999
COL serial# for 999999
COL spid for a8
COL username for a15 trunc
COL module for a15 trunc
COL status for a9
COL machine for a15 trunc
COL event for a35 trunc
COL logon_time for a20
COL osuser for a15 trunc
COL WAIT_CLASS for a15
COL SECS_WAIT for a12
COL resource_group for a8 trunc

COL "PGA_USED(MB)" for 99990.09
COL "PGA_ALLOC(MB)" for 99990.09
COL "PGA_MAX(MB)" for 99990.09

COL "UNDO_USAGE(MB)" for 99990.09
COL "TEMP_USAGE(MB)" for 9999990.09
COL "PX_SLAVES" for a10
COL "PX_OPERS" for a12
COL LAST_CALL for A15
COL KILL_SESSION for a55
COL START_TRACE for a65
COL KILL_UNIX for a20

compute sum of "PGA_USED(MB)" on report
compute sum of "PGA_ALLOC(MB)" on report
compute sum of "PGA_MAX(MB)" on report
compute sum of "TEMP_USAGE(MB)" on report
compute sum of "UNDO_USAGE(MB)" on report
break on report

SELECT distinct s.inst_id,
       s.failed_over,
       s.RESOURCE_CONSUMER_GROUP as resource_group,
       s.sid, 
       s.serial#, 
       p.spid,
       s.username,
       s.status, 
          decode(s.command,
          1,'Create table' , 2,'Insert',
          3,'Select' , 6,'Update',
          7,'Delete' , 9,'Create index',
          10,'Drop index' ,11,'Alter index',
          12,'Drop table' ,13,'Create seq',
          14,'Alter sequence' ,15,'Alter table',
          16,'Drop sequ.' ,17,'Grant',
          19,'Create syn.' ,20,'Drop synonym',
          21,'Create view' ,22,'Drop view',
          23,'Validate index' ,24,'Create procedure',
          25,'Alter procedure' ,26,'Lock table',
          42,'Alter session' ,44,'Commit',
          45,'Rollback' ,46,'Savepoint',
          47,'PL/SQL Exec' ,48,'Set Transaction',
          60,'Alter trigger' ,62,'Analyze Table',
          63,'Analyze index' ,71,'Create Snapshot Log',
          72,'Alter Snapshot Log' ,73,'Drop Snapshot Log',
          74,'Create Snapshot' ,75,'Alter Snapshot',
          76,'drop Snapshot' ,85,'Truncate table',
          40,'Alter Tablespace',
          50,'Explain plan',
          35,'Alter Database',
          189,'Merge',
          0,'No command', '? : '||s.command) as COMMAND,
       s.sql_id,
       --s.prev_sql_id,
       --s.sql_exec_id,
       sq.plan_hash_value,
        --sq.optimizer_cost "SQL_COST",
       --s.WAIT_TIME,
       DECODE (TRUNC (s.last_call_et / 86400),0,'',TO_CHAR (TRUNC (s.last_call_et / 60 / 60 / 24), '000')|| 'd,')|| TO_CHAR (TO_DATE (MOD(last_call_et, 86400), 'SSSSS'),'hh24"h"MI"m"SS"s"') "LAST_CALL",
       DECODE (TRUNC (s.seconds_in_wait / 86400),0,'',TO_CHAR (TRUNC (s.seconds_in_wait / 60 / 60 / 24), '000')|| 'd,')|| TO_CHAR (TO_DATE (MOD(s.seconds_in_wait, 86400), 'SSSSS'),'MI"m"SS"s"') as secs_wait,
       w.event,
       s.wait_class as wait_class,
       s.blocking_session as blk_ses,
       TO_CHAR (s.logon_time, 'dd/mm/yyyy hh24:mi:ss') AS "LOGON_TIME",
       DECODE (ps."px oper cnt", '', 'N/A', ps."px oper cnt") as "PX_OPERS",
       DECODE (ps."px count", '', 'N/A', ps."px count") as "PX_SLAVES",
       s.osuser, 
       s.machine,
       s.module,
       p.pga_used_mem / 1024 / 1024 "PGA_USED(MB)",
       p.pga_alloc_mem / 1024 / 1024 "PGA_ALLOC(MB)",
       pga_max_mem / 1024 / 1024 "PGA_MAX(MB)",
       t.used_ublk * (SELECT distinct block_size FROM dba_tablespaces WHERE contents = 'UNDO')/1024/1024 "UNDO_USAGE(MB)",       
       ROUND (((su.blocks * (select value from v$parameter where name = 'db_block_size')) / 1024 / 1024), 2) "TEMP_USAGE(MB)",
       --ROUND (((su.blocks * pa.VALUE) / 1024 / 1024), 2) "TEMP_USAGE(MB)",
       sio.physical_reads,
	   sio.block_changes,
       'alter system kill session '''||s.sid||','|| s.serial#||',@'||s.inst_id||''' immediate;' as kill_session,'kill -9 ' || p.spid || '' AS kill_unix,
       'EXEC'||' dbms_system.set_sql_trace_in_session('||s.sid||', '||s.serial#||', TRUE);' start_trace, s.SERVICE_NAME
  FROM gv$session s, 
       gv$process p, 
       gv$session_wait w,
       gv$sql sq,
       gv$sess_io sio,
       gv$parameter pa,
       gv$transaction t,
       gv$sort_usage su,
       (SELECT qcsid, COUNT (DISTINCT server_set) "px oper cnt",
         COUNT (*) "px count"
        FROM gv$px_session 
        WHERE NOT server_set IS NULL
        GROUP BY qcsid, DEGREE) ps
WHERE s.SID     = ps.qcsid(+)
--
  AND s.SID     = sio.SID
  AND s.inst_id = sio.inst_id
--
  AND s.sid     = w.sid
  AND s.inst_id = w.inst_id
--
  AND s.sql_id  = sq.sql_id
  AND s.inst_id = sq.inst_id
  AND s.module  = sq.module
  AND s.sql_hash_value = sq.hash_value(+)
--
  AND s.paddr   = p.addr
  AND s.inst_id = p.inst_id
--
  AND s.taddr   = t.addr(+)
  AND s.inst_id = t.inst_id(+)
--
  AND s.saddr   = su.session_addr(+)
  AND s.inst_id = su.inst_id(+)
--
  AND s.TYPE <> 'BACKGROUND'
  AND s.username IS NOT NULL
--  AND s.status  = 'ACTIVE'
  AND s.inst_id LIKE NVL2('&1','&1%','%')
--
  AND s.status LIKE upper (NVL2('&2','&2%','%'))
-- 
  AND w.event LIKE NVL2('&3','%&3%','%')
--
  AND s.username LIKE upper(NVL2('&4','%&4%','%'))
--
  AND pa.NAME = 'db_block_size'
  --AND s.program NOT LIKE ('%(P%')                 --Eliminate Parallel Slaves
ORDER BY   last_call
/
