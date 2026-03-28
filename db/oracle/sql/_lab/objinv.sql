set pagesize 10000
set linesize 132
col object_name format a40
set echo off
prompt ***************************** Relacao de Objetos Invalidos no owner
select object_name,object_type,status from user_objects where status='INVALID';
set echo off