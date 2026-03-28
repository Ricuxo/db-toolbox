--Mostra log de execução do rman pelo sql_plus.
--Não funcionou no oracle 10

select output
from v$rman_output
where session_recid = (select max(session_recid) from v$rman_status)
order by recid ;