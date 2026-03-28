Set head off
select 'DB_NAME: '||name,
'SESSION_USER: '||sys_context('USERENV','SESSION_USER'),
'AUTHENTICATED_IDENTITY: '||sys_context('USERENV','AUTHENTICATED_IDENTITY'),
'AUTHENTICATION_METHOD: '||sys_context('USERENV','AUTHENTICATION_METHOD'),
'LDAP_SERVER_TYPE: '||sys_context('USERENV','LDAP_SERVER_TYPE'),
'ENTERPRISE_IDENTITY: '||sys_context('USERENV','ENTERPRISE_IDENTITY')
from sys.v_$database;


/* Saida ideal

Database Information
--------------------
- DB_NAME : TSEC02
- DB_DOMAIN : trivadislabs.com
- INSTANCE : 1
- INSTANCE_NAME: TSEC02
- SERVER_HOST : db19
Authentification Information
----------------------------
- SESSION_USER : CMU_USERS
- PROXY_USER :
- AUTHENTICATION_METHOD : PASSWORD_GLOBAL
- IDENTIFICATION_TYPE : GLOBAL SHARED
- NETWORK_PROTOCOL :
- OS_USER : oracle
- AUTHENTICATED_IDENTITY. : TRIVADISLABS\KING
- ENTERPRISE_IDENTITY : cn=Ben King,ou=Senior Management,ou=People,dc=trivadislabs,dc=com
*/