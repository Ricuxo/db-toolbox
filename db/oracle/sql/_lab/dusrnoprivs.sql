set pagesize 1000
set linesize 300

alter session set NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI';

col username format a30
col user_id format 9999999
col ACCOUNT_STATUS format a32
col lock_date format a16
col EXPIRY_DATE format a16
col created format a16

select username
     , user_id
     , ACCOUNT_STATUS
     , LOCK_DATE
     , EXPIRY_DATE
     , CREATED
  from dba_users du
 where not exists (select 1
                     from dba_tab_privs dtp
                    where dtp.GRANTEE = du.username)
   and not exists (select 1
                     from dba_role_privs drp
                    where drp.GRANTEE = du.username)
   and username not in ('DIP','XS$NULL','ANONYMOUS','SYS','DBSNMP','SYSTEM','OUTLN','TSMSYS')
 order by username
/