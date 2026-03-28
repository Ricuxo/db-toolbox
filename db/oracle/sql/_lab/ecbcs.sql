--
--
--   NAME 
--     ecbcs.sql - Buffer Cache Statistics
--
--   DESCRIPTION
--     Mostra dados estatisticos sobre o buffer cache.
--
--   HISTORY
--     02/06/2008 => Eduardo Chinelatto
--     
-----------------------------------------------------------------------------

SET PAGES 100
set wrap off
set lines 130
set pages 100


--
-- Exibe buffer cache hit ratio
--

COLUMN physical_reads      FORMAT 999,999,999,999 heading 'Physical|reads'
COLUMN logical_reads       FORMAT 999,999,999,999 heading 'Logical|reads'
COLUMN hit_ratio           FORMAT 99.00           heading 'Hit|ratio'
COLUMN name                FORMAT A20             heading 'Cache name'

select name, physical_reads, db_block_gets + consistent_gets logical_reads,
       (1 - (physical_reads / (db_block_gets + consistent_gets))) * 100 hit_ratio
from v$buffer_pool_statistics
where (db_block_gets + consistent_gets) > 0;

--
-- Exibe buffer cache advice
--

COLUMN size_for_estimate         FORMAT 999,999,999,999 heading 'Cache Size (MB)'
COLUMN buffers_for_estimate      FORMAT 999,999,999     heading 'Buffers'
COLUMN estd_physical_read_factor FORMAT 999.90          heading 'Estd Phys|Read Factor'
COLUMN estd_physical_reads       FORMAT 999,999,999,999 heading 'Estd Phys| Reads'

SELECT size_for_estimate, buffers_for_estimate, estd_physical_read_factor, estd_physical_reads
FROM V$DB_CACHE_ADVICE
WHERE name = 'DEFAULT' AND
      block_size = (SELECT value FROM V$PARAMETER WHERE name = 'db_block_size') AND
      advice_status = 'ON';



