select inst_id, to_char(begin_time,'dd/mm/YYYY HH24:MI') begin_time, UNXPSTEALCNT, EXPSTEALCNT , SSOLDERRCNT, NOSPACEERRCNT, MAXQUERYLEN
from gv$undostat  where begin_time > sysdate -30
AND (SSOLDERRCNT>0 OR NOSPACEERRCNT>0)
order by inst_id, begin_time;