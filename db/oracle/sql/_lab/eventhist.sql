Rem
Rem    NOME
Rem      eventhist.sql
Rem
Rem    DESCRIÇÃO
Rem      Este script mostra por quais recursos/eventos uma sessão esperou.
Rem
Rem    UTILIZAÇÃO
Rem      @eventhist.sql <sid>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      26/02/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

SET VERIFY OFF
COL EVENT FOR A30

PROMPT
PROMPT  Mostra por quais recursos/eventos uma sessão esperou

SELECT SID,                    
       EVENT,                  
       TOTAL_WAITS,            
       TOTAL_TIMEOUTS,         
       TIME_WAITED,            
       AVERAGE_WAIT,           
       MAX_WAIT,               
       TIME_WAITED_MICRO
FROM v$session_event
where sid = ('&1')
order by TIME_WAITED desc
/

PROMPT A view v$session_event mostra as informações de evento totalizadas para a sessão com as colunas:
PROMPT • event: Nome do evento de espera
PROMPT • total_waits: Número total de esperas por evento
PROMPT • total_timeouts: Número total de timeouts por evento
PROMPT • time_waited: Tempo total de espera por esse evento, em centésimos de segundo
PROMPT • average_wait: Tempo médio em que esse evento foi esperado, em centésimos de segundo
PROMPT • time_waited_micro: Tempo total de espera por esse evento, em milionésimos de segundo.
PROMPT A view v$session_event resume todas as esperas de sessão para cada sessão listada em v$session. 
PROMPT

SET VERIFY ON