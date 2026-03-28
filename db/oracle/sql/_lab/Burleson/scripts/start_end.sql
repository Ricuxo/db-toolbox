/*  */
create or replace FUNCTION get_start(
tab_name  VARCHAR2,
col_id   NUMBER
)  RETURN NUMBER AS
start_val NUMBER;
BEGIN
  IF col_id=1 THEN
 start_val:=1;
  ELSE
 SELECT
  SUM(NVL(data_precision,data_length))+1 INTO start_val
 FROM
  user_tab_columns
 WHERE
  table_name=tab_name AND
  column_id<col_id;
  END IF;
  RETURN start_val;
END;
/
--
--
create or replace FUNCTION get_end(
tab_name  VARCHAR2,
col_id   NUMBER
)   RETURN NUMBER AS
end_val NUMBER;
BEGIN
  SELECT
 SUM(NVL(data_precision,data_length)) INTO end_val
  FROM
 user_tab_columns
  WHERE
 table_name=tab_name AND
 column_id<=col_id;
  RETURN end_val;
END;
/
