/*  */
col owner format a10 Heading 'Table|Owner'
col table_name format a40  heading 'Table|Name'
col last_analyzed heading 'Last Date|Analyzed'
start title80 'Table Last Analyzed'
break on owner
spool rep_out\&db\last_anal
select owner,table_name,to_date(last_analyzed,'dd-mon-yy hh24:mi') last_analyzed 
from dba_tables 
where 
owner not in ('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC')
order by owner,table_name,last_analyzed
/
spool off
