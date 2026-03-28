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

set pagesize 50
set linesize 1000
--set buffer 3000

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
col kill_session for a50
col LAST_CALL_ET for a30
col TRACE_IT for a70
col Kill_UNIX for a50
compute sum of PGA_ALLOC_MEM_MB ON REPORT
break on report

SELECT a.inst_id,
       a.sid,
       a.serial#,
       b.pid as PID_ORACLE,
       b.spid as SPID_SO_SERVER,
       a.process as PROCESS_CLIENT,
       a.sql_address,
       a.sql_id,
       a.username,
       a.status,
       to_char(a.logon_time,'yyyy/mm/dd hh24:mi:ss') logon_time,
       decode( trunc(last_call_et/86400),  -- 86400 seg = 1 dia
               0, '',                 -- se 0 dias, coloca brancos
               to_char(trunc(last_call_et/60/60/24), '0') || 'd, ')|| to_char( to_date(mod(last_call_et, 86400), 'SSSSS'),'hh24"h"MI"m"SS"s"') last_call_et,
       a.prev_hash_value,
       a.module,
       a.machine,
       a.osuser,
       b.PGA_ALLOC_MEM/1024/1024 pga_alloc_mem_MB,       
       'alter system kill session '''||a.sid||','||a.serial#||''' immediate;' as Kill_session,
       'exec dbms_system.set_ev('''||a.sid||''','''||a.serial#||''',10046,12,'''');' as Trace_it,
       'kill -9 '||b.spid||'' as Kill_UNIX
FROM   gv$session a, gv$process b
WHERE  a.paddr    = b.addr
AND    a.inst_id  = b.inst_id
AND    a.type <> 'BACKGROUND'
AND    (UPPER(a.username) like UPPER('&1') OR UPPER(a.SERVER) like UPPER('&1') OR UPPER(a.SCHEMANAME) like UPPER('&1') OR UPPER(a.MACHINE) like UPPER('&1') OR UPPER(a.MODULE) like UPPER('&1') OR UPPER(a.OSUSER) like UPPER('&1') OR TO_CHAR(a.sql_id) = '&1')
AND    a.status LIKE DECODE(UPPER('&2'),'A','ACTIVE','I','INACTIVE','%')
ORDER BY b.PGA_ALLOC_MEM/1024/1024 ASC
/

PROMPT