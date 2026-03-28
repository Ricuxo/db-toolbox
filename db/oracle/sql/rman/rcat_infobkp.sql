--
-- Lista tempo de todos os backups do catalogo.
--

set lines 500
set pages 500
select 
DB_NAME,
to_char(start_time,'DD/mm/yy HH24:MI') StartTime,
to_char(end_time,'DD/mm/yy HH24:MI') EndTime,
(end_time-start_time)*1440 RunMin,
ELAPSED_SECONDS/3600 hrs,
INPUT_BYTES/1024/1024/1024 SUM_BYTES_BACKED_IN_GB,
OUTPUT_BYTES/1024/1024/1024 SUM_BACKUP_PIECES_IN_GB,
input_type,
status
from RC_RMAN_BACKUP_JOB_DETAILS
--where input_type = 'DB FULL'
order by 5;

