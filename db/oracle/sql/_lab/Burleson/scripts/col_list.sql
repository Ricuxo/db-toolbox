/*  */
col data_type format a10
col data_length heading Length format 999999
col data_precision heading Precision format 999999999
col data_scale heading scale format 99999
col column_name format a15
col table_name format a10
set pages 60
select owner,table_name,column_name, data_type, data_length, data_precision,data_scale,nullable
from dba_tab_columns
where owner=upper('&owner');
