set pages 1000 lines 1000
column sid format 9999999
column program format a30
column username format a15
column osuser format a15
column name format a27
column machine format a30
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
select  s.sid SID, s.username, s.osuser, s.SQL_HASH_VALUE, s.status, n.name,
        a.value Cpu,
        s.program, s.logon_time, s.LAST_CALL_ET, s.machine
  from v$session s, v$sesstat a, v$statname n
 where a.statistic# IN (8,11,12,233)
 and   a.statistic# = n.statistic#
 and   a.sid=s.sid
 and   a.value > 1000
 and   s.username is not null
 and   s.logon_time > trunc(sysdate)
order by a.value desc;
 