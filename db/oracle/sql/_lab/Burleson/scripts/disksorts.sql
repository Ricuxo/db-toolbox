/*  */
REM
REM FUNCTION: Generate a summary of Disk Sort Area Usage
REM
REM disksort.sql 
REM
COLUMN value NEW_VALUE bs NOPRINT
SELECT value FROM v$parameter WHERE name='db block size';
START title80 "Instance Disk Area Average Sizes"
SPOOL rep_out\&&db\disk_sort
SELECT
	Tablespace_name,
	COUNT(*) areas,
	(SUM(total_blocks)/COUNT(*))*&&bs avg_sort_bytes
FROM v$sort_segment
GROUP BY tablespace_name;
SPOOL OFF
