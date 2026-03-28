/*  */
rem
rem  Name:     pid1.sql
rem
rem  FUNCTION: Generate a list of current oracle sids/pids
rem
column username format a15 heading 'User Name'
column program format a15 heading 'Executing|Program'
column pid format 9999
column sid format 9999
column osuser heading Operating|system|User
set lines 130
break on username 
compute count of pid on username
set pages 58
ttitle "Oracle Processes"
spool cur_proc
select 
	NVL(a.username,'Null') username,
	b.pid,
	a.sid,
	decode(a.terminal,'?','Detached',a.terminal) terminal,
	b.program,
	hextointeger(b.spid) spid,
	a.osuser,
	a.serial#
 from 
	v$session a, 
	v$process b
where 
	a.PADDR = b.ADDR
order by 
	a.username,
	b.pid
/
spool off
clear breaks
clear columns
set pages 22
ttitle off
pause Press enter to continue
