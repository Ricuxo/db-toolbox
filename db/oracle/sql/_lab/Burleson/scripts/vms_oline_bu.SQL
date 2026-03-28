/*  */
REM Script to create a hot backup script on VMS
REM Created 6/23/98 MRA
REM
create table bu_temp (line_no number,line_txt varchar2(2000)) tablespace tools; 
truncate table bu_temp;
set verify off embedded off
define dest_dir=&1;
column dup new_value dup_it noprint
select ''||chr(39)||'backup/ignore=(noback, interlock,label)/log '||chr(39)||'' dup 
from dual;

declare
--
-- Declare cursors
--
-- Cursor to get all tablespace names
--
cursor get_tbsp is
select tablespace_name from dba_tablespaces;
--
-- cursor to create BEGIN BACKUP command
--
cursor bbu_com (tbsp varchar2) is
select 
'alter tablespace '||tablespace_name||' begin backup;'
from dba_tablespaces where tablespace_name=tbsp;
--
-- Cursor to create HOST backup commands
--
cursor bu_com (tbsp varchar2) is
select
'host '||&&dup_it||file_name||' - '||chr(10)||
' mua0:ora_'||tbsp||file_id||'.bck/sav'
from dba_data_files where tablespace_name=tbsp;
--
-- Cursor to create END BACKUP command
--
cursor ebu_com (tbsp varchar2) is
select
'alter tablespace '||tablespace_name||' end backup;'||chr(10) from
dba_tablespaces
where tablespace_name=tbsp;
--
-- Cursor to create redo log HOST backup commands
--
cursor bu_rdo (num number) is
select
'host '||&&dup_it||member||' - '||chr(10)||
' mua0:ora_redo'||substr(member,instr(member,'log',-1,1)+3,2)||'.bck/sav'
from v$logfile order by group#;
--
-- Temporary variable declarations
--
tbsp_name varchar2(64);
line_num number:=0;
line_text varchar2(2000);
num number:=0;
--
-- Begin build of commands into temporary table
--
begin
--
-- first, create script header
--
line_num := line_num+1;
select 'REM Online Backup Script for '||name||' instance' 
into line_text from v$database;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM Script uses OpenVMS format backup commands'  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM created on '||to_char(sysdate, 'dd-mon-yyyy hh24:mi')||' by user '||user  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM developed for TVA by Mike Ault - DMR Consulting Group 23-Jun-2011'  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM Script expects to be fed backup directory location on execution.'  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM Script should be re-run anytime physical structure of database altered.'  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM '  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
--
-- Now get tablespace names and loop through until all are handled
--
open get_tbsp;
loop
-- 
-- Get name
--
	fetch get_tbsp into tbsp_name;
	exit when get_tbsp%NOTFOUND;
--
-- Add comments to script showing which tablespace
--
	select 'REM' into line_text from dual;
  	insert into bu_temp values (line_num,line_text);
	line_num:=line_num+1;
	select 'REM Backup for tablespace '||tbsp_name into line_text from dual;
  	insert into bu_temp values (line_num,line_text);
	line_num:=line_num+1;
	select 'REM' into line_text from dual;
  	insert into bu_temp values (line_num,line_text);
	line_num:=line_num+1;
--
-- Get begin backup command built for this tablespace
--
  	open bbu_com (tbsp_name);
  	fetch bbu_com into line_text;
  	insert into bu_temp values (line_num,line_text);
  	close bbu_com;
--
-- The actual backup commands are per datafile, open cursor and loop
--
  	open bu_com (tbsp_name);
  	loop
                fetch bu_com into line_text;
  		exit when bu_com%NOTFOUND;
		line_num:=line_num+1;
		insert into bu_temp values (line_num,line_text);
  	end loop;
	close bu_com;
--
-- Build end backup command for this tablespace
--
  open ebu_com(tbsp_name);
  fetch ebu_com into line_text;
  insert into bu_temp values (line_num,line_text);
  close ebu_com;
  line_num := line_num+1;
  select ' ' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
end loop;
  close get_tbsp;
--
-- Backup redo logs, normally you won't recover redo logs you
-- will use your current redo logs so current SCN information not lost
-- commands just here for completeness
--
  select 'REM' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM Backup for redo logs' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM Normally you will not recover redo logs' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
--
-- Create host backup commands for all redo logs
--
  open bu_rdo(num);
  loop
	if num=3 
		then num:=0;
	end if;
	fetch bu_rdo into line_text;
	exit when bu_rdo%NOTFOUND;
	num:=num+1;
	line_num:=line_num+1;
	insert into bu_temp values (line_num,line_text);
  end loop;
  close bu_rdo;
--
-- Now get all archive logs, performing a switch to be sure all
-- required archives are written out
--
  line_num:=line_num+1;
  select 'REM' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM Backup for archive logs' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'alter system switch logfile;' into line_text from dual;
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'archive log all;' into line_text from dual;
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
--
-- The next command builds the actual backup command based on the 
-- value of the log_archive_dest initialization parameter, it looks for the
-- last right square bracket in the name and just uses that section with
-- a wildcard
--
  select 'host '||&&dup_it||substr(value,1,instr(value,']',-1,1))||'*/DELETE'||' - '||chr(10)||
  ' mua0:ora_archive.bck/sav'
  into line_text from v$parameter where name='log_archive_dest';
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
--
-- Next, backup a control file just to be sure
-- we have a good one available that is current with this backup
-- 
   select 'alter database backup control file to '||'&&dest_dir'||'ora_conbackup.bac;'  
   into line_text from dual;
   line_num:=line_num+1;
   insert into bu_temp values (line_num,line_text);
   select 'host '||&&dup_it||'&&dest_dir'||'ora_conbackup.bac - '||chr(10)||
   ' mua0:ora_control.bck/sav'
   into line_text from dual;
   line_num:=line_num+1;
   insert into bu_temp values (line_num,line_text);
end;
/
rem
rem Now generate output based on bu_temp table contents
rem
set verify off feedback off heading off termout off pages 0
set embedded on lines 132
column line_no noprint
spool thot_bu.sql
select * from bu_temp order by line_no;
spool off
rem
rem get rid of bu_temp table
rem
drop table bu_temp;
set verify on feedback on heading on termout on pages 22
set embedded off lines 80
clear columns
undef dest_dir
