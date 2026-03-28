/*  */
create or replace procedure update_it (rows IN NUMBER, tab_name IN VARCHAR2) AS
  cursor_name 	INTEGER;
  ret 		INTEGER;
  rowcount 	NUMBER:=1;
  maxrows 	NUMBER;
  temp_id	ROWID;
  i		INTEGER:=1;
  CURSOR proc_row(row NUMBER, maxr NUMBER) IS 
	SELECT idrow FROM temp_tab WHERE numrow BETWEEN row and maxr;
  sql_com 	VARCHAR2(100);
  new_date 	DATE;
  maxcount	NUMBER;
BEGIN
  --
  -- First clear out the temp_tab of old entries
  --
  sql_com:='TRUNCATE TABLE temp_tab';
  cursor_name:=DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(cursor_name,sql_com,dbms_sql.v7);
  ret:=DBMS_SQL.EXECUTE(cursor_name);
  DBMS_SQL.CLOSE_CURSOR(cursor_name);
  --
  -- Add the where clause for a specific retrieval at the end of the next command
  --
  sql_com:='INSERT INTO temp_tab SELECT rownum, rowid FROM '||tab_name;
  cursor_name:=DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(cursor_name,sql_com,dbms_sql.v7);
  ret:=DBMS_SQL.EXECUTE(cursor_name);
  DBMS_SQL.CLOSE_CURSOR(cursor_name);
  SELECT MAX(numrow) INTO maxcount FROM temp_tab;
  IF maxcount>0 THEN 
  maxrows:=rowcount+rows; 
  new_date:=sysdate+2;
  LOOP
	DBMS_OUTPUT.PUT_LINE('Rowcount:'||TO_CHAR(rowcount)||' Maxrows:'||TO_CHAR(maxrows));
	OPEN proc_row(rowcount,maxrows);
	FETCH proc_row into temp_id;
	LOOP
	EXIT WHEN proc_row%NOTFOUND;
		sql_com:='UPDATE '||tab_name||'
			SET entry_ts='||chr(39)||new_date||chr(39)||'
			WHERE rowid='||chr(39)||temp_id||chr(39);
		cursor_name:=DBMS_SQL.OPEN_CURSOR;
		DBMS_SQL.PARSE(cursor_name,sql_com,dbms_sql.v7);
		ret:=DBMS_SQL.EXECUTE(cursor_name);
		DBMS_SQL.CLOSE_CURSOR(cursor_name);
		rowcount:=rowcount+1;
		FETCH proc_row INTO TEMP_ID;
		DBMS_OUTPUT.PUT_LINE(to_char(rowcount));
	END LOOP;
	CLOSE proc_row;
	COMMIT;
 	maxrows:=rowcount+rows;
  	IF rowcount=maxcount+1 
	THEN 
		EXIT;
	END IF;
  END LOOP;
  END IF;
END;
