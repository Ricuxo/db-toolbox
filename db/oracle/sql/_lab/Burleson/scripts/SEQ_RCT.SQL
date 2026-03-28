/*  */
REM
REM    FUNCTION: SCRIPT FOR RE-CREATING DATABASE SEQUENCES
REM
REM              This script must be run by 'SYS'.  
REM 
REM
REM              Running this script will in turn create a script to 
REM              build all the sequences in the database.  This created 
REm              script is called 'create_sequences.sql'.
REM 
REM              This script will start the sequence (start with value) 
REM              at the last value of the sequence at the time the 
REM              script is run (LAST_NUMBER).
REM
REM
REM Only preliminary testing of this script was performed.  Be sure to test 
REM it completely before relying on it.  
REM
 
set verify off
set feedback off
rem set termout off
set echo off
set pagesize 0
define cr='chr(10)'
 
set termout on
select 'Creating sequence build script...' from dual;
rem set termout off
 
create table seq_temp (grantor_owner varchar2(30),
text VARCHAR2(255))
/ 
DECLARE
   CURSOR seq_cursor IS select   sequence_owner,
				  sequence_name, 
				  min_value, 
				  max_value, 
				 increment_by,
				decode(cycle_flag,'Y','CYCLE','NOCYCLE'),
				decode(order_flag,'Y','ORDER','NOORDER'),
	decode(to_char(cache_size),'0','NOCACHE','CACHE '||to_char(cache_size)),
				last_number
			  from dba_sequences 
			where sequence_owner not in ('SYS','SYSTEM')
			 order by sequence_owner; 
	seq_owner       dba_sequences.sequence_owner%TYPE;
	seq_name        dba_sequences.sequence_name%TYPE;
	seq_min         dba_sequences.min_value%TYPE;
	seq_max         dba_sequences.max_value%TYPE;
	seq_inc         dba_sequences.increment_by%TYPE;
	seq_order       VARCHAR2(7);
	seq_cycle       VARCHAR2(7);
	seq_cache       VARCHAR2(15);
	seq_lnum        dba_sequences.last_number%TYPE;   
	seq_string     VARCHAR2(255);
   procedure write_out(p_string VARCHAR2) is
   begin
      insert into seq_temp (grantor_owner,text) 
			values (seq_owner,p_string);
   end;
 
BEGIN
   OPEN seq_cursor;
   LOOP
      FETCH seq_cursor INTO     seq_owner,
				seq_name,
				seq_min,
				seq_max,
				seq_inc,
				seq_order,
				seq_cycle,
				seq_cache,
				seq_lnum;
      EXIT WHEN seq_cursor%NOTFOUND;
	seq_string:=('DROP SEQUENCE '||seq_owner||'.'||seq_name||';'||$$cr||
			'CREATE SEQUENCE '||seq_owner||'.'||seq_name||&&cr||
				'INCREMENT BY '||seq_inc||&&cr||
				'START WITH '||seq_lnum||&&cr||
				'MAXVALUE '||seq_max||&&cr||
				'MINVALUE '||seq_min||&&cr||
				seq_cycle||&&cr|| 
				seq_cache||&&cr||
				seq_order||';');   
write_out(seq_string);
   END LOOP;
   CLOSE seq_cursor;
END;
/
 col dbname new_value db noprint
select name dbname from v$database;
spool &db_crt_seqs.sql
break on downer skip 1
col text format a60 word_wrap
col downer noprint 
select    grantor_owner downer,text
from     seq_temp 
order by downer 
/
spool off
 
drop table seq_temp;
 set termout on verify on feedback on
clear columns
clear breaks
prompt Finished build
