set pagesize 0
set linesize 300
column COMMAND format A160

 select 'alter '||decode(owner, 'PUBLIC', 'PUBLIC ', '')||decode(object_type, 'PACKAGE BODY', 'PACKAGE', object_type)||' '||decode(owner, 'PUBLIC', '', owner||'.')||object_name||' compile '||decode(object_type, 'PACKAGE BODY', 'BODY', '')||';'
   from dba_objects
  where status = 'INVALID'
    and owner = nvl('&OWNER', owner)
/