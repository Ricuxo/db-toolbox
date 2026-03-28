select 'ALTER TRIGGER "'||OWNER||'"."'||OBJECT_NAME||'" COMPILE;'
from dba_objects where status='INVALID' AND OBJECT_TYPE='TRIGGER'
union
select 'ALTER FUNCTION "'||OWNER||'"."'||OBJECT_NAME||'" COMPILE;'
from dba_objects where status='INVALID' AND OBJECT_TYPE='FUNCTION'
union
select 'ALTER PACKAGE "'||OWNER||'"."'||OBJECT_NAME||'" COMPILE BODY;'
from dba_objects where status='INVALID' AND OBJECT_TYPE='PACKAGE BODY'
union
select 'ALTER PROCEDURE "'||OWNER||'"."'||OBJECT_NAME||'" COMPILE;'
from dba_objects where status='INVALID' AND OBJECT_TYPE='PROCEDURE'
union
select 'ALTER VIEW "'||OWNER||'"."'||OBJECT_NAME||'" COMPILE;'
from dba_objects where status='INVALID' AND OBJECT_TYPE='VIEW'
union
select 'ALTER PUBLIC SYNONYM "'||OBJECT_NAME||'" COMPILE;'
from dba_objects where status='INVALID' AND OBJECT_TYPE='SYNONYM' and owner='PUBLIC'
union
select 'ALTER SYNONYM "'||OWNER||'"."'||OBJECT_NAME||'" COMPILE;'
from dba_objects where status='INVALID' AND OBJECT_TYPE='SYNONYM'
union
select 'ALTER TYPE "'||OWNER||'"."'||OBJECT_NAME||'" COMPILE;'
from dba_objects where status='INVALID' AND OBJECT_TYPE='TYPE'
union
select 'ALTER TYPE "'||OWNER||'"."'||OBJECT_NAME||'" COMPILE BODY;'
from dba_objects where status='INVALID' AND OBJECT_TYPE='TYPE BODY';