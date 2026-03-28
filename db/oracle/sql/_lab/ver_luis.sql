Rem
Rem    NOME
Rem      ver.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista informações sobre as sessões ativas.
Rem
Rem    UTILIZAÇÃO
Rem      @ver
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      27/12/06 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set pagesize 250
set linesize 1000
--set buffer 3000
col service_name for a20
col inst_id for 999
col LOGON_TIME for a20
col serial# for 99999
col username FOR A15
col status for A15
col osuser for A10
col machine for A35 
col terminal for A15
col osuser for a20
col program for A65 
col sid for 999999
col spid for 9999999
col process for a15
col kill_session for a60
col LAST_CALL for a14
col TRACE_IT for a70
col Kill_UNIX for a50
col SPID_SO_SERVER for a14
col PROCESS_CLIENT for a14
col command for a14
col RMGROUP for a15
col KILL_SESSION10G for a60

compute sum of PGA_ALLOC_MEM_MB ON REPORT
compute sum of session_uga_memory_max ON REPORT
compute sum of session_uga_memory ON REPORT
break on report

SELECT a.inst_id,
       FAILED_OVER failed,
       a.sid,
       a.serial#,
--       b.pid as PID_ORACLE,
       b.spid as SPID_SO_SERVER,
       a.process as PROCESS_CLIENT,
       a.status,
       a.RESOURCE_CONSUMER_GROUP RMGROUP,
       a.prev_sql_id,
--       a.PREV_CHILD_NUMBER,
       a.sql_id,
       a.sql_child_number,
       c.name COMMAND,
--       to_char(a.sql_exec_start,'dd/mm/yyyy hh24:mi:ss') sql_exec_start,
       decode( trunc(last_call_et/86400),  -- 86400 seg = 1 dia
               0, '',                 -- se 0 dias, coloca brancos
               to_char(trunc(last_call_et/60/60/24), '0') || 'd, ')|| to_char( to_date(mod(last_call_et, 86400), 'SSSSS'),'hh24"h"MI"m"SS"s"') last_call,
       a.username,
       to_char(a.logon_time,'yyyy/mm/dd hh24:mi:ss') logon_time,
       'alter system kill session '''||a.sid||','||a.serial#||''' immediate;' as Kill_session10g,
       'alter system kill session '''||a.sid||','||a.serial#||',@'|| a.inst_id ||'''  immediate;' as Kill_session,
       a.osuser,
       a.machine,
       a.module,
       a.action,
       b.PGA_ALLOC_MEM/1024/1024 pga_alloc_mem_MB,
                (select ss.value/1024/1024 from v$sesstat ss, v$statname sn
                  where ss.sid = a.sid and sn.statistic# = ss.statistic# 
            and sn.name = 'session uga memory') session_uga_memory,
        (select ss.value/1024/1024 from v$sesstat ss, v$statname sn
          where ss.sid = a.sid and sn.statistic# = ss.statistic# 
            and sn.name = 'session uga memory max')    session_uga_memory_max,
       'exec dbms_system.set_ev('''||a.sid||''','''||a.serial#||''',10046,12,'''');' as Trace_it,
       'kill -9 '||b.spid||'' as Kill_UNIX,
       a.SERVICE_NAME
FROM   gv$session a, gv$process b, AUDIT_ACTIONS c
WHERE  a.paddr    = b.addr
AND    a.inst_id  = b.inst_id
AND    a.command  = c.action
AND    a.type <> 'BACKGROUND'
AND    (UPPER(a.username) like UPPER('&1') OR UPPER(a.machine) like UPPER('&1') OR TO_CHAR(a.inst_id) = '&1' OR UPPER(a.SERVER) like UPPER('&1') OR UPPER(a.program) like UPPER('&1') OR UPPER(a.SCHEMANAME) like UPPER('&1') OR UPPER(a.MACHINE) like UPPER('&1') OR UPPER(a.MODULE) like UPPER('&1') OR UPPER(a.OSUSER) like UPPER('&1') OR TO_CHAR(a.sql_hash_value) = '&1' OR UPPER(a.service_name) like UPPER('&1'))
AND    a.status LIKE DECODE(UPPER('&2'),'A','ACTIVE','I','INACTIVE','K','KILLED','%')
--AND  c.name='UPDATE'
--ORDER BY a.inst_id, last_call_et ASC
ORDER BY a.logon_time
/

PROMPT
