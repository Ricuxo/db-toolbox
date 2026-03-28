/*  */
Rem db_cache_ad.sql
Rem from Oracle9i tuning
Rem Mike Ault Initial creation
Rem
col size_est   format 999,999,999,999 heading 'Cache Size (m)'
col buf_est    format 999,999,999     heading 'Buffers'
col est_rf format 999.90       heading 'Estd Phys|Read Factor'
col est_pr format 999,999,999     heading 'Estd Phys| Reads'
SET LINES 80 PAGES 55
@title80 'DB Cache Advisor Report'
SPOOL rep_out/&db/db_cache_ad
SELECT 
   size_for_estimate size_est, 
   buffers_for_estimate buf_est,
   estd_physical_read_factor est_rf, 
   estd_physical_reads est_pr
 FROM V$DB_CACHE_ADVICE
 WHERE name = 'DEFAULT'
   AND block_size = (SELECT value FROM V$PARAMETER 
                     WHERE name = 'db_block_size')
   AND advice_status='ON';
SPOOL OFF
SET PAGES 22
TTITLE OFF
