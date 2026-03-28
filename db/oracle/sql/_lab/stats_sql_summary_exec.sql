DECLARE
v_hash number;
v_execs number;
v_disk number;
v_gets number;
v_rows number;
v_cpu number;
v_ela number;
v_execs_ant number;
v_disk_ant number;
v_gets_ant number;
v_rows_ant number;
v_cpu_ant number;
v_ela_ant number;
v_snaptime_ant date;
v_qtd_execs number;
v_qtd_disk number;
v_qtd_gets number;
v_qtd_rows number;
v_qtd_cpu  number;
v_qtd_ela  number;
v_qtd_snaptime number;
v_qtd_execs_min number;

v_cntlp number(10);
CURSOR C1 IS
select SNAP_ID,DBID,INSTANCE_NUMBER,SNAP_TIME,STARTUP_TIME
from perfstat.STATS$SNAPSHOT
where trunc(SNAP_TIME) > = trunc(sysdate - &1)
order by SNAP_ID;

Begin
v_hash := &2;
v_cntlp:=1;
for lp1 in c1
loop
   Begin
   if v_cntlp = 1
   then
      select EXECUTIONS,DISK_READS,BUFFER_GETS,ROWS_PROCESSED,CPU_TIME,ELAPSED_TIME
      into v_execs,v_disk,v_gets,v_rows,v_cpu,v_ela
      from perfstat.STATS$SQL_SUMMARY
      where SNAP_ID=lp1.SNAP_ID
      and DBID=lp1.DBID
      and INSTANCE_NUMBER=lp1.INSTANCE_NUMBER
      and HASH_VALUE=v_hash;
      v_execs_ant := v_execs;
      v_disk_ant  := v_disk;
      v_gets_ant  := v_gets;
      v_rows_ant  := v_rows;
      v_cpu_ant   := v_cpu;
      v_ela_ant   := v_ela;
      v_cntlp := v_cntlp + 1;
      v_snaptime_ant := lp1.SNAP_TIME;
   else
      select EXECUTIONS,DISK_READS,BUFFER_GETS,ROWS_PROCESSED,CPU_TIME,ELAPSED_TIME
      into v_execs,v_disk,v_gets,v_rows,v_cpu,v_ela
      from perfstat.STATS$SQL_SUMMARY
      where SNAP_ID=lp1.SNAP_ID
      and DBID=lp1.DBID
      and INSTANCE_NUMBER=lp1.INSTANCE_NUMBER
      and HASH_VALUE=v_hash;
      v_qtd_execs := v_execs - v_execs_ant;
      v_qtd_disk := v_disk - v_disk_ant;
      v_qtd_gets := v_gets - v_gets_ant;
      v_qtd_rows := v_rows - v_rows_ant;
      v_qtd_cpu  := v_cpu - v_cpu_ant;
      v_qtd_ela  := v_ela - v_ela_ant;
      v_qtd_snaptime := round((lp1.SNAP_TIME - v_snaptime_ant)*1440);
      v_qtd_execs_min := round(v_qtd_execs/v_qtd_snaptime);
      v_execs_ant := v_execs;
      v_disk_ant  := v_disk;
      v_gets_ant  := v_gets;
      v_rows_ant  := v_rows;
      v_cpu_ant   := v_cpu;
      v_ela_ant   := v_ela;
      v_cntlp := v_cntlp + 1;
      v_snaptime_ant := lp1.SNAP_TIME;
--      dbms_output.put_line(v_hash||'-'||lp1.SNAP_ID||'-'||to_char(lp1.SNAP_TIME,'DD/MM/YY-HH24:MI:SS')||'-'||v_qtd_snaptime||'-'||v_qtd_execs||'-'||v_qtd_gets||'-'||v_qtd_disk);
      dbms_output.put_line(to_char(lp1.SNAP_TIME,'DD/MM/YY-HH24:MI:SS')||' '||v_qtd_execs_min||' '||v_qtd_snaptime||' '||v_qtd_execs);
   end if;
   exception
   when no_data_found then
    dbms_output.put_line(v_hash||'-'||lp1.SNAP_ID||'-'||to_char(lp1.SNAP_TIME,'DD/MM/YY-HH24:MI:SS'));
    v_cntlp:=1;
   End;
end loop;
End;
/

