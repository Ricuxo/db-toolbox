/*  */
column name format a30 heading 'Statistic'
column meas_date format a22 heading 'Statistic|Measurement|Date'
column value heading 'Measurement|Value'
break on name SKIP 1
COMPUTE AVG OF value ON name
set lines 75 pages 47 verify off feedback off
start title80 'Collected Statistics'
spool rep_out\&db\meas_rep2.lis
select name,value,to_char(meas_date,'dd-mon-yy hh24:mi:ss') meas_date
from dba_running_stats 
where meas_date>to_date(&date1,'dd-mon-yy hh24:mi:ss')
 and meas_date<to_date(&date2,'dd-mon-yy hh24:mi:ss') and value>0
and name not in ('TABLE','VIEW','INDEX','SEQUENCE','TABLESPACE','CLUSTER','PACKAGE',
'PACKAGE BODY','PROCEDURE','FUNCTION','SYNONYM','TRIGGER')
order by name,meas_date
/
spool off
set verify on feedback on pages 22
