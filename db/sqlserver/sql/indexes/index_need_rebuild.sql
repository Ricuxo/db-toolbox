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

/*
usar isso aqui para acompanhar o rebuild

SET STATISTICS PROFILE ON
e
SET STATISTICS PROFILE Off 

SET STATISTICS PROFILE ON
alter index [PK__PointOfS__F329C13BD7F01E08] on [PointOfSales] rebuild with (data_compression = page, online = on,  RESUMABLE = on, fillfactor = 80, maxdop = 1)
SET STATISTICS PROFILE off
*/


/*
SELECT node_id,physical_operator_name, SUM(row_count) row_count,
  SUM(estimate_row_count) AS estimate_row_count,
  CAST(SUM(row_count)*100 AS float)/SUM(estimate_row_count)  percent_completed
FROM sys.dm_exec_query_profiles  
WHERE session_id= (colocar o SPID da conexão que quer monitorar)
GROUP BY node_id,physical_operator_name 
ORDER BY node_id;
*/