select name, gets, sleeps,
sleeps*100/sum(sleeps) over() sleep_pct, sleeps*100/gets
sleep_rate
from v$latch where gets>0
order by sleeps desc
/
