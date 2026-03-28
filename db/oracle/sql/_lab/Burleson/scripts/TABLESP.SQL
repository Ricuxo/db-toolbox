/*  */
REM 
REM  FUNCTION: SCRIPT FOR CREATING TABLESPACES
REM
REM  FUNCTION: This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM FUNCTION: Running this script will in turn create a script to build all the
REM FUNCTION: tablespaces in the database.  This created script, 
REM FUNCTION: create_tablespaces.sql, can be run by any user with the DBA role 
REM FUNCTION: or with the 'CREATE TABLESPACE' system privilege.
REM
REM Only preliminary testing of this script was performed.  Be sure to test
REM it completely before relying on it.
REM
 
set verify off;
set termout off;
set feedback off;
set echo off;
set pagesize 0;
 
set termout on;
select 'Creating tablespace build script...' from dual;
set termout off;
 
create table ts_temp (lineno number, ts_name varchar2(30),
                    text varchar2(800))
/ 
DECLARE
   CURSOR ts_cursor IS select   tablespace_name,
                                initial_extent,
                                next_extent,
                                min_extents,
                                max_extents,
                                pct_increase,
                                status
                        from    sys.dba_tablespaces
                        where tablespace_name != 'SYSTEM'
                        and status != 'INVALID'
                        order by tablespace_name;
   CURSOR df_cursor (c_ts VARCHAR2) IS select   file_name,
                                                bytes
                                       from     sys.dba_data_files
                                       where    tablespace_name = c_ts
                                         and    tablespace_name != 'SYSTEM'
                                       order by file_name;
   lv_tablespace_name   sys.dba_tablespaces.tablespace_name%TYPE;
   lv_initial_extent    sys.dba_tablespaces.initial_extent%TYPE;
   lv_next_extent       sys.dba_tablespaces.next_extent%TYPE;
   lv_min_extents       sys.dba_tablespaces.min_extents%TYPE;
   lv_max_extents       sys.dba_tablespaces.max_extents%TYPE;
   lv_pct_increase      sys.dba_tablespaces.pct_increase%TYPE;
   lv_status            sys.dba_tablespaces.status%TYPE;
   lv_file_name         sys.dba_data_files.file_name%TYPE;
   lv_bytes             sys.dba_data_files.bytes%TYPE;
   lv_first_rec         BOOLEAN;
   lv_string            VARCHAR2(800);
   lv_lineno            number := 0;
 
   procedure write_out(p_line INTEGER, p_name VARCHAR2, 
             p_string VARCHAR2) is
   begin
     insert into ts_temp (lineno, ts_name, text) values 
            (p_line, p_name, p_string);
   end;
 
BEGIN
   OPEN ts_cursor;
   LOOP
      FETCH ts_cursor INTO lv_tablespace_name,
                           lv_initial_extent,
                           lv_next_extent,
                           lv_min_extents,
                           lv_max_extents,
                           lv_pct_increase,
                           lv_status;
      EXIT WHEN ts_cursor%NOTFOUND;
      lv_lineno := 1;
      lv_string := ('CREATE TABLESPACE '||lower(lv_tablespace_name));
      lv_first_rec := TRUE;
      write_out(lv_lineno, lv_tablespace_name, lv_string);
      OPEN df_cursor(lv_tablespace_name);
      LOOP
         FETCH df_cursor INTO lv_file_name,
                              lv_bytes;
         EXIT WHEN df_cursor%NOTFOUND;
         if (lv_first_rec) then
            lv_first_rec := FALSE;
            lv_string := 'DATAFILE ';
         else
            lv_string := lv_string || ',';
         end if;
         lv_string:=lv_string||''''||lv_file_name||''''||
                    ' SIZE '||to_char(lv_bytes) || ' REUSE';
      END LOOP;
      CLOSE df_cursor;
         lv_lineno := lv_lineno + 1;
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
         lv_string := (' DEFAULT STORAGE (INITIAL ' ||
                      to_char(lv_initial_extent) ||
                      ' NEXT ' || lv_next_extent);
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
         lv_string := (' MINEXTENTS ' ||
                      lv_min_extents ||
                      ' MAXEXTENTS ' || lv_max_extents);
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
         lv_string := (' PCTINCREASE ' ||
                      lv_pct_increase || ')');
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_string := ('   '||lv_status);
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
         lv_string:='/';
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
         lv_string:='                                                  ';
         write_out(lv_lineno, lv_tablespace_name, lv_string);
   END LOOP;
   CLOSE ts_cursor;
END;
/
 column name new_value db noprint
select name from v$database;
spool rep_out\&db\cre_tbsp.sql
set heading off
set recsep off
col text format a80 word_wrap
 
 
select   text
from     ts_temp
order by ts_name, lineno;
 
spool off;
 
drop table ts_temp;
set verify on
set termout on
set feedback on
set echo on
set recsep on
set heading on
set pagesize 22 lines 80
clear columns
