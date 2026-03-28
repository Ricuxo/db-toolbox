/*  */
CREATE OR REPLACE PROCEDURE load_pool(pct_load IN NUMBER) as
cur_num INTEGER;
row_proc INTEGER;
SQL_TEXT VARCHAR2(2000);
test_val INTEGER;
numobjs INTEGER;
dummy INTEGER;
i INTEGER;
shared_val NUMBER;
pool_size NUMBER;
loop_ctr integer;
cursor get_share is
 select sum(bytes) from
  v$sgastat where pool='shared pool' and name <>'free memory';
cursor get_var is
 select value from v$parameter where name = 'shared_pool_size';
BEGIN
loop_ctr:=0;
SELECT MAX(object_id) INTO numobjs FROM DBA_OBJECTS;
LOOP
BEGIN
 FOR i IN 0..numobjs LOOP
  SELECT COUNT(*) INTO test_val 
   FROM dba_objects WHERE object_id=i;
  IF test_val=1 THEN
   sql_text:='SELECT count(*) FROM dba_objects WHERE object_id='||to_char(i)||
    ' AND '||to_char(loop_ctr)||'='||to_char(loop_ctr);
   cur_num:=dbms_sql.open_cursor;
   dbms_sql.parse(cur_num,sql_text,DBMS_SQL.NATIVE);
   dbms_sql.define_column(cur_num,1,dummy);
   row_proc:=dbms_sql.execute(cur_num);
   dbms_sql.close_cursor(cur_num);
   open get_share;
   open get_var;
   fetch get_share into shared_val;
   fetch get_var into pool_size;
   CLOSE get_share;
   CLOSE get_var;
     dbms_output.put_line('Shared pool size: '||to_char(shared_val/pool_size*100));
    IF (shared_val/pool_size)*100>=pct_load THEN
     dbms_output.put_line('Shared pool size: '||to_char(shared_val/pool_size*100));
     EXIT;
    END IF;
  END IF;
 END LOOP;
END;
    IF (shared_val/pool_size)*100>=pct_load THEN
     dbms_output.put_line('Shared pool size: '||to_char(shared_val/pool_size*100));
     EXIT;
    END IF;
loop_ctr:=loop_ctr+1;
END LOOP;
END;
