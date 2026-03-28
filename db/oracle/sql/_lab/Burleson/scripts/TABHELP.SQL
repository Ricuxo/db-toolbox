/*  */
 CREATE OR REPLACE PROCEDURE table_help (
	tabown 	IN VARCHAR2,
	tabname IN VARCHAR2)
 AS
--
--
 	tabcomment  		VARCHAR2(2000);
 	colname  		VARCHAR2(32);
 	colcomment  		VARCHAR2(2000);
 	tab_name  		VARCHAR2(32);
--
--
	CURSOR get_tab_com (tabo VARCHAR2 ,tabn VARCHAR2) IS
 		 SELECT  
			table_name
			,comments
 		 FROM  
			sys.dba_tab_comments
 		 WHERE  
			owner=UPPER(tabo)
 		 	AND table_name=UPPER(tabn);
--
--
 	CURSOR get_col_com (tabo VARCHAR2,tabn VARCHAR2) IS
 		 SELECT  
			column_name
			,comments
 		 FROM  
			sys.dba_col_comments
 		 WHERE  
			owner=UPPER(tabo)
 		 	AND table_name=UPPER(tabn);
--
--
 BEGIN
  DBMS_OUTPUT.PUT_LINE(CHR(10));
  OPEN get_tab_com(tabown,tabname);
  FETCH get_tab_com INTO tab_name, tabcomment;
  DBMS_OUTPUT.PUT_LINE('TABLE: '||tabname||' COMMENT: '||tabcomment);
  OPEN get_col_com(tabown,tabname);
  LOOP 
	   FETCH get_col_com INTO colname,colcomment;
	   EXIT WHEN get_col_com%NOTFOUND;
	  DBMS_OUTPUT.PUT_LINE('   COLUMN: '||colname||' COMMENT: '||colcomment);
  END LOOP;
  CLOSE get_tab_com;
  CLOSE get_col_com;
 END;
 /
