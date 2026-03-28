/*  */
set heading off verify off termout off pages 0 feedback off
define cr='chr(10)';
define ap='chr(39)';
spool analy_it.sql
select 
'begin'||&&cr||
'dbms_utility.analyze_schema('||&&ap||username||&&ap||','||&&ap||'ESTIMATE'||&&ap||',0,15);'||&&cr||
'end;'||&&cr||
'/'
from dba_users where username not in ('SYS','SYSTEM');
spool off
start analy_it
host del analy_it.sql
exit
