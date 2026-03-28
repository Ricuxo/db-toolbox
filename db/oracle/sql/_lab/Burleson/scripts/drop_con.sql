/*  */
/*
CREATE OR REPLACE PROCEDURE drop_constraints (tab IN VARCHAR2)
IS
   CURSOR cons_cur
   IS
      SELECT table_name, constraint_name
        FROM user_constraints
       WHERE table_name = UPPER (tab)
        ORDER BY constraint_type;

   PROCEDURE ddl (str IN VARCHAR2)
   IS
      cur INTEGER := DBMS_SQL.OPEN_CURSOR;
      fdbk INTEGER;
   BEGIN
      DBMS_SQL.PARSE (cur, str, DBMS_SQL.NATIVE);
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.CLOSE_CURSOR (cur);
   EXCEPTION
      WHEN OTHERS
      THEN
         IF SQLCODE = -2273
         THEN
            DBMS_OUTPUT.PUT_LINE ('Unable to ' || str);
         END IF;
   END;
BEGIN
   FOR rec IN cons_cur
   LOOP
      ddl ('ALTER TABLE ' || rec.table_name || 
           '   DROP CONSTRAINT ' || rec.constraint_name);
   END LOOP;
END;
/
*/
