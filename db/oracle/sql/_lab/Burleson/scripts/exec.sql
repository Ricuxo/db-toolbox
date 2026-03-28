/*  */
create or replace procedure exec ( 
string IN VARCHAR2)                                              
AS                                                          
 cursor_name   INTEGER;                                             
 ret   INTEGER;                                                                              
BEGIN                                                       
 cursor_name := DBMS_SQL.OPEN_CURSOR;                               
 DBMS_SQL.PARSE(cursor_name,string,dbms_sql.v7);                
 ret := DBMS_SQL.EXECUTE(cursor_name);                            
 DBMS_SQL.CLOSE_CURSOR(cursor_name);                                                                                                                   
END; 
/
