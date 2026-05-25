-- ############################################################
-- glogin.sql - Global SQL*Plus Environment (Production-Grade)
-- Autor: DBA Team
-- Compatibilidade: Oracle 11g, 12c, 18c, 19c — Standalone, RAC, DataGuard
-- Revisão: 2025
-- ############################################################

-- ===== SUPRIME SAÍDA DOS COMANDOS INTERNOS DO GLOGIN =====
SET TERMOUT ON
SET ECHO OFF
SET FEEDBACK OFF        -- OFF durante setup; ativado no final
SET VERIFY OFF
SET DEFINE ON           -- mantém substituição ativa (&var), mas controlada
SET SERVEROUTPUT ON SIZE UNLIMITED

-- ===== FORMATAÇÃO GERAL =====
SET HEADING ON
SET PAGESIZE 100
SET LINESIZE 220
SET TRIMSPOOL ON
SET TAB OFF
SET WRAP OFF
SET NULL '<NULL>'       -- exibe NULL explicitamente — evita confusão com string vazia
SET TIMING ON           -- exibe tempo de execução de cada statement
SET AUTOCOMMIT OFF      -- segurança: sem commit implícito acidental

-- ===== FORMATAÇÃO DE DATAS =====
ALTER SESSION SET NLS_DATE_FORMAT        = 'DD/MM/YYYY HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT   = 'DD/MM/YYYY HH24:MI:SS.FF3';

-- ===== PROMPT DINÂMICO (usa variáveis built-in do SQL*Plus) =====
-- _USER              : usuário conectado (built-in, atualizado automaticamente)
-- _CONNECT_IDENTIFIER: identificador de conexão (built-in)
-- Ref: SQL*Plus User's Guide 19c — SET SQLPROMPT
SET SQLPROMPT "_USER'@'_CONNECT_IDENTIFIER'> '"

-- ===== INFORMAÇÕES DO AMBIENTE AO CONECTAR =====
PROMPT
PROMPT ==========================================
PROMPT   CONEXAO ESTABELECIDA
PROMPT ==========================================

SELECT
    d.name                                          AS DB_NAME,
    d.db_unique_name                                AS DB_UNIQUE_NAME,
    d.open_mode,
    d.database_role,
    i.host_name,
    i.version,
    TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS')        AS DATA_HORA
FROM v$database d, v$instance i;

PROMPT ==========================================
PROMPT

-- ===== ALERTA DE AMBIENTE (PRIMARY / STANDBY / READ ONLY) =====
-- Usa query direta — evita problema de &&var não definida em PL/SQL anônimo
SET FEEDBACK OFF
COLUMN alerta_env NOPRINT NEW_VALUE ALERTA_ENV

SELECT
    CASE database_role
        WHEN 'PRIMARY'              THEN '*** ATENCAO: BANCO PRIMARIO — CUIDADO COM DDL/DML ***'
        WHEN 'PHYSICAL STANDBY'     THEN '>>> STANDBY FISICO (Data Guard) — somente leitura'
        WHEN 'LOGICAL STANDBY'      THEN '>>> STANDBY LOGICO (Data Guard)'
        WHEN 'SNAPSHOT STANDBY'     THEN '>>> SNAPSHOT STANDBY — DML permitido temporariamente'
        ELSE database_role
    END AS alerta_env
FROM v$database;

PROMPT &&ALERTA_ENV
PROMPT

-- ===== ALIASES DE COLUNA PADRÃO (DBA day-to-day) =====
COL username        FORMAT A25
COL machine         FORMAT A35
COL program         FORMAT A40
COL sid             FORMAT 99999
COL serial#         FORMAT 999999
COL status          FORMAT A10
COL sql_id          FORMAT A15
COL event           FORMAT A40
COL wait_class      FORMAT A20
COL object_name     FORMAT A35
COL owner           FORMAT A20
COL job_name        FORMAT A35
COL log_mode        FORMAT A12
COL db_unique_name  FORMAT A20
COL host_name       FORMAT A40
COL open_mode       FORMAT A20
COL database_role   FORMAT A20

-- ===== EDITOR PADRÃO =====
DEFINE _EDITOR = vi

-- ===== HISTÓRICO DE COMANDOS =====
-- Suportado a partir do SQL*Plus 12.2 (client-side)
-- Comente a linha abaixo se estiver usando client 11g
SET HISTORY ON

-- ===== REATIVA FEEDBACK PARA SESSÃO INTERATIVA =====
SET FEEDBACK ON

-- ===== MENSAGEM FINAL =====
PROMPT Ambiente pronto. TIMING ON | AUTOCOMMIT OFF | NULL exibido como <NULL>
PROMPT