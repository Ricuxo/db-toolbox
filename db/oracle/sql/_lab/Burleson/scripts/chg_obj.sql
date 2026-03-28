/*  */
REM: chg_obj.sql
REM: show report of objects that have been modified
REM: since a given date, excluding views
REM: MRA
column owner format a5 heading Owner
column object_name format a27 heading Name
column object_type format a12 heading Type
column modified format a15 heading Modified
undef chg_date
set pages 45 verify off 
@title80 'Changed Objects Since &&chg_date'
spool rep_out\&&db\changed_objects.doc
select owner,object_name,object_type,to_char(last_ddl_time,'dd-mon-yy hh:mi') Modified
from dba_objects where owner= 'DBO' and last_ddl_time>to_date('&&chg_date','dd-mon-yy')
and object_type != 'VIEW'
order by object_type,4
/
spool off
ttitle off
