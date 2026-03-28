Rem
Rem    NOME
Rem      grantdba.sql 
Rem
Rem    DESCRIÇÃO   
Rem      Este script lista todos os usuários com privilégio DBA.
Rem   
Rem    UTILIZAÇÃO
Rem      grantdba.sql
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      05/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

select d.NAME as BANCO,
       r.GRANTEE,
       r.GRANTED_ROLE,
       r.ADMIN_OPTION,
       r.DEFAULT_ROLE,
       'revoke '||r.GRANTED_ROLE|| ' from ' ||r.GRANTEE|| ';' AS "GRANTs EM ROLES"
from v$database d, dba_role_privs r
where GRANTED_ROLE = 'DBA'
order by 2;