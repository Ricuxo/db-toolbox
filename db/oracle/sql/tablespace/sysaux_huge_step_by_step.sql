---- https://blog.toadworld.com/2017/11/15/sysaux-and-purging-big-objects-segments-manually
---- https://mwidlake.wordpress.com/2011/06/02/why-is-my-sysaux-tablespace-so-big-statistics_levelall/
---- https://jhdba.wordpress.com/2009/05/19/purging-statistics-from-the-sysaux-tablespace/


@?/rdbms/admin/awrinfo


select occupant_desc, space_usage_kbytes/1024 MB
from v$sysaux_occupants
where space_usage_kbytes > 0
order by space_usage_kbytes;



https://asktom.oracle.com/pls/apex/asktom.search?tag=reclaimreuse-lob-space
https://asktom.oracle.com/pls/apex/asktom.search?tag=lob-purge




SOLUTION
1. Remove/Purge the orphaned rows from tables.


DELETE FROM sys.WRH$_LATCH a
WHERE NOT EXISTS
(SELECT 1
FROM sys.wrm$_snapshot b
WHERE b.snap_id = a.snap_id
AND dbid=(SELECT dbid FROM v$database)
AND b.dbid = a.dbid
AND b.instance_number = a.instance_number);

DELETE FROM sys.WRH$_SYSSTAT a
WHERE NOT EXISTS
(SELECT 1
FROM sys.wrm$_snapshot b
WHERE b.snap_id = a.snap_id
AND dbid=(SELECT dbid FROM v$database)
AND b.dbid = a.dbid
AND b.instance_number = a.instance_number);

DELETE FROM sys.WRH$_PARAMETER a
WHERE NOT EXISTS
(SELECT 1
FROM sys.wrm$_snapshot b
WHERE b.snap_id = a.snap_id
AND dbid=(SELECT dbid FROM v$database)
AND b.dbid = a.dbid
AND b.instance_number = a.instance_number);

COMMIT;