set serveroutput on size 1000000
declare
 
 cursor c1 is
    select * from v$lock where request != 0
      order by id1, id2;
  wid1            number := -999999;
  wid2            number := -999999;
  wholder_detail  varchar2(200);
  v_err_msg          varchar2(80);
  wsid            number(5);
  wstep           number(2);
  wtype           varchar2(10);
  wobject_name    varchar2(180);
  wobject_name1   varchar2(80);
  wlock_type      varchar2(50);
  w_lastcallet 	varchar2(11);
  h_lastcallet	varchar2(11);
begin
  for c1_rec in c1 loop
    if c1_rec.id1 = wid1 and c1_rec.id2 = wid2 then
       null;
    else
       wstep  := 10;
       select sid , type into wsid , wtype
         from v$lock
         where id1  = c1_rec.id1
           and id2  = c1_rec.id2
           and request = 0
           and lmode != 4;
      dbms_output.put_line('  ');
       wstep  := 20;
      select 'Holder DBU: '||s.username ||' OSU: '||s.osuser ||' DBP:'||p.spid||' APP: '|| s.process ||
		' SID:' || s.sid || ' Status: ' || s.status  ||
		' (' ||    	floor(last_call_et/3600)||':'||
   				floor(mod(last_call_et,3600)/60)||':'||
   				mod(mod(last_call_et,3600),60) || 
		') Module:'|| module ||
              ' AppSrvr: ' || substr(replace(machine,'LOCALHOST',null),1,15)
          into wholder_detail
          from v$session s, v$process p
          where s.sid= wsid
            and s.paddr = p.addr;
      dbms_output.put_line(wholder_detail);

      begin
	select decode(wtype,'TX', 'Transaction',
                            'DL', 'DDL Lock',
                            'MR', 'Media Recovery',
                            'RT', 'Redo Thread',
                            'UN', 'User Name',
                            'TX', 'Transaction',
                            'TM', 'DML',
                            'UL', 'PL/SQL User Lock',
                            'DX', 'Distributed Xaction',
                            'CF', 'Control File',
                            'IS', 'Instance State',
                            'FS', 'File Set',
                            'IR', 'Instance Recovery',
                            'ST', 'Disk Space Transaction',
                            'TS', 'Temp Segment',
                            'IV', 'Library Cache Invalida-tion',
                            'LS', 'Log Start or Switch',
                            'RW', 'Row Wait',
                            'SQ', 'Sequence Number',
                            'TE', 'Extend Table',
                            'TT', 'Temp Table',
                            'Un-Known Type of Lock')
		into wlock_type
		from dual;
        declare
          cursor c3 is
            select object_id from v$locked_object
              where session_id = wsid;
        begin
          wobject_name := '';
          for c3_rec in c3 loop
            select object_type||': '||owner||'.'||object_name 
              into wobject_name
              from dba_objects 
              where object_id = c3_rec.object_id;
            wobject_name := wobject_name ||' '||wobject_name1;
          end loop;
        exception
          when others then
            wobject_name := wobject_name ||' No Object Found';
        end;
        dbms_output.put_line('Lock Held: '||wlock_type||' for Object :'||wobject_name);
      exception
        when no_data_found then
          dbms_output.put_line('Lock Held: '||wlock_type||' No object found in DBA Objects');
      end;
    end if;
       wstep  := 30;
    select '....   Requestor DBU: '||s.username ||' OSU: '||s.osuser ||' DBP:'||p.spid||' APP: '|| s.process ||
                ' SID:' || s.sid || ' Status: ' || s.status  ||
                ' (' ||         floor(last_call_et/3600)||':'||
                                floor(mod(last_call_et,3600)/60)||':'||
                                mod(mod(last_call_et,3600),60) ||
                ') Module:'|| module ||
              ' AppSrvr: ' || substr(replace(machine,'LOCALHOST\',null),1,15) 
          into wholder_detail
          from v$session s, v$process p
          where s.sid= c1_rec.sid
            and s.paddr = p.addr;
    dbms_output.put_line(wholder_detail);
    wid1  := c1_rec.id1;
    wid2  := c1_rec.id2;
  end loop;
  if wid1 = -999999 then
       wstep  := 40;
    dbms_output.put_line('No one requesting locks held by others');
  end if;
exception
  when others then
         v_err_msg := (sqlerrm ||'  '|| sqlcode||' step='||to_char(wstep));
    DBMS_OUTPUT.PUT_LINE(v_err_msg);
end;
/
 
  
