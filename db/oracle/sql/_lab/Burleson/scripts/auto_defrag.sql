/*  */
create or replace  view free_space (
	tablespace, 
	file_id, 
	pieces, 
	free_bytes, 
	free_blocks, 
	largest_bytes,
	largest_blks,
	fsfi) 
as
select 
	tablespace_name, 
	file_id, 
	count(*),
	sum(bytes), 
	sum(blocks),
	max(bytes), 
	max(blocks),
	sqrt(max(blocks)/sum(blocks))*(100/sqrt(sqrt(count(blocks)))) 
from 
	sys.dba_free_space
group by 
	tablespace_name, 
	file_id
/
create table dba_running_stats (
NAME VARCHAR2(64),
VALUE NUMBER,
REP_ORDER NUMBER,
MEAS_DATE DATE,
delta number)
storage(initial 1m next 1m pctincrease 0)
/
CREATE OR REPLACE PROCEDURE auto_defrag AS
CURSOR get_frags IS
	SELECT 
		tablespace,
		COUNT(tablespace), 
		SUM(pieces)
	FROM free_space
	GROUP BY tablespace;
pieces		NUMBER;
files		NUMBER;
tbname		VARCHAR2(64);
sql_stmt	VARCHAR2(255);
cur		INTEGER;
rows		INTEGER;
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
BEGIN
OPEN get_frags;
LOOP
	FETCH get_frags INTO tbname,files,pieces;
	EXIT WHEN get_frags%NOTFOUND;
	IF pieces>files 
	THEN
	  BEGIN
		write_out('defragmenting '||tbname,pieces,99,sysdate,0);
		dbms_output.put_line('defragmenting '||tbname||' pieces:'||to_char(pieces));
		cur:=dbms_sql.open_cursor;
		sql_stmt:='alter tablespace '||tbname||' coalesce';
		dbms_sql.parse(cur,sql_stmt,dbms_sql.v7);
		rows:=dbms_sql.execute(cur);
		dbms_sql.close_cursor(cur);
	  EXCEPTION
		WHEN OTHERS THEN
		write_out('error during defrag of '||tbname,pieces,99,sysdate,0);
		dbms_output.put_line('error defragmenting '||tbname||' error:'||to_char(sqlcode));
	  END;
	END IF;
	COMMIT;
END LOOP;
END auto_defrag;
/
Declare
x number;
begin
dbms_job.submit(x,'begin auto_defrag; end;',trunc(sysdate)+1,'trunc(sysdate+1)');
end;
/
