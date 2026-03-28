-- -----------------------------------------------------------------------------------
-- Author       : Henrique
-- Description  : Ver hard parse no banco de dados.Retirado do Livro OWI
-- Call Syntax  : @hard_parse.sql
--
-- Last Modified: 27/07/2016
-- -----------------------------------------------------------------------------------

select a.*,
sysdate-b.startup_time days_old
from v$sysstat a, v$instance b
where a.name like 'parse%';
