/*  */
rem*************** RevealNet Oracle Administration ***********************
rem
rem  File: tbsp_exp.sql
rem
rem  This is a part of the RevealNet Oracle Administration library.
rem       
rem  All rights reserved.
rem
rem  For more information, call RevealNet at 1-800-REVEAL4
rem  or check out our Web page: www.revealnet.com
rem
rem  Modifications (Date, Who, Description)
rem
rem FUNCTION: Creates a basic shell script to perform tablespace level 
rem FUNCTION: exports for a database
rem FUNCTION: Each tablespace is given its own export that handles
rem FUNCTION: its tables and their related indexes, grants and contraints
rem
rem NOTE: Only preliminary testing of this script has been done, you 
rem NOTE: should test this script throughly before production use.
rem
rem **********************************************************************
rem
set verify off echo off termout on feedback off 
prompt ...creating tablespace level export script
set termout off
drop table exp_temp;
create table exp_temp (file# number, line_no number, line_txt long);

declare

cursor count_tabs (tbsp in varchar2) is
	select 
		count(*) 
	from 
		dba_tables
	where 
		tablespace_name=tbsp;
 
cursor get_tbsp is
	select 
		tablespace_name 
	from 
		dba_tablespaces 
	where 
		tablespace_name != 'SYSTEM';

cursor get_owners ( tbsp in VARCHAR2 ) is
	select 
		distinct(owner)
	from
		dba_tables
	where
		tablespace_name=tbsp;

cursor get_tabs ( tbsp in VARCHAR2, owner in varchar2 ) is
	select 
		table_name 
	from 
		dba_tables 
	where
		tablespace_name=tbsp
		and owner=owner;

row_cntr 		integer:=0;
tablespace_nm 	dba_tablespaces.tablespace_name%TYPE;
owner		dba_tables.owner%TYPE;
table_nm		dba_tables.table_name%TYPE;
ln_txt		long;
own_cnt		integer;
tab_cnt		integer;
file_no		integer;
tab_count	integer;
dbname		v$database.name%TYPE;

procedure insert_tab (file_no number, row_cntr number, ln_txt long) is
begin
	insert into exp_temp (file#,line_no, line_txt)
	values (file_no,row_cntr,ln_txt);
end;

begin
/*
 initialize various counters 
*/
row_cntr:=0;
tab_count:=0;
file_no:=1;
/*
 Get database name 
*/
select name into dbname from v$database;
ln_txt:='# Tablespace level export script for instance: '||dbname;
row_cntr:=row_cntr+1;
insert_tab (file_no, row_cntr, ln_txt);
/*
 Set command in script to set SID 
*/
ln_txt:='ORACLE_SID='||lower(dbname);
row_cntr:=row_cntr+1;
insert_tab (file_no, row_cntr, ln_txt);
/*
First run to build export script header
 Get all tablespace names other than system 
*/
if get_tbsp%ISOPEN then
	close get_tbsp;
	open get_tbsp;
else
	open get_tbsp;
end if;
loop 
	fetch get_tbsp into tablespace_nm;
	exit when get_tbsp%NOTFOUND;
/*
See if tablespace has tables
*/
	if count_tabs%ISOPEN then
		close count_tabs;
		open count_tabs(tablespace_nm);
	else
		open count_tabs(tablespace_nm);
	end if;
	fetch count_tabs into tab_count;
	if tab_count=0 then
		goto end_loop1;
	end if;
	row_cntr:=row_cntr+1;
	ln_txt:='#';
	insert_tab (file_no, row_cntr, ln_txt);
	row_cntr:=row_cntr+1;
	ln_txt:='#';
	insert_tab (file_no, row_cntr, ln_txt);
	select '# Tablespace: '||tablespace_nm into ln_txt from dual;
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt);
	select '#   Export DMP file name: '||tablespace_nm||'_'||trunc(sysdate)||'.dmp' into ln_txt
	from dual;
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt);
	row_cntr:=row_cntr+1;
	ln_txt:='#   Owners for '||tablespace_nm;
	insert_tab (file_no, row_cntr, ln_txt);
	select '' into ln_txt from dual;
	own_cnt:=0;
/* 
Get tablespace table owners
*/
	if get_owners%ISOPEN then
		close get_owners;
		open get_owners(tablespace_nm);
	else
		open get_owners(tablespace_nm);
	end if;
	tab_cnt:=0;
	loop  
		fetch get_owners into owner;
		exit when get_owners%NOTFOUND;
/*
Get tablespace tables
*/
		ln_txt:='#   Tables for tablespace: '||tablespace_nm;
		row_cntr:=row_cntr+1;
		insert_tab (file_no, row_cntr, ln_txt);
		ln_txt:='';
		if get_tabs%ISOPEN then
			close get_tabs;
			open get_tabs(tablespace_nm,owner);
		else
			open get_tabs(tablespace_nm, owner);
		end if;
		loop
			fetch get_tabs into table_nm;
			exit when get_tabs%NOTFOUND;
			tab_cnt:=tab_cnt+1;
			if tab_cnt=1 then
				ln_txt:='/*    '||ln_txt||owner||'.'||table_nm;
			else
				ln_txt:=ln_txt||', '||owner||'.'||table_nm;			
			end if;
		end loop;
	close get_tabs;
	row_cntr:=row_cntr+1;
	ln_txt:=ln_txt||' */';
	insert_tab (file_no, row_cntr, ln_txt);
	end loop;
	close get_owners;
<<end_loop1>>
null;
end loop;
close get_tbsp;
ln_txt:='####### End of Header -- Start of actual export script ########';
row_cntr:=row_cntr+1;
insert_tab (file_no, row_cntr, ln_txt);
ln_txt:='set -x ';
row_cntr:=row_cntr+1;
insert_tab (file_no, row_cntr, ln_txt); 
select 'script tablespace_exp_'||trunc(sysdate)||'.log' into ln_txt
from dual;
row_cntr:=row_cntr+1;
insert_tab (file_no, row_cntr, ln_txt); 

/*
Now build actual export command sets
*/
/*
 Get all tablespace names other than system 
*/
if get_tbsp%ISOPEN then
	close get_tbsp;
	open get_tbsp;
else
	open get_tbsp;
end if;
loop 
	fetch get_tbsp into tablespace_nm;
	exit when get_tbsp%NOTFOUND;
/*
See if tablespace has tables
*/
	if count_tabs%ISOPEN then
		close count_tabs;
		open count_tabs(tablespace_nm);
	else
		open count_tabs(tablespace_nm);
	end if;
	fetch count_tabs into tab_count;
	if tab_count=0 then
		goto end_loop;
	end if;
	row_cntr:=row_cntr+1;
	ln_txt:='#';
	insert_tab (file_no, row_cntr, ln_txt);
	row_cntr:=row_cntr+1;
	ln_txt:='#';
	insert_tab (file_no, row_cntr, ln_txt);
	select '# Export script for tablespace '||tablespace_nm into ln_txt from dual;
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt);
	select 
		'# created on '||sysdate into ln_txt 
	from 
		dual;
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt); 
	ln_txt:='if ( -r  '||tablespace_nm||'.par'||' ) then';
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt);
 	ln_txt:='   rm '||tablespace_nm||'.par';
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt); 
	ln_txt:='end if';
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt); 
	ln_txt:='touch '||tablespace_nm||'.par';
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt); 
/*
Set up basic export commands
*/
	select 
	'echo '||chr(39)||'grants=y indexes=y constraints=y compress=y'||chr(39)||'>>'||tablespace_nm||'.par'
	into
		ln_txt
	from 
		dual;
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt);
	select '' into ln_txt from dual;
	own_cnt:=0;
	ln_txt:='echo '||chr(39)||'tables=('||chr(39)||'>>'||tablespace_nm||'.par';
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt);
/* 
Get tablespace table owners
*/
	if get_owners%ISOPEN then
		close get_owners;
		open get_owners(tablespace_nm);
	else
		open get_owners(tablespace_nm);
	end if;
	tab_cnt:=0;
	loop  
		fetch get_owners into owner;
		exit when get_owners%NOTFOUND;
/*
Get tablespace tables
*/
		if get_tabs%ISOPEN then
			close get_tabs;
			open get_tabs(tablespace_nm,owner);
		else
			open get_tabs(tablespace_nm,owner);
		end if;
		loop
			fetch get_tabs into table_nm;
			exit when get_tabs%NOTFOUND;
			tab_cnt:=tab_cnt+1;
			if tab_cnt=1 then
			ln_txt:='echo '||chr(39)||owner||'.'||table_nm||chr(39)||'>>'||tablespace_nm||'.par';
			else
			ln_txt:='echo '||chr(39)||', '||owner||'.'||table_nm||chr(39)||'>>'||tablespace_nm||'.par';			
			end if;
			row_cntr:=row_cntr+1;
			insert_tab (file_no, row_cntr, ln_txt);
		end loop;
		close get_tabs;
	end loop;
	close get_owners;
	ln_txt:='echo '||chr(39)||')'||chr(39)||'>>'||tablespace_nm||'.par';
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt);
/*
Set file name for export file
*/
	select 
		'echo '||chr(39)||'file='||tablespace_nm||'_'||trunc(sysdate)||'.dmp'||chr(39)||'>>'||
		tablespace_nm||'.par'
	into ln_txt 
	from 
		dual;
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt);
	select
		'exp system/angler parfile='||tablespace_nm||'.par'
	into 
		ln_txt
	from
		dual;
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt);
	select 
		'compress '||tablespace_nm||'_'||trunc(sysdate)||'.dmp '
	into 
		ln_txt
	from
		dual;
	row_cntr:=row_cntr+1;
	insert_tab (file_no, row_cntr, ln_txt); 
	file_no:=file_no+1;
<<end_loop>>
null;
end loop;
close get_tbsp;
commit;
end;
/

set heading off feedback off long 4000 lines 80 pages 0 verify off
set recsep off embedded on echo off termout off
column file# noprint
column line_no noprint
column line_txt format a80 word_wrapped 
spool tablespace_export.sh
select * from exp_temp
order by file#,line_no;
spool off
set heading on feedback on long 2000 lines 80 pages 22 verify on
set recsep on embedded off echo off termout on
clear columns
prompt  Procedure completed
