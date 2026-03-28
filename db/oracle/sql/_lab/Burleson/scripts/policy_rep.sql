/*  */
COL object_owner format a15 heading 'Owner'
COL object_name format a15 heading 'Object'
COL policy_name format a15 heading 'Policy'
COL pf_owner format a15 heading 'Policy Proc Owner'
COL PACKAGE format a15 heading 'Policy Package'
col FUNCTION format a15 heading 'Policy Function'
col sel format a1 heading 'S'
col ins format a1 heading 'I'
col upd format a1 heading 'U'
col del format a1 heading 'D'
set lines 132 pages 50
@title132 'Fine Grained Security Policies'
spool rep_out\&db\fgs_report
SELECT
OBJECT_OWNER,
OBJECT_NAME,    
POLICY_NAME,    
PF_OWNER,       
PACKAGE,        
FUNCTION,       
DECODE(SEL,'YES','Y','NO','N',SEL) SEL,            
DECODE(INS,'YES','Y','NO','N',INS) INS,            
DECODE(UPD,'YES','Y','NO','N',UPD) UPD,            
DECODE(DEL,'YES','Y','NO','N',DEL) DEL,            
CHK_OPTION,     
ENABLE
FROM DBA_POLICIES;
SPOOL OFF
set lines 80 pages 22
ttitle off
