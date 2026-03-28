/*  */
create or replace procedure check_corrupt(schema_name in varchar2) is
cursor c is
  select OWNER,
         object_NAME,
         DECODE(object_type,
                'TABLE',1,
                'INDEX',2,
                'CLUSTER',4,object_type) object_type
  from dba_objects
  where owner = schema_name
        and object_type in ('TABLE','CLUSTER','INDEX') ;
v_corrupt_count BINARY_INTEGER;
object_name varchar2(64);
owner_name varchar2(64);
object_type integer;
begin
 DBMS_REPAIR.ADMIN_TABLES('REPAIR_TABLE',1,3);
 DBMS_REPAIR.ADMIN_TABLES('REPAIR_TABLE',1,1);
 DBMS_REPAIR.ADMIN_TABLES('REPAIR_TABLE',1,2);
 FOR C_REC IN C LOOP
  object_name:=c_rec.object_name;
  owner_name:=c_rec.owner;
  object_type:=c_rec.object_type;
  DBMS_OUTPUT.PUT_LINE(owner_name||'.'||object_name);
  DBMS_REPAIR.CHECK_OBJECT(SCHEMA_NAME=>OWNER_NAME,
     OBJECT_NAME=>OBJECT_NAME,OBJECT_TYPE=>object_type,CORRUPT_COUNT=>v_corrupt_count);
  DBMS_OUTPUT.PUT_LINE(owner_name||'.'||object_name||
     ' Corrupt Count='||to_char(v_corrupt_count));
 END LOOP;
END check_corrupt;
/
