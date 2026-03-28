/*  */
rem
rem FUNCTION: Generate a list of stored code
rem
COLUMN OBJECT_TYPE FORMAT A12 HEADING 'Module|Type' 
COLUMN OBJECT_NAME FORMAT A40 HEADING 'Module|Name'
column owner format a10 heading 'Module|Owner'
SET LINES 80 verify off feedback off
SET PAGES 58
break on owner on object_type
@TITLE80 'STORED PROCEDURES'
spool rep_out\&db\st_proc
select owner,object_type,object_name 
from dba_objects where
object_type in ('FUNCTION','PACKAGE','PACKAGE BODY','PROCEDURE')
order by owner,object_type
/
spool off
clear columns
clear breaks
set lines 80 pages 22 verify on feedback on
