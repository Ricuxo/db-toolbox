/*  */
column sids format a10 heading "Sid,Ser#"
column username format a15 heading Username
column ltime format a20 heading "Login Time"
column program format a30 heading Program
start title80 'User Login Times'
spool rep_out\&db\login_tm
select s.sid||','||n.serial# sids,
       n.username,
       n.status "Status",
       n.program,
       to_char(sysdate-(hsecs-s.value)/(24*3600*100),
          'MM/DD/YYYY HH24:MI:SS') ltime
from sys.V_$sesstat s,
     sys.V_$session n,
     sys.v_$timer
where s.statistic# = 13
and   s.sid = n.sid
and   s.value != 0
order by 2,5;
spool off
