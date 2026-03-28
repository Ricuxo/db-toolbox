prompt # 
prompt # Gera lista para MATAR as sessoes que estao a um determinado tempo parado
prompt # É possivel alterar o script e informar as sessoes de usuario OC4J%
prompt # de forma que será gerado a lista apenas de sessoes destes usuários.
prompt # 
prompt # O valor passado na variavel QTDE_SEGUNDOS_WAIT é o parametro
prompt # que será utilizado para trazer as sessoes que estao a este X segundos parado.
prompt # 
set pages 1000 lines 150
column sid format 99999999
column matar format a25
column osuser format a20
column username format a20
column logon_time format a20
undef qtde_segundos_wait
 
select 'kill -9 '||p.spid||'    ## ' matar, s.sid, s.username, s.osuser, trunc(w.seconds_in_wait/60/60) wait_horas, to_char(LOGON_TIME, 'dd/mm/yyyy hh24:mi:ss') logon_time
from v$session s, v$process p, v$session_wait w
where s.sid = p.pid 
and   s.sid = w.sid
and   s.status = 'INACTIVE'
--and   s.username like 'OC4J%' -- caso queira selecionar apenas usuarios OC4J%
and   s.username is not null
and   w.seconds_in_wait > &qtde_segundos_wait
/

undef qtde_segundos_wait