How to find the daily growth of a database from OEM repository

SQL> select rollup_timestamp, average
from mgmt$metric_daily
where target_name = 'MT1D'
and column_label = 'Used Space(GB)'
order by rollup_timestamp;