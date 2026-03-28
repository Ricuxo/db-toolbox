prompt # Leituras em memoria APENAS de sessoes dos usuarios OC4J com status=ACTIVE.
prompt # Query que mais consomem BUFFER GETs(qtde blocos de memoria) POR EXECUCAO.
prompt # cada bloco de memoria equivale ao parametro do init.ora DB_BLOCK_SIZE
prompt # cpu_time = 1000000 microseconds (1 second)
prompt # 
set lines 120
set pages 10000
COLUMN SID format 9999999
column username format a15
column osuser   format a15
column module format a40
column sql_text format a50
column logon format a11
select * from (select   s.sid, s.username 
	       , s.osuser
	       , s.module, to_char(s.logon_time, 'DD/MM HH24:MI') logon
	       , a.hash_value
	       , s.status, round(a.cpu_time/1000000,2) cpu_segundos, a.disk_reads, a.executions, a.buffer_gets, buf_exec, a.sql_text
	         from (select  SQL_TEXT, ADDRESS,
	                       hash_value, cpu_time, EXECUTIONS, BUFFER_GETS, DISK_READS, 
	                       ROUND(BUFFER_GETS/decode(EXECUTIONS, 0, 1, EXECUTIONS)) buf_exec
	                 from v$sqlarea
	                where USERS_OPENING > 0
	                AND   EXECUTIONS >0
	                order by buf_exec desc) a,
	               v$session s
	        where s.sql_address = a.address 
	        AND   s.username is not null
	        and   s.username like 'OC4J%'
	        AND   S.STATUS = 'ACTIVE'
	        ORDER BY buf_exec desc)
	where rownum < 300
	ORDER BY buf_exec desc;
