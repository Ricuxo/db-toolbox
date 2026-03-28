/*  */
create or replace PROCEDURE startup_date (good_date out date)
AS
	jdate 		DATE;
	jsec 		NUMBER;
	hr 		VARCHAR2(2);
	sec 		VARCHAR2(2);
	minute 		VARCHAR2(2);
	startup_date 	VARCHAR2(32);
	show_date	DATE;
BEGIN
 SELECT 
TO_DATE(TO_NUMBER(value,'99999999'),'J') 
  INTO 
jdate 
  FROM
  	v$instance 
  WHERE 
	key='STARTUP TIME - JULIAN';
 SELECT 
	(TO_NUMBER(value,'9999999')) 
  INTO 
	jsec 
  FROM 
	v$instance
  WHERE 
	key='STARTUP TIME - SECONDS';
 hr:=TO_CHAR(TRUNC(jsec/3600,0));
 minute:= TO_CHAR(TRUNC(((jsec/3600)-hr)*60,0));
 sec:= TO_CHAR(TRUNC((((((jsec/3600)-hr)*60)-minute)*60),0));
 IF length(hr)=1 THEN
  	hr:='0'||hr;
END IF;
IF length(minute)=0 THEN
  	minute:='0'||minute;
END IF;
IF length(sec)=1 THEN
  	sec:='0'||sec;
END IF;
startup_date:=jdate||' '||hr||':'||minute||':'||sec;
dbms_output.put_line('date:'||startup_date);
good_date := TO_DATE(startup_date, 'dd-mon-yy hh24:mi:ss');
show_date := TO_DATE(startup_date, 'dd-mon-yy hh24:mi:ss');
dbms_output.put_line('date:'||to_char(show_date, 'dd-mon-yy hh24:mi:ss'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
 dbms_output.put_line('Startup Date: unknown');
END;
