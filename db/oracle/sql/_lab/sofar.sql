SELECT b.username, b.osuser,  b.terminal, b.machine, b.sid, b.serial#,TO_CHAR(a.START_TIME,'HH24:MI:SS') INICIO, ROUND((a.SOFAR/decode(a.TOTALWORK,0,1,a.TOTALWORK))*100,2) PERCENTUAL_FEITO , a.OPNAME 
FROM gV$SESSION_LONGOPS a, gv$session b where a.totalwork > 0 and 
      a.inst_id = b.inst_id and
      b.sid = a.sid and 
      (a.SOFAR/decode(a.TOTALWORK,0,1,a.TOTALWORK))*100 < 100;
