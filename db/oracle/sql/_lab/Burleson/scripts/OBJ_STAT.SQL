/*  */
rem
rem  NAME       :  obj_stat.sql
rem
rem  FUNCTION   :  Report on all objects and their status
rem
column  owner           format a17      heading "Owner"
column  object_name     format a23      heading "Object"
column object_type      format a20      heading "Type of Object"
column status           format a10      heading "Status"
rem
set verify off  feedback off lines 80 pages 58 heading off
rem 
break on owner on  object_type
start  title80 "Database Object Status"
spool rep_out\&db\obj_stat
rem
prompt Enter % for all objects
rem
select  owner,
	object_type,
	object_name,
	status
from dba_objects 
where object_type like upper('&type')
order by 1,2;
spool off
set verify on  feedback on lines 80 pages 22 heading on
clear columns
clear breaks
undef type
pause Press enter to continue
