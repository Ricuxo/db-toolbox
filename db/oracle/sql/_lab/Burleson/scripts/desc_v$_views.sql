/*  */
set pages 8000 lines 130 embedded on heading off feedback off
spool desc_v$views.sql
select 'set pages 20000 lines 80 embedded on feedback off' from dual;
select 'column view_name format a30 heading '||chr(39)||'View Name'||chr(39) from dual;
select 'column view_definition format a60 word_wrapped heading '||chr(39)||'Definition'||chr(39) from dual;
select 'spool desc_v$_views.doc' from dual;
select 'select '||chr(39)||'Specification of Fixed View: '||view_name||chr(39)||'||chr(10)||chr(10)||'||chr(10)||
'view_name||'||chr(39)||' select statement: '||chr(39)||
'||chr(10)||chr(10),view_definition from sys.v_$fixed_view_definition'||chr(10)||
  ' where view_name = '||chr(39)||view_name||chr(39)||';'||chr(10)||'desc sys.'||view_name
from sys.v_$fixed_view_definition where view_name like 'GV%';
select 'spool off' from dual;                                                    
spool off
