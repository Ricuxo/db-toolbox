prompt # Leituras fisicas 
prompt # Query que mais consomem DISK READS(qtde blocos) POR EXECUCAO,  com LOGON TIME de HOJE(conexao de hoje).
prompt # cada bloco ao parametro do init.ora DB_BLOCK_SIZE
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
	       , s.status, round(a.cpu_time/1000000,2) cpu_segundos, a.disk_reads, a.executions, a.buffer_gets, dsk_exec, a.sql_text
	         from (select  SQL_TEXT, ADDRESS,
	                       hash_value, cpu_time, EXECUTIONS, BUFFER_GETS, DISK_READS, 
	                       ROUND(DISK_READS/decode(EXECUTIONS, 0, 1, EXECUTIONS)) dsk_exec
	                 from v$sqlarea
	                where USERS_OPENING > 0
	                AND   EXECUTIONS >0
	                order by dsk_exec desc) a,
	               v$session s
	        where s.sql_address = a.address 
	        AND   s.username is not null
	        and   s.logon_time > trunc(sysdate)
	        ORDER BY dsk_exec desc)
	where rownum < 30
	ORDER BY dsk_exec desc;
