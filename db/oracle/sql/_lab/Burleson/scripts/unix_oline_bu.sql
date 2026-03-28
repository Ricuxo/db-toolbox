/*  */
REM Script to create a hot backup script on UNIX
REM Created 6/23/98 MRA
REM
create table bu_temp (line_no number,line_txt varchar2(2000))
storage (initial 1m next 1m pctincrease 0);
truncate table bu_temp;
set verify off embedded off
define dest_dir=&1;
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
cursor tar1_com (tbsp varchar2) is
select '/bin/tar cvf - '||file_name||' \'
from dba_data_files where tablespace_name=tbsp 
and file_id=(select min(file_id)from dba_data_files 
where tablespace_name=tbsp);
--
cursor tar2_com (tbsp varchar2) is
select
file_name||' \'
from dba_data_files where tablespace_name=tbsp
and file_id>(select min(file_id) from dba_data_files 
where tablespace_name=tbsp);
--
cursor tar3_com (tbsp varchar2) is
select '/bin/tar cvrf - '||file_name||' \'
from dba_data_files where tablespace_name=tbsp 
and file_id=(select min(file_id)from dba_data_files 
where tablespace_name=tbsp);
--
cursor comp_com (tbsp varchar2) is
select
'|compress>&&dest_dir/'||tablespace_name||'_'||to_char(sysdate,'dd_mon_yy')||'.Z'||chr(10)||'exit'
from dba_tablespaces where tablespace_name=tbsp;

--
-- Cursor to create END BACKUP command
--
cursor ebu_com (tbsp varchar2) is
select
'alter tablespace '||tablespace_name||' end backup;' from
dba_tablespaces
where tablespace_name=tbsp;
--
-- Cursor to create redo log HOST backup commands
--
cursor tar1_rdo is
select '/bin/tar cvf -  \'
from dual;
--
cursor tar2_rdo is
select
member||' \'
from v$logfile;
--
cursor comp_rdo is
select
'|compress>&&dest_dir/redo_logs_'||to_char(sysdate,'dd_mon_yy')||'.Z'||chr(10)||'exit'
from dual;
--
-- Temporary variable declarations
--
tbsp_name varchar2(64);
line_num number:=0;
line_text varchar2(2000);
min_value number;
first_tbsp boolean;
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
select 'REM Script uses UNIX tar format backup commands'  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM created on '||to_char(sysdate, 'dd-mon-yyyy hh24:mi')||' by user '||user  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM developed for Burleson Consulting - DMR Consulting Group 7-Oct-2011'  
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
first_tbsp:=TRUE;
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
	line_num:=line_num+1;
  	close bbu_com;
--
-- The actual backup commands are per datafile, open cursor and loop
--
  	open tar1_com (tbsp_name);
	open tar2_com (tbsp_name);
open tar3_com (tbsp_name);
	open comp_com (tbsp_name);
	min_value:=line_num;
  	loop
		if line_num=min_value
		then
				select 'host' into line_text from dual;
				insert into bu_temp values (line_num,line_text);
				line_num:=line_num+1;
			if first_tbsp THEN
                  fetch tar1_com into line_text;
                else
                  fetch tar3_com into line_text;
                end if;
		else
			fetch tar2_com into line_text;
  				exit when tar2_com%NOTFOUND;
		end if;
		insert into bu_temp values (line_num,line_text);
		line_num:=line_num+1;
           first_tbsp:=FALSE;
  	end loop;
	fetch comp_com into line_text;
	insert into bu_temp values (line_num,line_text);
    line_num:=line_num+1;
	close tar1_com;
	close tar2_com;
close tar3_com;
	close comp_com;
--
-- Build end backup command for this tablespace
--
  open ebu_com(tbsp_name);
  fetch ebu_com into line_text;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  close ebu_com;
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
  open tar1_rdo;
  open tar2_rdo;
  open comp_rdo;
  min_value:=line_num;
  loop
	if line_num=min_value 
	then
	 select 'host' into line_text from dual;
	 insert into bu_temp values (line_num,line_text);
	 line_num:=line_num+1;
	 fetch tar1_rdo into line_text;
	else
	 fetch tar2_rdo into line_text;
	 exit when tar2_rdo%NOTFOUND;
	end if;
	insert into bu_temp values (line_num,line_text);
  	line_num:=line_num+1;
  end loop;
  fetch comp_rdo into line_text;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  close tar1_rdo;
  close tar2_rdo;
  close comp_rdo;
--
-- Now get all archive logs, performing a switch to be sure all
-- required archives are written out
--
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
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'archive log all;' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
--
-- The next command builds the actual backup command based on the 
-- value of the log_archive_dest initialization parameter, it looks for the
-- last right square bracket in the name and just uses that section with
-- a wildcard
--
  select 'host compress '||substr (value,1,instr(value,'/',-1,1))||'*'
  into line_text from v$parameter where name='log_archive_dest';
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'host tar cvf - '||substr (value,1,instr(value,'/',-1,1))||'*.Z'||
  '|compress>&&dest_dir/'||
  substr (value,instr(value,'/',-1,1)+1,length(value))||'_'||to_char(sysdate,'dd_mon_yy')||'.Z'
  into line_text from v$parameter where name='log_archive_dest';
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
--
-- Next, backup a control file just to be sure
-- we have a good one available that is current with this backup
-- 
   select 'alter database backup control file to '||'&&dest_dir'||'/ora_conbackup_'||to_char(sysdate,'dd_mon_yy')||'.bac;'  
   into line_text from dual;
   insert into bu_temp values (line_num,line_text);
   line_num:=line_num+1;
end;
/
rem
rem Now generate output based on bu_temp table contents
rem
set verify off feedback off heading off termout off pages 0
set embedded on lines 132
column line_no noprint
column dbname new_value db noprint
select name dbname from v$database;
spool rep_out\&db\thot_bu.sql
select * from bu_temp order by line_no;
spool off
rem directory syntax for UNIX
rem 
rem host  sed '1,$ s/ *$//g' thot_bu.sql>hot_bu.sql
rem
drop table bu_temp;
set verify on feedback on heading on termout on pages 22
set embedded off lines 80
clear columns
undef dest_dir

