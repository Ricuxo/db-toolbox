find_privs.sql - Lists all privileges per specified user.

SAMPLE OUTPUT Go to Script 
--------------------------------------------------------------------------------

SQL> @find_privs.sql
User or Role Name > WEBSYS

Object Privileges for WEBSYS...
no rows selected

Column privileges for WEBSYS...
no rows selected

System privileges for WEBSYS...

GRANTEE              PRIVILEGE                      WITH ADMIN
-------------------- ------------------------------ ----------
WEBSYS               CREATE PUBLIC SYNONYM          NO
WEBSYS               CREATE ROLE                    NO
WEBSYS               DROP ANY ROLE                  NO
WEBSYS               DROP PUBLIC SYNONYM            NO
WEBSYS               UNLIMITED TABLESPACE           NO


Role privileges for WEBSYS...

GRANTEE              GRANTED_ROLE                   WITH ADMIN
-------------------- ------------------------------ ----------
WEBSYS               CONNECT                        NO
WEBSYS               OWS_ADMIN_ROLE                 YES
WEBSYS               OWS_DEFAULT_ROLE               YES
WEBSYS               OWS_STANDARD_ROLE              YES
WEBSYS               RESOURCE                       NO
SCRIPT Go to Top 
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

======================inicio====================================================

Salve o script abaixo no servidor ou local com o nome de find_privs.sql
Para execução : @find_privs.sql

================================================================================

set linesize 132
set verify off
-- set feedback off
set pagesize 60

col grantee for a20 wrap
col owner for a20 wrap
col table_name for a30 wrap
col column_name for a30 wrap
col privilege for a30 wrap
col granted_rol for a20 wrap
col grantable for a10 wrap heading 'WITH GRANT'
col admin_option for a10 wrap heading 'WITH ADMIN'

accept grantee_nm prompt 'User or Role Name > '

prompt
prompt Object Privileges for &&grantee_nm....

select grantee,owner,table_name,privilege,grantable from sys.DBA_TAB_PRIVS where grantee=upper('&&grantee_nm') order by 2, 3, 1, 4;

prompt
prompt Column privileges for &&grantee_nm....

select grantee,owner,table_name,column_name,privilege,grantable from sys.DBA_COL_PRIVS where grantee=upper('&&grantee_nm') order by 2, 3,4, 5, 1;

prompt
prompt System privileges for &&grantee_nm....

select grantee,privilege,admin_option from sys.DBA_SYS_PRIVS where grantee=upper('&&grantee_nm') order by 1, 2;

prompt
prompt Role privileges for &&grantee_nm....

select grantee,granted_role,admin_option from sys.DBA_ROLE_PRIVS where grantee=upper('&&grantee_nm') order by 1, 2;

quit

====================final ========================================================

