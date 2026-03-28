 SET pages 2000
SET verify OFF
SET heading off
set lines 150
undef warning
def Warning=5
spool alter_chunk.sql
 -- Alter tables and table partitions in ts with a size of > 1GB to next 1MB
 SELECT 'alter ' ||
 decode(a.segment_type, 'TABLE PARTITION', 'TABLE', a.segment_type)  || ' '
 || a.owner || '.' || a.segment_name || ' storage (pctincrease 0 next 1M);'
 FROM dba_segments a
 WHERE
   a.next_extent * (DECODE(
                   POWER(1+(a.pct_increase/100),(&&warning+1))-1,
0,(&&warning+1),POWER(1+(a.pct_increase/100),(&&warning+1))-1)/
           (DECODE(a.pct_increase,0,100,a.pct_increase)/100))
  >
  (SELECT max(bytes) FROM dba_free_space b
   WHERE a.tablespace_name = b.tablespace_name
   AND b.tablespace_name != 'SYSTEM')
 AND a.segment_type in ('TABLE PARTITION', 'TABLE')
 AND a.next_extent > 1024000
 AND a.owner not in ('SYS','SYSTEM')
 AND  1073741824 <= (
   SELECT SUM(bytes) FROM dba_data_files f
   WHERE f.tablespace_name = a.tablespace_name
   AND f.tablespace_name != 'SYSTEM')
 GROUP BY a.segment_type, a.owner, a.segment_name
 UNION ALL
 -- Alter tables and table partitions in ts with a size of <1GB to next 128KB
 SELECT 'alter ' ||
 decode(a.segment_type, 'TABLE PARTITION', 'TABLE', a.segment_type)  || ' '
 || a.owner || '.' || a.segment_name || ' storage (pctincrease 0 next
128K);'
 FROM dba_segments a
 WHERE
   a.next_extent * (DECODE(
                   POWER(1+(a.pct_increase/100),(&&warning+1))-1,
0,(&&warning+1),POWER(1+(a.pct_increase/100),(&&warning+1))-1)/
           (DECODE(a.pct_increase,0,100,a.pct_increase)/100))
  >
  (SELECT max(bytes) FROM dba_free_space b
   WHERE a.tablespace_name = b.tablespace_name
   AND b.tablespace_name != 'SYSTEM')
 AND a.segment_type in ('TABLE PARTITION', 'TABLE')
 AND a.next_extent > 128000
 AND a.owner not in ('SYS','SYSTEM')
 AND  1073741824 > (
   SELECT SUM(bytes) FROM dba_data_files f
   WHERE f.tablespace_name = a.tablespace_name
   AND f.tablespace_name != 'SYSTEM')
 GROUP BY a.segment_type, a.owner, a.segment_name
 UNION ALL
 -- Alter indexes or IOTs (partitioned or not) in ts with a size of > 1GB to next 1 MB
 SELECT 'alter ' || DECODE(i.index_type, 'IOT - TOP', 'TABLE', 'index') ||
        ' ' || DECODE(i.index_type, 'IOT - TOP', i.table_owner, a.owner) ||
'.' ||
        DECODE(i.index_type, 'IOT - TOP', i.table_name, a.segment_name) ||
        ' storage (pctincrease 0 next 1M);'
 FROM dba_segments a, dba_indexes i
 WHERE a.segment_name = i.index_name
 AND a.owner = i.owner
 AND a.next_extent * (DECODE(
                   POWER(1+(a.pct_increase/100),(&&warning+1))-1,
0,(&&warning+1),POWER(1+(a.pct_increase/100),(&&warning+1))-1)/
           (DECODE(a.pct_increase,0,100,a.pct_increase)/100))
  >
  (SELECT max(bytes) FROM dba_free_space b
   WHERE a.tablespace_name = b.tablespace_name
   AND b.tablespace_name != 'SYSTEM')
 AND a.segment_type in ('INDEX PARTITION', 'INDEX')
 AND a.next_extent > 1024000
 AND a.owner not in ('SYS','SYSTEM')
 AND  1073741824 <= (
   SELECT SUM(bytes) FROM dba_data_files f
   WHERE f.tablespace_name = a.tablespace_name
   AND f.tablespace_name != 'SYSTEM')
 GROUP BY i.index_type, i.table_owner, a.owner, i.table_name, a.segment_name
 UNION ALL
 -- Alter indexes or IOTs (partitioned or not) in ts with a size of <1GB to next 128 KB
 SELECT 'alter ' || DECODE(i.index_type, 'IOT - TOP', 'TABLE', 'index') ||
        ' ' || DECODE(i.index_type, 'IOT - TOP', i.table_owner, a.owner) ||
'.' ||
        DECODE(i.index_type, 'IOT - TOP', i.table_name, a.segment_name) ||
        ' storage (pctincrease 0 next 128K);'
 FROM dba_segments a, dba_indexes i
 WHERE a.segment_name = i.index_name
 AND a.owner = i.owner
 AND a.next_extent * (DECODE(
                   POWER(1+(a.pct_increase/100),(&&warning+1))-1,
0,(&&warning+1),POWER(1+(a.pct_increase/100),(&&warning+1))-1)/
           (DECODE(a.pct_increase,0,100,a.pct_increase)/100))
  >
  (SELECT max(bytes) FROM dba_free_space b
   WHERE a.tablespace_name = b.tablespace_name
   AND b.tablespace_name != 'SYSTEM')
 AND a.segment_type in ('INDEX PARTITION', 'INDEX')
 AND a.next_extent > 128000
 AND a.owner not in ('SYS','SYSTEM')
 AND  1073741824 > (
   SELECT SUM(bytes) FROM dba_data_files f
   WHERE f.tablespace_name = a.tablespace_name
   AND f.tablespace_name != 'SYSTEM')
 GROUP BY i.index_type, i.table_owner, a.owner, i.table_name, a.segment_name
 UNION ALL
 -- Alter Lobs segments to next 1 MB
 SELECT 'alter table ' || l.owner || '.' || l.table_name || ' modify lob ('||l.column_name || ')  (storage (pctincrease 0 next 1M));'
 FROM dba_segments a, dba_lobs l
 WHERE
   a.segment_name = l.segment_name
 AND
   a.next_extent * (DECODE(
                   POWER(1+(a.pct_increase/100),(&&warning+1))-1,
0,(&&warning+1),POWER(1+(a.pct_increase/100),(&&warning+1))-1)/
           (DECODE(a.pct_increase,0,100,a.pct_increase)/100))
  >
  (SELECT max(bytes) FROM dba_free_space b
   WHERE a.tablespace_name = b.tablespace_name
   AND b.tablespace_name != 'SYSTEM')
 AND a.segment_type IN ('LOBSEGMENT')
 AND a.next_extent > 1024000
 AND a.owner not in ('SYS','SYSTEM');
spool off;