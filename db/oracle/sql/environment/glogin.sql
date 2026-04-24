-- ############################################################
-- glogin.sql - Global SQL*Plus Environment
-- Autor: DBA Team
-- Descrição: Configurações padrão ao conectar no SQL*Plus
-- ############################################################

-- ===== IDENTIFICAÇÃO DO AMBIENTE =====
SET TERMOUT ON
SET ECHO OFF
SET FEEDBACK ON
SET VERIFY OFF
SET HEADING ON
SET PAGESIZE 100
SET LINESIZE 200
SET TRIMSPOOL ON
SET TAB OFF
SET SERVEROUTPUT ON SIZE UNLIMITED

-- ===== FORMATAÇÃO DE DATAS =====
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

-- ===== PROMPT CUSTOMIZADO =====
COLUMN _USER NEW_VALUE MY_USER
COLUMN _CONNECT_IDENTIFIER NEW_VALUE MY_DB

SELECT 
    USER AS _USER,
    SYS_CONTEXT('USERENV','DB_NAME') AS _CONNECT_IDENTIFIER
FROM dual;

SET SQLPROMPT '_USER@_CONNECT_IDENTIFIER> '

-- ===== INFORMAÇÕES DO AMBIENTE AO CONECTAR =====
PROMPT
PROMPT ==========================================
PROMPT   Conectado em:
PROMPT ==========================================

SELECT 
    name         AS DB_NAME,
    open_mode,
    database_role,
    TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS') AS DATA_ATUAL
FROM v$database;

PROMPT ==========================================
PROMPT

-- ===== ALERTA PARA PRODUÇÃO =====
COLUMN DB_ROLE NEW_VALUE DB_ROLE
SELECT database_role AS DB_ROLE FROM v$database;

BEGIN
    IF '&&DB_ROLE' = 'PRIMARY' THEN
        DBMS_OUTPUT.PUT_LINE('*** ATENCAO: VOCE ESTA NO BANCO PRIMARIO ***');
    END IF;
END;
/

-- ===== AJUSTES PARA CONSULTAS =====
COL username FORMAT A20
COL machine FORMAT A30
COL program FORMAT A40
col job_name for a30

-- ===== ALIAS ÚTEIS =====
DEFINE _EDITOR=vi

-- ===== HISTÓRICO DE COMANDOS (se suportado) =====
SET HISTORY ON

-- ===== DESATIVA SUBSTITUIÇÃO AUTOMÁTICA CHATINHA =====
SET DEFINE ON

-- ===== MENSAGEM FINAL =====
PROMPT Ambiente pronto para uso.
PROMPT