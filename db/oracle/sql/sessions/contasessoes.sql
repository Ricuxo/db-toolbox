Rem
Rem    NOME
Rem      countsessions.sql
Rem
Rem    DESCRIÇÃO
Rem      Lista a quantidade de sessões por usuário, program, osuser e sql_hash_value.
Rem
Rem    UTILIZAÇÃO
Rem      @countsessions.sql
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      16/06/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

select USERNAME, 
       COUNT(USERNAME) 
from V$SESSION
group by USERNAME
having COUNT(USERNAME) > 10
order by 2 desc
/


select PROGRAM, 
       COUNT(PROGRAM) 
from V$SESSION
group by PROGRAM
having COUNT(PROGRAM) > 10
order by 2 desc
/


select OSUSER, 
       COUNT(OSUSER) 
from V$SESSION
group by OSUSER
having COUNT(OSUSER) > 10
order by 2 desc
/


select SQL_HASH_VALUE, 
       COUNT(SQL_HASH_VALUE) 
from V$SESSION
group by SQL_HASH_VALUE
having COUNT(SQL_HASH_VALUE) > 10
order by 2 desc
/