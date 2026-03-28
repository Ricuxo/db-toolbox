/*  */
create table bu_temp (line_no number,line_txt varchar2(2000)) tablespace temp; 
set verify off
define dest_dir=&1;
declare

cursor get_tbsp is
select tablespace_name from dba_tablespaces;

cursor bbu_com (tbsp varchar2) is
select 
'alter tablespace '||tablespace_name||' begin backup;'
from dba_tablespaces where tablespace_name=tbsp;

cursor tar_com (tbsp varchar2) is
select
'host /bin/tar cvf - '||file_name||'|compress>&&dest_dir/'||
substr (file_name,instr(file_name,'/',-1,1)+1,length(file_name))||'.Z'
from dba_data_files where tablespace_name=tbsp;

cursor ebu_com (tbsp varchar2) is
select
'alter tablespace '||tablespace_name||' end backup;' from
dba_tablespaces
where tablespace_name=tbsp;

cursor tar_rdo is
select
'host /bin/tar cvf - '||member||'|compress>&&dest_dir/'||
substr (member,instr(member,'/',-1,1)+1,length(member))||'.Z'
from v$logfile order by group#;

tbsp_name varchar2(64);
line_num number:=0;
line_text varchar2(2000);

begin
line_num := line_num+1;
open get_tbsp;
loop
	fetch get_tbsp into tbsp_name;
	exit when get_tbsp%NOTFOUND;
  	open bbu_com (tbsp_name);
  	fetch bbu_com into line_text;
  	insert into bu_temp values (line_num,line_text);
  	close bbu_com;
  	open tar_com (tbsp_name);
  	loop
                fetch tar_com into line_text;
  		exit when tar_com%NOTFOUND;
		line_num:=line_num+1;
		insert into bu_temp values (line_num,line_text);
  	end loop;
	close tar_com;
  open ebu_com(tbsp_name);
  fetch ebu_com into line_text;
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
  close ebu_com;
end loop;
  close get_tbsp;
  select 'alter system switch logfile;' into line_text from dual;
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
  open tar_rdo;
  loop
	fetch tar_rdo into line_text;
	exit when tar_rdo%NOTFOUND;
	line_num:=line_num+1;
	insert into bu_temp values (line_num,line_text);
  end loop;
  close tar_rdo;
  select 'host compress '||substr (value,1,instr(value,'/',-1,1))||'*'
  into line_text from v$parameter where name='log_archive_dest';
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
  select 'host tar cvf - '||substr (value,1,instr(value,'/',-1,1))||'*.Z'||
  '|compress>&&dest_dir/'||
  substr (value,instr(value,'/',-1,1)+1,length(value))||'.Z'
  into line_text from v$parameter where name='log_archive_dest';
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
end;
/
set verify off feedback off heading off termout off pages 0
set embedded on lines 132
column line_no noprint
column dbname new_value db noprint
select name dbname from v$database;
spool rep_out\&db\thot_bu.sql
select * from bu_temp order by line_no;
spool off
rem uncomment this next line and change
rem directory syntax for UNIX
rem 
rem host  sed '1,$ s/ *$//g' thot_bu.sql>hot_bu.sql
rem
drop table bu_temp;
set verify on feedback on heading on termout on pages 22
set embedded off lines 80
clear columns
undef dest_dir
