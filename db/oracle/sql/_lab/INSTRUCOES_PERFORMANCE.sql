--Segue um SELECT para acompanhar a performance de instruções do banco de dados.

select a.username, a.sid, a.serial#, b.spid, c.buffer_gets, c.sorts, c.rows_processed, to_char(a.logon_time,'DD-MM-RRRR HH24:MI:SS') as "HORARIO", c.address
from v$session a, v$process b, v$sqlarea c
where a.paddr=b.addr and a.sql_address=c.address and a.username is not null
order by c.buffer_gets desc;