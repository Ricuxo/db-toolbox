def DATINI="2023-08-01:17:25:00"
def DATFIN="2023-08-01:17:28:00"
 
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
 
clear breaks
col sidqueue for a20 head "SID|QUEUE"
col COMPLETE_SESSION_ID for a14 head "SESSION_ID"
col USERNAME for a15 wrap
col MODULE for a15 wrap
col EVENT for a20 wrap
col OBJ for a30 wrap
col MINUTOS for 999.9
break on sample_time skip page on level
set pages 1000
 
with ash as (
    select a.*,
        O.OWNER || '.' || O.OBJECT_NAME as obj,
        u.username, 
        case when blocking_session is NULL then 'N' else 'Y' end IS_WAITING,
        case
            when
            instr(
                listagg(DISTINCT '.'||blocking_session||'.') 
                    WITHIN GROUP (order by blocking_session) 
                    OVER (partition by sample_id) ,
                '.'||session_id||'.'
                ) = 0 
            then 'N'
            else 'Y'
            end as IS_HOLDING,
        case
            when blocking_session is NULL then NULL
            when instr(
                listagg(DISTINCT '.'||session_id||'.') 
                    WITHIN GROUP (order by session_id) 
                    OVER (partition by sample_id) ,
                '.'||blocking_session||'.'
                ) = 0 
            then 'N'
            else 'Y'
            end as IS_BLOCKING_SID_ACTIVE
    from dba_hist_active_sess_history a
    left join dba_objects o on o.object_id = a.CURRENT_OBJ#
    left join dba_users u on u.user_id = a.user_id
    where SAMPLE_TIME between &datini and &datfin
),
ash_with_inactive as (
-- I need to include the inactive blocking sessions because ASH does not record INACTIVE
    select
        sample_id, cast(sample_time as date) as sample_time, 
        session_id, session_serial#, instance_number,
        blocking_session, blocking_session_serial#, blocking_inst_id,
        sql_id, sql_exec_start, sql_exec_id, TOP_LEVEL_SQL_ID, XID, 
        username, module, nvl(event,'On CPU') event, 
        sysdate + ( (sample_time - min(sample_time) over (partition by session_id, session_serial#, instance_number, event_id, SEQ#)) * 86400) - sysdate as swait,
        obj, 
        IS_WAITING, IS_HOLDING, 'Y' IS_ACTIVE, IS_BLOCKING_SID_ACTIVE
    from ash
    UNION ALL
    select DISTINCT
        sample_id, cast(sample_time as date) as sample_time, 
        blocking_session as session_id, blocking_session_serial# as session_serial#, blocking_inst_id as instance_number,
        NULL as blocking_session, NULL as blocking_session_serial#, NULL as blocking_instance,
        NULL as sql_id, NULL as sql_exec_start, NULL as sql_exec_id, NULL as TOP_LEVEL_SQL_ID, NULL as XID, 
        NULL as username, NULL as module, '**INACTIVE**' as event, NULL as swait, NULL as obj, 
        'N' as IS_WAITING, 'Y' as IS_HOLDING, 'N' IS_ACTIVE, null as IS_BLOCKING_SID_ACTIVE
    from ash a1
    where IS_BLOCKING_SID_ACTIVE = 'N' 
),
locks as (
    select b.*,
        listagg(DISTINCT '.'||event||'.') within group (order by lock_level) over (partition by sample_id, top_level_sid) event_chain,
        listagg(DISTINCT '.'||username||'.') within group (order by lock_level) over (partition by sample_id, top_level_sid) user_chain,
        listagg(DISTINCT '.'||module||'.') within group (order by lock_level) over (partition by sample_id, top_level_sid) module_chain,
        listagg(DISTINCT '.'||obj||'.') within group (order by lock_level) over (partition by sample_id, top_level_sid) obj_chain,
        listagg(DISTINCT '.'||xid||'.') within group (order by lock_level) over (partition by sample_id, top_level_sid) xid_chain,
        listagg(DISTINCT '.'||session_id||'.') within group (order by lock_level) over (partition by sample_id, top_level_sid) sid_chain,
        listagg(DISTINCT '.'||sql_id||'.') within group (order by lock_level) over (partition by sample_id, top_level_sid) sql_id_chain
    from (
        select a.*,
            rownum rn, level lock_level,
            case when level > 2 then lpad(' ',2*(level-2),' ') end || 
                case when level > 1 then '+-' end || session_id as sidqueue,
            session_id || ',' || session_serial# || '@' || instance_number COMPLETE_SESSION_ID,
            CONNECT_BY_ROOT session_id as top_level_sid
        from ash_with_inactive a
        connect by
            prior sample_id = sample_id
            and prior session_id = blocking_session 
            and prior instance_number = blocking_inst_id 
            and prior session_serial# = blocking_session_serial# 
        start with
            IS_HOLDING = 'Y' and IS_WAITING = 'N'
        order SIBLINGS by sample_time, swait desc
    ) b
)
select
--     sample_id, 
    sample_time, lock_level, sidqueue, COMPLETE_SESSION_ID, 
    username, module, xid,
    event, swait, OBJ,
    sql_id, sql_exec_start, sql_exec_id, top_level_sql_id
from locks
where 1=1
--and event_chain like '%TM%contention%'
--and user_chain like '%PROD_BATCH%'
--and module_chain like '%PB%'
--and obj_chain like '%PGM%'
--and xid_chain like '%1300%'
--and sid_chain like '%7799%'
--and sql_id_chain like '%fmxzsf8gxn0ym%'
order by rn
/