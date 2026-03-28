--Mostra relações entre tabelas baseado no usuário

select
   a.table_name||' ('||
   rtrim(max(decode(c.position,1,c.column_name))||','||
   max(decode(c.position,2,c.column_name))||','||
   max(decode(c.position,3,c.column_name))||','||
   max(decode(c.position,4,c.column_name)),',')||') referencia '||
   b.table_name||' ('||
   rtrim(max(decode(d.position,1,d.column_name))||','||
   max(decode(d.position,2,d.column_name))||','||
   max(decode(d.position,3,d.column_name))||','||
   max(decode(d.position,4,d.column_name)),',')||')' relacionamentos
from
   dba_constraints  a,
   dba_constraints  b,
   dba_cons_columns c,
   dba_cons_columns d
where
   a.r_constraint_name=b.constraint_name and
   a.constraint_name=c.constraint_name and
   b.constraint_name=d.constraint_name and
   a.constraint_type='R' and
   b.constraint_type in ('P', 'U') and
   a.owner='&owner'   
group by a.table_name, b.table_name
order by 1;


-- Exemplo de saída
-- RELACIONAMENTOS
-- --------------------------------------------------------------------------------
-- COUNTRIES (REGION_ID) referencia REGIONS (REGION_ID)
-- DEPARTMENTS (LOCATION_ID) referencia LOCATIONS (LOCATION_ID)
-- DEPARTMENTS (MANAGER_ID) referencia EMPLOYEES (EMPLOYEE_ID)
-- EMPLOYEES (DEPARTMENT_ID) referencia DEPARTMENTS (DEPARTMENT_ID)
-- EMPLOYEES (JOB_ID) referencia JOBS (JOB_ID)
-- EMPLOYEES (MANAGER_ID) referencia EMPLOYEES (EMPLOYEE_ID)
-- JOB_HISTORY (DEPARTMENT_ID) referencia DEPARTMENTS (DEPARTMENT_ID)
-- JOB_HISTORY (EMPLOYEE_ID) referencia EMPLOYEES (EMPLOYEE_ID)
-- JOB_HISTORY (JOB_ID) referencia JOBS (JOB_ID)
-- LOCATIONS (COUNTRY_ID) referencia COUNTRIES (COUNTRY_ID)