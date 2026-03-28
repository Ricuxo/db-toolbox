/*  */
set heading off feedback off pages 0 termout on echo on
set recsep off verify off
set embedded on
define cr='chr(10)'
column x word_wrapped
column dbname new_value db noprint
select name dbname from v$database;
spool rep_out\&db\ck_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||a.constraint_name||&&cr||
constraint_type||'( '||a.search_condition||' )'||&&cr||
';' x
from cons_temp a where constraint_type in ( 'Check','Default' ) and
search_condition not like '%NULL%'
/
spool off
spool rep_out\&db\pk_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||';'||&&cr||
'drop index '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||a.constraint_name||&&cr||
constraint_type||'( '||a.constraint_columns||' )'||&&cr||
'using index tablespace '||b.tablespace_name||&&cr||
'pctfree '||b.pct_free||&&cr||
'initrans '||b.ini_trans||&&cr||
'maxtrans '||b.max_trans||&&cr||
'storage ('||&&cr||
'initial '||b.initial_extent||&&cr||
'next '||b.next_extent||&&cr||
'minextents '||b.min_extents||&&cr||
'maxextents '||b.max_extents||&&cr||
'pctincrease '||b.pct_increase||&&cr||')'||&&cr||
';' x
from cons_temp a, user_indexes b where
a.constraint_type in ('Primary Key','Unique') and
a.constraint_name=b.index_name 
/
spool off
spool rep_out\&db\fk_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||&&cr||
';'||&&cr||
'drop index '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||'FK_'||a.table_name||'_'||a.con_number||&&cr||
a.constraint_type||'( '||&&cr||
a.constraint_columns||' )'||&&cr||
'references '||a.referenced_owner||'.'||b.table_name||' ( '||&&cr||
b.constraint_columns||' ) '||&&cr||
decode (a.delete_rule,'CASCADE','on delete cascade','')||&&cr||
';'||&&cr||
'create index '||'FK_'||a.table_name||'_'||a.con_number||' on '||a.table_name||'( '||&&cr||
a.constraint_columns||') '||&&cr||
'tablespace &tablespace_name'||&&cr||
';' x
from cons_temp a, cons_temp b
where a.constraint_type = 'Foreign Key' and
a.referenced_constraint=b.constraint_name
/
spool off
set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
clear breaks
undef cr
