--
--
--  NAME
--    ecevent.sql
--
--  DESCRIPTION
--    Mostra as sessoes com um determinado evento com valor crescente.
--
--  HISTORY
--    02/06/2008 => Eduardo Chinelatto
--
-----------------------------------------------------------------------------

set serveroutput on
set verify off
set wrap off
set lines 130
set pages 100


prompt
prompt Sessoes com determinado evento crescente
prompt ========================================
prompt
accept v_name prompt 'Entre com o nome do evento: '
prompt
prompt Aguarde 15 segundos...
prompt

declare
  type RecDados is record (
    time_waited number,
    total_waits number);

  type TabValues is table of RecDados index by binary_integer;

  l_tab_values TabValues;
  l_name       varchar2(64);
begin
  dbms_output.enable(1048576);

  l_name := '&v_name';
  for lst in (select * from v$session_event where event = l_name order by event) loop
    l_tab_values(lst.sid).time_waited := lst.time_waited;
    l_tab_values(lst.sid).total_waits := lst.total_waits;
  end loop;

  dbms_lock.sleep(15);

  dbms_output.put_line('.                                                 Total    Time');
  dbms_output.put_line('Sid   Evento                                      waits  waited');
  dbms_output.put_line('----- ----------------------------------------- ------- -------');

  for lst in (select * from v$session_event where event = l_name order by event) loop
    if l_tab_values.exists(lst.sid) and lst.total_waits > l_tab_values(lst.sid).total_waits then
      dbms_output.put_line(rpad(to_char(lst.sid), 6, ' ') || rpad(lst.event, 41, '.') || 
                           to_char(lst.total_waits - l_tab_values(lst.sid).total_waits, '9999999') ||
                           to_char((lst.time_waited - l_tab_values(lst.sid).time_waited) / 100, '9990D00'));
    end if;
  end loop;
end;
/

--
-- Fim
--
