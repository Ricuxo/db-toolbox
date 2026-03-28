REM -------------------------------------------------------------------------- 
REM REQUIREMENTS: 
REM    select access on  v$px_session px, v$session s, v$instance i 
REM -------------------------------------------------------------------------- 
REM PURPOSE: 
REM    To lists users running a parallel query and their associated slaves. 
REM --------------------------------------------------------------------------- 
REM DISCLAIMER: 
REM    This script is provided for educational purposes only. It is not 
REM    supported by Oracle Support Services. 
REM    The script has been tested and appears to work as intended. 
REM    You should always run new scripts on a test instance initially. 
REM -------------------------------------------------------------------------- 
REM Main text of script follows: 

col username for a12 
col "QC SID" for A6 
col SID for A6 
col "QC/Slave" for A10 
col "Requested DOP" for 9999 
col "Actual DOP" for 9999 
col "slave set" for  A10 
set pages 100 

select 
  s.inst_id,
  decode(px.qcinst_id,NULL,username, 
        ' - '||lower(substr(s.program,length(s.program)-4,4) ) ) "Username", 
  decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" , 
  to_char( px.server_set) "Slave Set", 
  to_char(s.sid) "SID", 
  decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) "QC SID", 
  px.req_degree "Requested DOP", 
  px.degree "Actual DOP",
  s.event
from 
  gv$px_session px, 
  gv$session s 
where 
  px.sid=s.sid (+) 
 and 
  px.serial#=s.serial# 
 and px.inst_id=s.inst_id
order by 6 ,2, 1 desc 
/ 

