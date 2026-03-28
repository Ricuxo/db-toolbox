select /*+ PARALLEL(10) */ users.username as "Login",users.ACCOUNT_STATUS as "Status da Conta",users.CREATED as "Data de criacao", users.PROFILE as "Perfil", MAX(to_char(TIMESTAMP, 'dd/mm/yyyy hh24:mi:ss')) as "Ultimo Login",
aud.os_username as "Os User",aud.userhost as "Host Origem",aud.terminal as "Terminal"
FROM dba_users users 
FULL OUTER JOIN dba_audit_trail aud
ON aud.username = users.username
AND aud.action_name = 'LOGON'
GROUP BY users.username,users.ACCOUNT_STATUS,users.CREATED,users.PROFILE,aud.os_username,aud.userhost,aud.terminal;



----12 em diante
select username as "Login",ACCOUNT_STATUS as "Status da Conta", CREATED as "Data de criacao", PROFILE as "Perfil", LAST_LOGIN as "Ultimo Login"
from dba_users;
