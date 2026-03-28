disc
set instance &instance_name_for_sys
conn sys as sysdba

SPOOL CLOSE_TRACES.SQL

set hea off 
select 'oradebug setospid '||spid|| '
oradebug close_trace'  
from v$process p, v$session s
where s.PADDR = p.addr
/

SPOOL OFF

@CLOSE_TRACES.SQL

spool close_trace_dbms_system.sql

SELECT 'EXEC DBMS_SYSTEM.SET_EV('||S.SID||','||S.SERIAL#||','||10046||','||0||','||''''''||')' 
FROM V$SESSION S,V$PROCESS P WHERE S.PADDR=P.ADDR
/

spool off

@close_trace_dbms_system.sql

UNDEFINE &&user_name