set linesize 300
set pagesize 999

COLUMN COMMAND FORMAT A100
COLUMN CHILDS  FORMAT A60

select 'alter table '||a.owner||'.'||a.table_name||' enable constraint '||a.constraint_name||';' COMMAND
     , a.owner||'.'||a.table_name CHILDS
  from dba_constraints a
     , dba_constraints b
 where a.constraint_type = 'R'
   and a.r_constraint_name = b.constraint_name
   and a.r_owner  = b.owner
   and b.owner = '&OWNER'
   and b.table_name = '&TABLE_NAME'
/