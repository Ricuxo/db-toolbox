-- -----------------------------------------------------------------------------------
-- File Name    : @ind_new.sql 
-- Author       : Henrique
-- Description  : Mostra novos indices criados no banco de dados. Retirado do Livro OWI
-- Call Syntax  :  @indices_new.sql
--
-- Last Modified: 27/07/2016
-- -----------------------------------------------------------------------------------
select owner,
substr(object_name,1,30) object_name,
object_type,
created
from dba_objects
where object_type in ('INDEX','INDEX PARTITION')
and owner not in (select username from dba_users where ORACLE_MAINTAINED='Y')
order by created;
