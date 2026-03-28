/*  */
Rem gives a files per mountpoint count
rem must supply cutoff for length of mountpoint string
rem example - /u03/oracle if /u03 is mountpoint, enter 4
rem MRA 
rem
col mount_point heading 'Mount|Point'
col num_files heading 'Number|of Files'
col meg heading 'Megabytes'
start title80 'Files by Mount Point'
spool rep_out\&&db\files_mp
select mount_point,sum(num_files) num_files, sum(meg) meg from 
(
select substr(file_name,1,&&num_char) mount_point, count(*) num_files, sum(bytes/(1024*1024)) meg from dba_data_files
group by substr(file_name,1,&&num_char)
union
select substr(file_name,1,&&num_char) mount_point, count(*) num_files, sum(bytes/(1024*1024)) meg from dba_temp_files
group by substr(file_name,1,&&num_char)
)
group by mount_point
order by mount_point
/
spool off
