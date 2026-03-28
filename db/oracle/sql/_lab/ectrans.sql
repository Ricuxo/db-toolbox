col sid for 99999
col username for a12
col osuser for a12
col start_time for a20
col tamanho for 99,999,999,990
col log_io for 999,999,990
col phy_io for 999,999,990
col tablespace_name for a20
col inst_id for 999

select d.sid, d.username, d.osuser, start_time, round(a.used_ublk * c.block_size / 1024) tamanho, a.log_io, a.phy_io, b.tablespace_name
from v$transaction a, dba_rollback_segs b, dba_tablespaces c, v$session d
where a.xidusn = b.segment_id and
b.tablespace_name = c.tablespace_name and
a.ses_addr = d.saddr;
