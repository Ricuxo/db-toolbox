Rem
Rem    NOME
Rem      systemevent.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script lista os eventos de espera do banco (total de todas as sessões desde a última inicialização)      
Rem
Rem    UTILIZAÇÃO
Rem      @systemevent
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      07/03/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

PROMPT
PROMPT Lista os eventos de espera do banco (total de todas as sessões desde a última inicialização)

select EVENT, 
       TOTAL_WAITS,
       TIME_WAITED/100 as SUM_WAITED_SEG,
       AVERAGE_WAIT/100 as AVG_WAITED_SEG,        
       TOTAL_TIMEOUTS, 
       TIME_WAITED_MICRO
from  v$system_event
order by TOTAL_WAITS
/
