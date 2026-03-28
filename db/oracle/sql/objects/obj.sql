--Verificar detalhes de um objeto em específico

col OBJECT_NAME for a40
SELECT owner,object_name,object_type from dba_objects where object_name=upper( '&&1');