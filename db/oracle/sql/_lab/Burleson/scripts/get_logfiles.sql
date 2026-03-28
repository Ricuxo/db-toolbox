/*  */
CREATE  OR REPLACE PROCEDURE get_logfiles(
                                        logfile_dir in  VARCHAR2, 
                                        logfile_lis in  VARCHAR2) 
AS
 cur        INTEGER;
 sql_com    VARCHAR2(2000);
 file_full_name VARCHAR2(255);
 file_proc  INTEGER;
 file_hand  utl_file.file_type;
 file_buff  VARCHAR2(1022);
 file_type  VARCHAR2(4);
 ctr NUMBER:=0;
BEGIN
 file_hand:=utl_file.fopen(logfile_dir,logfile_lis,'R');
 LOOP
   ctr:=ctr+1;
   BEGIN
   utl_file.get_line(file_hand,file_buff);
   cur:=dbms_sql.open_cursor;
   file_full_name:=logfile_dir||'\'||file_buff;
   sql_com:= 'begin ';
   IF ctr=1 THEN
   sql_com:=sql_com||'dbms_logmnr.add_logfile('||chr(39)||file_full_name||chr(39)||','||
   dbms_logmnr.new||'); end;';
   else
   sql_com:=sql_com||'dbms_logmnr.add_logfile('||chr(39)||file_full_name||chr(39)||','||
   dbms_logmnr.addfile||'); end;';
   end if;
   dbms_output.put_line(sql_com);
   dbms_sql.parse(cur,sql_com,dbms_sql.v7);
   file_proc:=dbms_sql.execute(cur);
   dbms_sql.close_cursor(cur);
   EXCEPTION
    WHEN no_data_found THEN
   EXIT;
    WHEN others THEN
   EXIT;
   END;
 END LOOP;
 utl_file.fclose(file_hand);
END;
/
