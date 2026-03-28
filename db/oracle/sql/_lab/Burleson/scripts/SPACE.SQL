/*  */
create or replace procedure space as
 CURSOR datafile1 IS
  SELECT tablespace_name, file_id, max(bytes) largeextent,
    sum(bytes) totalfreespace
    FROM sys.dba_free_space
    GROUP BY tablespace_name, file_id
    ORDER BY tablespace_name, file_id;
 CURSOR datafile2 (fileid INTEGER) IS
  SELECT name, bytes
    FROM v$datafile
    WHERE file# = fileid;
dbname VARCHAR2(8);
BEGIN
SELECT name INTO dbname
  FROM v$database;
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Space Report for Database '||dbname);
DBMS_OUTPUT.PUT_LINE('-----------------------------------');
DBMS_OUTPUT.PUT_LINE('');
FOR file IN datafile1 LOOP
  DBMS_OUTPUT.PUT_LINE('Tablespace Name:           '
  ||file.tablespace_name);
--DBMS output...Name:'|file...         < commented out.  didn't pass syntax check.
  DBMS_OUTPUT.PUT_LINE('');
  FOR filedata IN datafile2 (file.file_id) LOOP
    DBMS_OUTPUT.PUT_LINE('Data File Name:              '
      ||filedata.name);
    DBMS_OUTPUT.PUT_LINE('Total File Size (KB):        '
      ||ROUND(filedata.bytes/1024,0));
    DBMS_OUTPUT.PUT_LINE('Free Space in File (KB):     '
      ||ROUND(file.totalfreespace/1024,0));
    DBMS_OUTPUT.PUT_LINE('% Free Space in File:        '
      ||ROUND(((file.totalfreespace/filedata.bytes)*100),0)||'%');
    DBMS_OUTPUT.PUT_LINE('Largest Extent (KB):      '
      ||ROUND(file.largeextent/1024,0));
    DBMS_OUTPUT.PUT_LINE('');
  END LOOP;
END LOOP;
END;
/
