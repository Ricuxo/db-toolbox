-- -----------------------------------------------------------------------------------
-- File Name    : @tab_fts.sql 
-- Author       : Henrique
-- Description  : Table scans rows gotten reflect the cumulative number of rows read for full table scans. Retirado do Livro OWI
-- Call Syntax  : @tab_fts.sql
--
-- Last Modified: 27/07/2016
-- -----------------------------------------------------------------------------------

select a.sid, b.name, a.value 
 from   v$sesstat a, v$statname b 
 where  a.statistic# = b.statistic# 
 and    a.value     <> 0 
 and    b.name = 'table scan blocks gotten' 
 order by 3,1;