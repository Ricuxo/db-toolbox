/*  */
CREATE OR REPLACE PROCEDURE flush_it ( pct_full IN NUMBER) AS
--
-- Cursor definitions
--
CURSOR get_share IS
 SELECT SUM(sharable_mem) FROM
  sql_summary;
--
CURSOR get_var IS
 SELECT value FROM v$sga WHERE name LIKE 'Var%';
--
CURSOR get_time IS 
 SELECT sysdate FROM dual;
--
-- Variable definitions
--
	todays_date DATE;
	mem_ratio 	NUMBER;
	share_mem 	NUMBER;
	variable_mem NUMBER;
	cur 		INTEGER;
	sql_com 	VARCHAR2(60);
	row_proc 	NUMBER;
--
-- Procedure Body
--
BEGIN
 OPEN get_share;
 OPEN get_var;
 FETCH get_share INTO share_mem;
dbms_output.put_line('share_mem: '||to_char(share_mem));
 FETCH get_var INTO variable_mem;
dbms_output.put_line('variable_mem: '||to_char(variable_mem));
 mem_ratio:=share_mem/variable_mem;
dbms_output.put_line(to_char(mem_ratio));
 IF mem_ratio>(pct_full/100) THEN
  cur:=dbms_sql.open_cursor;
  sql_com:='ALTER SYSTEM FLUSH SHARED_POOL';
  dbms_sql.parse(cur,sql_com,dbms_sql.v7);
  row_proc:=dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
  OPEN get_time;
  FETCH get_time INTO todays_date;
  INSERT INTO dba_running_stats VALUES 
	(
	'Flush of Shared Pool',1,35,todays_date,0
	);
  COMMIT;
 END IF;
END;
