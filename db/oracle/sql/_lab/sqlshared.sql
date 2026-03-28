Rem
Rem    DESCRIÇÃO
Rem    MOSTRA O TEXTO SQL PARA CONSULTAS NO SHARED POOL E CONSULTAS QUE MAIS UTILIZAM I/O E LEITURAS LÓGICAS (OBTENÇÕES DE BUFFER)
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem    Daniel Borges  15/01/11 
Rem
select buffer_gets,
       disk_reads,
       executions,
       buffer_gets/executions B_E,
       sql_text
from   V$sql
where hash_value = '&hash'
order by disk_reads desc;