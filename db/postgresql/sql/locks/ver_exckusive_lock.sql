-- =============================================================================
-- Script : ver_exclusive_lock.sql
-- Banco  : PostgreSQL
-- Objetivo: Listar sessoes que possuem AccessExclusiveLock ativo,
--           exibindo PID, usuario, aplicacao, estado, query em execucao
--           e o objeto bloqueado.
-- Uso    : Util para identificar sessoes que podem estar causando bloqueio
--          em operacoes DDL ou de manutencao de tabelas.
-- =============================================================================

SELECT
    a.pid,
    a.usename,
    a.application_name,
    a.state,
    a.query,
    l.locktype,
    l.mode,
    l.granted,
    l.relation::regclass AS objeto
FROM pg_locks l
JOIN pg_stat_activity a
  ON a.pid = l.pid
WHERE l.mode = 'AccessExclusiveLock';