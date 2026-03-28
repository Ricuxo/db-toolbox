-- -----------------------------------------------------------------------------------
-- File Name    : @enq_obj.sql 
-- Author       : Henrique
-- Description  : Durante um evento de enqueue mostra o objeto que está sendo disputado.Retirado do Livro OWI
-- Call Syntax  : @enq_obj.sql
--
-- Last Modified: 27/07/2016
-- -----------------------------------------------------------------------------------

select c.sid waiter_sid, a.object_name, a.object_type
from   dba_objects a, v$session b, v$session_wait c
where  (a.object_id = b.row_wait_obj# or
        a.data_object_id = b.row_wait_obj#)
and    b.sid       = c.sid
and    chr(bitand(c.P1,-16777216)/16777215) ||
       chr(bitand(c.P1,16711680)/65535) = 'TX'
and c.event = 'enqueue';
