-- -----------------------------------------------------------------------------------
-- File Name    : @enq_types.sql 
-- Author       : Henrique
-- Description  : Mostra os tipos de enqueue. Retirado do Livro OWI
-- Call Syntax  : @enq_types.sql
--
-- Last Modified: 30/07/2016
-- -----------------------------------------------------------------------------------

select sid, event, chr(bitand(P1,-16777216)/16777215)|| chr(bitand(P1,16711680)/65535) as "Type", mod(p1,16) as "mode"
from v$session_wait where event = 'enqueue';
