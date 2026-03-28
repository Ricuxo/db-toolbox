undefine LUSERNAME
undefine USERNAME

--clear screen
prompt TYPE THE USER ACCOUNT
accept LUSERNAME
SET TIMING OFF
SET TIME OFF
SET FEEDBACK OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYYMMDD HH24:MI';
SET FEEDBACK ON
SET LINESIZE 5000
SET PAGESIZE 25

COL USERNAME FORMAT A30
COL USER_ID FORMAT 99999999999999
COL PASSWORD FORMAT A30
COL ACCOUNT_STATUS FORMAT A32
COL LOCK_DATE FORMAT A21
COL EXPIRY_DATE FORMAT A21
COL DEFAULT_TABLESPACE FORMAT A30
COL TEMPORARY_TABLESPACE FORMAT A30
COL CREATED FORMAT A21
COL PROFILE FORMAT A30
COL INITIAL_RSRC_CONSUMER_GROUP FORMAT A30
COL EXTERNAL_NAME FORMAT A40

COL GRANTEE FORMAT A30
COL GRANTED_ROLE FORMAT A30
COL ADMIN_OPTION FORMAT A12
COL DEFAULT_ROLE FORMAT A12

COL OWNER FORMAT A30
COL TABLE_NAME FORMAT A30
COL GRANTOR FORMAT A30
COL PRIVILEGE FORMAT A40
COL GRANTABLE FORMAT A9
COL HIERARCHY FORMAT A9

COL USED_MB FORMAT 9999999
COL MAX_MB FORMAT A9
COL TABLESPACE_NAME FORMAT A30
COL BYTES FORMAT 99999999999999
COL MAX_BYTES FORMAT 99999999999999
COL BLOCKS FORMAT 99999999999999
COL MAX_BLOCKS FORMAT 99999999999999
COL DROPPED FORMAT A7
COL "%FREE_MB" FORMAT A9
COL ATTENTION FORMAT A9

prompt
prompt
prompt ******************************************************************************************************************************
prompt ***********************************************     USER         REPORT    ***************************************************
prompt ******************************************************************************************************************************

SELECT USERNAME
     , USER_ID
     , PASSWORD
     , ACCOUNT_STATUS
     , LOCK_DATE
     , EXPIRY_DATE
     , DEFAULT_TABLESPACE
     , TEMPORARY_TABLESPACE
     , CREATED
     , PROFILE
     , INITIAL_RSRC_CONSUMER_GROUP
     , EXTERNAL_NAME
  FROM DBA_USERS DU
 WHERE DU.USERNAME LIKE UPPER(NVL('&LUSERNAME', USERNAME))
 ORDER BY USERNAME
/

prompt
prompt
prompt ****************************** User Quotas
prompt ***********************************************************************

SELECT USERNAME
     , TABLESPACE_NAME
     , (BYTES/1024/1024) USED_MB
     , decode(MAX_BYTES, -1, 'UNLIMITED', MAX_BYTES/1024/1024) MAX_MB
     , BLOCKS
     , decode(MAX_BLOCKS, -1, 'UNLIMITED', MAX_BLOCKS) MAX_BLOCKS
     , DROPPED
     , decode(MAX_BYTES, -1, 'UNLIMITED', 100 - round(BYTES * 100 / MAX_BYTES, 2)) "%FREE_MB"
     , case when MAX_BYTES = -1
            then ' '
            when 100 - round(BYTES * 100 / MAX_BYTES, 2) <= 10
            then '<======'
       end ATTENTION
  FROM DBA_TS_QUOTAS
 WHERE USERNAME like NVL('&LUSERNAME', USERNAME)
 ORDER BY round(BYTES * 100 / MAX_BYTES, 2) asc
/

prompt
prompt
prompt ****************************** User system privileges
prompt ***********************************************************************

SELECT GRANTEE
     , PRIVILEGE
     , ADMIN_OPTION
  FROM DBA_SYS_PRIVS
 WHERE GRANTEE like NVL('&LUSERNAME', GRANTEE)
/

prompt
prompt
prompt ****************************** User role privileges
prompt ***********************************************************************

SELECT GRANTEE
     , GRANTED_ROLE
     , ADMIN_OPTION
     , DEFAULT_ROLE
  FROM DBA_ROLE_PRIVS
 WHERE GRANTEE like UPPER(NVL('&LUSERNAME', GRANTEE))
/

prompt
prompt
prompt ****************************** User object privileges
prompt ***********************************************************************

SELECT GRANTEE
     , OWNER
     , TABLE_NAME
     , GRANTOR
     , PRIVILEGE
     , GRANTABLE
     , HIERARCHY
  FROM DBA_TAB_PRIVS
 WHERE GRANTEE LIKE NVL('&LUSERNAME', GRANTEE)
 ORDER BY TABLE_NAME
/

undefine LUSERNAME
undefine USERNAME

@@reset