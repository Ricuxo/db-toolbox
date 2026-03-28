Segue um select que uso para compilar os objetos inválidos.

select 'alter ' || lower(decode(object_type,'PACKAGE BODY','package',object_type)) || ' ' || owner || '.' || object_name || ' ' ||
decode (object_type,'PACKAGE BODY','compile body','compile') || ';'
from dba_objects where status <> 'VALID';