-- -----------------------------------------------------------------------------------
-- File Name    : @direct_path_write.sql 
-- Author       : Henrique
-- Description  : Mostra sessões que estão fazendo escrita direta. Retirado do Livro OWI
-- Call Syntax  : @direct_path_read.sql
--
-- Last Modified: 30/07/2016
-- -----------------------------------------------------------------------------------

select a.NAME,  b.SID,  b.VALUE,
c.username, c.program,  round((sysdate - c.LOGON_TIME) * 24) hours_connected
from v$statname a, v$sesstat b, v$session c
where b.SID = c.SID
and a.STATISTIC# = b.STATISTIC#
and b.VALUE > 0 
and a.NAME = 'physical writes direct'
order by b.VALUE desc;
