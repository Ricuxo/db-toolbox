/*  */
set echo on
spool ref_prac.doc

create or replace type location_t AS OBJECT
(lname VARCHAR2(32),
address1 VARCHAR2(32),
address2 VARCHAR2(32),
city     VARCHAR2(16),
state    CHAR(2),
zipplus4 VARCHAR2(10),
phone    VARCHAR2(20));
/
show err

create or replace type ename_t AS OBJECT
(first_name VARCHAR2(32),
last_name   VARCHAR2(32),
middle_init VARCHAR2(3),
title       VARCHAR2(3));
/
show err

create or replace type employee_t AS OBJECT
(enumber number,
ename ename_t);
/
show err

create or replace type department_t AS OBJECT
(deptno number,
department_name varchar2(16));
/
show err

create table departments of department_t;

create table locations of location_t;

insert into locations values (location_t('Home','5055 Forest Run',null,'Alpharetta','GA','30022','770-555-1212'));

insert into locations values (location_t('Work','18000 Century Blvd','Suite 100','Norcross','GA','30123','770-555-1212'));

insert into departments values (department_t(1,'Executive'));

select * from departments;

select * from locations;

select REF(d) from departments d;
                                                                                                   
select REF(l) from locations l;
 
create table employees (
employee employee_t,
dept REF department_t SCOPE is departments,
eloc REF location_t SCOPE IS locations);

insert into employees 
select 
       employee_t(1,ename_t('Michael','Ault','R.','Mr.')), 
       REF(d) , 
       REF(l) 
FROM 
     departments d, 
     locations l 
where 
     d.deptno=1 and l.lname='Home';

select * from employees;

select e.employee.enumber, e.employee.ename.last_name, deref(e.dept), deref(e.eloc) 
from employees e;

spool off

