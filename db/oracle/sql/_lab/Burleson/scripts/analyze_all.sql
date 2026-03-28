/*  */
set heading off verify off pages 0 feedback off
ttitle off
spool analz_sch.sql
select distinct 'execute dbms_utility.analyze_schema('||chr(39)||
owner||chr(39)||','||chr(39)||'&METHOD'||chr(39)||','||&NUM_OF_ROWS||',&PERCENT_TO_USE);'
from dba_tables where owner not in ('SYS','SYSTEM')
/
spool off
spool analz_sch.log
set echo on
start analz_sch.sql
set echo off
spool off
