/*  */
REM  trig_rct.sql
REM
REM    FUNCTION: SCRIPT FOR RE-CREATING DATABASE TRIGGERS 
REM              This script can be run by anyone with access to dba_ triggers
REM              This script is intended to run with Oracle7.
REM              Running this script will in turn create a script to 
REM              build all the triggers in the database.  This created 
REM              script is called 'crt_trig.sql'.
REM              Only preliminary testing of this script was performed.  
REM              Be sure to test it completely before relying on it.  
set verify off feedback off termout off echo off pagesize 0 long 4000
set termout on arraysize 1
select 'Creating trigger build script...' from dual;
rem set termout off
set echo on
create table trig_temp (owner varchar2(30),
			trigger_name varchar2(30),
			trigger_type varchar2(16),
			triggering_event varchar2(26),
			table_owner varchar2(30),
			table_name varchar2(30),
			referencing_names varchar2(87),
			when_clause varchar2(2000),
			trigger_body long,
			trigger_columns varchar2(400)) 
storage (initial 100k next 100k)
tablespace tools;
 
DECLARE
   CURSOR trig_cursor IS select owner,
				trigger_name, 
				trigger_type , 
				triggering_event, 
				'on '||table_owner,
				table_name,
				referencing_names,
				'when '||when_clause,
				trigger_body
			from dba_triggers 
			where owner not in ('SYS','SYSTEM')
			and table_name=upper('&tab_name')
			and owner=upper('&owner')
			order by trigger_name;
	cursor trig_col ( owner varchar2, name varchar2 ) is 
			select trigger_owner,
				trigger_name,
				column_name
			from dba_trigger_cols 
			where trigger_owner = owner and
				trigger_name = name;

	trig_owner      dba_triggers.owner%TYPE;
	trig_name       dba_triggers.trigger_name%TYPE;
	trig_type       dba_triggers.trigger_type%TYPE;
	trig_event      dba_triggers.triggering_event%TYPE;
	trig_towner     dba_triggers.table_owner%TYPE;
	trig_tname      dba_triggers.table_name%TYPE;
	trig_rnames     dba_triggers.referencing_names%TYPE;
	trig_wclause    dba_triggers.when_clause%TYPE;
	trig_body       dba_triggers.trigger_body%TYPE;   
	trig_col_own    dba_trigger_cols.trigger_owner%TYPE;
	trig_col_nam    dba_trigger_cols.trigger_name%TYPE;
	trig_column     dba_trigger_cols.column_name%TYPE;   
	all_columns     varchar2(400);
	counter         integer:=0;

BEGIN
   OPEN trig_cursor;
   LOOP
      FETCH trig_cursor INTO    trig_owner,
				trig_name,
				trig_type,
				trig_event,
				trig_towner,
				trig_tname,
				trig_rnames,
				trig_wclause,
				trig_body;
      EXIT WHEN trig_cursor%NOTFOUND;
	all_columns :='';       
	counter := 0;
	open trig_col(trig_owner,trig_name);
	loop
		fetch trig_col into
				     	trig_col_own,
					trig_col_nam,
					trig_column;
		exit when trig_col%NOTFOUND; 
			counter := counter+1;
			if counter = 1 then
			all_columns := ' of '||all_columns||trig_column;
			else
			all_columns := all_columns||', '||trig_column;
		end if;
	end loop;
	close trig_col;
	if trig_rnames = 'REFERENCING NEW AS NEW OLD AS OLD' then
		trig_rnames := '';
	end if;
	if trig_wclause = 'when ' then
		trig_wclause := '';
	end if;
	insert into trig_temp values (trig_owner,
				trig_name,
				trig_type,
				trig_event,
				trig_towner,
				trig_tname,
				trig_rnames,
				trig_wclause,
				trig_body,
				all_columns);
   END LOOP;
   CLOSE trig_cursor;
   commit;
END;
/
define cr='chr(10)'
spool rep_out\crt_trgs.sql
set heading off
set recsep off pages 0

select '/'||&&cr||&&cr||'create or replace trigger '||owner||'.'||trigger_name||&&cr||
decode(trigger_type,'BEFORE EACH ROW','BEFORE ',
		'AFTER EACH ROW','AFTER ',trigger_type)||triggering_event||&&cr||
trigger_columns||&&cr||
table_owner||'.'||table_name||' '||referencing_names||&&cr||
decode(trigger_type,'BEFORE EACH ROW','FOR EACH ROW',
		'AFTER EACH ROW','FOR EACH ROW','')||&&cr||
when_clause,
trigger_body
from trig_temp 
order by owner;
spool off
drop table trig_temp;   
set verify on feedback on termout on echo on pagesize 22
set heading on recsep on
clear columns
