/*  */
CREATE TABLE sql_scripts (file_date date, 
                          file_length int, 
                          file_name varchar2(32))
   ORGANIZATION EXTERNAL
  (TYPE ORACLE_LOADER
  DEFAULT DIRECTORY ext_file_dir
  ACCESS PARAMETERS  
  (records delimited by newline nologfile nodiscardfile nobadfile FIELDS
   (file_date   POSITION (1:16)  char,
    file_length POSITION (30:37) unsigned integer external,
    file_name   POSITION (39:67) char))
  LOCATION ('file.lis'))
/
