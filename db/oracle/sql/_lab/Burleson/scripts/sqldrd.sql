/*  */
REM Name: sqldrd.sql
REM Function: return the sql statements from the shared area with
REM Function: highest disk reads
REM History: Presented in paper 35 at IOUG-A 1997, converted for
REM use 6/24/97 MRA
REM
DEFINE access_level = 500 (NUMBER)
COLUMN username FORMAT a10 HEADING 'User Name'
COLUMN executions 	FORMAT 999,999 	 HEADING 'Exec'
COLUMN sorts 		FORMAT 99999 	 HEADING 'Sorts'
COLUMN command_type 	FORMAT 99999 	 HEADING 'CmdT'
COLUMN disk_reads 	FORMAT 999,999,999 HEADING 'Block Reads'
COLUMN sql_text 	FORMAT a70 	HEADING 'Statement' WORD_WRAPPED
SET LINES 130 VERIFY OFF FEEDBACK OFF pages 50 trimspool on
START title132 'SQL Statements With High Reads'
SPOOL rep_out/&db/sqldrd.lis
SELECT 
	username, executions,
	sorts,command_type,
	disk_reads,sql_text
FROM 
	v$sqlarea, dba_users
WHERE 
        parsing_user_id=user_id and 
        username not in ('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC')
	and disk_reads > &&access_level
ORDER BY 
	disk_reads;
SPOOL OFF
SET LINES 80 VERIFY ON FEEDBACK ON
undef access_level

