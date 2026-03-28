/*  */
REM Script to create a hot backup recovery script on NT using ocopy
REM Created 6/23/98 MRA
REM 
create table bu_temp (line_no number,line_txt varchar2(2000)); 
truncate table bu_temp;
set verify off embedded off esc ^
REM &&ora_home &&dest_dir
column dup new_value dup_it noprint
select ''||chr(39)||'&&ora_home'||'\ocopy '||chr(39)||'' dup 
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
-- Cursor to create recovery commands
--
cursor rec_com (tbsp varchar2) is
select
&&dup_it||' '||'&&dest_dir'||'\datafiles\'||tbsp||file_id||'.bck '||file_name
from dba_data_files where tablespace_name=tbsp;
--
-- Cursor to create redo log recovery commands
--
cursor rec_rdo (num number) is
select
&&dup_it||
' '||'&&dest_dir'||'\logs'||substr(member,instr(member,'\LOG',2,1),instr(member,'.',1,1))||' '||
member
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
select 'REM Recovery Script for '||name||' instance' 
into line_text from v$database;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM Script uses ocopy - NT format backup commands'  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM created on '||to_char(sysdate, 'dd-mon-yyyy hh24:mi')||' by user '||user  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM developed for Burleson Consulting - DMR Consulting 15-Dec-2011'  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM '  
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
	select 'REM Recovery for tablespace '||tbsp_name into line_text from dual;
  	insert into bu_temp values (line_num,line_text);
	line_num:=line_num+1;
	select 'REM' into line_text from dual;
  	insert into bu_temp values (line_num,line_text);
	line_num:=line_num+1;
--
-- The actual recovery commands are per datafile, open cursor and loop
--
  	open rec_com (tbsp_name);
  	loop
                fetch rec_com into line_text;
  		exit when rec_com%NOTFOUND;
		line_num:=line_num+1;
		insert into bu_temp values (line_num,line_text);
  	end loop;
	close rec_com;
end loop;
  close get_tbsp;
--
-- Recover redo logs, normally you won't recover redo logs you
-- will use your current redo logs so current SCN information not lost
-- commands just here for completeness uncomment commands below to
-- enable redo log recovery (not advised)
--
  select 'REM' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM Recovery for redo logs' into line_text from dual;
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
  /*open rec_rdo(num);
  loop
	fetch rec_rdo into line_text;
	exit when rec_rdo%NOTFOUND;
	num:=num+1;
	line_num:=line_num+1;
	insert into bu_temp values (line_num,line_text);
  end loop;
  close rec_rdo;*/
--
-- Now recover all archive logs
--
  line_num:=line_num+1;
  select 'REM' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM Recovery for archive logs' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
--
-- The next command builds the actual recovery command based on the 
-- value of the log_archive_dest initialization parameter, it looks for the
-- last right square bracket in the name and just uses that section with
-- a wildcard
--
  select &&dup_it||' '||'&&dest_dir'||'\archives\*.* '||value||'\*.*'
  into line_text from v$parameter where name='log_archive_dest';
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
end;
/
rem
rem Now generate output based on bu_temp table contents
rem
set verify off feedback off heading off termout off pages 0
set embedded on lines 132
column db_name new_value db noprint
column line_no noprint
select name db_name from v$database;
spool rep_out\&&db\rec_db.bat
select * from bu_temp order by line_no;
spool off
rem
rem get rid of bu_temp table
rem
drop table bu_temp;
set verify on feedback on heading on termout on pages 22
set embedded off lines 80 esc \
clear columns
undef ora_home
undef dest_dir
rem exit

