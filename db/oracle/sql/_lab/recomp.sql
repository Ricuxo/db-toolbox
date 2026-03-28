set pages 10000
select 'alter '||DECODE(object_type, 'PACKAGE BODY', 'PACKAGE', OBJECT_TYPE)||' '
		  ||owner||'.'||object_name||
			DECODE(object_type, 'PACKAGE BODY', ' COMPILE BODY;', ' COMPILE;')
from sys.dba_objects
where status = 'INVALID'
and   object_type <>  'SYNONYM'
/

