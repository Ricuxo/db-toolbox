/*  */
rem
rem FUNCTION: Report on objects creation and modification dates
rem
column owner format a10
column created format a19
column modified format a19
column object_type format a10
column object_name format a15
break on owner on object_type
set verify off feedback off lines 131 pages 57
@title132 'Object Modification and Creation Dates'
spool rep_out\&db\object
select owner, object_name, to_char(created, 'dd-mon-yy hh:mi:ss') created,
to_char(last_ddl_time,'dd-mon-yy hh:mi:ss') modified, object_type from dba_objects
where 
owner like upper('%&owner%') and object_name like upper('%&object_name%')
order by owner,object_type
/
spool off
undef owner
undef object_name
clear columns
clear breaks
set verify on feedback on pages 22
