/*  */
col object_name format a25 heading "Packages w/o Body"
select object_name from dba_objects
 where object_type = 'PACKAGE'
MINUS
select object_name from dba_objects
 where object_type = 'PACKAGE BODY'
/
