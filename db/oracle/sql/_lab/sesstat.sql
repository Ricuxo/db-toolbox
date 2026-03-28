prompt # 
prompt # Mostra as 10 sessoes que mais estao consumindo o recurso
prompt # O valor da blocagem corresponde o parametro "db_block_size=Xk"
prompt # 

column username format a15
column osuser format a20
column logon format a11
set lines 300
prompt > 
prompt > QTDE de commits executados, statistic#=4 (user commits)
select sum(b.value) from v$sesstat b where b.statistic#=4;

prompt > 
prompt > Sessoes que mais executaram commit HOJE, statistic#=4 (user commits)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=4
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que mais executaram rollback HOJE, statistic#=5 (user rollbacks)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=5
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que estao consumindo PGA, "statistic# in 20,21" (user rollbacks)
select * from (select a.sid, a.username, a.osuser, a.status, b.statistic#, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic# in (15,16,20,21)
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que estao consumindo mais DB_CACHE(value=qtde blocos Xk), statistic#=40 (db block gets)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=40
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que estao consumindo mais DB_CACHE e Memory reads(value=qtde blocos Xk), statistic#=41 (consistent gets)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=41
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que estao consumindo mais Physical Reads(value=qtde blocos Xk), statistic#=42 (physical reads)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=42
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que estao alterando DB_CACHE(value=qtde blocos Xk), statistic#=43 (db block changes)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=43
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que estao alterando DB_CACHE e Memory Write(value=qtde blocos Xk), statistic#=44 (consistent changes)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=44
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que mais estao realizando Physical Write(value=qtde blocos Xk), statistic#=46 (physical writes)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=46
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que mais estao realizando Physical Write(value=qtde blocos Xk) sem checkpoint, statistic#=47 (physical writes non checkpoint)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=47
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que mais estao realizando Physical Reads com direct path(value=qtde blocos Xk), statistic#=97 (physical reads direct)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=97
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que mais estao realizando Physical Writes com direct path(value=qtde blocos Xk), statistic#=98 (physical writes direct)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=98
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que mais estao realizando Physical Reads com LOB(value=qtde blocos Xk), statistic#=99 (physical reads direct (lob))
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=99
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que mais estao realizando Physical Write com LOB(value=qtde blocos Xk), statistic#=100 (physical writes direct (lob))
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=100
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que mais estao gerando redo, statistic#=119 (redo writes)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=119
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que mais estao gerando Blocos de redo(value=qtde blocos Xk), statistic#=120 (redo blocks written)
select * from (select a.sid, a.username, a.osuser, a.status, 
                      to_char(a.logon_time, 'DD/MM HH24:MI') logon,  b.value, a.SQL_HASH_VALUE, w.SECONDS_IN_WAIT sec_wait, a.program, a.module, w.event
                 from v$session a, v$sesstat b, v$session_wait w
                where b.statistic#=120
                  and a.sid = b.sid
                  and a.sid = w.sid
                  and a.username is not null
                  and a.logon_time > trunc(sysdate)
                order by b.value desc) a
         where rownum <10;
prompt > 
prompt > Sessoes que mais estao gerando consumindo recurso via DBLINKs
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
