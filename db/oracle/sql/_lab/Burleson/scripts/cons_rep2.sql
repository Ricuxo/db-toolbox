/*  */
set pages 0 verify off feedback off 
column table_name format a20
column constraint_name format a25
column type format a15
column delete_rule format a15
column column_name format a15
start title80 "Constraint Report"
spool rep_out/&&db/cons_rep.lis
select a.table_name,a.constraint_name,decode (constraint_type,'P', 'Primary',
'R', 'Foreign Key') type, delete_rule, column_name from
user_constraints a, user_cons_columns b where
constraint_type in ('P','R') and
a.owner=b.owner and
a.constraint_name=b.constraint_name
order by table_name,constraint_type asc
/
spool off

