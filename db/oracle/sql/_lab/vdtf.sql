set linesize 165
set pagesize 999
COLUMN file#                format 999999
COLUMN TBS_NAME             format a30
COLUMN STATUS               format a8
COLUMN ENABLED              format a10
COLUMN CHECKPOINT_CHANGE#   format 999999999999999
COLUMN BLOCKS               format 999999
COLUMN NAME                 format a70
COLUMN SIZE_M               format 9999999

  with tbsnumber
    as (select TS#
	     from v$tablespace tbs
		where tbs.NAME like NVL('&LTBSNAME',tbs.NAME))
select dtf.file#
     , tbs.NAME TBS_NAME
     , dtf.STATUS
     , dtf.ENABLED
     , dtf.CHECKPOINT_CHANGE#
     , dtf.BLOCK_SIZE BLOCKS
     , dtf.NAME
     , sum(dtf.BYTES)/1024/1024 SIZE_M
  from v$tablespace tbs
     , v$datafile dtf
	 , tbsnumber
 where dtf.TS# = tbsnumber.TS#
   and tbs.TS# = tbsnumber.TS#
 group by dtf.file#
     , tbs.NAME
     , dtf.STATUS
     , dtf.ENABLED
     , dtf.CHECKPOINT_CHANGE#
     , dtf.BLOCK_SIZE
     , dtf.NAME
/
