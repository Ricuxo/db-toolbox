/*  */
drop table temp_size_table;
create table temp_size_table (
table_name varchar2(64),
blocks number)
storage (initial 16k next 16k)
tablespace &&data_tablespace;
