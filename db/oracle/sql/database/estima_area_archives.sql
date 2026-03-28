set head off
set pagesize 0
set linesize 132
select host||' - '||instancia||' - '||'('||QTDE||'*'||TAMANHO||'*'||SEMANA||') = '||QTDE*TAMANHO*SEMANA/1024/1024/1024||' GB' FROM
(select host_name host,instance_name instancia from v$instance),
(select count(*)/05 QTDE from v$log_history where trunc(first_time) >= trunc(sysdate - 5) and trunc(first_time) <= trunc(sysdate)),
(SELECT BYTES TAMANHO FROM V$LOG WHERE rownum=1),
(SELECT 5 SEMANA FROM DUAL);