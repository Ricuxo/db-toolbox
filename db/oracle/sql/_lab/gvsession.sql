alter session set nls_date_format = 'YYYYMMDD HH24:MI';
set pagesize 999
set linesize 500

column SID format 9999999999
column SERIAL# format 9999999999
column USERNAME format a15
column STATUS format a8
column STATE format a20
column SCHEMANAME format a15
column MACHINE format a28
column PROGRAM format a15
column SQL_TEXT format a64
column LOGON_TIME format a14
column EVENT format a64
column min_wait format 999
column wait_time format 999

select GS.INST_ID
     , SID
     , SERIAL#
     , USERNAME
     , STATUS
     , STATE
     , SCHEMANAME
     , MACHINE
     , substr(PROGRAM, 1, 15) PROGRAM
     , SQ.SQL_TEXT
     , LOGON_TIME
     , EVENT
     , SECONDS_IN_WAIT MIN_WAIT
     , WAIT_TIME
  FROM GV$SESSION GS
     , GV$SQLTEXT SQ
 WHERE GS.SQL_HASH_VALUE = SQ.HASH_VALUE (+)
   AND GS.INST_ID = SQ.INST_ID
   AND GS.SID = NVL('&SID', GS.SID)
   AND ('&&USERNAME' is null or GS.USERNAME LIKE '&&USERNAME')
   AND GS.STATUS = NVL('&STATUS', GS.STATUS)
order by USERNAME, SID, SERIAL#, SQ.PIECE
/

undefine USERNAME

@reset