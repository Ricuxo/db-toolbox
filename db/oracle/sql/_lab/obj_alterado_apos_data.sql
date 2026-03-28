prompt # 
prompt #  Verifica objetos alterados após a DATA informada
prompt #  

undef data_alteracao_objeto_ddmmyyyy
def data_alteracao_objeto_ddmmyyyy=&&data_alteracao_objeto_ddmmyyyy
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
column object_name format a30
column owner format a13
SET LINES 150
select 
  OBJECT_NAME
 ,OWNER      
 ,OBJECT_TYPE
 ,CREATED
, last_ddl_time
 ,STATUS
 ,OBJECT_ID
from dba_objects
where  last_ddl_time > to_date(&data_alteracao_objeto_ddmmyyyy, 'ddmmyyyy') 
ORDER BY 
  last_ddl_time, OWNER,OBJECT_NAME
/
