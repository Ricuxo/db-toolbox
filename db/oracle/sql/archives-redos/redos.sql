set lines 500
column THREAD#       format 999999
column GROUP#        format 999999
column MEMBER        format a70
column MB            format 999999 justify left
column ARCHIVED      format a8 
column STATUS        format a10
column LOG_FILE_STATUS format a15  justify center
set feedback off
set heading on

prompt
prompt Redo log groups/files:

select 
       a.THREAD#, 
       a.GROUP#, 
       a.STATUS, 
       b.MEMBER, 
       (a.BYTES/1024/1024) as MB, 
       nvl( b.STATUS, 'EM USO' ) LOG_FILE_STATUS,
       a.ARCHIVED, 
       a.SEQUENCE#
from V$LOG a, V$LOGFILE b
where b.GROUP# = a.GROUP#
order by 1, 2
/

set heading off
select 'Total: ' || ( select count(0) from V$LOGFILE ) || ' redo log files - ' ||
       ( select sum( BYTES * MEMBERS ) / 1024 / 1024 || ' MB' from V$LOG )
from dual
/

prompt

set heading on
set feedback on
