column tm new_value file_time noprint
select to_char(sysdate, 'YYYYMMDD') tm from dual ;
prompt &file_time
spool C:\Temp\logfile_id&file_time..log