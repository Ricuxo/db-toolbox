/*  */
CREATE OR REPLACE FUNCTION l_length(cTabName varchar2, 
                                       cColName varchar2, 
                                       cRowid   varchar2) 
    RETURN NUMBER 
    IS 
           cur_id integer; 
           buff   varchar2(32767); 
           len    integer; 
           offset integer; 
           v_length integer; 
           stmt varchar2(500); 
           ret    integer; 
    BEGIN 
 
          stmt :=  ' SELECT  '|| cColName || ' FROM  ' || cTabName || 
                   ' WHERE rowid = '||''''||cRowid||''''; 
 
          cur_id := dbms_sql.open_cursor; 
          dbms_sql.parse(cur_id, stmt, dbms_sql.NATIVE); 
          dbms_sql.define_column_long(cur_id, 1); 
          ret := dbms_sql.execute(cur_id); 
 
          IF (dbms_sql.fetch_rows(cur_id) > 0 ) 
          THEN 
              offset := 1; 
              len := 0; 
              LOOP 
                 dbms_sql.column_value_long(cur_id, 1,32767, offset, 
                                            buff,  v_length); 
                 len := len + v_length; 
                 EXIT  WHEN v_length < 32767; 
                 offset := offset + v_length; 
              END LOOP; 
          END IF; 
          dbms_sql.close_cursor(cur_id); 
          return( len ); 
    END; 
/

