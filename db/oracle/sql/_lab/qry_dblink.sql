prompt > 
prompt > Sessoes que mais estao consumindo recurso via DBLINKs
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic# in (185,186)
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
