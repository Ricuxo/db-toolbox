/*  */
set lines 132 pages 64 verify off feedback off
ttitle 'Foreign Key Indexes'
spool fk_indexes
select b.owner, b.constraint_name, c.index_name, a.constraint_type
from dba_constraints a, dba_cons_columns b, dba_ind_columns c
where a.constraint_type='R'
and a.owner not in ('SYS','SYSTEM','SCOTT','SYSMAN','ORDSYS','CTXSYS','ODM',
 'XDB','RMAN','ODSYS','CTXSYS','MDSYS','WKSYS','WMSYS')
and a.constraint_name=b.constraint_name
and b.column_name=c.column_name
and a.table_name=c.table_name(+)
/
spool off
set lines 80 verify on feedback on
