REM " Script mostra LISTA DE EVENTOS DE ESPERA SOFRIDOS pela sessão"
REM " Autor - Luiz Noronha - 07/04/2010"
REM 

REM The colum 


SET heading 		ON;

col WAIT_CLASS 		for a15
col event		for a65
col total_waits		for 999,999,999,999
col total_timeouts	for 999,999,999
col time_waited		for 999,999,999,999
col average_wait	for 999,999,999,999

COLUMN STARTUP_TIME HEADING '';

UNDEFINE SID

break on sid skip 1 dup
col event    format a39
col username format a6   trunc
select b.sid, 
	decode(b.username,null, substr(b.program,18),b.username) username,
	a.event,
	a.total_waits,
	a.total_timeouts,
	a.time_waited,
	a.average_wait,
	a.max_wait,
	a.time_waited_micro
from   gv$session_event a, gv$session b
where  b.sid = a.sid
  AND  b.inst_id = a.inst_id
  AND  a.sid = &1 
  AND  a.inst_id = &2
order by 1, 6;

CLEAR BREAKS
undefine 1
undefine 2