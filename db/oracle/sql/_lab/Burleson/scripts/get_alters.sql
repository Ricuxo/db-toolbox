/*  */
col username format a20
col sql_text format a60
col date_now new_value now noprint
set lines 132 pages 59 feedback off echo off
select to_char(sysdate,'ddmonyyyyhh24mi') date_now from dual;
@title132 'Users Issuing ALTER Commands'
spool rep_out\&&db\get_alters&&now
select username,sql_text from v$sqlarea, dba_users 
where (upper(sql_text) like '%ALTER MAT%' or
upper(sql_text) like '%ALTER SUM%') and
parsing_user_id=user_id and username !='MRAULT'
/
spool off
set lines 80 pages 24
ttitle off
