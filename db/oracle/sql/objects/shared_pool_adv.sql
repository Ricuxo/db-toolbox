/*  */
ttitle 'Shared Pool Advice'
spool shared_pool_adv
select shared_pool_size_for_estimate est_size, shared_pool_size_factor factor,
estd_lc_size, estd_lc_time_saved, estd_lc_memory_object_hits hits
from v$shared_pool_advice
/
spool off
ttitle off
