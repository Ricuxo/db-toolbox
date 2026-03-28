select   
	SID,
	event,
	p1,
	p2,
	p3,
        SECONDS_IN_WAIT
from v$session_wait
order by 6 desc

/
