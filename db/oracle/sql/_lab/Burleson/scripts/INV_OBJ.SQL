/*  */
rem Name: inv_obj.sql
rem Purpose: Show alll invalid objects in database
rem Mike Ault 7/2/96 Created
rem Mike Ault 11/7/01 Verified on Oracle9i
rem
column object_name 	format A20 heading 'Object|Name'
column owner 		format a10 heading 'Object|Owner'
column last_time 	format a20 heading 'Last Change|Date'
column object_type      format a12 heading 'Object|Type'
set lines 80 feedback off pages 57 verify off
start title80 'Invalid Database Objects'
spool rep_out/&db/inv_obj
select 
	owner, 
	object_name,
	object_type, 
	to_char(last_ddl_time,'DD-MON-YY hh:mi:ss') Last_time
from dba_objects where status='INVALID'
/
spool off
pause Press enter to continue
set lines 80 feedback on pages 22 verify on
clear columns
ttitle off
