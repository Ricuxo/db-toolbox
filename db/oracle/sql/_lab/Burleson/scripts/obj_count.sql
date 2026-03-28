/*  */
col owner format a10 heading 'Owner'
col object_type format a20 heading 'Object|Type'
col obj_count format 9,999 heading 'Object|Count'
set lines 80 pages 55
break on owner
start title80 'Object Counts'
spool rep_out\&db\object_count
select owner,object_type,count(*) obj_count from dba_objects
where owner not in ('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC')
group by owner,object_type
/
spool off
ttitle off
set pages 22
/
