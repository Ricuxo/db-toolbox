REM " Gera script de restore RMAN"
REM " Autor - Andre Campos - 03/08/2009"

SET heading on;
SET verify off;
SET feedback off;
SET recsep off;
SET lin 10000
COL NEXT_TIME for a25

PROMPT
pause "VERIFICAR QUAL SEQUENCIA DE ARCHIVE PARA O PONTO DO RESTORE"

SELECT sequence#,
       TO_CHAR (completion_time, 'dd/mm/yyyy hh24:mi:ss') AS "NEXT_TIME"
  FROM v$archived_log
 WHERE next_time > TRUNC (SYSDATE - 5);

ACCEPT V_Sequence prompt "Informe a Sequencia de Archive Equivalente ao Horario a Ser Restaurado..................:"
PROMPT
ACCEPT File_System prompt "Informe o nome do File System </file_system_name>..................:"
PROMPT
ACCEPT Host_Destino prompt "Informe o nome do Servidor onde será feito o restore..................:"
PROMPT

SET pages 0
SET heading on;
SELECT 'export ORACLE_SID=' || NAME || ''
  FROM v$database;
spool %temp%\restore.txt   
REM "Informar password para usuário de backup"
SELECT '$ORACLE_HOME/bin/rman rcvcat rmanbackup/backupedm@rmanp1'
  FROM DUAL;
SELECT 'connect target /'
  FROM DUAL;
SELECT 'set DBID=' || dbid || ''
  FROM v$database;
PROMPT
SELECT 'SQL "startup nomount";'
  FROM DUAL;
PROMPT
SELECT 'run 
   {'
  FROM DUAL;

REM "Informar sequencia de archive equivalente ao dia e horario a ser restaurado"
REM SELECT sequence#,
REM       TO_CHAR (completion_time, 'dd/mm/yyyy hh24:mi:ss') AS "NEXT_TIME"
REM  FROM v$archived_log
REM WHERE next_time > TRUNC (SYSDATE - 1);

SELECT 'set until sequence &V_Sequence thread 1;'
  FROM DUAL;

SELECT 'allocate channel c1 type ''SBT_TAPE'';'
  FROM DUAL;

SELECT 'allocate channel c2 type ''SBT_TAPE'';'
  FROM DUAL;

REM "Informar o HOST onde será feito restore"
SELECT 'send ''NSR_ENV=(NSR_SERVER=snehpu43.internal.timbrasil.com.br, NSR_CLIENT=&Host_Destino..internal.timbrasil.com.br)'';'
  FROM DUAL;
SELECT 'restore controlfile;'
  FROM DUAL;
SELECT 'SQL "alter database mount";'
  FROM DUAL;

SELECT    'set newname for datafile '
       || file#
       || ' TO '''
       || REPLACE (NAME,
                   SUBSTR (NAME, 1, INSTR (NAME, '/', 1, 2)),
                   '&&File_system/'
                  )
       || ''';'
  FROM v$datafile
UNION ALL
SELECT 'restore datafile ' || file_id || '; '
  FROM dba_data_files
UNION ALL
SELECT 'switch datafile all;'
  FROM DUAL
UNION ALL
SELECT 'recover datafile ' || file_id || '; '
  FROM dba_data_files
UNION ALL
SELECT    'SQL "alter database rename file '''''
       || MEMBER
       || ''''''
       || CHR (10)
       || '     TO '''''
       || REPLACE (MEMBER,
                   SUBSTR (MEMBER, 1, INSTR (MEMBER, '/', 1, 2)),
                   '&&File_System/'
                  )
       || '''''";'
  FROM v$logfile;
SELECT ' }'
  FROM DUAL;
SELECT 'SQL ''alter database open resetlogs'';'
  FROM DUAL;
SELECT    'SQL "alter tablespace '
       || tablespace_name
       || ' add tempfile '''''
       || REPLACE (file_name,
                   SUBSTR (file_name, 1, INSTR (file_name, '/', 1, 2)),
                   '&&File_system/'
                  )
       || ''''' size '
       || BYTES / 1024 / 1024
       || 'M";'
  FROM dba_temp_files
/
spool off
ed %temp%\restore.txt
PROMPT

