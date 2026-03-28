/*  */
create view proc_count as
select owner,name,type,count(*) lines from dba_source
group by owner,name,type
/
