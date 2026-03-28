Rem
Rem    NOME
Rem      searchsql.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista sessões ativas com determinado sql.
Rem
Rem    UTILIZAÇÃO
Rem      @searchsql
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      NORONHA      09/04/2013 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set pagesize 10000
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
col SQL_TEXT for a50
compute sum of PGA_ALLOC_MEM_MB ON REPORT
compute sum of session_uga_memory_max ON REPORT
compute sum of session_uga_memory ON REPORT
break on report

SELECT a.inst_id,
       a.sid,
       a.serial#,
       a.sql_id,
       a.sql_address,
       a.sql_hash_value,
       b.sql_text,
       a.username,
       to_char(a.logon_time,'yyyy/mm/dd hh24:mi:ss') logon_time,
       decode( trunc(last_call_et/86400),  -- 86400 seg = 1 dia
               0, '',                 -- se 0 dias, coloca brancos
               to_char(trunc(last_call_et/60/60/24), '0') || 'd, ')|| to_char( to_date(mod(last_call_et, 86400), 'SSSSS'),'hh24"h"MI"m"SS"s"') last_call_et,
       a.prev_hash_value,
       a.module,
       a.machine,
       a.osuser,       
       'alter system kill session '''||a.sid||','||a.serial#||''' immediate;' as Kill_session,
       'exec dbms_system.set_ev('''||a.sid||''','''||a.serial#||''',10046,12,'''');' as Trace_it
FROM   gv$session a, gv$sql b
WHERE  a.inst_id  = b.inst_id
AND    a.sql_id  = b.sql_id
AND    a.sql_address = b.address
AND    a.sql_child_number = b.child_number
AND    UPPER(b.sql_text) like UPPER('%&1%')
AND    a.status='ACTIVE'
AND    A.USERNAME NOT IN ('SYSTEM','SYS')
ORDER BY a.inst_id, last_call_et ASC
/

PROMPT