Rem
Rem    NOME
Rem      license.sql
Rem
Rem    DESCRIÇÃO
Rem      Este script fornece informações o total de acessos deste banco de dados.
Rem      
Rem    UTILIZAÇÃO
Rem      @license
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       01/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------


--
column PROCESSES format a15
select SESSIONS_MAX SES_MAX, 
       SESSIONS_WARNING SES_WARNING,
       SESSIONS_CURRENT SES_CURRENT, 
       SESSIONS_HIGHWATER SES_HIGHWATER, 
       USERS_MAX, 
       VALUE PROCESSES
from V$LICENSE, V$PARAMETER
where V$PARAMETER.NAME = 'processes'
/
--
