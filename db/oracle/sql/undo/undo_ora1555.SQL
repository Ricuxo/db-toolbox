--Mostra problemas com o erro ORA01555 e como corrigir.

set pages 5000
set lines 500
set pagesize 100
set linesize 100
column UNXPSTEALCNT  heading "# Unexpired|Stolen"
column EXPSTEALCNT   heading "# Expired|Reused"
column SSOLDERRCNT   heading "ORA-1555|Error"
column NOSPACEERRCNT heading "Out-Of-space|Error"
column MAXQUERYLEN   heading "Max Query|Length"
col begin_time format a20
select inst_id, to_char(begin_time,'dd/mm/YYYY HH24:MI') begin_time, UNXPSTEALCNT, EXPSTEALCNT , SSOLDERRCNT, NOSPACEERRCNT, MAXQUERYLEN
from gv$undostat  where begin_time > sysdate -15
AND (SSOLDERRCNT>0 OR NOSPACEERRCNT>0)
order by inst_id, begin_time;

PROMPT ###Coluna ORA-1555 Error com 1 indica undo_retention baixo
PROMPT ###Coluna Out-Of-space Error com 1 indica tablespace pequena