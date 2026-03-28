set linesize 165
set pagesize 999
COLUMN FILE_ID              format 999999
COLUMN TBS_FILE_NAME        format a30
COLUMN STATUS               format a12
COLUMN AUTOEXTENSIBLE		format a14
COLUMN FILE_NAME            format a70
COLUMN SIZE_M               format 9999999

  with tbsnumber
    as (select TABLESPACE_NAME
	     from dba_tablespaces tbs
		where tbs.TABLESPACE_NAME like NVL('&LTBSFILE_NAME',tbs.TABLESPACE_NAME))
select dtf.FILE_ID
     , tbs.TABLESPACE_NAME TBS_FILE_NAME
     , dtf.STATUS
	 , dtf.AUTOEXTENSIBLE
     , dtf.FILE_NAME
     , sum(dtf.BYTES)/1024/1024 SIZE_M
  from dba_tablespaces tbs
     , dba_data_files dtf
	 , tbsnumber
 where dtf.TABLESPACE_NAME = tbsnumber.TABLESPACE_NAME
   and tbs.TABLESPACE_NAME = tbsnumber.TABLESPACE_NAME
 group by dtf.FILE_ID
        , tbs.TABLESPACE_NAME
        , dtf.STATUS
	    , dtf.AUTOEXTENSIBLE
        , dtf.FILE_NAME
/

@reset