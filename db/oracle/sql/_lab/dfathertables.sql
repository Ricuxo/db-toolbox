set linesize 300
set pagesize 999

COLUMN FATHERS  FORMAT A100
COLUMN "CONSTRAINT" FORMAT A60

select f.owner||'.'||f.table_name FATHERS
     , f.constraint_name "CONSTRAINT"
  from dba_constraints f
     , dba_constraints c
 where c.constraint_type = 'R'
   and c.r_constraint_name = f.constraint_name
   and c.r_owner  = f.owner
   and c.owner = '&OWNER'
   and c.table_name = '&TABLE_NAME'
/