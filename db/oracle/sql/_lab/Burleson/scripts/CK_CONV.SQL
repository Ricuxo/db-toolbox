/*  */
REM    	FUNCTION: SCRIPT FOR RE-CREATING DATABASE CONSTRAINTS 
REM
REM    	FUNCTION: This script must be run by the constraint owner.  
REM 
REM 	FUNCTION: This script is intended to run with Oracle7.
REM
REM FUNCTION: Running this script will in turn create a script to build all the 
REM FUNCTION: constraints owned in the database.  Th created script is called 
REM FUNCTION: 'create_constraints.sql'.
REM 
REM
REM Only preliminary testing of this script was performed.  Be sure to test 
REM it completely before relying on it.  
REM
 
set verify off
rem set feedback off
rem set termout off
rem set echo off
set pagesize 0
set long 4000
set termout on
select 'Creating constraint build script...' from dual;
rem set termout off
 
create table cons_temp (owner varchar2(30),
			constraint_name varchar2(30),
			constraint_type varchar2(11),
			search_condition varchar2(2000),
			table_name varchar2(30),
			referenced_owner varchar2(30),
			referenced_constraint varchar2(30),
			delete_rule varchar2(9),
			constraint_columns varchar2(2000),
			con_number number); 

DECLARE
 
   CURSOR cons_cursor IS 
	select	owner,
   		constraint_name, 
   		decode(constraint_type,'C','CK_',
					'V','DF_'),
   				table_name,
   				search_condition, 
				r_owner,
				r_constraint_name,
				delete_rule
     from user_constraints 
     where owner not in ('SYS','SYSTEM') and 
     constraint_type in ('C','V')
     ;
     cursor cons_col (cons_name in varchar2) is select 
	   	owner,
	   	constraint_name,
		column_name
     from user_cons_columns 
     where owner not in ('SYS','SYSTEM')
	and constraint_name=cons_name
     order by  constraint_name, 
		position;

	cursor get_cons (tab_nam in varchar2) is
	select distinct 
		OWNER,TABLE_NAME,CONSTRAINT_NAME,CONSTRAINT_TYPE
	from cons_temp
	where table_name=tab_nam
	and constraint_type in ('CK_','DF_')
	order by owner,table_name,constraint_name;

	cursor get_tab_nam is
	select distinct table_name
	from cons_temp
	where constraint_type in ('CK_','DF_')
	order by table_name;

	tab_nam	user_constraints.table_name%TYPE;
   	cons_owner	user_constraints.owner%TYPE;
   	cons_name  	user_constraints.constraint_name%TYPE;
   	cons_type	varchar2(11);
   	cons_sc	user_constraints.search_condition%TYPE;
	cons_tname	user_constraints.table_name%TYPE;
	cons_rowner	user_constraints.r_owner%TYPE;
	cons_rcons	user_constraints.r_constraint_name%TYPE;
	cons_dr		user_constraints.delete_rule%TYPE;   
	cons_col_own	user_cons_columns.owner%TYPE;
	cons_col_nam	user_cons_columns.constraint_name%TYPE;
	cons_column	user_cons_columns.column_name%TYPE;
	cons_tcol_name	user_cons_columns.table_name%TYPE;
	all_columns 	varchar2(2000);
	counter		integer:=0;
	cons_nbr 	integer;

BEGIN
   OPEN cons_cursor;
   LOOP
      FETCH cons_cursor INTO 	cons_owner,
      				cons_name,
      				cons_type,
      				cons_sc,
      				cons_tname,
      				cons_rowner,
				cons_rcons,
      				cons_dr;
      EXIT WHEN cons_cursor%NOTFOUND;
	all_columns :='';	
	counter := 0;
	open cons_col (cons_name);
	loop
		fetch cons_col into
					cons_col_own,
	   				cons_col_nam,
	   				cons_column;
	exit when cons_col%NOTFOUND; 
		if cons_owner = cons_col_own and cons_name=cons_col_nam
		then
			counter := counter+1;
			if counter = 1 then
			all_columns := all_columns||cons_column;
			else
			all_columns := all_columns||', '||cons_column;
			end if;
		end if;
	end loop;
	close cons_col;
	insert into cons_temp values (cons_owner,
				      cons_name,
				      cons_type,
				      cons_tname,
				      cons_sc,
				      cons_rowner,
				      cons_rcons,
				      cons_dr,
				all_columns,
				0);
   commit;
   END LOOP;
   CLOSE cons_cursor;
   commit;
begin
 open get_tab_nam;
loop
  fetch get_tab_nam into tab_nam;
  exit when get_tab_nam%NOTFOUND;
/*sys.dbms_output.put_line(tab_nam);*/
  open get_cons (tab_nam);
  cons_nbr:=0;
  loop
    fetch get_cons into cons_owner,
			cons_tname,
			cons_name,
			cons_type;
    exit when get_cons%NOTFOUND;
    cons_nbr:=cons_nbr+1;
/*    sys.dbms_output.put_line('cons_nbr='||cons_nbr);*/
/*sys.dbms_output.put_line(cons_owner||'.'||cons_name||' '||cons_type);*/
    update cons_temp set con_number=cons_nbr where
	constraint_name=cons_name and
	constraint_type=cons_type and
	owner=cons_owner;
  end loop;
  close get_cons;
  commit;
end loop;
close get_tab_nam;
commit;
end;
END;
/
create index pk_cons_temp on cons_temp(constraint_name);
create index lk_cons_temp on cons_temp(constraint_type);
create index lk_cons_temp2 on cons_temp(referenced_constraint);
set heading off feedback off pages 0 termout off echo off
set recsep off verify off
set embedded on
spool ck_rct.sql
select 'alter table '||a.table_name||' drop constraint '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||constraint_type||a.table_name||'_'||a.con_number||&&cr||
decode(constraint_type,'CK_','CHECK ','DF_','DEFAULT ')||'( '||a.search_condition||' );'
from cons_temp a where constraint_type in ( 'CK_','DF_' )
/
spool off
drop table cons_temp;
set verify on
rem set feedback on
rem set termout on
rem set echo on
set pagesize 22
clear columns
clear computes
