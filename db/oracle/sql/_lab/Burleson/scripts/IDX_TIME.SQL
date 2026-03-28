/*  */
column mod_time format a25 heading 'Modification|Time'
column object_name format a30 heading 'Index|Name'
set verify off
start title80 'Index Modification Times'
spool rep_out/&db/idx_time
select object_name,to_char(last_ddl_time,'DD-MON-YY HH:MI:SS') MOD_TIME from dba_objects where 
object_type='INDEX' and owner='&owner_name';
spool off
