Rem
Rem    NOME
Rem      plus.sql 
Rem
Rem    DESCRIÇÃO
Rem      Ajustes do ambiente SQl*Plus e informações da base de dados.
Rem
Rem    UTILIZAÇÃO
Rem      @plus
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      26/01/07 - criação do script
Rem      NORONHA      30/10/09 - Logon Automático, FlashBack ON/OFF
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set tab off
--SET SQLPLUSCOMPATIBILITY 8.1.7
-- Format for administration purpose
col object_name for a15
col grantee for a20
col grantor for a20
col privilege for a25
col sql_text for a75
col file_name for a45
col column_name for A20
col object_name for A30
col spid for A7
col sid for 999999
col serial# for 9999999
col segment_name for a25
col degree for a5
col owner for a20
col table_owner for a20
col table_name for a20
col comments for a90
col partition_name for a4 heading Part
col subpartition_name for a5 heading Spart
col truncated for a5
col username FOR A10
col status for A3 trunc
col osuser for A10
col machine for A20 trunc
col terminal for A15
col program for A25 trunc
col module for A16
col member for A40
col waiting_session heading wait for 9999999
col holding_session heading holding for 9999999
col lock_type for a13
col mode_held for a10
col mode_requested for a15
col db_link for a25
col referenced_owner for a15
col referenced_name for a20
col referenced_link_name for a25
col host for a20
col directory_path for a40
col parameter for a30
col value for a30
col triggering_event for a40
col sid_serial for a15
col last_call_et for a15 heading 'LAST_CALL_ET|HH:MM:SS' justify r
col load for a6 justify right
col executes for 9999999
col sql_text for a100
col name for a15
col file_id for 9999
col mb for 99999


-- Used by Trusted Oracle
col rowlabel format a15

-- used for the show errors command
col line/col for a8
col error for a65  word_wrapped

-- used for the show sga command
col name_col_plus_show_sga for a24

-- defaults for show parameters
col name_col_plus_show_param for a36 heading name
col value_col_plus_show_param for a30 heading value

-- defaults for set autotrace explain report
col id_plus_exp for 990 heading i
col parent_id_plus_exp for 990 heading p
col plan_plus_exp for a60
col object_node_plus_exp for a8
col other_tag_plus_exp for a29
col other_plus_exp for a44

-- info
set heading off time on feedback off
column user new_value usuario
column name new_value instancia
column host_name new_value nome_host
column crlf new_value crlf
column sid_curr new_value sid_da_sessao
set termout off
set linesize 1000
-- Sets do SQLPlus
clear breaks
clear columns
set heading on
set long 10000000
set longchunksize 1000
set feedback on
set verify off

set pagesize 9000
set trimspool on
SET SQLPROMPT 'system on &&_CONNECT_IDENTIFIER> ' 
SET TERMOUT ON
