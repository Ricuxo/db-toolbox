Rem
Rem    NOME
Rem      xplan.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script exibe o plano de execução da query na sessão aual.
Rem
Rem    UTILIZAÇÃO
Rem      @xplan
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      02/04/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
set pagesize 100 
set hea off
set linesize 1000
select * from table(dbms_xplan.display())
/

set hea on
set pagesize 14

PROMPT OUTRAS OPCOES
PROMPT
PROMPT
PROMPT Shared Pool
PROMPT select * from table(dbms_xplan.display_cursor('SQL_ID',null,'ALL'));
PROMPT select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));
PROMPT
PROMPT AWR
PROMPT select * from table(dbms_xplan.display_awr('SQL_ID',null,null,'ALL'));
PROMPT select * from table(dbms_xplan.display_awr('SQL_ID',null,DBID,'ALL'));
