/*  */
CREATE OR REPLACE PACKAGE utl_long AS

  /* SubType for object names */
  SUBTYPE st_object_name IS all_objects.object_name%TYPE;
  
  /* Record type for column info */
  TYPE rt_column IS RECORD
    (owner st_object_name, 
	 table_name st_object_name, 
	 column_name st_object_name);
	 
  /* INSTR mimic for LONG columns */
  FUNCTION INSTR (
    vp_row IN ROWID,
    vp_exp IN VARCHAR2)
    RETURN NUMBER;
  
END;
/

CREATE OR REPLACE PACKAGE BODY utl_long AS
  
  /* Get LONG column name from ROWID */
  FUNCTION rowid_to_column (
    vp_row IN ROWID)
	RETURN rt_column  
  IS
    v_rtn rt_column;
	CURSOR c_column IS
    SELECT a.owner, a.object_name, t.column_name
    FROM   all_objects a, all_tab_columns t
    WHERE  t.data_type = 'LONG'
    AND    t.table_name = a.object_name
    AND    t.owner = a.owner
    AND    a.object_id = DBMS_ROWID.ROWID_OBJECT (vp_row);
  BEGIN
    OPEN c_column;
	FETCH c_column INTO v_rtn;
	CLOSE c_column;
	RETURN v_rtn;
  END;
  
  /* INSTR mimic for LONG columns */
  FUNCTION INSTR (
    vp_row IN ROWID,
    vp_exp IN VARCHAR2)
    RETURN NUMBER 
  IS
    v_clb CLOB := NULL;
	v_exe INTEGER := 0;
    v_pos PLS_INTEGER := 0;
    v_len PLS_INTEGER := 0;
    v_pce VARCHAR2 (32767);
    v_cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR;
    v_col rt_column := rowid_to_column (vp_row);
  BEGIN
    DBMS_LOB.CREATETEMPORARY (v_clb, TRUE, DBMS_LOB.CALL);
	DBMS_SQL.PARSE (v_cur, 'SELECT ' || v_col.column_name || ' FROM ' || 
	  v_col.owner || '.' || v_col.table_name || ' WHERE ROWID = :v_row', DBMS_SQL.NATIVE);
	DBMS_SQL.BIND_VARIABLE (v_cur, 'v_row', vp_row);
    DBMS_SQL.DEFINE_COLUMN_LONG (v_cur, 1);
    v_exe := DBMS_SQL.EXECUTE_AND_FETCH (v_cur);
	LOOP
      DBMS_SQL.COLUMN_VALUE_LONG (v_cur, 1, 32767, v_pos, v_pce, v_len);
      EXIT WHEN v_len = 0;
      DBMS_LOB.WRITE(v_clb, v_len, v_pos + 1, v_pce);
      v_pos := v_pos + v_len;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR (v_cur);
	RETURN DBMS_LOB.INSTR (v_clb, vp_exp);
  EXCEPTION
    WHEN OTHERS THEN
	  DBMS_SQL.CLOSE_CURSOR (v_cur);
	RAISE;
  END;
 
END;
/
