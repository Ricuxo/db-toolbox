Rem
Rem    NOME
Rem      control.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script exibe informações sobre os arquivos de controles (CONTROL FILES).
Rem
Rem    UTILIZAÇÃO
Rem      @control
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      13/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------


col NAME for a70
set feedback off

PROMPT
PROMPT    DESCRIÇÃO: Este script exibe informações sobre os arquivos de controles (CONTROL_FILES).

select * from v$controlfile;


PROMPT
PROMPT   CONTROL_FILE_RECORD_KEEP_TIME: Specifies the minimum number of days before a reusable record  
PROMPT   in the control file can be reused. In the event a new record needs to be added to a reusable section and the 
PROMPT   oldest record has not aged enough, the record section expands. If this parameter is set to 0,
PROMPT   then reusable sections never expand, and records are reused as needed.

   
col NAME for a30
col VALUE for a10
select NAME, VALUE from V$PARAMETER where NAME = 'control_file_record_keep_time';
PROMPT

PROMPT
PROMPT OBS: Para ver mais informações tecle ENTER!
PAUSE

select * from V$CONTROLFILE_RECORD_SECTION;

PROMPT
PROMPT TYPE              - Identifies the type of record section: DATABASE, CKPT PROGRESS, REDO THREAD,  
PROMPT  "                   REDO LOG, DATAFILE, FILENAME, TABLESPACE, LOG HISTORY, OFFLINE RANGE, ARCHIVED LOG, 
PROMPT  "                   BACKUP SET, BACKUP PIECE, BACKUP DATAFILE, BACKUP REDOLOG, DATAFILE COPY, 
PROMPT  "                   BACKUP CORRUPTION, COPY CORRUPTION, DELETED OBJECT, or PROXY COPY.
PROMPT RECORD_SIZE       - Record size in bytes
PROMPT RECORDS_TOTAL     - Number of records allocated for the section  
PROMPT RECORDS_USED      - Number of records used in the section 
PROMPT FIRST_INDEX       - Index (position) of the first record  
PROMPT LAST_INDEX        - Index of the last record  
PROMPT LAST_RECID        - Record ID of the last record
PROMPT
PROMPT
set feedback on