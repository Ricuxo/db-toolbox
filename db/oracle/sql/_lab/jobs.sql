Rem
Rem    NOME
Rem      jobs.sql  
Rem
Rem    DESCRIÇÃO
Rem      Lista os jobs schedulados no Banco Oracle.
Rem      
Rem    UTILIZAÇÃO
Rem      @jobs
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      26/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------


--
column JOB      format 99999
column LOG_USER format a15
column WHAT     format a50
column BROKEN   format a6
column INTERVAL format a15
COLUMN proximo FORMAT a20
COLUMN ultimo FORMAT a20
--
select JOB, 
       LOG_USER, 
       WHAT, 
       THIS_DATE,       
       to_char(last_date,'dd/mm/yyyy hh24:mi') ultimo,
       to_char(next_date,'dd/mm/yyyy hh24:mi' ) proximo,
       TOTAL_TIME, 
       BROKEN, 
       FAILURES, 
       INTERVAL
from DBA_JOBS
order by JOB;
--
set heading off
select decode( count(0), 0, 'Não há' ) || ' jobs.'
from DBA_JOBS;
--
prompt
--
