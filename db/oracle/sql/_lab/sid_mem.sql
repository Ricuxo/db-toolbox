set pages 1000 lines 120
column sid format  999999999
column spid format 999999999
prompt #
prompt # Sessoes que estao consumindo memoria (PGA)
prompt #
select b.sid, b.value
      from v$sesstat b
      where  b.statistic# =  21
      and b.value > 1373741824;


select vs.inst_id, vs.sid sid,
       vs.serial# serial#,
       p.spid spid,
       VS.STATUS,
       vs.process process,
       vs.SQL_HASH_VALUE,
       vs.osuser OSUSER,
       vs.username,
       vs.machine,
       vs.program,
       w.seconds_in_wait, w.event, 
       SUBSTR(to_char(VS.LOGON_TIME, 'DD-MM-YY HH24:MI:SS'),1,17) DT_HR_INICIAL,
       vs.LAST_CALL_ET,
       vs.LOCKWAIT,
       substr((vs.row_wait_obj#),1,30) obj#,
       substr((vs.row_wait_file#),1,30) file#,
       substr((vs.row_wait_block#),1,30) block#,
       substr((vs.row_wait_row#),1,30) row#,
       SUBSTR(to_char(sysdate, 'DD-MM-YY HH24:MI:SS'),1,17) DT_HR_ATUAL
  from Gv$session vs, Gv$process p, Gv$session_wait w,  v$sesstat b
 where p.addr = vs.paddr
   and vs.sid = w.sid
   and vs.sid = b.sid
   and b.statistic# =  21
   and b.value > 1373741824
/
