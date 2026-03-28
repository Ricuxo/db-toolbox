/*  */
rem
rem FUNCTION: Report on database table or procedure grants
rem
column table_name format a16 heading 'Table or|Procedure'
column grantee format a16 heading 'Role or|User'
column privilege format a10 heading 'Granted|Privilege'
column object_type heading 'Type of|Object'
accept user prompt 'Enter user name: '
set lines 80 feedback off verify off
@title80 'Table and Procedure Grants by User/Role'
break on object_type on grantee on table_name
spool rep_out\&db\tgrnt
select grantee,table_name,privilege,object_type 
from dba_tab_privs a, dba_objects b
where grantee like upper('%&user%')
and a.owner=b.owner
and a.table_name=b.object_name
order by 4,1,2
/
spool off
set feedback on verify on
clear columns
clear breaks
ttitle off
