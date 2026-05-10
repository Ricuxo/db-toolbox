/*
-----------------------------------------------------------------------------------
Nome      : lock_blocking_sessions.sql
Objetivo  : Identificar sessões bloqueadas e suas respectivas sessões bloqueadoras
Banco     : PostgreSQL

Descrição :
Esta query analisa os locks ativos no banco de dados, identificando sessões que
estão aguardando por locks (waiting) e correlacionando com as sessões que estão
mantendo esses locks (blocking).

Ela permite visualizar:
- Sessões bloqueadas (waiting)
- Sessões bloqueadoras (blocking)
- Queries envolvidas
- Tipo de lock
- Tabelas afetadas

Uso típico :
- Troubleshooting de lentidão
- Identificação de deadlocks ou contenção
- Monitoramento de concorrência

Observações :
- Baseado nas visões pg_locks e pg_stat_activity
- Considera locks por relation (tabela) e transactionid
- Ignora auto-bloqueios (mesmo PID)

Autor     : <seu nome>
Data      : <data>
-----------------------------------------------------------------------------------
*/

SELECT
    waiting.locktype           AS waiting_locktype,
    waiting.relation::regclass AS waiting_table,
    waiting_stm.query          AS waiting_query,
    waiting.mode               AS waiting_mode,
    waiting.pid                AS waiting_pid,
    other.locktype             AS other_locktype,
    other.relation::regclass   AS other_table,
    other_stm.query            AS other_query,
    other.mode                 AS other_mode,
    other.pid                  AS other_pid,
    other.granted              AS other_granted
FROM
    pg_catalog.pg_locks AS waiting
JOIN
    pg_catalog.pg_stat_activity AS waiting_stm
    ON (
        waiting_stm.pid = waiting.pid
    )
JOIN
    pg_catalog.pg_locks AS other
    ON (
        (
            waiting."database" = other."database"
        AND waiting.relation  = other.relation
        )
        OR waiting.transactionid = other.transactionid
    )
JOIN
    pg_catalog.pg_stat_activity AS other_stm
    ON (
        other_stm.pid = other.pid
    )
WHERE
    NOT waiting.granted
AND
    waiting.pid <> other.pid;