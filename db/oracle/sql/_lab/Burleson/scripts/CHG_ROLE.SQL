/*  */
create or replace FUNCTION Change_role(
	role_in in varchar2,
	newpass in VARCHAR2) RETURN NUMBER AS
p_password VARCHAR2(32) := newpass;
p_role     varchar(32) := role_in;
no_of_rows number;
cursor_name INTEGER;
sqlStmt varchar2(300);

BEGIN
   cursor_name := dbms_sql.open_cursor;
   SqlStmt:='begin dbms_session.set_role('||chr(39)||p_role||' identified by '||p_password||chr(39)||'); END;';
   dbms_output.Put_line(SqlStmt);
   dbms_sql.parse(cursor_name,sqlstmt,dbms_sql.v7);
   no_of_rows := dbms_sql.execute(cursor_name);
   dbms_sql.close_cursor(cursor_name);
   RETURN no_of_rows;
END;
/
