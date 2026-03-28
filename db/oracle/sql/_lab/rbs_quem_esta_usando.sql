prompt # 
prompt #  Verifica quem esta utilizando a area de ROLLBACK
prompt #  
set lines 10000
set pages 10000
column machine format a20
column username format a20
column name format a20

select s.sid, rs.status , s.username, s.osuser, s.machine, 
      rn.name, (t.USED_UBLK*8192)/1024 USED_UBLK, 
      rs.xacts, rs.aveactive
 from v$transaction t ,
      v$session s,
      v$rollname rn,
      v$rollstat rs 
where t.ses_addr = s.saddr
and   rn.USN     = t.xidusn 
and   rs.usn     = rn.usn 
order by rn.name, rs.writes ;
