set feed off
set wrap off
set lines 130
set pages 100
alter session set nls_date_format='dd/mm/yyyy-hh24:mi:ss';
PROMPT =============================================================================================================
col kinstance_name for a12  heading 'Instancia'
col khostname      for a20  heading 'Servidor'
col kstatus                 heading 'Estado'
col ksessions      for 9999 heading 'Sessoes'
col start_time     for a20  heading 'Start_Time'
col today          for a20  heading 'Today'
col days_running   for 9999 heading 'Days_Running'
col sql_text     for A100  heading Sql     word wrap
col child_number for 99999 heading Child#

select decode(i.instance_name, null, '   ', '>> ') ||
       c.instance_name kinstance_name,
       c.host_name khostname,
       c.status kstatus,
       l.sessions_current ksessions,
       i.startup_time start_time,
       sysdate today,
       trunc(sysdate - i.startup_time) days_running
from gv$instance c,
     gv$license l,
     gv$instance i
where c.instance_number = i.instance_number (+)
  and c.thread# = i.thread# (+)
  and l.inst_id = c.inst_id;
PROMPT 
PROMPT =============================================================================================================
set feed on
set lines 150
SET SERVEROUTPUT ON
set echo off

DECLARE
    csid1       gv$session.sid%type;
    cusr1       gv$session.username%type;
    cmac1       gv$session.machine%type;
    cprg1       gv$session.program%type;
    csid2       gv$session.sid%type;
    cusr2       gv$session.username%type;
    cmac2       gv$session.machine%type;
    cprg2       gv$session.program%type;
    contador    number;
    c2sid       gv$session.sid%type;
    c2serial    gv$session.serial#%type;
    c2username  gv$session.username%type;
    c2osuser    gv$session.osuser%type;
    c2machine   gv$session.machine%type;
    c2program   gv$session.program%type;
    c2instance  gv$instance.instance_name%type;
    c2host      gv$instance.host_name%type;
    c2spid      gv$process.spid%type;
    c2hash      gv$session.sql_hash_value%type;
    c2status    gv$session.status%type;
    c2logon     gv$session.logon_time%type;
    c3child     v$sql.child_number%type;
    c3text      v$sqltext.sql_text%type;
    
    CURSOR c1
    IS 
    select /*+ rule */ s1.sid ,s1.username,s1.machine, s1.program, s2.sid,s2.username,s2.machine, s2.program  
    from gv$lock l1, gv$session s1, gv$lock l2, gv$session s2 
    where s1.sid=l1.sid 
    and s2.sid=l2.sid 
    and l1.BLOCK=1 
    and l2.request > 0 
    and l1.id1 = l2.id1 
    and l2.id2 = l2.id2;

    CURSOR c2
    IS
    select s.sid, s.serial#, s.username, s.osuser, s.machine, s.program, i.instance_name, i.host_name, p.spid, s.sql_hash_value, s.status,s.logon_time
    from gv$session s, gv$process p, gv$instance i
    where s.sid = csid1
    and s.paddr = p.addr
    and p.inst_id = i.inst_id;

    CURSOR c3
    IS
    select s.child_number, t.sql_text
    from gv$sqltext t, gv$sql s
    where s.hash_value = c2hash
    and s.address = t.address
    and s.hash_value = t.hash_value
    order by s.child_number, t.piece;

BEGIN
	open c1;
	contador := 0;
	LOOP
	fetch c1 into csid1,cusr1,cmac1,cprg1,csid2,cusr2,cmac2,cprg2;
	if c1%found then
		contador := contador + 1;
		DBMS_OUTPUT.PUT_LINE('A SESSAO SID='||csid1||' USER='||cusr1||'@'||substr(cprg1,1,7)||'@'||cmac1||' esta bloqueando o SID='||csid2||' USER='||cusr2||'@'||substr(cprg2,1,7)||'@'||cmac2);	
       end if;

	if contador = 0 then
		DBMS_OUTPUT.PUT_LINE('NAO HA SESSOES EM LOCK!!!');
	end if;

        EXIT WHEN c1%NOTFOUND;
        END LOOP;

	if contador <> 0 then
        open c2;
        open c3;
        fetch c2 into c2sid, c2serial, c2username, c2osuser, c2machine, c2program, c2instance, c2host, c2spid, c2hash, c2status, c2logon;
        fetch c3 into c3child, c3text ;

            DBMS_OUTPUT.PUT_LINE ('=============================================================================================================');
            dbms_output.put_line('Sid..............: ' || c2sid);
            dbms_output.put_line('Serial#..........: ' || c2serial);
            dbms_output.put_line('Status...........: ' || c2status);
            dbms_output.put_line('Username.........: ' || c2username);
            dbms_output.put_line('Maquina..........: ' || c2machine);
            dbms_output.put_line('Programa.........: ' || c2program);
            dbms_output.put_line('OS User..........: ' || c2osuser);
            dbms_output.put_line('Host.............: ' || c2host);
            dbms_output.put_line('Instance.........: ' || c2instance);
            dbms_output.put_line('SQL Hash Value...: ' || c2hash);
            dbms_output.put_line('PID..............: ' || c2spid);
            dbms_output.put_line('Logon Time ......: ' || c2logon);
            dbms_output.put_line('Child Number.....: ' || c3child);
            dbms_output.put_line('Query ...........: ' || c3text);
            DBMS_OUTPUT.PUT_LINE ('=======================================================');
            DBMS_OUTPUT.PUT_LINE ('=DIRECIONAR O CHAMADO AO CLIENTE COM ESTAS INFORMACOES=');
            DBMS_OUTPUT.PUT_LINE ('=======================================================');
        close c2;
        close c3;
	end if;
	close c1;

END;
/