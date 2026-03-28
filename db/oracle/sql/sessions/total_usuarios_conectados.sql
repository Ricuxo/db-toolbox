Rem
Rem    NOME
Rem      constot.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista os totais de usuários conectados.
Rem
Rem    UTILIZAÇÃO
Rem      @constot
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      27/12/06 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
--
col status format a8
--

--
select a.STATUS, 
       count(0) QTD
from V$SESSION a, V$PROCESS b
where a.TYPE != 'BACKGROUND'
and b.ADDR (+) = a.PADDR
group by a.STATUS;
--
set heading off;
select 'Total: ' || count(0)
from V$SESSION a, V$PROCESS b
where a.TYPE != 'BACKGROUND'
and b.ADDR (+) = a.PADDR;
set heading on;
prompt;
--
