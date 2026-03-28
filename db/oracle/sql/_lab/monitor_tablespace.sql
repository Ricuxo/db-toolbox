set serveroutput on size 1000000
declare
cursor c1 is select a.tablespace_name, tot_alocado, tot_livre, trunc((1-(tot_livre/tot_alocado))*100) per_ocupado
               from (select sum(bytes) tot_alocado, tablespace_name
                       from dba_data_files
                      group by tablespace_name) a,
                    (select sum(bytes) tot_livre, tablespace_name
                       from dba_free_space
                      group by tablespace_name) b
              where a.tablespace_name=b.tablespace_name(+)
              order by a.tablespace_name, tot_livre ;
v_estouro     varchar2(10);
begin
dbms_output.put_line('tablespace                   alocado                livre  ocup     threshold  est');
dbms_output.put_line('---------------  -------------------    ----------------- ----- -------------  ---');
for r1 in c1 loop
    v_estouro := null;
    if    r1.tot_livre is null or r1.tot_livre < 100000 then
          v_estouro:=' ***';              
          dbms_output.put_line(rpad(r1.tablespace_name,15,' ')||' '||
                               to_char(r1.tot_alocado,'999g999g999g999g999')||' '||
                               '   *** SEM espaco  LIVRE   ***');
    elsif r1.tot_alocado > 42949672960 then
          if  r1.per_ocupado >= 98 then
              if     r1.per_ocupado = 98 then
                     v_estouro:=' *';
              else
                     v_estouro:=' ***';              
              end if;
          end if;
          dbms_output.put_line(rpad(r1.tablespace_name,15,' ')||' '||
                               to_char(r1.tot_alocado,'999g999g999g999g999')||' '||
                               to_char(r1.tot_livre,'999g999g999g999g999')||' '||
                               to_char(r1.per_ocupado,'999')||'% '||
                               'threshold=98%'||' '||v_estouro);
    elsif r1.tot_alocado > 21474836480 then
          if  r1.per_ocupado >= 97 then
              if     r1.per_ocupado = 97 then
                     v_estouro:=' *';
              elsif  r1.per_ocupado >= 98 then
                     v_estouro:=' ***';
              else
                     v_estouro:=' **';              
              end if;
          end if;
          dbms_output.put_line(rpad(r1.tablespace_name,15,' ')||' '||
                               to_char(r1.tot_alocado,'999g999g999g999g999')||' '||
                               to_char(r1.tot_livre,'999g999g999g999g999')||' '||
                               to_char(r1.per_ocupado,'999')||'% '||
                               'threshold=97%'||' '||v_estouro);
    elsif r1.tot_alocado > 10737418240 then
          if  r1.per_ocupado >= 96 then
              if     r1.per_ocupado = 96 then
                     v_estouro:=' *';
              elsif  r1.per_ocupado >= 98 then
                     v_estouro:=' ***';
              else
                     v_estouro:=' **';              
              end if;
          end if;
          dbms_output.put_line(rpad(r1.tablespace_name,15,' ')||' '||
                               to_char(r1.tot_alocado,'999g999g999g999g999')||' '||
                               to_char(r1.tot_livre,'999g999g999g999g999')||' '||
                               to_char(r1.per_ocupado,'999')||'% '||
                               'threshold=96%'||' '||v_estouro);
    elsif r1.tot_alocado > 5368709120 then
          if  r1.per_ocupado >= 95 then
              if     r1.per_ocupado = 95 then
                     v_estouro:=' *';
              elsif  r1.per_ocupado >= 98 then
                     v_estouro:=' ***';
              else
                     v_estouro:=' **';              
              end if;
          end if;
          dbms_output.put_line(rpad(r1.tablespace_name,15,' ')||' '||
                               to_char(r1.tot_alocado,'999g999g999g999g999')||' '||
                               to_char(r1.tot_livre,'999g999g999g999g999')||' '||
                               to_char(r1.per_ocupado,'999')||'% '||
                               'threshold=95%'||' '||v_estouro);
    else
          if  r1.per_ocupado >= 90 then
              if     r1.per_ocupado = 90 then
                     v_estouro:=' *';
              elsif  r1.per_ocupado >= 98 then
                     v_estouro:=' ***';
              else
                     v_estouro:=' **';              
              end if;
          end if;
          dbms_output.put_line(rpad(r1.tablespace_name,15,' ')||' '||
                               to_char(r1.tot_alocado,'999g999g999g999g999')||' '||
                               to_char(r1.tot_livre,'999g999g999g999g999')||' '||
                               to_char(r1.per_ocupado,'999')||'% '||
                               'threshold=90%'||' '||v_estouro);
    end if;
end loop;

end;
/
