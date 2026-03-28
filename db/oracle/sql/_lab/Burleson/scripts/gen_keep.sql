/*  */
set lines 132 feedback off verify off
set pages 0
spool keep_them.sql
select  'execute dbms_shared_pool.keep('||chr(39)||OWNER||'.'||name||chr(39)||','||
         chr(39)||decode(type,'PACKAGE','P','PROCEDURE','P','FUNCTION','P','SEQUENCE','Q',
                              'TRIGGER','R')||chr(39)||')'
from
 v$db_object_cache
where
 type not in ('NOT LOADED','NON-EXISTENT','VIEW','TABLE','INVALID TYPE','CURSOR','PACKAGE BODY')
 and executions>loads and executions>1 and kept='NO'
order by owner,namespace,type,executions desc
/
spool off
