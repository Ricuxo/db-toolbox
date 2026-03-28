Rem
Rem    NOME
Rem      role.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista os privilégios da role especificada.
Rem
Rem    UTILIZAÇÃO
Rem      @role <ROLE>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      30/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set pages 40
col PRIVILEGE for a35
col SCHEMA.OBJECT for a30
set feedback off
set verify off

PROMPT
PROMPT Privilégios de Sistema:
select GRANTEE,        
       PRIVILEGE,      
       ADMIN_OPTION,
       'revoke ' ||PRIVILEGE|| ' from ' ||GRANTEE|| ';' AS "GRANTs DE SISTEMA"
FROM DBA_SYS_PRIVS
where GRANTEE = upper('&1')
/


PROMPT
PROMPT Privilégios de Objeto:
select GRANTEE, 
       PRIVILEGE,
       ' ON '  as "ON",        
       OWNER|| '.'||TABLE_NAME AS "SCHEMA.OBJECT",           
       GRANTABLE,
       GRANTOR, 
       'revoke ' ||PRIVILEGE|| ' on ' ||OWNER|| '.'||TABLE_NAME|| ' from ' ||GRANTEE|| ';' AS "GRANTs DE OBJETO"     
from DBA_TAB_PRIVS 
where grantee =  upper('&1')
/

set feedback on
set verify on





