/*  */
create or replace PROCEDURE get_count (
 	tab_name  IN VARCHAR2, 
	rows OUT NUMBER
)  AS
  cur     INTEGER;
  ret     INTEGER;
 com_string   VARCHAR2(100);
 row_count      NUMBER;
BEGIN
 com_string :=
  'SELECT count(1) row_count FROM '||tab_name;
 cur := DBMS_SQL.OPEN_CURSOR;
 DBMS_SQL.PARSE(cur,com_string,dbms_sql.v7);
 DBMS_SQL.DEFINE_COLUMN(cur, 1, row_count);
 ret := DBMS_SQL.EXECUTE(cur);
 ret := DBMS_SQL.FETCH_ROWS(cur);
 DBMS_SQL.COLUMN_VALUE(cur, 1, row_count);
 DBMS_SQL.CLOSE_CURSOR(cur);
 DBMS_OUTPUT.PUT_LINE('Count='||TO_CHAR(row_count));
 rows:=row_count;
EXCEPTION
WHEN others THEN
null;
END;
