/*  */
CREATE OR REPLACE PROCEDURE flush_it(
    p_free IN NUMBER, num_runs IN NUMBER) IS
--
CURSOR get_share IS
SELECT 
  LEAST(MAX(b.value)/(1024*1024),SUM(a.bytes)/(1024*1024))
   FROM v$sgastat a, v$parameter b
 WHERE (a.pool='shared pool'
 AND a.name <> ('free memory'))
 AND b.name = 'shared_pool_size';
--
CURSOR get_var IS
 SELECT  value/(1024*1024) 
 FROM v$parameter
 WHERE name = 'shared_pool_size';
--
CURSOR get_time IS 
 SELECT sysdate FROM dual;
--
-- Following cursors from Steve Adams Nice_flush
--
  CURSOR reused_cursors IS
    SELECT address || ',' || hash_value
    FROM sys.v_$sqlarea
    WHERE executions > num_runs;
  cursor_string varchar2(30);
--
  CURSOR cached_sequences IS
    SELECT  sequence_owner, sequence_name
    FROM  sys.dba_sequences
    WHERE cache_size > 0;
  sequence_owner varchar2(30);
  sequence_name varchar2(30);
--
  CURSOR candidate_objects IS
    SELECT kglnaobj, decode(kglobtyp, 6, 'Q', 'P')
    FROM sys.x_$kglob
    WHERE inst_id = userenv('Instance') AND
      kglnaown = 'SYS' AND kglobtyp in (6, 7, 8, 9);
  object_name varchar2(128);
  object_type char(1);
--
-- end of Steve Adams Cursors
--
  todays_date 	DATE;
  mem_ratio 	NUMBER;
  share_mem 	NUMBER;
  variable_mem 	NUMBER;
  cur 		INTEGER;
  sql_com 	VARCHAR2(60);
  row_proc 	NUMBER;
--
BEGIN
 OPEN get_share;
 OPEN get_var;
 FETCH get_share INTO share_mem;
 FETCH get_var INTO variable_mem;
 mem_ratio:=share_mem/variable_mem;
 IF mem_ratio>p_free/100 THEN
 --
 -- Following keep sections from Steve Adams nice_flush
 --
 BEGIN
  OPEN reused_cursors;
  LOOP
    FETCH reused_cursors INTO cursor_string;
    EXIT WHEN reused_cursors%notfound;   
    sys.dbms_shared_pool.keep(cursor_string, 'C');
  END LOOP;
 END;   
 BEGIN
  OPEN cached_sequences;
  LOOP
    FETCH cached_sequences INTO sequence_owner, sequence_name;
    EXIT WHEN cached_sequences%notfound;   
    sys.dbms_shared_pool.keep(sequence_owner || '.' || sequence_name, 'Q');
  END LOOP;
 END;   
 BEGIN
  OPEN candidate_objects;
  LOOP
    FETCH candidate_objects INTO object_name, object_type;
    EXIT WHEN candidate_objects%notfound;   
    sys.dbms_shared_pool.keep('SYS.' || object_name, object_type);
  END LOOP;
 END;   
 --
 -- end of Steve Adams section
 --
  cur:=DBMS_SQL.OPEN_CURSOR;
  sql_com:='ALTER SYSTEM FLUSH SHARED_POOL';
  DBMS_SQL.PARSE(cur,sql_com,dbms_sql.v7);
  row_proc:=DBMS_SQL.EXECUTE(cur);
  DBMS_SQL.CLOSE_CURSOR(cur);
  OPEN get_time;
  FETCH get_time INTO todays_date;
  INSERT INTO dba_running_stats VALUES 
	(
	'Flush of Shared Pool',1,35,todays_date,0
	);
  COMMIT;
 END IF;
END flush_it;
