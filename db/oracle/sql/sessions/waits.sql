Rem
Rem    NOME
Rem      waits.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script mostra os maiores eventos de espera do banco no momento. 
Rem
Rem    UTILIZAÇÃO
Rem      @waits
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      28/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

col inst_id for 999
col event   for a60

select event, state, count(*) from gv$session_wait where wait_class <> 'Idle' group by event, state order by 3 desc;
