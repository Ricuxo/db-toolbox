/*  */
-- Script to create a hot backup script on UNIX/LINUX
-- Using Oracle UTL_FILE to create a sql file
-- Based on a script by Mike Ault
--
-- History
-- DATE      PROGRAMMER      ACTION
-- 
-- 9/27/1999 Bob Rudolf PCS  Created
-- 5/02/2000 Bob Rudolf PCS  Updated to allow for multiple datafiles 
--
--
CREATE OR REPLACE PROCEDURE build_backup
IS
--
    l_file_handle UTL_FILE.FILE_TYPE;
    l_file_name   VARCHAR2(50);
    l_out_str     VARCHAR2(1000);
    l_path_name   VARCHAR2(50) := '/vol1/backup';
    v_copy_str    VARCHAR2(50) := 'host /bin/tar cvf - ';
    v_nhcopy_str  VARCHAR2(50) := '/bin/tar cvf - ';
    v_data_dir    VARCHAR2(50) := '/vol1/backup/datafile/';
    v_log_dir     VARCHAR2(50) := '/vol1/backup/logs/';
    v_baklog_dir  VARCHAR2(50) := '/vol1/backup/logs/';
    v_arclog_dir  VARCHAR2(50) := '/vol1/backup/arc_logs/';
    v_cont_dir    VARCHAR2(50) := '/vol1/backup/control/control.bak';
    v_init_dir    VARCHAR2(50) := '/vol1/app/oracle/admin/tprod2/pfile';
    v_initbak_dir VARCHAR2(50) := '/vol1/backup/init/';
    v_error_msg   VARCHAR2(254);
    v_tbsp_name   VARCHAR2(32);
    v_tbsp        VARCHAR2(32);
    v_str         VARCHAR2(100);
    min_value     NUMBER;
    line_num      NUMBER := 1;
    first_tbsp    BOOLEAN;
    e_function_error  EXCEPTION;

--
--
-- Declare cursors
--
-- Cursor to get all tablespace names
--
cursor get_tbsp is select tablespace_name from dba_tablespaces
where contents = 'PERMANENT'
and tablespace_name not like('TEMP%');
--
-- cursor to create BEGIN BACKUP command
--
cursor bbu_com (v_tbsp VARCHAR2) is
select 'alter tablespace '||tablespace_name||' begin backup;' 
from dba_tablespaces where tablespace_name = v_tbsp;
--
-- Cursor to create HOST backup commands
--
cursor tar1_com (v_tbsp VARCHAR2) is
select 'host /bin/tar cvf - '||file_name||' -'
from dba_data_files where tablespace_name = v_tbsp 
and file_id = (select min(file_id)from dba_data_files 
where tablespace_name = v_tbsp);
--
cursor tar2_com (v_tbsp VARCHAR2) is
select file_name||' -'
--select 'host '||file_name||' -'
from dba_data_files where tablespace_name = v_tbsp
and file_id > (select min(file_id) from dba_data_files 
where tablespace_name = v_tbsp);
--
cursor tar3_com (v_tbsp VARCHAR2) is
select 'host /bin/tar cvrf - '||file_name||' -'
from dba_data_files where tablespace_name = v_tbsp 
and file_id = (select min(file_id)from dba_data_files 
where tablespace_name = v_tbsp);
--
cursor comp_com (v_tbsp VARCHAR2) is
select '| compress > '||v_data_dir||tablespace_name||'_'||to_char(sysdate,'ddmonyy')||'.Z'
from dba_tablespaces where tablespace_name = v_tbsp;
--
-- Cursor to create END BACKUP command
--
cursor ebu_com (v_tbsp VARCHAR2) is
select 'alter tablespace '||tablespace_name||' end backup;' from
dba_tablespaces
where tablespace_name = v_tbsp;
--
-- Cursor to create redo log HOST backup commands
--
cursor tar1_rdo is select 'host /bin/tar cvf -  ' from dual;
--
cursor tar2_rdo is select member||' -' from v$logfile;
--
cursor comp_rdo is select '| compress > '||v_log_dir||'/redo_logs_'||
to_char(sysdate,'dd_mon_yy')||'.Z' from dual;
--
-- Temporary variable declarations
--
--
-- Begin build of commands into temporary table
--
BEGIN
 l_file_name := 'backup.sh';
BEGIN
 l_file_handle := utl_file.fopen(l_path_name, l_file_name, 'w', 32767);
 EXCEPTION
 WHEN UTL_FILE.INVALID_PATH THEN
   v_error_msg := 'Unable to open file: Invalid path.';
   RAISE e_function_error ;
 WHEN UTL_FILE.INVALID_MODE THEN
   v_error_msg := 'Unable to open file: Invalid mode.';
   RAISE e_function_error ;
 WHEN UTL_FILE.INVALID_OPERATION THEN
   v_error_msg := 'Unable to open file: Invalid operation.';
   RAISE e_function_error ;
END;
--
--
-- First, create script header
--
utl_file.put_line(l_file_handle, 'set echo on');
select '## Online Backup Script for '||name||' instance' into l_out_str from v$database;
utl_file.put_line(l_file_handle, l_out_str);
select '## created on '||to_char(sysdate, 'DD-MON-YYYY HH24:MI')||' by user '||user  into l_out_str from dual;
utl_file.put_line(l_file_handle, l_out_str);
utl_file.put_line(l_file_handle, '## developed by Bob Rudolf, Precision Computer Systems.');
utl_file.put_line(l_file_handle, '## based on a script by Mike Ault.');
utl_file.put_line(l_file_handle, '## Script should be run before each backup');
utl_file.put_line(l_file_handle, '## since the created script is date stamped');
utl_file.put_line(l_file_handle, '##');
--
--
-- Log on as sysdba to build the backup.sql file
-- For versions before 9i uncomment this line
-- utl_file.put_line(l_file_handle, 'svrmgrl <<EOF');
-- For versions before 9i comment this line
utl_file.put_line(l_file_handle, 'sqlplus -s "/ as sysdba"<<EOF');
--
--
-- Create a log file to record everything
utl_file.put_line(l_file_handle, 'spool '||v_baklog_dir||to_char(sysdate,'ddmonyy')||'.log');
--
--
-- Now get tablespace names and loop through until all are handled
--
open get_tbsp;
first_tbsp := TRUE;
loop
-- 
-- Get name
--
  fetch get_tbsp into v_tbsp_name;
  exit when get_tbsp%NOTFOUND;
--
-- Add comments to script showing which tablespace
--
  utl_file.put_line(l_file_handle, '--');
  utl_file.put_line(l_file_handle, '--Backup for tablespace '||v_tbsp_name);
  utl_file.put_line(l_file_handle, '--');
--
-- Get begin backup command built for this tablespace
--
  open bbu_com (v_tbsp_name);
  fetch bbu_com into l_out_str;
  utl_file.put_line(l_file_handle, l_out_str);
  close bbu_com;
--
-- The actual backup commands are per datafile, open cursor and loop
--
  open tar1_com (v_tbsp_name);
  open tar2_com (v_tbsp_name);
  open tar3_com (v_tbsp_name);
  open comp_com (v_tbsp_name);
  min_value := line_num;
  loop
    if line_num = min_value then
      if first_tbsp THEN
        fetch tar1_com into l_out_str;
      else
        fetch tar3_com into l_out_str;
      end if;
      line_num := line_num + 1;
    else
      fetch tar2_com into l_out_str;
      exit when tar2_com%NOTFOUND;
    end if;
    utl_file.put_line(l_file_handle,l_out_str);
    first_tbsp := FALSE;
  end loop;
  fetch comp_com into l_out_str;
  utl_file.put_line(l_file_handle,l_out_str);
  close tar1_com;
  close tar2_com;
  close tar3_com;
  close comp_com;
--
-- Build end backup command for this tablespace
--
  open ebu_com(v_tbsp_name);
  fetch ebu_com into l_out_str;
  utl_file.put_line(l_file_handle,l_out_str);
  close ebu_com;

end loop;

close get_tbsp;
--
-- Backup redo logs, normally you won't recover redo logs you
-- will use your current redo logs so current SCN information not lost
-- commands just here for completeness
--
utl_file.put_line(l_file_handle,'--');
utl_file.put_line(l_file_handle,'-- Backup for redo logs');
utl_file.put_line(l_file_handle,'-- Normally you will not recover redo logs');
utl_file.put_line(l_file_handle,'--');
--
-- Create host backup commands for all redo logs
--
open tar1_rdo;
open tar2_rdo;
open comp_rdo;
min_value := line_num;
loop
  if line_num = min_value then
    line_num := line_num+1;
    fetch tar1_rdo into l_out_str;
  else
    fetch tar2_rdo into l_out_str;
    exit when tar2_rdo%NOTFOUND;
  end if;
  utl_file.put_line(l_file_handle,l_out_str);
end loop;
fetch comp_rdo into l_out_str;
utl_file.put_line(l_file_handle,l_out_str);
close tar1_rdo;
close tar2_rdo;
close comp_rdo;
--
-- Now get all archive logs, performing a switch to be sure all
-- required archives are written out
--
utl_file.put_line(l_file_handle,'--');
utl_file.put_line(l_file_handle,'-- Backup for archive logs');
utl_file.put_line(l_file_handle,'--');
utl_file.put_line(l_file_handle,'alter system switch logfile;');
utl_file.put_line(l_file_handle,'archive log all;');
--
-- The next command builds the actual backup command based on the 
-- value of the log_archive_dest initialization parameter, it looks for the
-- last right square bracket in the name and just uses that section with
-- a wildcard
--
select 'host /bin/tar cvf - '||substr(value,10,length(value)-9)||'/*.arc'||
' | compress > '||v_arclog_dir||
substr (value,instr(value,'/',-1,1)+1,length(value))||'_'||to_char(sysdate,'dd_mon_yy')||'.Z'
into l_out_str from v$parameter where name='log_archive_dest_1';
utl_file.put_line(l_file_handle,l_out_str);
--
-- Next, backup a control file just to be sure
-- we have a good one available that is current with this backup
-- 
select 'alter database backup controlfile to '||chr(39)||v_cont_dir||chr(39)||';'
into l_out_str from dual;
utl_file.put_line(l_file_handle,l_out_str);
--
--
utl_file.put_line(l_file_handle,'spool off<<EOF');
utl_file.put_line(l_file_handle,'exit');
utl_file.fflush(l_file_handle);
utl_file.fclose(l_file_handle);

EXCEPTION
  WHEN e_function_error THEN
    dbms_output.put_line('err msg...'||v_error_msg);
    v_error_msg := v_error_msg|| SUBSTR(sqlerrm, 1, 250); 
    utl_file.fflush(l_file_handle);
    utl_file.fclose(l_file_handle);
    RAISE_APPLICATION_ERROR(-20050, v_error_msg);
  WHEN OTHERS THEN 
    dbms_output.put_line('err msg...'||v_error_msg);
    v_error_msg := SUBSTR(sqlerrm, 1, 250);
    utl_file.fflush(l_file_handle);
    utl_file.fclose(l_file_handle);
    RAISE_APPLICATION_ERROR(-20051, v_error_msg);

END; -- END OF BACKUP_PROC
/
SHOW ERRORS

