--Mostra etapas do backup.
--
--Exemplo de saida.
--
--OPNAME PCT MIN_RESTANTES MIN_ATEAGORA
-------------------------------- ---------- ------------- ------------
--RMAN: aggregate input 67.6037414 176 368
--RMAN: full datafile restore 100 0 26
--RMAN: full datafile restore 100 0 10
--RMAN: full datafile restore 100 0 21
--RMAN: full datafile restore 100 0 22
--RMAN: full datafile restore 100 0 20
--RMAN: full datafile restore 100 0 51
--RMAN: full datafile restore 49.1620893 26 25
--RMAN: full datafile restore 100 0 32
--RMAN: full datafile restore 100 0 26
--RMAN: full datafile restore 100 0 20
--RMAN: full datafile restore 100 0 27
--RMAN: full datafile restore 100 0 26
--RMAN: full datafile restore 100 0 19
--RMAN: full datafile restore 100 0 52
--RMAN: full datafile restore 49.4441805 25 24

col OPNAME for a30
select OPNAME,SOFAR/TOTALWORK*100 PCT, trunc(TIME_REMAINING/60) MIN_RESTANTES,
trunc(ELAPSED_SECONDS/60) MIN_ATEAGORA
from gv$session_longops where TOTALWORK>0 and OPNAME like '%RMAN%';