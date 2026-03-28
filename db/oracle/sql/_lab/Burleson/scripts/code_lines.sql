/*  */
rem code_lines.sql
rem
select count(*) from dba_objects do, sys.source$ s
where do.object_type in ('FUNCTION','JAVA SOURCE','PACKAGE','PACKAGE BODY','PROCEDURE','TRIGGER','TYPE','TYPE BODY') and
do.object_id=s.obj# and
do.owner = upper('&owner')
/

