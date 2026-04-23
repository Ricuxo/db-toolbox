-- limpa tela
clear screen

prompt ========================================
prompt        CONEXAO ORACLE
prompt ========================================

accept v_user prompt 'Usuario: '
accept v_pass prompt 'Senha: ' hide
accept v_host prompt 'Hostname: '
accept v_port prompt 'Porta: '
accept v_service prompt 'Service Name: '
accept v_sys prompt 'Conectar como SYSDBA? (S/N): '

-- monta string
column conn_string new_value conn_string

select 
case 
    when upper('&v_sys') = 'S' then
        '&v_user/&v_pass@//&v_host:&v_port/&v_service as sysdba'
    else
        '&v_user/&v_pass@//&v_host:&v_port/&v_service'
end as conn_string
from dual;

prompt
prompt Conectando...
prompt

connect &conn_string