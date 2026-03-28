--Este comando é útil para monitorar sessões ativas no banco de dados. Ele lista todas as sessões ativas, exibe o comando em execução, 
--o tempo médio por execução e apresenta os planos de execução do comando. Caso o comando tenha mais de um plan_hash_value, todos são exibidos na mesma linha.
--As sessões são ordenadas pelo tempo médio por execução (sec_per_exec) em ordem decrescente, facilitando a identificação de comandos com maior custo de execução.

SELECT 
 s.inst_id,
 s.username,
 s.sid, 
 s.serial#, 
 s.status, 
 s.client_identifier, 
 s.sql_id, 
 s.last_call_et,
 DECODE(
 NVL(MAX(q.executions), 0), 
 0, 
 MAX(q.executions), 
 ROUND(SUM(q.elapsed_time) / SUM(q.executions) / 1000000, 2)
 ) AS sec_per_exec,    MAX(q.executions) AS executions, 
 LISTAGG(q.plan_hash_value, ', ' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER BY q.plan_hash_value) AS plan_hash_values,
 MAX(q.sql_plan_baseline) AS sql_plan_baseline, 
 MAX(q.sql_profile) AS sql_profile, 
 MAX(q.SQL_PATCH) AS sql_patch
FROM 
 gv$session s
JOIN 
 gv$sql q
ON 
 s.sql_id = q.sql_id
 AND s.inst_id = q.inst_id
WHERE s.status = 'ACTIVE' 
 AND s.type='USER'
 AND s.username <> USER
GROUP BY 
 s.inst_id, 
 s.username, 
 s.sid, 
 s.serial#, 
 s.status, 
 s.client_identifier, 
 s.sql_id, 
 s.last_call_et
ORDER BY 
 sec_per_exec DESC;