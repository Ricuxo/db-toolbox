SET ECHO OFF;
SET FEEDBACK OFF;
SET HEADING OFF;
SET SERVEROUTPUT ON SIZE 1000000
BEGIN
  FOR cur_rec IN (SELECT owner, object_name, object_type 
                  FROM   dba_objects
                  WHERE  object_type IN ('TABLE', 'VIEW', 'PACKAGE', 'PROCEDURE', 'FUNCTION', 'SEQUENCE') and owner in ('AA', 'SMASH')) LOOP
    BEGIN
      IF cur_rec.object_type = 'TABLE' THEN
        DBMS_OUTPUT.PUT_LINE('DROP ' ||cur_rec.object_type || ' "' ||cur_rec.owner||'.'||cur_rec.object_name|| '" CASCADE CONSTRAINTS;');
      ELSE
        DBMS_OUTPUT.PUT_LINE('DROP ' ||cur_rec.object_type || ' "' ||cur_rec.owner||'.'||cur_rec.object_name|| '";');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('FAILED: DROP ' || cur_rec.object_type || ' "' ||cur_rec.owner||'.'|| cur_rec.object_name || '"');
    END;
  END LOOP;
END;
/
SET ECHO ON
SET FEEDBACK ON
SET HEADING ON