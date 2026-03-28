/*  */
REM FUNCTION: SCRIPT FOR CREATING 9.1 DB FROM EXISTING DB
REM           This script must be run by a user with the DBA role.
REM           This script is intended to run with Oracle9i.
REM           Running this script will in turn create a script to 
REM           rebuild the database.  This created 
REM           script, crt_db91.sql,  is run by SQLDBA
REM           Only preliminary testing of this script was performed.
REM           Be sure to test it completely before relying on it.
REM M. Ault 8/23/01 Burleson Consulting Consulting
REM
rem SET VERIFY OFF FEEDBACK OFF ECHO OFF PAGES 0
SET TERMOUT ON
PROMPT Creating db build script...
DROP SEQUENCE lineno_seq;
CREATE SEQUENCE lineno_seq MINVALUE 1 INCREMENT BY 1 NOCACHE; 
set verify on feedback on echo on

execute recreate_db2;
