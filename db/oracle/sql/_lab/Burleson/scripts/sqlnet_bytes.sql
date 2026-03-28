/*  */
@title80 'SQLNet Byte report'
spool rep_out\&&db\sqlnet_bytes
select 'Bytes per roundtrip', (a.value+b.value)/c.value BPRT
from
v$sysstat a, v$sysstat b, v$sysstat c
where
a.name='bytes sent via SQL*Net to client'
and b.name='bytes received via SQL*Net from client'
and c.name='SQL*Net roundtrips to/from client'
union
select 'Bytes sent per trip', a.value/(c.value) 
from
v$sysstat a, v$sysstat c
where
a.name='bytes sent via SQL*Net to client'
and c.name='SQL*Net roundtrips to/from client'
union
select 'Bytes recieved per Trip', b.value/(c.value)
from
v$sysstat b, v$sysstat c
where
b.name='bytes received via SQL*Net from client'
and c.name='SQL*Net roundtrips to/from client'
/
spool off
