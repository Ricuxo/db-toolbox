set serveroutput on;

declare
        object_mem number;
        shared_sql number;
        cursor_mem number;
        mts_mem number;
        used_pool_size number;
        free_mem number;
        pool_size varchar2(512); -- mesmo com V$PARAMETER.VALUE
begin

-- Objetos Armazenados (packages, views)
select sum(sharable_mem) into object_mem from v$db_object_cache;
-- Uso de cursores pelos Usuários -- executar este durante pico de uso.
-- assume 250 bytes por cursores abertos, para cada usuário concorrente.
select sum(250*users_opening) into cursor_mem from v$sqlarea;

-- Para um teste no sistema - pega o uso de um usuário, multiplica-o pelos # usuários
-- select (250 * value) bytes_per_user
-- from v$sesstat s, v$statname n
-- where s.statistic# = n.statistic#
-- and n.name = 'opened cursors current'
-- and s.sid = 25; -- aonde 25 é o SID do processo.

-- MTS (Multithreaded Shared Servers) memória necessita manter a informação das sessões para compartilhar com os usuários do servidor.
-- Este comando computa um total para todos os usuário conectados correntemente. (executar
-- durante um período de pico). Alternativamente calcular para um único usuário e
-- multiplica-o pelos # usuários.
select sum(value) into mts_mem from v$sesstat s, v$statname n
       where s.statistic#=n.statistic#
       and n.name='session uga memory max';

-- Livre (Não usado) memória na SGA: dá uma indicação da quantidade de memória
-- que está sendo desperdiçada do total alocada.
select bytes into free_mem from v$sgastat
        where name = 'free memory' and pool='shared pool';
-- Para não MTS adicionar objetos, shared sql, cursores e 30% acima.
used_pool_size := round(1.3*(object_mem+cursor_mem));

-- Para MTS mts precisa contribuir para ser incluído (commentado nas linhas anteriores)
-- used_pool_size := round(1.3*(object_mem+shared_sql+cursor_mem+mts_mem));

select value into pool_size from v$parameter where name='shared_pool_size';

-- Mostrando os Resultados
dbms_output.put_line ('Object mem:    '||to_char (object_mem) || ' bytes');
dbms_output.put_line ('Cursors:       '||to_char (cursor_mem) || ' bytes');
-- dbms_output.put_line ('MTS session:   '||to_char (mts_mem) || ' bytes');
dbms_output.put_line ('Free memory:   '||to_char (free_mem) || ' bytes ' ||
'('|| to_char(round(free_mem/1024/1024,2)) || 'MB)');
dbms_output.put_line ('Shared pool utilization (total):  '||
to_char(used_pool_size) || ' bytes ' || '(' ||
to_char(round(used_pool_size/1024/1024,2)) || 'MB)');
dbms_output.put_line ('Shared pool allocation (actual):  '|| pool_size
||' bytes ' || '(' || to_char(round(pool_size/1024/1024,2)) || 'MB)');
dbms_output.put_line ('Percentage Utilized:  '||to_char
(round(used_pool_size/pool_size*100)) || '%');
end;
/
