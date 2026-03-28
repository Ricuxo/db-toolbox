/*  */
rem set heading off feedback off pages 0 termout off echo off
set recsep off verify off
set embedded on
column x word_wrapped
define cr = 'chr(10)'
spool fk_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||&&cr||
';'||&&cr||
'drop index '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||a.constraint_name||' '||a.constraint_type||'( '||&&cr||
a.constraint_columns||' )'||&&cr||
'references '||a.referenced_owner||'.'||b.table_name||' ( '||&&cr||
b.constraint_columns||' ) '||&&cr||
decode (a.delete_rule,'CASCADE','on delete cascade','')||&&cr|| 
';'||&&cr||
'create index '||a.constraint_name||' on '||a.table_name||'( '||&&cr||
a.constraint_columns||') '||&&cr||
'tablespace &tablespace_name'||&&cr|| 
';' x
from cons_temp a, cons_temp b
where a.constraint_type = 'Foreign Key' and
a.referenced_constraint=b.constraint_name
/
