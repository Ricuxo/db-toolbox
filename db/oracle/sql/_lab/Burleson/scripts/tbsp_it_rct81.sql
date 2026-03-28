/*  */
CREATE OR REPLACE PROCEDURE RCT_IT_TBSP AS
lineno_count INTEGER;
file_handle UTL_FILE.FILE_TYPE;
--
TYPE ts_temp IS TABLE OF VARCHAR2(2048)
 INDEX BY BINARY_INTEGER;
ts_table TS_TEMP;
--
   CURSOR get_block IS
     SELECT value 
          FROM v$parameter 
          WHERE name='db_block_size';
   CURSOR ts_cursor IS 
     SELECT   tablespace_name,
              initial_extent,
              next_extent,
              min_extents,
              max_extents,
              pct_increase,
              min_extlen,
              logging,
              status,
              contents,
              extent_management,
              allocation_type,
              contents
            FROM    sys.dba_tablespaces
            WHERE tablespace_name != 'SYSTEM'
                  AND status != 'INVALID'
            ORDER BY tablespace_name;
   CURSOR df_cursor (c_ts VARCHAR2) IS 
     SELECT
               file_name,
               bytes,
               autoextensible,
               maxbytes,
               increment_by
      FROM     sys.dba_data_files
      WHERE    tablespace_name = c_ts
               and tablespace_name != 'SYSTEM'
      ORDER BY file_name;
--
   block_size           NUMBER;
   lv_tablespace_name   sys.dba_tablespaces.tablespace_name%TYPE;
   lv_initial_extent    sys.dba_tablespaces.initial_extent%TYPE;
   lv_next_extent       sys.dba_tablespaces.next_extent%TYPE;
   lv_min_extents       sys.dba_tablespaces.min_extents%TYPE;
   lv_max_extents       sys.dba_tablespaces.max_extents%TYPE;
   lv_pct_increase      sys.dba_tablespaces.pct_increase%TYPE;
   lv_status            sys.dba_tablespaces.status%TYPE;
   lv_file_name         sys.dba_data_files.file_name%TYPE;
   lv_bytes             sys.dba_data_files.bytes%TYPE;
   lv_max_extend        sys.dba_data_files.maxbytes%TYPE;
   lv_ext_incr          sys.dba_data_files.increment_by%TYPE;
   lv_autoext           sys.dba_data_files.autoextensible%TYPE;
   lv_contents          sys.dba_tablespaces.contents%TYPE;
   lv_first_rec         BOOLEAN;
   lv_string            VARCHAR2(800);
   lv_lineno            NUMBER := 0;
   lv_min_extlen        sys.dba_tablespaces.min_extlen%TYPE;
   lv_logging           sys.dba_tablespaces.logging%TYPE;
   lv_extent_man        sys.dba_tablespaces.extent_management%TYPE;
   lv_allocation        sys.dba_tablespaces.allocation_type%TYPE;
   sub_strg             VARCHAR2(20); 
PROCEDURE write_out(
                 p_string VARCHAR2) IS
   BEGIN
    SELECT lineno_seq.nextval into lineno_count from dual;
    SELECT p_string INTO ts_table (lineno_count)
    FROM dual; 
    dbms_output.put_line(p_string);
   END;
BEGIN
   OPEN get_block;
   FETCH get_block INTO block_size;
   CLOSE get_block;
   OPEN ts_cursor;
   LOOP
      FETCH ts_cursor INTO lv_tablespace_name,
              Lv_initial_extent,
              Lv_next_extent,
              Lv_min_extents,
              Lv_max_extents,
              Lv_pct_increase,
              Lv_min_extlen,
              Lv_logging,
              Lv_status,
              Lv_contents,
              Lv_extent_man,
              Lv_allocation,
              lv_contents;
      EXIT WHEN ts_cursor%NOTFOUND;
      lv_string := ('CREATE TABLESPACE '||lower(lv_tablespace_name));
      lv_first_rec := TRUE;
      write_out(lv_string);
      OPEN df_cursor(lv_tablespace_name);
      LOOP
         FETCH df_cursor INTO lv_file_name,
                              lv_bytes,
                              lv_autoext,
                              lv_max_extend,
                              lv_ext_incr;
         EXIT WHEN df_cursor%NOTFOUND;
         IF (lv_first_rec) THEN
            lv_first_rec := FALSE;
            lv_string := 'DATAFILE ';
         ELSE
            lv_string := lv_string || ',';
         END IF;
         lv_string:=lv_string||''''||lv_file_name||''''||
                    ' SIZE '||to_char(lv_bytes) || ' REUSE';
         IF lv_autoext='YES' THEN
          IF lv_max_extend=0 THEN 
               sub_strg:='MAXSIZE UNLIMITED';
          ELSE
               sub_strg:=' MAXSIZE '||TO_CHAR(lv_max_extend);
          END IF;
          IF lv_ext_incr != 0 THEN
           lv_string:=lv_string||chr(10)||' AUTOEXTEND ON NEXT '||
           to_char(lv_ext_incr*block_size)||sub_strg;
          END IF;
         END IF;
         IF lv_min_extlen != 0 AND lv_extent_man!='LOCAL' THEN
           lv_string:=lv_string||chr(10)||
          'MINIMUM EXTENT '||TO_CHAR(lv_min_extlen);
         END IF;
      END LOOP;
      CLOSE df_cursor;
         write_out(lv_string);
         lv_string := ('   '||lv_contents);
         write_out(lv_string);
      IF lv_extent_man!='LOCAL' THEN
         lv_string := (' DEFAULT STORAGE (INITIAL ' ||
                      TO_CHAR(lv_initial_extent) ||
                      ' NEXT ' || lv_next_extent);
      ELSE
         Lv_string:=('EXTENT MANAGEMENT '||lv_extent_man);
       IF lv_allocation='UNIFORM' THEN
         Lv_string:=lv_string||' '||lv_extent_man||' SIZE '||lv_initial_extent;
       ELSE
         Lv_string:=lv_string||' AUTOALLOCATE';
       END IF;
      END IF;
         write_out(lv_string);
      IF lv_extent_man!='LOCAL' THEN
         lv_string := (' MINEXTENTS ' ||
                      lv_min_extents ||
                      ' MAXEXTENTS ' || lv_max_extents);
         write_out(lv_string);
         lv_string := (' PCTINCREASE ' ||
                      lv_pct_increase || ')');
         write_out(lv_string);
      END IF;
         lv_string := ('   '||lv_logging);
         write_out(lv_string);
         lv_string := ('   '||lv_status);
         write_out(lv_string);
         lv_string:='/';
         write_out(lv_string);
         lv_string:=chr(10);
         write_out(lv_string);
   END LOOP;
   CLOSE ts_cursor;
BEGIN
 file_handle:=UTL_FILE.FOPEN('d:\oracle\sql_scripts\','rebuild_tbsp81.sql','W',2048);
 FOR i in 1..lineno_count LOOP
  UTL_FILE.PUT_LINE(file_handle,ts_table(i));
  DBMS_OUTPUT.PUT_LINE(ts_table(i));
 END LOOP;
 UTL_FILE.FCLOSE(file_handle);
EXCEPTION
WHEN others THEN
UTL_FILE.FCLOSE(file_handle);
END;
BEGIN
dbms_output.put_line(to_char(lineno_count));
 FOR i in 1..lineno_count LOOP
  DBMS_OUTPUT.PUT_LINE(ts_table(i));
 END LOOP;
EXCEPTION
WHEN others THEN
dbms_output.put_line(sqlerrm);
END;
END;
/
show err
