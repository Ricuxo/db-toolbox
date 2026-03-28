set lines 160
col MESSAGE for a100
col TIMESTAMP for a20
select message, 	TO_CHAR(TIMESTAMP, 'DD-MM-RRRR HH24:MI:SS') "TIMESTAMP" from v$dataguard_status;
