/*  */
rem 
rem FUNCTION: Creates summary of v_$sqlarea and dba_users for use in
rem           sqlmem.sql and sqlsummary.sql reports
rem
rem
rem exit 
rem
rem - 
rem
create view sql_summary as select username, sharable_mem, persistent_mem, runtime_mem
from sys.v_$sqlarea a, dba_users b
where a.parsing_user_id = b.user_id;
