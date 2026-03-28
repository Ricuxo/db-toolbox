/*  */
@title80 'PGA Target Advice Report'
spool rep_out\&db\pga_advice
SELECT round(PGA_TARGET_FOR_ESTIMATE/1024/1024) target_mb,        ESTD_PGA_CACHE_HIT_PERCENTAGE cache_hit_perc,        ESTD_OVERALLOC_COUNT FROM   v$pga_target_advice
/
spool off
