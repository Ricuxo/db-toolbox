/*  */
create or replace FUNCTION Change_password(
newpass in VARCHAR2) RETURN NUMBER AS
p_password VARCHAR2(32) := newpass;
no_of_rows number;
cursor_name INTEGER;
sqlStmt varchar2(300);

BEGIN
   select user into p_user from dual;
   cursor_name := dbms_sql.open_cursor;
   SqlStmt := 'alter user '||p_user||' identified by '||p_password;
   dbms_output.Put_line(SqlStmt);
   dbms_sql.parse(cursor_name,sqlstmt,dbms_sql.v7);
   no_of_rows := dbms_sql.execute(cursor_name);
   dbms_sql.close_cursor(cursor_name);
   RETURN no_of_rows;
END;
/
