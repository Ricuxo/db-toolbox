Rem
Rem    NOME
Rem      latchfree.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script mostra as sessões que estão aguardando por latch free.
Rem
Rem    UTILIZAÇÃO
Rem      @latchfree 
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      06/03/09 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off

PROMPT
PROMPT 
PROMPT DEFINIÇÃO: LATCH (trinco) é um lock interno de baixo nível usado pelo Oracle para proteger estruturas de memória. 



PROMPT
PROMPT
PROMPT DESCRIÇÃO: Esta consulta exibe as sessões aguardando pelo evento latch free.

col EVENT      for a12
col LATCH_NAME for a20
col WAIT_TIME  for a38
col STATE      for a25

SELECT w.sid, 
       w.event, 
       n.name as latch_name, 
       decode(w.wait_time,  0, 'SECONDS_IN_WAIT = DA SESSAO ATUAL',  
                           -5, 'SECONDS_IN_WAIT = DA SESSAO ANTERIOR',
                           -4, 'SECONDS_IN_WAIT = DA SESSAO ANTERIOR',
                           -3, 'SECONDS_IN_WAIT = DA SESSAO ANTERIOR',
                           -2, 'SECONDS_IN_WAIT = DA SESSAO ANTERIOR',
                           -1, 'SECONDS_IN_WAIT = DA SESSAO ANTERIOR',
                            1, 'SECONDS_IN_WAIT = DA SESSAO ANTERIOR',
                            2, 'SECONDS_IN_WAIT = DA SESSAO ANTERIOR',
                            3, 'SECONDS_IN_WAIT = DA SESSAO ANTERIOR',
                            4, 'SECONDS_IN_WAIT = DA SESSAO ANTERIOR',
                            5, 'SECONDS_IN_WAIT = DA SESSAO ANTERIOR') as wait_time,
       w.seconds_in_wait as sec_in_wait,     
       w.p1text, 
       w.p1, 
       w.p1raw,
       w.p3 as tries_for_latch,
       w.state
FROM v$session_wait w, v$latchname n
WHERE w.event = 'latch free'
  AND w.p2 = n.latch#
ORDER BY n.name, w.seconds_in_wait desc
/


PROMPT
PROMPT
PROMPT DESCRIÇÃO: Esta consulta exibe o SQL_HASH_VALUE das sessões aguardando por latch free.

SELECT W.event,
       l.name as latch_name, 
       se.sql_hash_value, 
       count(1) qtd
FROM gv$session_wait W, gv$latch l, gv$session se
WHERE w.event = 'latch free'
  AND w.p2 = l.latch#
  AND w.sid = se.sid
GROUP BY w.event, l.name, se.sql_hash_value
ORDER BY l.name, qtd
/



PROMPT
PROMPT
PROMPT DESCRIÇÃO: Esta consulta exibe informações das sessões aguardando pelo evento latch free.

col "SID,SERIAL#" for a10
col USERNAME      for a12
col PROGRAM       for a30
col last_call_et  for a12
col MODULE        for a30
col STATE         for a8  

SELECT b.name as LATCH_NAME,
       a.sid || ',' || c.serial# as "SID,SERIAL#", 
       c.status, 
       case when c.last_call_et > 60 then
         case when c.last_call_et / 60 > 60 then
           lpad( trunc( c.last_call_et / 60 / 60 ), 2, '0' ) || ':' ||
           lpad( round( 60 * ( round( c.last_call_et / 60 / 60, 2 ) - floor( c.last_call_et / 60 /60 ) ) ), 2, '0' ) || ':00'
         else
           '00:' || lpad( trunc( c.last_call_et / 60 ), 2, '0' ) || ':' || 
           lpad( round( 60 * ( round( c.last_call_et / 60, 2 ) - floor( c.last_call_et / 60 ) ) ), 2, '0' )
         end
       else
         '00:00:' || lpad( c.last_call_et, 2, '0' )
       end last_call_et, 
       c.username, 
       c.program,
       c.module, 
       c.sql_hash_value, 
       a.state, 
       a.seconds_in_wait
FROM v$session_wait a, v$latchname b, v$session c
WHERE a.event = 'latch free'
  AND a.state = 'WAITING'
  AND a.p2 = b.LATCH# 
  AND a.sid = c.sid
/

PROMPT


set feedback on