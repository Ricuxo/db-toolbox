/*  */
column name format a25 heading 'Measurement|Name'
column value heading 'Measurement|Date'
column delta heading 'Measurement|Delta'
column meas_date format a23 heading 'Measurement|Date'
column normal format 999999.9999 heading 'Delta|Normalized|to 100'
undef start_date
undef measurement
column max_val new_value norm_val noprint;
  select 
	max(delta) max_val
  from 
	dba_running_stats
  where 
  	upper(name)=upper('&&measurement') and
	to_char(meas_date,'dd-mon-yy hh24:mi:ss') between 
	to_char(to_date('&&start_date','dd-mon-yy hh24:mi:ss')) 
	and to_char(sysdate,'dd-mon-yy hh24:mi:ss'); 
select
   name,
   value,
   delta,
   to_char(meas_date,'dd-mon-yy hh24:mi:ss') meas_date,
   delta/&&norm_val*100 normal
from
   dba_running_stats
where
   upper(name)=upper('&&measurement')
   and to_char(meas_date,'dd-mon-yy hh24:mi:ss') between 
	to_char(to_date('&&start_date','dd-mon-yy hh24:mi:ss')) 
	and to_char(sysdate,'dd-mon-yy hh24:mi:ss')
order by meas_date
/
