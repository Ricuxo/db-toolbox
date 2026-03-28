
@save_sqlplus_settings

set verify off
clear breaks
col "SID" format 99999
col "Serial#" format 99999
col "OS Process" format a10
col "Oracle User" format a15
col Rollback format a12
col "OS User" format a8
col Status format a8
col program format a30
col logon_time format a10
col start_time format a20
col Blocks format 999999999

select s.sid "SID", s.serial# "Serial#", p.spid "OS Process", s.username "Oracle User",
   r.name "Rollback", s.osuser "OS User", s.status Status,
   t.used_ublk Blocks, to_char(s.logon_time, 'HH24:MI:SS') logon_time, start_time
from v$process p, v$rollname r, v$session s, v$transaction t
where  s.taddr = t.addr
and t.xidusn   = r.usn   
and   p.addr (+) =s.paddr
and s.sid like '&1'
union 
select s.sid "SID", s.serial# "Serial#", p.spid "OS Process", s.username "Oracle User",
   r.name "Rollback", s.osuser "OS User", s.status Status,
   t.used_ublk Blocks, to_char(s.logon_time, 'HH24:MI:SS') logon_time, start_time
from v$process p, v$rollname r, v$session s, v$transaction t
where  s.taddr = t.addr
and t.xidusn   = r.usn   
and   p.addr =s.paddr (+)
and s.sid like '&1'
/

@restore_sqlplus_settings
