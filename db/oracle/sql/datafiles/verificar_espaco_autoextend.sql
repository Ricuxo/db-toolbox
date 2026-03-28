col maxbytes for 999999999999999
col bytes for 999999999999999
col REMAINING for 999999999999999
col FILE_NAME for a80

PROMPT
PROMPT #####################
PROMPT ##### DATAFILES #####
PROMPT #####################
PROMPT
select file_name, ROUND(bytes/1024/1024,-1) as MB, ROUND(maxbytes/1024/1024,-1) MAXBYTES,
increment_by*((bytes/1024/1024)/blocks) "INCREMENT",
ROUND((maxbytes/1024/1024)-(bytes/1024/1024),-1) remaining
from dba_data_files
where autoextensible = 'YES'
/


PROMPT 
PROMPT #####################
PROMPT ##### TEMPFILES #####
PROMPT #####################
PROMPT 
select file_name, ROUND(bytes/1024/1024,-1) as MB, ROUND(maxbytes/1024/1024,-1) MAXBYTES,
increment_by*((bytes/1024/1024)/blocks) "INCREMENT",
ROUND((maxbytes/1024/1024)-(bytes/1024/1024),-1) remaining
from dba_temp_files
where autoextensible = 'YES'
/
PROMPT
PROMPT
