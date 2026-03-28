-- -----------------------------------------------------------------------------------
-- File Name    : @hot_blocks.sql 
-- Author       : Henrique
-- Description  : Verificar hot blocks.Retirado do Livro OWI
-- Call Syntax  : @hot_blocks.sql
--
-- Last Modified: 27/07/2016
-- -----------------------------------------------------------------------------------

select sid, p1raw, p2, p3, seconds_in_wait, wait_time, state
from v $ session_wait
where event = 'latch free'
order by p2, p1raw;
