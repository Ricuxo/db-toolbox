/*  */
column meas_date format a17 heading 'Defrag Date'
column name format a40 heading 'Tablespace Defraged' word_wrapped
column value format 99999 heading 'Pieces'
set pages 47
@title80 'Defragged Tablespaces Report'
spool rep_out/&db/defrag_tbsp
select name,to_char(meas_date,'dd-mon-yy hh24:mi')meas_date,value 
from dba_running_stats where meas_date>trunc(sysdate-1)
and name like '%defrag%' 
/
spool off

