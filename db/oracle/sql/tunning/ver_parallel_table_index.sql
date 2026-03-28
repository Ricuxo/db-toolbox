col owner for a30
col table_name for a30
select owner,table_name,degree,instances from dba_tables where
(trim (degree)not in ( '1','0') or trim(instances) not in ( '1','0') )
and owner not in ('SYSTEM','SYS','OUTLN','DBSNMP','OPS$ORACLE')
/


select owner,index_name,degree,instances from dba_indexes
where (trim (degree)not in ( '1','0') or trim(instances) not in ( '1','0') )
and owner not in ('SYSTEM','SYS','OUTLN','DBSNMP','OPS$ORACLE')
/


sqlplus sys/esperanca_2015@//afprbr01_db:1941/afprbr01 as sysdba

select name, value from v$sysstat where name like 'Parallel%';



-- For Tables
 select 'alter table '||owner||'."'||table_name||'" parallel (degree 4);' from dba_tables where owner='IC';

-- For indexes
select 'alter index '||owner||'."'||index_name||'" parallel (degree 4);' from dba_indexes where owner='IC';