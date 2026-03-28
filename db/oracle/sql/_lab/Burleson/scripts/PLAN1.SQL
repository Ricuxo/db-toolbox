/*  */
set lines 132 pages 47
COLUMN QUERY_PLAN FORMAT A80
column statement_id format a11 heading ID
spool ex_plan..lis
SELECT statement_id,
LPAD( '  ' , 2*LEVEL)||OPERATION||' '||options||' '||OBJECT_NAME||' cost: '||cost ||' goal:'||optimizer QUERY_PLAN
FROM &&owner..PLAN_TABLE 
CONNECT BY PRIOR ID = PARENT_ID 
START WITH ID=0;
spool off
truncate table &&owner..plan_table;
ed ex_plan..lis
undef id
undef owner

