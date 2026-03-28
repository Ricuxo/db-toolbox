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
Rem      Luiz Noronha      23/04/2010 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

col inst_id for 999
col event   for a60

select   event,p1,p2,p3,count(event) as qtd
from gv$session_wait where WAIT_CLASS# <> 6
group by event,p1,p2,p3
order by 2 desc
/