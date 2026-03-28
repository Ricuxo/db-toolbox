--
--
--  NAME
--    ecmdt.sql
--
--  DESCRIPTION
--    Mostra verticalmente todas as coluna de um registro.
--
--  PARAMETERS
--    &1 - Nome da tabela.
--    &2 - Nome da coluna chave.
--    &3 - Valor da chave.
--
--  OBJECTIVE
--    Abaixo esta um exemplo de como este script deve ser utilizado.
--
--    SQL> @ecmdt dba_tablespaces tablespace_name SYSTEM
--
--    Neste exemplo, sera exibido verticalmente o conteudo das colunas
--    da tabela dba_tablespaces, serao exibidos somente o registro onde
--    a coluna tablespace_name eh igual a SYSTEM.
--
--  HISTORY
--
-----------------------------------------------------------------------------
 
set serveroutput on
set verify off
set wrap off
set lines 130
set pages 100


declare
  l_conteudo varchar2(4000);
  l_valor    varchar2(50);
  l_tabela   varchar2(50);
  l_coluna   varchar2(50);
  l_sql      varchar2(200);
  l_tam_col  pls_integer;
begin
  l_tabela := upper('&1');
  l_coluna := upper('&2');
  l_valor := '&3';

  dbms_output.enable(1048576);

  select max(length(column_name)) + 2
    into l_tam_col
    from dba_tab_columns 
    where table_name = l_tabela;

  for lst in (select * from dba_tab_columns where table_name = l_tabela order by column_name) loop
    begin
      l_sql := 'select ' || lst.column_name || ' from ' || lst.owner || '.' || lst.table_name ||
               ' where ' || l_coluna || ' = ' || '''' || l_valor || '''';
      execute immediate l_sql into l_conteudo;
      dbms_output.put_line(rpad(lower(lst.column_name), l_tam_col, '.') || ': ' || substr(l_conteudo, 1, 60));
    exception
      when others then
        dbms_output.put_line(rpad(lower(lst.column_name), l_tam_col, '.') || ': ERRO!');
    end;
  end loop;
exception
  when others then
    null;
end;
/

