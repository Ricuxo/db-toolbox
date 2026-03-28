--
--
--  NAME
--    echang.sql
--
--  DESCRIPTION
--    Checa se a sessao apresenta qualquer tipo de atividade.
--
--  HISTORICO
--    02/06/2008 => Eduardo Chinelatto
--
-----------------------------------------------------------------------------

set serveroutput on
set verify off
set wrap off
set lines 130
set pages 100



prompt
accept v_sid number prompt 'Entre com o SID da sessao: '
prompt
prompt Aguarde 10 segundos...
prompt

declare
  type TabValues is table of number index by binary_integer;
  l_tab_values TabValues;
  l_sid        pls_integer;
  l_atividade  boolean;
begin
  l_sid := &v_sid;

  dbms_output.enable(65536);

  -- Exibe dados sobre a sessao

  l_atividade := false;
  for lst in (select s.sid, s.serial#, s.username, s.osuser, s.machine, s.program,
                     i.instance_name, i.host_name, p.spid, s.sql_address, s.status
              from gv$session s, gv$process p, gv$instance i
              where s.sid = &v_sid
                and s.paddr = p.addr
                and p.inst_id = i.inst_id ) loop
    dbms_output.put(chr(10));
    dbms_output.put_line('Sid...............: ' || lst.sid);
    dbms_output.put_line('Serial#...........: ' || lst.serial#);
    dbms_output.put_line('Status............: ' || lst.status);
    dbms_output.put_line('Username..........: ' || lst.username);
    dbms_output.put_line('Maquina...........: ' || lst.machine);
    dbms_output.put_line('Programa..........: ' || lst.program);
    dbms_output.put_line('OS User...........: ' || lst.osuser);
    dbms_output.put_line('Host..............: ' || lst.host_name);
    dbms_output.put_line('Instance..........: ' || lst.instance_name);
    dbms_output.put_line('PID...............: ' || lst.spid);
    l_atividade := true;
  end loop;
  if not l_atividade then
    dbms_output.put_line('Sessao inexistente!');
    return;
  end if;

  -- Verifica wait

  dbms_output.put(chr(10));
  for lst in (select * from gv$session_wait where state = 'WAITING' and sid = l_sid) loop
    dbms_output.put_line('Waiting...........: ' || lst.event);
  end loop;

  -- Verifica qualquer tipo de atividade na sessao

  for lst in (select * from gv$sesstat where sid = l_sid) loop
    l_tab_values(lst.statistic#) := lst.value;
  end loop;

  dbms_lock.sleep(10);

  dbms_output.put(chr(10));
  l_atividade := false;
  for lst in (select s.statistic#, n.name, s.value
              from v$statname n, gv$sesstat s
              where s.sid = l_sid and n.statistic# = s.statistic#) loop
    if lst.value <> l_tab_values(lst.statistic#) then
      if not l_atividade then
        dbms_output.put_line('Atividade');
        dbms_output.put_line('---------');
        dbms_output.put(chr(10));
      end if;
      dbms_output.put_line('> ' || rpad(lst.name, 40, '.') || ' ' || (lst.value - l_tab_values(lst.statistic#)));
      l_atividade := true;
    end if;
  end loop;

  -- Provavelmente a sessao esta travada (hang)

  if not l_atividade then
    dbms_output.put_line('ATENCAO: A sessao nao apresenta nenhum tipo de atividade !');
  end if;
end;
/

--
-- Fim
--
