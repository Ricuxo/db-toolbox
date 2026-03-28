/*  */
col owner format a10 heading 'Owner'
col table_name format a30 heading 'Table Name'
col partition_type format a10 heading 'Partition|Type'
col pct_free format 9999 heading 'Pct|Free'
col ini_trans format 9999 heading 'Ini|Trans'
col freelists format 999999999 heading 'Freelists'
break on owner
set lines 132 pages 50
start title132 'Table Storage'
spool rep_out\&db\tab_stor2
select owner,table_name,pct_free,pct_used, ini_trans,freelists,'N/A' partition_type,
logging 
from dba_tables
where owner not in 
('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC')
 and pct_used is not null
union
select owner,table_name,def_pct_free,def_pct_used, def_ini_trans,def_freelists, partitioning_type, def_logging
from dba_part_tables
where owner not in 
('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC')
order by owner,partition_type,table_name
/
spool off
ttitle off
set lines 80 pages 22
