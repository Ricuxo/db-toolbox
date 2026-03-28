--
--
--  NAME
--    ecest.sql
--
--  DESCRIPTION
--    Mostra o estado das estatisticas do banco de dados.
--
--  HISTORY
--    02/06/2008 => Eduardo Chinelatto
--
-----------------------------------------------------------------------------

COL Mais_Atual               HEADING 'Estatistica|mais recente'
COL Mais_Antigo              HEADING 'Estatistica|mais antigo'
COL Total        FOR 999,990 HEADING 'Qtde|total'               JUSTIFY RIGHT
COL Analisado    FOR 999,990 HEADING 'Qtde com|estatistica'     JUSTIFY RIGHT
COL owner        FOR A20     HEADING 'Esquema'

set feed off

prompt
prompt Tabelas
prompt =======

select max(last_analyzed) Mais_Atual,
        min(last_analyzed) Mais_Antigo,
        count(*) Total,
        count(last_analyzed) Analisado,
        owner
 from dba_tables
 group by owner;

prompt
prompt Indices
prompt =======

select max(last_analyzed) Mais_Atual,
        min(last_analyzed) Mais_Antigo,
        count(*) Total,
        count(last_analyzed) Analisado,
        owner
 from dba_indexes
 group by owner;

prompt

-- Restaura configuracao do sqlplus

set feed on

--
-- Fim
--
