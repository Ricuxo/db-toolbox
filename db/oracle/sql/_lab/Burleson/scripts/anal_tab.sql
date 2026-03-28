/*  */
column meas_date format a17 heading 'Analysis Date'
column name format a40 heading 'Tables Analyzed' word_wrapped
column value format 999.99 heading 'Percent|Changed'
set pages 47
@title80 'Analyzed Tables Report'
spool rep_out/&db/anal_tab
select name,to_char(meas_date,'dd-mon-yy hh24:mi')meas_date,value 
from dba_running_stats where meas_date>trunc(sysdate-1)
and name like '%anal%' 
/
spool off

