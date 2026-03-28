select b.owner,b.object_name,b.object_type,a.value*8192/1024/1024 PHRDS_MB from v$segstat a,dba_objects b
where a.obj#=b.object_id
and a.STATISTIC_NAME='physical reads'
and a.value*8192/1024/1024 > 100
order by PHRDS_MB
/
