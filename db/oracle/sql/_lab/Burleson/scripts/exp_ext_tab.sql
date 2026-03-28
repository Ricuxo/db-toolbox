/*  */
 CREATE TABLE sql_scripts_ext (permissions VARCHAR2(20),
  filetype NUMBER(3),owner VARCHAR2(20),
  group_name varchar2(20), size_in_bytes number,
  date_edited date , script_name VARCHAR2(64))
 ORGANIZATION EXTERNAL
( TYPE ORACLE_INTERNAL
  DEFAULT_DIRECTORY sql_dir
  LOCATION (sql_dir:'scripts1.txt',
            sql_dir:'scripts2.txt',
            sql_dir:'scripts3.txt'))
  PARALLEL
  AS SELECT * FROM sql_scripts_int;
