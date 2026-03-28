set heading off

--

select 'create user ' || USERNAME || ' identified by values ''' || PASSWORD || ''''
  from SYS.DBA_USERS
 where USERNAME = upper( '&&1' )
union all 
select '    default tablespace ' || DEFAULT_TABLESPACE
  from SYS.DBA_USERS
 where USERNAME = upper( '&&1' )
union all 
select '    temporary tablespace ' || TEMPORARY_TABLESPACE
  from SYS.DBA_USERS
 where USERNAME = upper( '&&1' )
union all 
select '    quota ' || decode( MAX_BYTES, -1, 'unlimited', MAX_BYTES ) || ' on ' || TABLESPACE_NAME
  from SYS.DBA_TS_QUOTAS
 where USERNAME = upper( '&&1' )
   and TABLESPACE_NAME in ( select TABLESPACE_NAME
                              from SYS.DBA_TABLESPACES )
union all
select '    profile ' || PROFILE || chr(10) || 
       '    account ' || decode( ACCOUNT_STATUS, 'OPEN', 'UNLOCK', 'LOCK' ) || ';' --, EXTERNAL_NAME
  from SYS.DBA_USERS
 where USERNAME = upper( '&&1' ); 
--
select 'grant ' || GRANTED_ROLE || ' to ' || GRANTEE || decode( ADMIN_OPTION, 'YES', ' with admin option;', ';' )
  from SYS.DBA_ROLE_PRIVS
 where GRANTEE = upper( '&&1' );
--

break on ALTER nodup
column ALTER format a54
select 'alter user ' || GRANTEE || ' default role ' "ALTER", GRANTED_ROLE
  from SYS.DBA_ROLE_PRIVS
 where GRANTEE = upper( '&&1' )
   and DEFAULT_ROLE = 'YES';
clear breaks

--

select 'grant ' || PRIVILEGE || ' to ' || GRANTEE || decode( ADMIN_OPTION, 'YES', ' with admin option;', ';' )
  from SYS.DBA_SYS_PRIVS
 where GRANTEE = upper( '&&1' );
--

select 'grant ' || PRIVILEGE || ' on ' || OWNER || '.' || TABLE_NAME || '.' || COLUMN_NAME || ' to ' || GRANTEE ||
       decode( GRANTABLE, 'YES', ' with grant option;', ';' )
  from SYS.DBA_COL_PRIVS
 where GRANTEE = upper( '&&1' )
 order by OWNER, TABLE_NAME, PRIVILEGE, GRANTABLE;
--
select 'grant ' || PRIVILEGE || ' on ' || OWNER || '.' || TABLE_NAME || ' to ' || GRANTEE ||
       decode( GRANTABLE, 'YES', ' with grant option;', ';' )
  from SYS.DBA_TAB_PRIVS
 where GRANTEE = upper( '&&1' )
 order by OWNER, TABLE_NAME, GRANTABLE;
--

