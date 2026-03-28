-- -----------------------------------------------------------------------------------
-- File Name    : @hard_parse_lot.sql 
-- Author       : Henrique
-- Description  : Descobrir as sessões atuais que executam muito hard parse.Retirado do Livro OWI
-- Call Syntax  : @hard_parse_lot.sql
--
-- Last Modified: 27/07/2016
-- -----------------------------------------------------------------------------------

select a.sid, c.username, b.name, a.value, round((sysdate – c.logon_time)*24) housr_connected
from v$sesstat a, v$statname b, v$session c
where c.sid = a.sid
and a.statistic# = b.statistic#
and a.value > 0
and b.name ='parse count (hard)'
order by a.value;

