Rem
Rem    NOME
Rem      access.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script lista os objetos que estão atualmente bloqueados e as sessões que estão acessando eles. 
Rem      This view displays objects in the database that are currently locked and the sessions that are accessing them.
Rem      
Rem    UTILIZAÇÃO
Rem      @access <object>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       01/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

col dtr for a20
col username FOR A13
col status for A3 trunc
col osuser for A10
col machine for A35 trunc
col terminal for A15
col osuser for a20
col program for A25 trunc
col module for a25 trunc
col sid for 999999
col spid for 9999999
col OWNER for a10
col OBJECT for a30

PROMPT
PROMPT  SID que está acessando o objeto

SELECT a.sid,
        a.serial#,
        c.owner || '.' || c.object as object,  
        c.type as object_type,
        b.spid,
        a.sql_hash_value,
        a.username,
        a.status,
        to_char(a.logon_time,'dd/mm/yyyy hh24:mi:ss') dtr,
        a.program,
        a.module,
        a.machine,
        a.osuser
FROM   gv$session a, gv$process b, gv$access c
WHERE  a.paddr = b.addr
AND    a.sid = c.sid
AND    a.username  IS NOT NULL
AND    c.object = ('&1')
ORDER BY dtr ASC, 8
/



