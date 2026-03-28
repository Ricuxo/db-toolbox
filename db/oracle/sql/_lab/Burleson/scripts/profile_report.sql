/*  */
REM NAME        : PROFILE_REPORT.SQL
REM PURPOSE     : GENERATE USER PROFILES REPORT
REM Revisions:
REM Date          Modified by     Reason for change
REM 08-Apr-1993     MIKE AULT     INITIAL CREATE
REM 14-May-1999     MIKE AULT     Added resource_type
REM
SET FLUSH OFF TERM OFF PAGESIZE 58 LINESIZE 78
COLUMN profile           HEADING Profile
COLUMN resource_name     HEADING 'Resource:'
COLUMN resource_type     HEADING 'Resource|Affects'
COLUMN limit             HEADING Limit
START title80 'ORACLE PROFILES REPORT'
DEFINE output = rep_out/&&db/prof_rep
SPOOL &output
SELECT 
     profile, 
     resource_name,
     resource_type, 
     limit  
FROM 
     sys.dba_profiles
GROUP BY 
     profile;
SPOOL OFF
CLEAR COLUMNS
SET FLUSH ON TERM ON
TTITLE OFF

