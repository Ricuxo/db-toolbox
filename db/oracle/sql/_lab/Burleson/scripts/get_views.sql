/*  */
select distinct a.owner,a.table_name from dba_tab_columns a, dba_dependencies b where 
a.table_name like 'V_%'
and a.column_name like '%DESCRIPTION' and a.owner not in ('SYS','SYSTEM')
and a.owner=b.owner and a.table_name=b.name
and b.referenced_type='TABLE'
and b.type='VIEW'
and b.referenced_owner='DIMENSION' and b.referenced_name in ('DIM_CUSTOMER','DIM_PRODUCT')
order by 'desc '||a.owner||'.'||a.table_name
/
