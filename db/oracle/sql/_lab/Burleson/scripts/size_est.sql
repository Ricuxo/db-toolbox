/*  */
column dbbs new_value db_block_size noprint
column row_count new_value rc noprint;
select value dbbs from v$parameter where name = 'db_block_size';
accept est_row_count prompt 'Enter estimated number of rows for table: '
accept owner prompt 'Enter table owner name: '
accept table prompt 'Enter example table_name: '
set verify off feedback off
select count(*) row_count from &&owner..&&table;
SELECT (COUNT( DISTINCT( SUBSTR( ROWID,1,8)))*&&db_block_size)/&&rc*&&est_row_count bytes
       FROM &&owner..&&table
/
undef owner
undef table
