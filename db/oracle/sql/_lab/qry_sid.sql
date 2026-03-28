prompt # 
prompt # Query's executadas por uma determinada sessao (informar o SID)
prompt # cada bloco de memoria equivale ao parametro do init.ora DB_BLOCK_SIZE
prompt # cpu_time = 1000000 microseconds (1 second)
prompt # 
set lines 120
set pages 10000
UNDEF SID
COLUMN SID format 9999999
column username_oc format a15
column osuser   format a15
column module format a40
column sql_text format a50
column logon format a11
select * from (select   s.sid, decode(v.user_name, null, s.username, v.user_name) username_oc
	       , s.osuser
	       , s.module, to_char(s.logon_time, 'DD/MM HH24:MI') logon
	       , v.hash_value
	       , s.status, round(a.cpu_time/1000000,2) cpu_segundos
	       , a.disk_reads, a.executions, a.buffer_gets, a.BUFFER_GETS/decode(a.executions,0,1,a.executions) buf_exec
	       , a.sql_text
	         from V$OPEN_CURSOR V, V$SESSION S, v$sqlarea a
	        WHERE S.SID = V.SID
                and s.sid = &sid
                and a.address = v.address
                AND   s.username is not null
	        and   s.logon_time > trunc(sysdate)
	        ORDER BY buf_exec desc)
	ORDER BY buf_exec desc;
UNDEF SID
