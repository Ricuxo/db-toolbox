/*  */
CREATE OR REPLACE PROCEDURE check_tables (owner_name in varchar2, pchng IN INTEGER) AS
--
CURSOR get_tab_count (own varchar2) IS
        SELECT table_name, nvl(num_rows,1) 
        FROM dba_tables
        WHERE owner = upper(own);
--
tab_name varchar2(32);
rows integer;
string varchar2(255);
cur integer;
ret integer;
row_count integer;
com_string varchar2(255);
--
BEGIN
OPEN get_tab_count (owner_name);
LOOP
        FETCH get_tab_count INTO tab_name, rows;
        if rows=0 then 
        rows:=1;
        end if;
EXIT WHEN get_tab_count%NOTFOUND;
dbms_output.put_line('Table name: '||tab_name||' rows: '||to_char(rows));
dba_utilities.get_count(upper(owner_name||'.'||tab_name),row_count);
   IF row_count=0 THEN
        row_count:=1;
   END IF;
dbms_output.put_line('Row count for '||tab_name||': '||to_char(row_count));
dbms_output.put_line('Ratio: '||to_char(row_count/rows));
        IF (row_count/rows)*100>100+pchng OR (rows/row_count)*100>100+pchng THEN
           string :=
                   'analyze table '||owner_name||'.'||tab_name||' compute statistics';
           cur := dbms_sql.open_cursor;
           dbms_sql.parse(cur,string,dbms_sql.v7);
           ret := dbms_sql.execute(cur)  ;
           dbms_sql.close_cursor(cur);
           dbms_output.put_line(' Table: '||tab_name||' had to be analyzed.');
        END IF;
END LOOP;
CLOSE get_tab_count;
--
EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20002,'Error in analyze: '||to_char(sqlcode)||' on '||tab_name,TRUE);
      IF dbms_sql.is_open(cur) THEN
        dbms_sql.close_cursor(cur);
      END IF;
END;
/

