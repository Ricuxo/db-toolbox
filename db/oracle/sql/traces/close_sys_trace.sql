conn sys as sysdba


SPOOL CLOSE_TRACES.SQL

set hea off 
select 'oradebug setospid '||spid|| '
oradebug close_trace'  
from v$process p, v$session s
where s.PADDR = p.addr
and s.type = 'BACKGROUND'
/

SPOOL OFF

@CLOSE_TRACES.SQL

SPOOL CLOSE_TRACES.SQL

set hea off 
select 'oradebug setospid '||spid|| '
oradebug event 10046 trace name context off'  
from v$process p, v$session s
where s.PADDR = p.addr
and s.type = 'BACKGROUND'
/

SPOOL OFF

@CLOSE_TRACES.SQL

SPOOL CLOSE_TRACES.SQL

set hea off 
select 'oradebug setospid '||spid|| '
oradebug event 10708 trace name context off'  
from v$process p, v$session s
where s.PADDR = p.addr
and s.type = 'BACKGROUND'
/

SPOOL OFF

@CLOSE_TRACES.SQL

spool trace_dbms_system.sql

SELECT 'EXEC DBMS_SYSTEM.SET_EV('||S.SID||','||S.SERIAL#||','||10046||','||0||','||''''''||')' 
FROM V$SESSION S,V$PROCESS P WHERE S.PADDR=P.ADDR
and s.username = '&&user_name'
/

spool off

@trace_dbms_system.sql

UNDEFINE user_name
