set serveroutput on;
declare

v_log    number;
v_days   number;
v_logsz  number;
v_adsw   number;
V_advol  number;
v_ahsw   number;
v_ahvol  number;


begin

select count(first_time) into v_log from v$log_history;
select count(distinct(to_char(first_time,'dd-mon-rrrr'))) into v_days from v$log_history;
select max(bytes)/1024/1024 into v_logsz from v$log;

v_adsw := round(v_log / v_days);
v_advol := round(v_adsw * v_logsz);
v_ahsw := round(v_adsw / 24);
v_ahvol := round((v_adsw / 24 )) * v_logsz;

dbms_output.put ('Total Switches' || ' '||v_log||'  ==>  ');
dbms_output.put ('Total Days' || ' '|| v_days||'  ==>  ');
dbms_output.put_line ('Redo Size' || ' ' || v_logsz);
dbms_output.put ('Avg Daily Switches' || ' ' || v_adsw||'  ==>  ');
dbms_output.put_line ('Avg Daily Volume in Meg' || ' ' || v_advol);
dbms_output.put ('Avg Hourly Switches' || ' ' || v_ahsw||'  ==>  ');
dbms_output.put_line ('Avg Hourly Volume in Meg' || ' ' || v_ahvol);


end;

/
