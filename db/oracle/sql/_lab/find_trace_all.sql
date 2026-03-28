
SPOOL FIND_TRACES.SQL

set hea off 
select 'oradebug setospid '||spid|| '
oradebug tracefile_name'  
from v$process p, v$session s
where s.PADDR = p.addr
/

SPOOL OFF

@FIND_TRACES.SQL

