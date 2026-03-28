Rem
Rem    NOME
Rem      rac.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista informações sobre o desempenho das instancias em RAC
Rem
Rem    UTILIZAÇÃO
Rem      @rac
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      05/07/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set verify off
set feedback off

PROMPT
PROMPT Tempo interconnect
set numwidth 20
column "AVG CR BLOCK RECEIVE TIME (ms)" format 9999999.9
select b1.inst_id, 
       b2.value "GCS CR BLOCKS RECEIVED", 
       b1.value "GCS CR BLOCK RECEIVE TIME",
       ((b1.value / b2.value) * 10) "AVG CR BLOCK RECEIVE TIME (ms)"
from gv$sysstat b1, gv$sysstat b2
where b1.name = 'global cache cr block receive time' 
  and b2.name = 'global cache cr blocks received' 
  and b1.inst_id = b2.inst_id 
   or b1.name = 'gc cr block receive time' 
  and b2.name = 'gc cr blocks received' 
  and b1.inst_id = b2.inst_id
/

PROMPT
PROMPT bla bla
set numwidth 20
column "AVG GLOBAL LOCK GET TIME (ms)" format 9999999.9
select b1.inst_id, 
      (b1.value + b2.value) "GLOBAL LOCK GETS", 
       b3.value "GLOBAL LOCK GET TIME",
      (b3.value / (b1.value + b2.value) * 10) "AVG GLOBAL LOCK GET TIME (ms)"
from gv$sysstat b1, gv$sysstat b2, gv$sysstat b3
where b1.name = 'global lock sync gets' 
  and b2.name = 'global lock async gets' 
  and b3.name = 'global lock get time'
  and b1.inst_id = b2.inst_id 
  and b2.inst_id = b3.inst_id
   or b1.name = 'global enqueue gets sync' 
  and b2.name = 'global enqueue gets async' 
  and b3.name = 'global enqueue get time'
  and b1.inst_id = b2.inst_id 
  and b2.inst_id = b3.inst_id
/


PROMPT 
PROMPT A query abaixo tem que mostrar perda ZERO nas 4 colunas:
PROMPT 
SELECT A.VALUE "GC BLOCKS LOST 1",
       B.VALUE "GC BLOCKS CORRUPT 1",
       C.VALUE "GC BLOCKS LOST 2",
       D.VALUE "GC BLOCKS CORRUPT 2"
FROM GV$SYSSTAT A, GV$SYSSTAT B, GV$SYSSTAT C, GV$SYSSTAT D
WHERE A.INST_ID=1 AND A.NAME='global cache blocks lost'
  AND B.INST_ID=1 AND B.NAME='global cache blocks corrupt'
  AND C.INST_ID=2 AND C.NAME='global cache blocks lost'
  AND D.INST_ID=2 AND D.NAME='global cache blocks corrupt'
/


PROMPT
set verify on
set feedback on