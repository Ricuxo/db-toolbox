set timing off
set feedback off
set linesize 150
set pagesize 30

COL NAME FORMAT A32
COL SIZE_MB FORMAT 99999999999
COL RESIZEABLE FORMAT A10

select name
     , (bytes/1024/1024) SIZE_MB
	 , RESIZEABLE
  from v$sgainfo
/

show sga
prompt
prompt
prompt

@reset