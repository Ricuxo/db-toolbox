SET FEEDBACK OFF
SET TIMING OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYYMMDD HH24:MI:SS';
SET LINESIZE 1000
SET PAGESIZE 9999
SET HEAD ON

COL SITUACAO FORMAT A135
COL MARK	 FORMAT A4
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
COL PASSWORD_VERSIONS FORMAT A32
COL EDITIONS_ENABLED FORMAT A16
COL AUTHENTICATION_TYPE FORMAT A32
UNDEFINE MINOR_DATE_THAN

var maxlenuser number;

begin

    select max(length(username))
	  into :maxlenuser
	  from dba_users;

end;
/

var vhost_sid varchar2(62);

begin

    select upper(' @'||host_name||'_'||instance_name)
	  into :vhost_sid
	  from v$instance;

end;
/

SET FEEDBACK ON
SET TIMING ON

prompt
prompt Use the format yyyymmdd for the first parameter asked
prompt (expiry_date < parameter)
prompt 

select rpad(username, :maxlenuser, ' ')
    || case when expiry_date < sysdate 
            then ' expirado em ' || expiry_date
	        else ' expirara em ' || expiry_date
            end
    || ' com status: ' || rpad(account_status, 16, ' ')
	|| case when lock_date < sysdate
            then ' locado em      ' || lock_date
            when lock_date > sysdate
            then ' sera locado em ' || lock_date
            else lpad(' ', 33, ' ')
	   end
	|| :vhost_sid SITUACAO
     , password
     , trunc(expiry_date - sysdate) days_left 
     , user_id
     , default_tablespace
     , temporary_tablespace
     , created
     , profile
     , initial_rsrc_consumer_group
     , password_versions
     , editions_enabled
     , authentication_type
  from dba_users
 where expiry_date < trunc(to_date('&&MINOR_DATE_THAN', 'yyyymmdd'))
   and username not in ('DIP','XS$NULL','ANONYMOUS','SYS','DBSNMP','SYSTEM','OUTLN','TSMSYS','ORACLE_OCM')
 order by expiry_date, account_status, password
/

SET FEEDBACK OFF
SET TIMING OFF
SET TIME OFF
SET HEAD OFF
SET PAGESIZE 0

prompt
prompt Type the output file name (spool) with extension TXT
prompt Usually this extension asks Extel for delimiters
prompt between fields
prompt For instance.: ford_rel/file_name.txt
prompt                or just file_name.txt
prompt

spool ./&filename

select upper('MARK'||'!'||
       'USERNAME'||'!'||
       'USER_ID'||'!'||
       'ACCOUNT_STATUS'||'!'||
       'EXPIRY_DATE'||'!'||
       'LOCK_DATE'||'!'||
       'DAYS_LEFT'||'!'||
       'PASSWORD'||'!'||
       'DEFAULT_TABLESPACE'||'!'||
       'TEMPORARY_TABLESPACE'||'!'||
       'CREATED'||'!'||
       'PROFILE'||'!'||
       'INITIAL_RSRC_CONSUMER_GROUP') TITTLE
  from dual
/
select '' mark
	 , '!'|| username
     , '!'|| user_id
     , '!'|| account_status
     , '!'|| expiry_date
     , '!'|| lock_date
     , '!'|| trunc(expiry_date - sysdate) days_left
     , '!'|| password
     , '!'|| default_tablespace
     , '!'|| temporary_tablespace
     , '!'|| created
     , '!'|| profile
     , '!'|| initial_rsrc_consumer_group
  from dba_users
 where expiry_date < trunc(to_date('&&MINOR_DATE_THAN', 'yyyymmdd'))
   and username not in ('DIP','XS$NULL','ANONYMOUS','SYS','DBSNMP','SYSTEM','OUTLN','TSMSYS','ORACLE_OCM')
 order by expiry_date, account_status, password
/

spool off;

UNDEFINE MINOR_DATE_THAN

@reset