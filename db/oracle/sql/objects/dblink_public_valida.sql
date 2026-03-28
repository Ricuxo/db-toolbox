prompt # 
prompt #  Valida os database link PUBLIC
prompt # 
set serveroutput on
DECLARE
CURSOR C1 IS select 'select INSTANCE_NAME||'', ''||HOST_NAME bco from v$instance@'||DB_LINK DB_LINK 
               from DBA_DB_LINKs
              WHERE OWNER = 'PUBLIC';
v_sql    varchar2(2000);
v_retorno varchar2(3000);
Begin
for r1 in c1 loop
    begin
    v_sql := r1.db_link;
    execute immediate v_sql into v_retorno;
    dbms_output.put_line('OK, '||v_retorno);
    exception
       when others then
            v_retorno := substr(sqlerrm,1,200);
            dbms_output.put_line('erro, '||v_sql||',  msg erro='|| v_retorno);    
    end;
end loop;
end;
/
