Rem
Rem    NOME
Rem      flashtb.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script prepara os comandos para executar um Flashback Table
Rem
Rem    UTILIZAÇÃO
Rem      @flashtb
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI     11/07/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off

col scn_to_timestamp(current_scn) for a40

PROMPT
PROMPT Verificar o SCN atual e seu TIMESTAMP
select current_scn, 
       scn_to_timestamp(current_scn) 
from v$database
/

PROMPT
PROMPT
PROMPT Ativar ROW MOVEMENT na tabela
PROMPT alter table <table_name> enable row movement;

PROMPT
PROMPT
PROMPT Comandos: 
PROMPT flashback table <table_name> to scn <scn_number>;
PROMPT flashback table <table_name> to timestamp (SYSTIMESTAMP - INTERVAL '.1' minute); 

PROMPT
