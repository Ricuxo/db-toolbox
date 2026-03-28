---Verifica se um smart scan foi executado.

select  sql_id,
    io_cell_offload_eligible_bytes qualifying,
    io_cell_offload_returned_bytes actual,
    round(((io_cell_offload_eligible_bytes - io_cell_offload_returned_bytes)/io_cell_offload_eligible_bytes)*100, 2) io_saved_pct,
    sql_text
from v$sql
where io_cell_offload_returned_bytes > 0
and instr(sql_text, '&sql_text') > 0 -- parte do texto sql executado
and parsing_schema_name = '&schema_name'; -- nome do schema
