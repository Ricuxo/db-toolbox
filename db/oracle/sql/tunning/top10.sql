---------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM 
  (SELECT hash_value,address,substr(sql_text,1,40) sql,
          [list of columns], [list of derived values]
     FROM [V$SQL or V$SQLXS or V$SQLAREA]
    WHERE [list of threshold conditions for columns]
    ORDER BY [list of ordering columns] DESC
   )
WHERE rownum <= [number of top SQL statements];
---------------------------------------------------------------------------------------------------------------------------------------------
set linesize 2000
set pagesize 0100
col sql format a200
---------------------------------------------------------------------------------------------------------------------------------------------

-- Top 10 by Buffer Gets:

SELECT * FROM (
SELECT substr(sql_text,1,200) sql,buffer_gets, executions, buffer_gets/executions "Gets/Exec", hash_value,address
FROM V$SQLAREA
WHERE buffer_gets > 10000
ORDER BY buffer_gets DESC
 )
WHERE rownum <= 10;

---------------------------------------------------------------------------------------------------------------------------------------------

-- Top 10 by Physical Reads:

SELECT * FROM (
SELECT substr(sql_text,1,200) sql,disk_reads, executions, disk_reads/executions "Reads/Exec", hash_value,address
FROM V$SQLAREA
WHERE disk_reads > 1000
AND   executions > 0
ORDER BY disk_reads DESC
 )
WHERE rownum <= 10;

---------------------------------------------------------------------------------------------------------------------------------------------

-- Top 10 by Executions:

SELECT * FROM (
SELECT substr(sql_text,1,40) sql,executions, rows_processed, rows_processed/executions "Rows/Exec", hash_value,address
FROM V$SQLAREA
WHERE executions > 100
ORDER BY executions DESC
 )
 WHERE rownum <= 10;

---------------------------------------------------------------------------------------------------------------------------------------------

-- Top 10 by Parse Calls:

SELECT * FROM (
SELECT substr(sql_text,1,40) sql,parse_calls, executions, hash_value,address
FROM V$SQLAREA
WHERE parse_calls > 1000
ORDER BY parse_calls DESC
 )
WHERE rownum <= 10;

---------------------------------------------------------------------------------------------------------------------------------------------

-- Top 10 by Sharable Memory:

SELECT * FROM (
SELECT substr(sql_text,1,40) sql,sharable_mem, executions, hash_value,address
FROM V$SQLAREA
WHERE sharable_mem > 1048576
ORDER BY sharable_mem DESC
 )
WHERE rownum <= 10;

---------------------------------------------------------------------------------------------------------------------------------------------

-- Top 10 by Version Count:

SELECT * FROM (
SELECT substr(sql_text,1,40) sql,version_count, executions, hash_value,address
FROM V$SQLAREA
WHERE version_count > 20
ORDER BY version_count DESC
 )
WHERE rownum <= 10;

---------------------------------------------------------------------------------------------------------------------------------------------

-- Top 10 by Cpu Time:

SELECT * FROM (
SELECT substr(sql_text,1,40) sql,cpu_time, executions, hash_value,address
FROM V$SQLAREA
WHERE cpu_time > 60
ORDER BY cpu_time DESC
 )
WHERE rownum <= 10;

---------------------------------------------------------------------------------------------------------------------------------------------
-- RAC
---------------------------------------------------------------------------------------------------------------------------------------------
-- The column CLUSTER_WAIT_TIME in V$SQLAREA represents the wait time incurred by individual SQL statements for global cache events and will 
-- identify the SQL which may need to be tuned.
---------------------------------------------------------------------------------------------------------------------------------------------

-- Top 10 by Cluster Wait Time:

SELECT * FROM (
SELECT inst_id,cluster_wait_time,substr(sql_text,1,40) sql,cpu_time, executions, hash_value,address
FROM GV$SQLAREA
WHERE cluster_wait_time > 10000
ORDER BY cluster_wait_time DESC
 )
WHERE rownum <= 10;
---------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM
(SELECT
    sql_fulltext,
    sql_id,
    child_number,
    disk_reads,
    executions,
    first_load_time,
    last_load_time
FROM    v$sql
ORDER BY elapsed_time DESC)
WHERE ROWNUM <= 10
/
---------------------------------------------------------------------------------------------------------------------------------------------

