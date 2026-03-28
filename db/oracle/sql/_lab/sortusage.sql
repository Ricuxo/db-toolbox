Rem
Rem    NOME
Rem      sortusage.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script mostra a utilização dos segmentos temporários.      
Rem
Rem    UTILIZAÇÃO
Rem      @sortusage 
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      10/03/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off
col USERNAME for a15
col tam_mb   for 9999999999999999

SELECT s.sid,
       s.serial#,
       s.username, 
       u.sqlhash,
       u.tablespace, 
       u.contents, 
       (u.blocks * (select VALUE from v$parameter where NAME = 'db_block_size')) / 1024/1024 as TAM_MB,
       ((select VALUE from v$parameter where NAME = 'db_block_size')/1024) as Block_KB,  
       u.blocks as block_qtd
FROM v$session s, v$sort_usage u
WHERE s.saddr=u.session_addr
order by 5
/

select * 
from v$sort_segment
order by CURRENT_USERS
/

PROMPT
set feedback off