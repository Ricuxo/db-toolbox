col target_type for a70
col TYPE_DISPLAY_NAME for a70
set lines 500
select distinct TARGET_TYPE, TYPE_DISPLAY_NAME
from mgmt_target_types
order by 1;