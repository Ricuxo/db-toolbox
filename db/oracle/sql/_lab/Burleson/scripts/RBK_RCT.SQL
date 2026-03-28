/*  */
REM
REM rbk_rct.sql
REM
REM FUNCTION: SCRIPT FOR CREATING ROLLBACK SEGMENTS
REM
REM This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM 
REM Running this script will in turn create a script to re-build 
REM the database rollback segments.  The created script is called 
REM create_rollback_segs.sql and can be run by any user with the DBA 
REM role or with the 'CREATE ROLLBACK SEGMENT' system privilege.
REM
REM NOTE:  This script will NOT capture the optimal storage for 
REM        a rollback segment that is offline.
REM 
REM        The rollback segments must be manually brought back online 
REM        after running the create_rollback_segs.sql script.
REM
REM        Only preliminary testing of this script was performed.  Be 
REM        sure to test it completely before relying on it.
REM
 
set verify off
set feedback off
set termout off
set echo off
set pagesize 0
 
set termout on
select 'Creating rollback segment build script...' from dual;
rem set termout off
 
create table rb_temp (lineno NUMBER, rb_name varchar2(30),
		    text varchar2(800))
/
 
DECLARE
   CURSOR rb_cursor IS select segment_name,
			      tablespace_name,
			      decode (owner, 'PUBLIC', 'PUBLIC ', NULL),
			      segment_id,
			      initial_extent,
			      next_extent,
			      min_extents,
			      max_extents, 
			      status
		       from sys.dba_rollback_segs 
			      where segment_name <> 'SYSTEM';
   CURSOR rb_optimal (r_no number) IS select usn,
			       decode(optsize, null, 'NULL', to_char(optsize))
			from sys.v_$rollstat
			       where usn=r_no;
   lv_segment_name        sys.dba_rollback_segs.segment_name%TYPE;
   lv_tablespace_name     sys.dba_rollback_segs.tablespace_name%TYPE;
   lv_owner               VARCHAR2(10);
   lv_segment_id          sys.dba_rollback_segs.segment_id%TYPE;
   lv_initial_extent      sys.dba_rollback_segs.initial_extent%TYPE;
   lv_next_extent         sys.dba_rollback_segs.next_extent%TYPE;
   lv_min_extents         sys.dba_rollback_segs.min_extents%TYPE;
   lv_max_extents         sys.dba_rollback_segs.max_extents%TYPE;
   lv_status              sys.dba_rollback_segs.status%TYPE;
   lv_usn                 sys.v_$rollstat.usn%TYPE;
   lv_optsize             VARCHAR2(40);
   lv_string              VARCHAR2(800);
   lv_lineno            number := 0;
 
   procedure write_out(p_line INTEGER, p_name VARCHAR2, p_string VARCHAR2) is
   begin
       insert into rb_temp (lineno, rb_name, text) values 
	      (p_line, p_name, p_string); 
   end;
 
BEGIN
  OPEN rb_cursor;
  LOOP
     FETCH rb_cursor INTO lv_segment_name,
			  lv_tablespace_name,
			  lv_owner,
			  lv_segment_id,
			  lv_initial_extent,
			  lv_next_extent,
			  lv_min_extents,
			  lv_max_extents,
			  lv_status;
     EXIT WHEN rb_cursor%NOTFOUND;
      lv_lineno := 1;
  OPEN rb_optimal(lv_segment_id);
  LOOP
     FETCH rb_optimal INTO lv_usn,
			   lv_optsize;
     EXIT WHEN rb_optimal%NOTFOUND;           
  END LOOP;
  CLOSE rb_optimal;
if lv_status = 'ONLINE' then
lv_string:='CREATE ' || lv_owner || 'ROLLBACK SEGMENT ' || 
	     lower(lv_segment_name);
write_out(lv_lineno, lv_segment_name, lv_string);
lv_lineno := lv_lineno + 1;
lv_string:='TABLESPACE ' || lower(lv_tablespace_name);
write_out(lv_lineno, lv_segment_name, lv_string);
lv_lineno := lv_lineno + 1;
lv_string:='STORAGE ' || '(INITIAL ' || lv_initial_extent || ' NEXT ' || 
	     lv_next_extent || ' MINEXTENTS ' || lv_min_extents ||
	     ' MAXEXTENTS ' || lv_max_extents ||
	     ' OPTIMAL ' || lv_optsize || ')' ;
write_out(lv_lineno, lv_segment_name, lv_string);
lv_lineno := lv_lineno + 1;
lv_string:='/';
write_out(lv_lineno, lv_segment_name, lv_string);
else
lv_string:='CREATE ' || lv_owner || 'ROLLBACK SEGMENT ' || 
	     lower(lv_segment_name);
write_out(lv_lineno, lv_segment_name, lv_string);
lv_lineno := lv_lineno + 1;
lv_string:='TABLESPACE ' || lower(lv_tablespace_name);
write_out(lv_lineno, lv_segment_name, lv_string);
lv_lineno := lv_lineno + 1;
lv_string:='STORAGE ' || '(INITIAL ' || lv_initial_extent || ' NEXT ' ||
	     lv_next_extent || ' MINEXTENTS ' || lv_min_extents ||
	     ' MAXEXTENTS ' || lv_max_extents || ')' ;
write_out(lv_lineno, lv_segment_name, lv_string);
lv_lineno := lv_lineno + 1;
lv_string:='/';
write_out(lv_lineno, lv_segment_name, lv_string);
end if;
lv_lineno := lv_lineno + 1;
lv_string:='                                                  ';
write_out(lv_lineno, lv_segment_name, lv_string);
END LOOP;
  CLOSE rb_cursor;
END;
/   
 column dbname new_value db noprint
select value dbname from v$parameter where name='db_name';
spool rep_out\&db\crt_rbks.sql
 
set heading off
col text format a80 word_wrap
 
select   text
from     rb_temp
order by rb_name, lineno;
 
spool off;
 
Drop table rb_temp;
set verify on
set feedback on
set termout on
set pagesize 22
set lines 80
clear columns
 set heading on
