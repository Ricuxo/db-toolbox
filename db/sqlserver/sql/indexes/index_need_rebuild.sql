SELECT OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name,
       OBJECT_NAME(ips.object_id) AS object_name,
       i.name AS index_name,
       i.type_desc AS index_type,
       ips.avg_fragmentation_in_percent,
     case
    when avg_fragmentation_in_percent > 30 then 'alter index ' + quotename( i.name) + ' on ' + quotename(OBJECT_NAME(ips.object_id)) + ' rebuild with (data_compression = page, online = on,  RESUMABLE = on, fillfactor = 80, maxdop = 1) '
    when avg_fragmentation_in_percent between 5 and 29  then 'alter index ' + quotename( i.name) + ' on ' + quotename(OBJECT_NAME(ips.object_id)) + ' reorganize'
    end as Manut,
     ips.avg_page_space_used_in_percent,
       ips.page_count,
       ips.alloc_unit_type_desc
FROM sys.dm_db_index_physical_stats(DB_ID(), default, default, default, 'SAMPLED') AS ips
INNER JOIN sys.indexes AS i
ON ips.object_id = i.object_id
   AND
   ips.index_id = i.index_id
where avg_fragmentation_in_percent> 5
ORDER BY page_count DESC;