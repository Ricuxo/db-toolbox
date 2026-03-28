     set serveroutput on
    set verify off
    set feed off

    prompt
    prompt Elimina Sessao
    prompt ==============
    prompt
    accept v_sid number prompt ‘Entre com o SID da sessao: ‘
    prompt

    begin
    for lst in (select s.sid, s.serial#, s.username, s.osuser, s.machine, s.program,
    i.instance_name, i.host_name, p.spid, s.sql_hash_value, s.status
    from v$session s, v$process p, v$instance i
    where s.sid = &v_sid
    and s.paddr = p.addr ) loop
    dbms_output.put_line(‘Sid…………..: ‘ || lst.sid);
    dbms_output.put_line(‘Serial#……….: ‘ || lst.serial#);
    dbms_output.put_line(‘Status………..: ‘ || lst.status);
    dbms_output.put_line(‘Username………: ‘ || lst.username);
    dbms_output.put_line(‘Maquina……….: ‘ || lst.machine);
    dbms_output.put_line(‘Programa………: ‘ || lst.program);
    dbms_output.put_line(‘OS User……….: ‘ || lst.osuser);
    dbms_output.put_line(‘Host………….: ‘ || lst.host_name);
    dbms_output.put_line(‘Instance………: ‘ || lst.instance_name);
    dbms_output.put_line(‘SQL Hash Value…: ‘ || lst.sql_hash_value);
    dbms_output.put_line(‘PID…………..: ‘ || lst.spid);
    end loop;
    end;
    /

    prompt
    accept v_conf prompt ‘Voce quer realmente eliminar esta sessao (S/N)? ‘
    prompt

    begin
    if ‘&v_conf’ in (‘S’, ‘s’) then
    for lst in (select sid, serial# from v$session where sid = &v_sid) loop
    execute immediate ‘alter system kill session ”’ || lst.sid || ‘,’ || lst.serial# || ”’ immediate’;
    dbms_output.put_line(‘Sessao eliminada !’);
    end loop;
    end if;
    end;
    /

    prompt

    – Restaura configuracao do sqlplus

    set feed on

    –
    – Fim
    – 