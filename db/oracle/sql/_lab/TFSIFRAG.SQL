SET ECHO off 
REM NAME:   TFSIFRAG.SQL 
REM USAGE:"@path/tfsifrag schema_name index_name" 
REM ------------------------------------------------------------------------ 
REM REQUIREMENTS: 
REM    SELECT on INDEX_STATS 
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    Reports index fragmentation statistics 
REM ------------------------------------------------------------------------ 
REM EXAMPLE: 
REM                     Index Fragmentation Statistic 
REM                 
REM    index name        S_EMP_USERID_UK 
REM    leaf rows deleted            0 
REM    leaf rows in use            25 
REM    index badness            0.000   
REM  
REM ------------------------------------------------------------------------ 
REM Main text of script follows: 
set verify off  
def ownr  = &&1  
def name  = &&2  
  
ttitle - 
  center 'Index Fragmentation Statistic'   skip 2 
  
set heading off  
  
col name                 newline  
col lf_blk_rows          newline  
col del_lf_rows          newline  
col ibadness newline   
  
validate index &ownr..&name;  
  
select  
  'index name        '||name,  
  'leaf rows deleted '||to_char(del_lf_rows,'999,999,990')  del_lf_rows,  
  'leaf rows in use  '||to_char(lf_rows-del_lf_rows,'999,999,990')  lf_blk_rows,	  
  'index badness     '||to_char(del_lf_rows/(lf_rows+0.00001),'999,990.999') ibadness  
from  
  index_stats  
/  
  
undef ownr  
undef name  
set verify on