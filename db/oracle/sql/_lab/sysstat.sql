Rem
Rem    NOME
Rem      sysstat.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script lista as estatísticas da Instância desde a última inicialização.      
Rem
Rem    UTILIZAÇÃO
Rem      @sysstat
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      07/03/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

PROMPT
PROMPT Este script lista as estatísticas da Instância desde a última inicialização.

select STATISTIC#, 
       NAME, 
       decode(CLASS,1,'Atividade Instância',
                    2,'Buffer Redo Log',
                    4,'Bloqueios - Enqueue',
                    8,'Buffer Cache',
                   16,'S.O.',
                   32,'Parallel or RAC',
                   64,'SQL - Acesso Tabelas',
                  128,'Depuração - Debug') class,   
       VALUE 
from v$sysstat 
order by 3, 4
/
