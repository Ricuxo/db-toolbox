/*  */
set embedded on feedback off pages 0 heading off
spool desc_dba.sql 
rem
SELECT 'SPOOL desc_dba.lis' FROM dual; 
rem
SELECT 
 'prompt Contents of view: '||view_name||chr(10)||  
 'DESC '||view_name 
FROM 
  dba_views 
WHERE view_name like 'DBA_%'
ORDER BY view_name;
rem 
SELECT 'SPOOL OFF' FROM dual;
spool off

start desc_dba.sql
