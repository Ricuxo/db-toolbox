-- -----------------------------------------------------------------------------------
-- File Name    : @user_commit.sql 
-- Author       : Henrique
-- Description  : Mostra as sessões que estão commitando muito.Retirado do Livro OWI
-- Call Syntax  : @user_commit.sql
--
-- Last Modified: 27/07/2016
-- -----------------------------------------------------------------------------------

select sid,value
from v$sesstat
where statistic# = (select statistic# from v$statname where name = 'user commits')
order by value;