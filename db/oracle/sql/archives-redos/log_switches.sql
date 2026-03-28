-- -----------------------------------------------------------------------------------
-- File Name    : @log_switches.sql 
-- Author       : Henrique
-- Description  : Mostra quantidade de log switches.Retirado do Livro OWI
-- Call Syntax  : @log_switches.sql
--
-- Last Modified: 27/07/2016
-- -----------------------------------------------------------------------------------

col creation_date for a20
col TIME for a10
col LOWEST_SCN_IN_LOG for 99999999999999
col HIGHEST_SCN_IN_LOG for 999999999999999
select thread#,
       to_char(first_time,'DD-MON-YYYY') creation_date,
       to_char(first_time,'HH24:MI')     time,
       sequence#,
       first_change# lowest_SCN_in_log,
       next_change#  highest_SCN_in_log,
       recid         controlfile_record_id,
       stamp         controlfile_record_stamp
from   v$log_history
order by first_time;
