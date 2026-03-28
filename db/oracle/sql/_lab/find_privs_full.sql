find_privs_full.sql - Lists all privileges per specified user -- full listing.

SAMPLE OUTPUT Go to Script 
--------------------------------------------------------------------------------

SQL >@find_privs_full.sql

Enter Username : WEBSYS
Roles granted to user

GRANTED_ROLE         ADM DEF
-------------------- --- ---
CONNECT              NO  YES
OWS_ADMIN_ROLE       YES YES
OWS_DEFAULT_ROLE     YES YES
OWS_STANDARD_ROLE    YES YES
RESOURCE             NO  YES

Table Privileges granted to a user through roles

GRANTED_ROLE         OWNER        TABLE_NAME                  PRIVILEGE
-------------------- ------------ --------------------------- ---------------------------
OWS_ADMIN_ROLE       WEBSYS       OWS_FIXED_ATTRIB            ALTER
OWS_ADMIN_ROLE       WEBSYS       OWS_FIXED_ATTRIB            INSERT
OWS_ADMIN_ROLE       WEBSYS       OWS_FIXED_ATTRIB            UPDATE
OWS_ADMIN_ROLE       WEBSYS       OWS_OBJECT_VIEW             UPDATE
OWS_ADMIN_ROLE       WEBSYS       OWS_OBJECT_VIEW             SELECT
OWS_ADMIN_ROLE       WEBSYS       OWS_OBJECT_VIEW             INSERT
OWS_ADMIN_ROLE       WEBSYS       OWS_OBJECT_VIEW             DELETE
OWS_ADMIN_ROLE       WEBSYS       OWS_FIXED_ATTRIB            SELECT
OWS_ADMIN_ROLE       WEBSYS       OWS_FIXED_ATTRIB            DELETE
OWS_ADMIN_ROLE       WEBSYS       OWS_ATTRIBUTES              ALTER
OWS_ADMIN_ROLE       WEBSYS       OWS_ATTRIBUTES              DELETE
OWS_STANDARD_ROLE    WEBSYS       OWS_CONTENT                 INSERT
OWS_STANDARD_ROLE    WEBSYS       OWS_CONTENT                 UPDATE
OWS_STANDARD_ROLE    WEBSYS       OWS_CONTENT                 SELECT
OWS_STANDARD_ROLE    WEBSYS       OWS_CS                      EXECUTE
OWS_STANDARD_ROLE    WEBSYS       OWS_OBJECT                  INSERT
OWS_STANDARD_ROLE    WEBSYS       OWS_OBJECT                  SELECT
OWS_STANDARD_ROLE    WEBSYS       OWS_OBJECT                  UPDATE
OWS_STANDARD_ROLE    WEBSYS       OWA_CONTENT                 EXECUTE

48 rows selected.

System Privileges assigned to a user through roles

GRANTED_ROLE         PRIVILEGE
-------------------- ---------------------------
CONNECT              ALTER SESSION
CONNECT              CREATE CLUSTER
CONNECT              CREATE DATABASE LINK
CONNECT              CREATE SEQUENCE
CONNECT              CREATE SESSION
CONNECT              CREATE SYNONYM
CONNECT              CREATE TABLE
CONNECT              CREATE VIEW
RESOURCE             CREATE CLUSTER
RESOURCE             CREATE INDEXTYPE
RESOURCE             CREATE OPERATOR
RESOURCE             CREATE PROCEDURE
RESOURCE             CREATE SEQUENCE
RESOURCE             CREATE TABLE
RESOURCE             CREATE TRIGGER
RESOURCE             CREATE TYPE

16 rows selected.

Table privileges assigned directly to a user

no rows selected

System privileges assigned directly to a user

PRIVILEGE                   ADM
--------------------------- ---
CREATE PUBLIC SYNONYM       NO
CREATE ROLE                 NO
DROP ANY ROLE               NO
DROP PUBLIC SYNONYM         NO
UNLIMITED TABLESPACE        NO
SCRIPT Go to Top 
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
===============inicio===========================================================

Salve o script abaixo no servidor ou local com nome: find_privs_full.sql
Para execução: @find_privs_full.sql

================================================================================

set echo off
set verify off
set pages 200
set linesize 120
col granted_role form a20
col owner form a12
col table_name form a27
col privilege form a27

ACCEPT username  prompt 'Enter Username : '

spool privs_full_list.txt

PROMPT Roles granted to user

SELECT granted_role,admin_option,default_role 
FROM DBA_ROLE_PRIVS
WHERE grantee=UPPER('&username');

PROMPT Table Privileges granted to a user through roles

SELECT granted_role, owner, table_name, privilege 
FROM ( SELECT granted_role 
         FROM DBA_ROLE_PRIVS WHERE grantee=UPPER('&username')
       UNION
       SELECT granted_role 
         FROM ROLE_ROLE_PRIVS
         WHERE role in (SELECT granted_role 
                            FROM DBA_ROLE_PRIVS WHERE grantee=UPPER('&username')
                           )
        ) roles, dba_tab_privs
WHERE granted_role=grantee;

PROMPT System Privileges assigned to a user through roles

SELECT granted_role, privilege
FROM ( SELECT granted_role 
         FROM DBA_ROLE_PRIVS WHERE grantee=UPPER('&username')
       UNION
       SELECT granted_role 
         FROM ROLE_ROLE_PRIVS
         WHERE role in (SELECT granted_role 
                            FROM DBA_ROLE_PRIVS WHERE grantee=UPPER('&username')
                           )
        ) roles, dba_sys_privs
WHERE granted_role=grantee;

PROMPT Table privileges assigned directly to a user

SELECT owner, table_name, privilege FROM DBA_TAB_PRIVS WHERE grantee=UPPER('&username');

PROMPT System privileges assigned directly to a user
SELECT privilege, admin_option FROM DBA_SYS_PRIVS WHERE grantee=UPPER('&username');

spool off
quit
