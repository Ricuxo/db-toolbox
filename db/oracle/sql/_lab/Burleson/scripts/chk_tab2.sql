/*  */
-- You may need to comment out the write_out procedue and subsequent
-- calls to it, I like to track what tables need analysis
-- pchng -- this is the percent change threshold for analysis, any table whose 
-- row count increases or decreases by this percent will be analyzed
-- lim_rows -- this sets the threshold for compute verses analyze, anything 
-- over lim_rows in size will be estimated at 30%.
--
CREATE OR REPLACE PROCEDURE check_tables (owner_name in varchar2, 
                                          pchng IN NUMBER,  
                                          lim_rows IN NUMBER) AS
--
CURSOR get_tab_count (own varchar2) IS
        SELECT table_name, nvl(num_rows,1) 
        FROM dba_tables
        WHERE owner = upper(own);
--
tab_name 	VARCHAR2(64);
rows 		NUMBER;
string 		VARCHAR2(255);
cur 		INTEGER;
ret 		INTEGER;
row_count 	NUMBER;
com_string 	VARCHAR2(255);
--
PROCEDURE write_out(
  par_name  IN VARCHAR2,
  par_value IN NUMBER, 
  rep_ord   IN NUMBER, 
  m_date    IN DATE,
  par_delta IN NUMBER) IS
 BEGIN
  INSERT INTO dba_running_stats VALUES(
   par_name,par_value,rep_ord,m_date,par_delta
  );
 END;
--
BEGIN
DBMS_SESSION.SET_CLOSE_CACHED_OPEN_CURSORS(TRUE);
OPEN get_tab_count (owner_name);
LOOP
BEGIN
        FETCH get_tab_count INTO tab_name, rows;
        tab_name:=owner_name||'.'||tab_name;
        IF rows=0 THEN 
        rows:=1;
        END IF;
EXIT WHEN get_tab_count%NOTFOUND;
DBMS_OUTPUT.PUT_LINE('Table name: '||tab_name||' rows: '||to_char(rows));
--
-- Need to have created the get_count procedure in the same schema
--
GET_COUNT(tab_name,row_count);
   IF row_count=0 THEN
        row_count:=1;
   END IF;
DBMS_OUTPUT.PUT_LINE('Row count for '||tab_name||': '||to_char(row_count));
DBMS_OUTPUT.PUT_LINE('Ratio: '||to_char(row_count/rows));
        IF (row_count/rows)>1+(pchng/100) OR (rows/row_count)>1+(pchng/100) THEN
               BEGIN
	IF (row_count<lim_rows) THEN
           		string :=
              		     'ANALYZE TABLE '||tab_name||' COMPUTE STATISTICS ';
	ELSE
		string :=
	 'ANALYZE TABLE '||tab_name||' ESTIMATE STATISTICS SAMPLE 30 PERCENT';
	END IF;
           cur := DBMS_SQL.OPEN_CURSOR;
DBMS_OUTPUT.PUT_LINE('Beginning analysis');
           DBMS_SQL.PARSE(cur,string,dbms_sql.native);
           ret := DBMS_SQL.EXECUTE(cur)  ;
           DBMS_SQL.CLOSE_CURSOR(cur);
           DBMS_OUTPUT.PUT_LINE(' Table: '||tab_name||' had to be analyzed.');
           write_out(' Table: '||tab_name||' had to be analyzed.', row_count/rows,33,sysdate,0);
           EXCEPTION
           WHEN OTHERS THEN
            raise_application_error(-20002,'Error in analyze: '||to_char(sqlcode)||' on '||tab_name,TRUE);
           write_out(' Table: '||tab_name||' error during analyze. '||to_char(sqlcode), row_count/rows,33,sysdate,0);
            IF dbms_sql.is_open(cur) THEN
                dbms_sql.close_cursor(cur);
              END IF;
           END;
        END IF;
EXCEPTION
WHEN others THEN
null;
END;
COMMIT;
END LOOP;
CLOSE get_tab_count;
END;
