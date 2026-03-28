/*  */
rem
rem  Name:     pid.sql
rem
rem  FUNCTION: Generate a list of current oracle sids/pids
rem
column username format a12 heading 'User Name'
column program format a15 heading 'Executing|Program'
column pid format 9999
column sid format 9999
column osuser heading Operating|system|User
column terminal format a10
column g_date new_value f_date noprint
select to_char(sysdate,'ddmmyyyyhh24mi') g_date from dual; 
set lines 130
break on username 
compute count of pid on username
set pages 58
start title132 "Oracle Processes"
spool rep_out\&db\cur_proc_&&f_date
select 
	NVL(a.username,'Null') username,
	b.pid,
	a.sid,
	decode(a.terminal,'?','Detached',a.terminal) terminal,
	b.program,
	c.value commits, 
        spid,
	a.osuser,
	a.serial#
 from 
	v$session a, 
	v$process b,
        v$sesstat c,
        v$statname d
where 
	a.PADDR = b.ADDR
    and b.pid=c.sid
    and c.statistic#=d.statistic#
    and d.name like '%commits'
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
