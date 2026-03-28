/*Mosta historico de estatisticas

Exemplo de saida:
OWNER                          TABLE_NAME                STATS_UPDATE_TIME
------------------------------ ------------------------- -------------------------------------
SCOTT                          EMP                       01-APR-17 01.28.05.300409 PM -03:00
SCOTT                          EMP                       12-APR-17 03.21.23.751332 PM -03:00
*/

select owner, table_name, stats_update_time
from DBA_TAB_STATS_HISTORY
where owner like nvl('&owner',owner)
and table_name like nvl('&table_name',table_name)
/
