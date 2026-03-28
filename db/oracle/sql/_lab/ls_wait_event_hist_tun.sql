/***************************************
* dba_hist_active_sess_history table
* "recent" system activity from Oracle Active Session History (ASH) tables
* Oracle keeps session history in the circular memory buffer in the SGA
****************************************/

@ls_awr_snap_day

SET VERIFY OFF
SET LINES 2000 PAGES 60


PROMPT ### historico de waits por snapshot - uso: @ls_awr_snap_day -> @ls_act_sess_hist_wait
PROMPT ### view: dba_hist_active_sess_history
PROMPT ################################################################

ACCEPT SNAP_BEGIN PROMPT 'Digite SNAP BEGIN: '
ACCEPT SNAP_END PROMPT 'Digite SNAP END: '


select event, count(*) from dba_hist_active_sess_history
where snap_id between &SNAP_BEGIN and &SNAP_END and event is not null and wait_class<>'Idle'
group by event order by 2 desc
/


PROMPT ### sql_id dos que agrediram(AGRESSORES) neste snapshot
PROMPT ### view: dba_hist_active_sess_history, dba_hist_sqltext
PROMPT ################################################################

ACCEPT EVENT_NAME PROMPT 'Digite EVENT NAME: '


col sql_id for a15
col sql_text_VITIMA for a150
col SID_SRL#_BLOCK for a14
col SID_SRL# for a9

select  distinct
ash.BLOCKING_INST_ID INST_BLOCK,
(ash.BLOCKING_SESSION  ||'.' || ash.BLOCKING_SESSION_SERIAL#) SID_SRL#_BLOCK,
c.sql_id ID,
c.TIME_WAITED,
ash.INSTANCE_NUMBER INST,
(ash.SESSION_ID ||'.' || ash.SESSION_SERIAL#) SID_SRL#,
ash.SESSION_TYPE SESS_TYPE,
ash.SQL_ID,
ash.SQL_CHILD_NUMBER,
ash.SQL_PLAN_HASH_VALUE SQL_PLAN_HASH,
ash.event,
dbms_lob.substr(b.sql_text,200,1) sql_text_VITIMA
from dba_hist_active_sess_history ash , dba_hist_sqltext b, dba_hist_active_sess_history c
where ash.snap_id BETWEEN '&SNAP_BEGIN' AND '&SNAP_END'
and ash.blocking_session = c.session_id
and ash.blocking_session_serial# = c.session_serial#
and ash.sql_id= b.sql_id
and ash.event like  '%&EVENT_NAME%'
ORDER BY c.TIME_WAITED
/

SET VERIFY ON
