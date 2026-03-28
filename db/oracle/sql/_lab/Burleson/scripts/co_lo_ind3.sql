/*  */
col owner format a10
col tablespace_name format a10
col table_name format a30
set lines 132 pages 47
ttitle 'Indexes Co-Located With Data'
spool co_lo_ind
select i.owner, i.index_name, i.tablespace_name,
       i.table_name,i.index_type
from 
   dba_indexes i, dba_tables t 
where
   i.owner not in ('SYS','SYSTEM','SCOTT','SYSMAN','ORDSYS','CTXSYS','ODM',
                    'XDB','RMAN','ODSYS','CTXSYS','MDSYS','WKSYS','WMSYS','OUTLN')
and (i.table_name=t.table_name 
     and i.owner=t.owner 
     and i.tablespace_name=t.tablespace_name)
order by owner,index_name
/
spool off
ttitle off
set lines 80
