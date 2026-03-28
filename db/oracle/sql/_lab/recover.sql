SET pagesize 20000
SET linesize 180
SET pause off
SET serveroutput on
SET feedback on
SET echo on
COL checkpoint_change# for 9999999999999999
SET num format 999999999999999

Spool recovery_info.txt
SELECT SUBSTR (NAME, 1, 80), status
  FROM v$datafile;
SELECT SUBSTR (NAME, 1, 80), RECOVER, fuzzy, checkpoint_change#
  FROM v$datafile_header;
SELECT group#, SUBSTR (MEMBER, 1, 60)
  FROM v$logfile;
SELECT *
  FROM v$recover_file;
SELECT DISTINCT status
           FROM v$backup;
SELECT hxfil filenumber, fhsta status, fhscn SCN, fhrba_seq SEQUENCE
  FROM x$kcvfh
order by 4;
SELECT DISTINCT (fuzzy)
           FROM v$datafile_header;
spool off



--recover database using backup controlfile until time '2012-03-23:18:54:42'


SELECT distinct fhscn SCN,count(1)
  FROM x$kcvfh
group by fhscn 



SELECT distinct fhrba_seq SEQUENCE,count(1)
  FROM x$kcvfh
group by fhrba_seq 

