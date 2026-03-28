/*  */
/* cal_stat.sql */
/* FUNCTION: PLSQL script cal_stat.sql, used by do_calst.sql*/
create or replace procedure calculate_statistics as
	jdate date;
	jsec number;
	hr number;
	minute number;
	sec1 number;
	sec2 number;
	sec number;
	startup_date varchar2(64);
    dd_ratio number := 0; 
    R_CALLS NUMBER  := 0; 
    H_RATIO NUMBER  := 0; 
    SUHW_CONT  NUMBER  := 0;
    SUBW_CONT  NUMBER  := 0;
    UHW_CONT   NUMBER  := 0;
    UBW_CONT   NUMBER  := 0; 
    DB_GETS NUMBER  := 0; 
    CON_GETS NUMBER := 0; 
    P_READS NUMBER  := 0; 
    SUH_WAITS NUMBER := 0;
    SUB_WAITS NUMBER := 0; 
    UH_WAITS NUMBER := 0; 
    UB_WAITS NUMBER := 0;  
    U_CALLS NUMBER  := 0; 
    CALLS_U NUMBER  := 0; 
    RLOG_WAIT NUMBER := 0; 
    STAT_NAME varCHAR2(64); 
    TEMP_NAME varCHAR2(64); 
    STAT_VAL NUMBER := 0;
    temp_value number := 0; 
BEGIN 
  DELETE DBA_TEMP;
begin
	select to_date(to_number(value,'99999999'),'J') into jdate from
		v$instance where key='STARTUP TIME - JULIAN';
	select (to_number(value,'9999999')) into jsec from v$instance
		where key='STARTUP TIME - SECONDS';
	hr:=trunc(jsec/3600,0);
	minute:= trunc(((jsec/3600)-hr)*60,0);
	sec:= trunc((((((jsec/3600)-hr)*60)-minute)*60),0);
	startup_date:=jdate||' '||to_char(hr)||':'||to_char(minute)||':'||
	to_char(sec);
	insert into dba_temp values ('Startup Date: '||startup_date,0,1);
EXCEPTION
    when no_data_found then
	insert into dba_temp values ('Startup Date: unknown',0,1);
end; 
begin
  STAT_NAME := 'recursive calls';
	select name,value into TEMP_name, temp_value
	from v$sysstat 
	where NAME = STAT_NAME;
   	r_calls:=temp_value;
EXCEPTION
    when no_data_found then
null;
end; 
begin  
  STAT_NAME := 'Data Dictionary Miss Percent'; 
	select stat_name, (sum(getmisses)/sum(gets))*100 into TEMP_name, dd_ratio 
	from v$rowcache; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, dd_ratio,17); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,17); 
    commit; 
end; 
begin 
  STAT_NAME := 'user calls'; 
	select name,value into TEMP_name, temp_value
	from v$sysstat 
	where NAME = STAT_NAME;
	u_calls:=temp_value;
EXCEPTION 
    when no_data_found then 
null;
end; 
begin 
  STAT_NAME := 'db block gets'; 
	select name,value into TEMP_name, temp_value
	from v$sysstat 
	where NAME = STAT_NAME;
	db_gets:=temp_value;
EXCEPTION 
    when no_data_found then 
null;
end; 
begin 
  STAT_NAME := 'consistent gets'; 
	select name,value into TEMP_name, temp_value
	from v$sysstat 
	where NAME = STAT_NAME;
	con_gets:=temp_value;
EXCEPTION 
    when no_data_found then 
null;
end; 
begin 
  STAT_NAME := 'physical reads'; 
	select name,value into TEMP_name, temp_value
	from v$sysstat 
	where NAME = STAT_NAME;
	p_reads:=temp_value;
EXCEPTION 
    when no_data_found then 
null;
end; 
begin 
  STAT_NAME := 'system undo header'; 
	select class,"COUNT" into TEMP_NAME, temp_value
	from v$waitstat  
	where CLASS = STAT_NAME; 
	suh_waits:=temp_value;
EXCEPTION 
    when no_data_found then 
null;
end; 
begin 
  STAT_NAME := 'system undo block'; 
	select class,"COUNT" into TEMP_NAME, temp_value
	from v$waitstat  
	where CLASS = STAT_NAME; 
	sub_waits:=temp_value;
EXCEPTION 
    when no_data_found then 
null;
end; 
begin 
  STAT_NAME := 'undo header'; 
	select class,"COUNT" into TEMP_NAME, temp_value
	from v$waitstat  
	where CLASS = STAT_NAME; 
	uh_waits:=temp_value;
EXCEPTION 
    when no_data_found then 
null;
end; 
begin 
  STAT_NAME := 'undo block'; 
	select class,"COUNT" into TEMP_NAME, temp_value
	from v$waitstat  
	where CLASS = STAT_NAME; 
	ub_waits:=temp_value;
EXCEPTION 
    when no_data_found then 
null;
end; 
begin 
    CALLS_U := (R_CALLS/U_CALLS); 
    H_RATIO := ((DB_GETS+CON_GETS)/(DB_GETS+CON_GETS+P_READS)); 
    SUHW_CONT  := (SUH_WAITS/(DB_GETS+CON_GETS)*100);
    SUBW_CONT  := (SUB_WAITS/(DB_GETS+CON_GETS)*100);
    UHW_CONT  := (UH_WAITS/(DB_GETS+CON_GETS)*100);
    UBW_CONT  := (UB_WAITS/(DB_GETS+CON_GETS)*100);
  STAT_NAME := 'RECURSIVE CALLS PER USER'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, CALLS_U,18); 
  STAT_NAME := 'CUMMULATIVE HIT RATIO'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, H_RATIO,2); 
  STAT_NAME := 'SYS UNDO HDR WAIT CONTENTION'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, SUHW_CONT,3); 
  STAT_NAME := 'SYS UNDO BLK WAIT CONTENTION'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, SUBW_CONT,3); 
  STAT_NAME := 'UNDO HDR WAIT CONTENTION'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, UHW_CONT,3);
  STAT_NAME := 'UNDO BLK WAIT CONTENTION'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, UBW_CONT,3);  
  STAT_NAME := 'freelist'; 
	select class,"COUNT" into TEMP_NAME, stat_val 
	from v$waitstat b 
	where class = STAT_NAME; 
  STAT_NAME := 'Free List Contention Ratio';
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL/(db_gets+con_gets),18); 
EXCEPTION 
    WHEN ZERO_DIVIDE THEN 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,32); 
    COMMIT; 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,32); 
    commit; 
end; 
/* If post 7.2 uncomment this next block */
/*begin
  STAT_NAME := 'Latch Miss%'; 
	select (1-((sum(sleeps)+sum(immediate_misses))/(
	sum(gets)+sum(immediate_misses)+sum(immediate_gets)))*100) into stat_val 
	from v$latch;
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,4); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,4); 
    commit; 
end; */
begin
  STAT_NAME := 'Rollback Wait %'; 
	select (sum(waits)/sum(gets))*100 into stat_val 
	from v$rollstat;
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,5); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,5); 
    commit; 
end; 
begin
  STAT_NAME := 'Library Reload %'; 
	select sum(reloads)/sum(pins)*100  into stat_val 
	from v$librarycache;
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,5); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,5); 
    commit; 
end; 
begin 
  STAT_NAME := 'enqueue deadlocks'; 
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,19); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,19); 
    commit; 
end; 
begin
  STAT_NAME := 'exchange deadlocks';
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,20);
EXCEPTION
    when no_data_found then
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,20);
    commit;
end;
begin
  STAT_NAME := 'table fetch by rowid';
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,9);
EXCEPTION
    when no_data_found then
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,9);
    commit;
end;
begin
  STAT_NAME := 'table scans (rowid ranges)';
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,10);
EXCEPTION
    when no_data_found then
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,10);
    commit;
end; 
begin
  STAT_NAME := 'table scans (cache partitions)';
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,11);
EXCEPTION
    when no_data_found then
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,11);
    commit;
end; 
begin
  STAT_NAME := 'table scans (short tables)';
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,12);
EXCEPTION
    when no_data_found then
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,12);
    commit;
end; 
begin 
  STAT_NAME := 'table scans (long tables)'; 
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,13); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,13); 
    commit; 
end; 
begin
  STAT_NAME:='Non-Index Lookups Ratio';
  select a.value/(a.value+b.value) into STAT_VAL
   from dba_temp a, dba_temp b
   where a.name='table scans (long tables)' 
   and b.name='table scans (short tables)';
       INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,8); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,8); 
    commit; 
end; 
begin 
  STAT_NAME := 'table fetch continued row'; 
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,14); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,14); 
    commit; 
end; 
begin 
  STAT_NAME := 'sorts (memory)'; 
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,15); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,15); 
    commit; 
end; 
begin 
  STAT_NAME := 'sorts (disk)'; 
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME;  
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,16); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,16); 
    commit; 
end; 
begin 
  STAT_NAME := 'redo log space requests'; 
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,6); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,6); 
    commit; 
end; 
begin 
  STAT_NAME := 'redo log space wait time'; 
	select name,value into TEMP_NAME, stat_val 
	from v$sysstat  
	where NAME = STAT_NAME; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL, 6); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,6); 
    commit; 
end; 
begin 
  STAT_NAME := 'TOTAL USERS'; 
	select count(*) into stat_val 
	from dba_users 
	where username not in ('SYS','SYSTEM','PUBLIC'); 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,21); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,21); 
    commit; 
end; 
begin 
  STAT_NAME := 'TOTAL TABLES'; 
	select count(*) into stat_val 
	from dba_tables where 
	tablespace_name NOT IN ('SYSTEM','ORA_TOOLS','TOOLS'); 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,22); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,22); 
    commit; 
end; 
begin 
  STAT_NAME := 'TOTAL TABLESPACES'; 
	select count(*) into stat_val 
	from dba_tablespaces; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,23); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,23); 
    commit; 
end; 
begin 
  STAT_NAME := 'TOTAL INDEXES'; 
	select count(*) into stat_val 
	from dba_indexes where 
	owner not in ('SYS','SYSTEM'); 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,24); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,24); 
    commit; 
end; 
begin 
  STAT_NAME := 'TOTAL ALLOCATED MEG'; 
	select SUM(BYTES)/1048576 into stat_val 
	from dba_DATA_FILES where 
	STATUS = 'AVAILABLE'; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,25); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,25); 
    commit; 
end; 
begin 
  STAT_NAME := 'TOTAL USED MEG'; 
	select SUM(BYTES)/1048576 into stat_val 
	from dba_EXTENTS; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,26); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,26); 
    commit; 
end; 
begin 
  STAT_NAME := 'Fixed Size'; 
	select name,value into TEMP_NAME, stat_val 
	from v$SGA  
	where NAME = STAT_NAME; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,27); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,27); 
    commit; 
end; 
begin 
  STAT_NAME := 'Variable Size'; 
	select name,value into TEMP_NAME, stat_val 
	from v$SGA  
	where NAME = STAT_NAME; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,28); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,28); 
    commit; 
end; 
begin 
  STAT_NAME := 'Database Buffers'; 
	select name,value into TEMP_NAME, stat_val 
	from v$SGA  
	where NAME = STAT_NAME; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,29); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,29); 
    commit; 
end; 
begin 
  STAT_NAME := 'Redo Buffers'; 
	select name,value into TEMP_NAME, stat_val 
	from v$SGA  
	where NAME = STAT_NAME; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,30); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,30); 
    commit; 
end; 
begin 
  STAT_NAME := 'TOTAL SGA SIZE'; 
	select STAT_NAME, SUM(b.value) into TEMP_NAME, stat_val 
	from v$sGA b; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,31); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,31); 
    commit; 
end; 
  COMMIT; 
END;         
/
