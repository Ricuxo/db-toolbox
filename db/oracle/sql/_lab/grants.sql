REM Exibe todos os privilegios do usuario
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true);
REM
set serveroutput on
set feedback off
set verify off
declare
test varchar2(20000);
h number;
j number := 0;
begin
dbms_output.enable(10000);
--prompt enter the user name accept user
dbms_output.put_line('***********************************************************************');
dbms_output.put_line('The Roles granted to the users are ');
dbms_output.put_line('***********************************************************************');
select DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT',upper('&&USER')) into test from dual;
for i in 1..ceil(length(test)/255)
loop
dbms_output.put_line(substr(test,j,255));
j := j+255;
end loop;
dbms_output.put_line('***********************************************************************');
j := 0;
dbms_output.put_line('The System privileges are ');
dbms_output.put_line('***********************************************************************');
select DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT',upper('&&USER')) into test from dual;
for i in 1..ceil(length(test)/255)
loop
dbms_output.put_line(substr(test,j,255));
j := j+255;
end loop;
dbms_output.put_line('************************************************************************');
j := 0;
dbms_output.put_line('The Object level privileges are ');
dbms_output.put_line('***********************************************************************');
select DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT',upper('&&USER')) into test from dual;
for i in 1..ceil(length(test)/255)
loop
dbms_output.put_line(substr(test,j,255));
j := j+255;
end loop;
dbms_output.put_line('*************************************************************************');


end;
/

