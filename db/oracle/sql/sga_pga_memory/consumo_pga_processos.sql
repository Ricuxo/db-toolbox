select
  st.sid,
  s.name, 
  st.value
from v$statname s, v$sesstat st
where st.statistic# = s.statistic#
and s.name = 'session pga memory max'
order by st.value;