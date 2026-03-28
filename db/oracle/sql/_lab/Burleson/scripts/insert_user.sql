/*  */
-- this requires a user_temp table that has been pre-loaded with:
-- cuid varchar2(6) (common userid - or username) the user to be created and a
-- pword varchar2(6) column for a generated password.
-- Will generate a password and load into the user_temp field pword
CREATE OR REPLACE FUNCTION gen_pword RETURN VARCHAR2 AS
   pi        NUMBER := 3.141592653589793238462643 ;
   seed      NUMBER ;
   pwd       VARCHAR2(6);
   pwd_len   NUMBER := 6;          /* length of password */
BEGIN
   dbms_output.enable(1000000);
   SELECT TO_NUMBER(TO_CHAR(hsecs)) / 8640000 INTO seed FROM v$timer ; /* 0<= seed  < 1 */
   pwd := NULL ;
       FOR  j  IN 1..pwd_len LOOP
          seed := POWER(pi + seed,5)  - TRUNC (POWER(pi + seed,5) );
          pwd := pwd || CHR( 64 + 1 + TRUNC (seed * 26)) ;
       END LOOP;
--       dbms_output.put_line (pwd);
RETURN pwd;
END;
/
show err

CREATE OR REPLACE PROCEDURE create_user(username IN VARCHAR2, def_role IN VARCHAR2, def_profile IN VARCHAR2) IS
def_tbsp VARCHAR2(20):='USERS';
tmp_tbsp VARCHAR2(20):='TEMP';
cur INTEGER;
row_proc NUMBER;
comm_line VARCHAR2(200);
pword VARCHAR2(6);
BEGIN
 pword:=gen_pword;
 dbms_output.put_line(comm_line);
--
 comm_line:='CREATE USER '||username||' IDENTIFIED BY '||pword||
  ' DEFAULT TABLESPACE '||def_tbsp||
  ' TEMPORARY TABLESPACE '||tmp_tbsp||
  ' QUOTA UNLIMITED ON '||def_tbsp||
  ' PROFILE '||def_profile;
 cur:=dbms_sql.open_cursor;
 dbms_sql.parse(cur,comm_line,dbms_sql.v7);
 row_proc:=dbms_sql.execute(cur);
 dbms_sql.close_cursor(cur);
--
 comm_line:='GRANT CREATE SESSION,'||def_role||' TO '||username;
 dbms_output.put_line(comm_line);
 cur:=dbms_sql.open_cursor;
 dbms_sql.parse(cur,comm_line,dbms_sql.v7);
 row_proc:=dbms_sql.execute(cur);
 dbms_sql.close_cursor(cur);
--
 comm_line:='UPDATE USER_TEMP SET pword='||CHR(39)||pword||CHR(39)||
  'WHERE cuid='||CHR(39)||username||CHR(39);
 cur:=dbms_sql.open_cursor;
 dbms_sql.parse(cur,comm_line,dbms_sql.v7);
 row_proc:=dbms_sql.execute(cur);
 dbms_sql.close_cursor(cur);
 COMMIT;
--
END;
/
show err

CREATE OR REPLACE PROCEDURE insert_users AS
CURSOR get_user_record IS
 SELECT upper(cuid), pword 
 FROM user_temp where pword is null;
user_rec user_temp%rowtype;
--
CURSOR check_db_user (cuid IN VARCHAR2) IS
 SELECT COUNT(*) FROM dba_users 
 WHERE UPPER(cuid)=username;
user_count NUMBER;
--
BEGIN
OPEN get_user_record;
--
LOOP
 FETCH get_user_record INTO user_rec;
 EXIT WHEN get_user_record%NOTFOUND;
 dbms_output.put_line('Processing CUID: '||user_rec.cuid);
--
 OPEN check_db_user(user_rec.cuid);
 FETCH check_db_user INTO user_count;
 CLOSE check_db_user;
--
  IF user_count=0 THEN
  dbms_output.put_line('User: '||user_rec.CUID||' does not exist');
  create_user(user_rec.cuid);
--
   COMMIT;
--
 END IF;
--
END LOOP;
--
END;
/
show err

