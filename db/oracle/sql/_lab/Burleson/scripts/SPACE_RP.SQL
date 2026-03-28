/*  */
set heading off feedback off verify off
set serveroutput on size 10000
column dbname new_value db noprint
select name dbname from v$database;
spool rep_out/&db/space
execute sys.space;
spool off
set heading on feedback on verify on
clear columns
