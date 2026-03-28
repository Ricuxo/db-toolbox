/*  */
REM
REM  FUNCTION: SCRIPT FOR CAPTURING OBJECT GRANTS
REM
REM  FUNCTION: This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM  FUNCTION: Running this script will create a script of all the object
REM  FUNCTION: grants to users and roles.  This created script is called 
REM  FUNCTION: grant_rc.sql.
REM
REM Since a DBA cannot grant objects other than his own, this script will 
REM contain various connect clauses before each set of grant statements.  
REM You must add the passwords for each user before executing the script.  
REM Object grants are very dependant on the user who issues the grant, 
REM therefore, it is important that the correct user issue the grant.
REM 
REM In addition, DO NOT change the order of the grant statement.  They are 
REM spooled in sequence order, so that dependant grants are executed in 
REM the correct order.  For example, lets say that Scott grants Jack select on 
REM emp with grant option, and in turn Jack grants select on Scott.emp to 
REM Steve.  It is essential that Scott's grant be issued before Jack's.  
REM Otherwise, Jack's grant will fail.
REM
REM NOTE:  This script DOES NOT include grants made by 'SYS'.
REM
REM Only preliminary testing of this script was performed.  Be sure to test
REM it completely before relying on it.
REM
 
set verify off
set feedback off
rem set termout off
set echo off
set pagesize 500
set heading off
set recsep off
define cr='chr(10)'
set termout on
select 'Creating object grant script by user...' from dual;
rem set termout off
 
create table g_temp (seq NUMBER, grantor_owner varchar2(20),
                    text VARCHAR2(255))
/ 
DECLARE
   cursor grant_cursor is 
       SELECT ur$.name, uo$.name, o$.name, ue$.name,
              m$.name, t$.sequence#, 
              decode(NVL(t$.option$,0), 1, ' WITH GRANT OPTION;',';')
       FROM sys.objauth$ t$, sys.obj$ o$, sys.user$ ur$,
            sys.table_privilege_map m$, sys.user$ ue$, sys.user$ uo$
       WHERE o$.obj# = t$.obj# AND t$.privilege# = m$.privilege AND
             t$.col# IS NULL AND t$.grantor# = ur$.user# AND
             t$.grantee# = ue$.user# and 
             o$.owner#=uo$.user# and 
             t$.grantor# != 0
       order by sequence#;
   lv_grantor    sys.user$.name%TYPE;
   lv_owner      sys.user$.name%TYPE;
   lv_table_name sys.obj$.name%TYPE;
   lv_grantee    sys.user$.name%TYPE;
   lv_privilege  sys.table_privilege_map.name%TYPE;
   lv_sequence   sys.objauth$.sequence#%TYPE;
   lv_option     VARCHAR2(30);
   lv_string     VARCHAR2(255);
   lv_first      BOOLEAN;
 
   procedure write_out(p_seq INTEGER, p_owner VARCHAR2, p_string VARCHAR2) is
   begin
      insert into g_temp (seq, grantor_owner,text)
             values (lv_sequence, lv_grantor, lv_string);
   end;
 
BEGIN
  OPEN grant_cursor;
    LOOP
      FETCH grant_cursor INTO lv_grantor,lv_owner,lv_table_name,lv_grantee,
         lv_privilege,lv_sequence,lv_option;
      EXIT WHEN grant_cursor%NOTFOUND;
      lv_string := 'GRANT ' ||lv_privilege||' ON '||lower(lv_owner)||'.'||
                   lower(lv_table_name) ||&&cr||
		   ' TO ' ||lower(lv_grantee) ||&&cr||
                   lv_option;
      write_out(lv_sequence, lv_grantor,lv_string);
    END LOOP;
  CLOSE grant_cursor;
END;
/
@title80 ''
ttitle off 
spool rep_out\&db\grt_o_gr.sql
break on guser skip 1
col text format a60 word_wrap
 
select   'connect ' || grantor_owner || '/' guser, text
from     g_temp
order by seq, grantor_owner
/
 
spool off
 set verify on
set feedback on
set termout on
set echo on
set pagesize 22
set heading on
set recsep on
clear columns
clear computes
clear breaks
drop table g_temp;
