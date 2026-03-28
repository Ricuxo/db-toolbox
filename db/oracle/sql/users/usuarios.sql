Rem
Rem    NOME
Rem      users.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista informações dos usuários
Rem
Rem    UTILIZAÇÃO
Rem      @users
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      26/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------



set linesize 2000
set buffer   2000
set pagesize 20

col username for a18

select USERNAME, 
       CREATED, 
       DEFAULT_TABLESPACE, 
       TEMPORARY_TABLESPACE, 
       ACCOUNT_STATUS,
       PROFILE
from DBA_USERS
order by USERNAME
/

set heading off
select 'Total de usuários: '||count(0)
from DBA_USERS;

prompt